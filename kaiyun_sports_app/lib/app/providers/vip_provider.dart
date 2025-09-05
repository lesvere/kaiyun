import 'package:flutter/foundation.dart';
import '../data/models/vip_models.dart';
import '../data/services/vip_service.dart';

class VipProvider extends ChangeNotifier {
  final VipService _vipService = VipService();
  
  VipUserInfo? _vipUserInfo;
  List<VipBenefit> _benefits = [];
  List<VipReward> _rewards = [];
  List<VipPointsRecord> _pointsRecords = [];
  List<VipExchangeItem> _exchangeItems = [];
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  
  // 缓存控制
  DateTime? _lastRefreshTime;
  static const Duration _cacheExpiration = Duration(minutes: 5);

  // Getters
  VipUserInfo? get vipUserInfo => _vipUserInfo;
  List<VipBenefit> get benefits => List.unmodifiable(_benefits);
  List<VipReward> get rewards => List.unmodifiable(_rewards);
  List<VipPointsRecord> get pointsRecords => List.unmodifiable(_pointsRecords);
  List<VipExchangeItem> get exchangeItems => List.unmodifiable(_exchangeItems);
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;

  // 获取未领取的奖励
  List<VipReward> get unclaimedRewards => 
      _rewards.where((reward) => reward.canClaim).toList();

  // 获取可用的特权
  List<VipBenefit> get availableBenefits => 
      _benefits.where((benefit) => benefit.isAvailable).toList();

  // 获取当前用户可兑换的商品
  List<VipExchangeItem> get availableExchangeItems => 
      _exchangeItems.where((item) => 
          item.canExchange && 
          (_vipUserInfo?.totalPoints ?? 0) >= item.pointsCost).toList();
          
  // 判断是否需要刷新缓存
  bool get _needsRefresh {
    if (_lastRefreshTime == null) return true;
    return DateTime.now().difference(_lastRefreshTime!) > _cacheExpiration;
  }

  /// 加载VIP用户信息
  Future<void> loadVipUserInfo(String userId, {bool forceRefresh = false}) async {
    if (userId.isEmpty) {
      _setError('用户ID无效');
      return;
    }
    
    if (!forceRefresh && !_needsRefresh && _vipUserInfo?.userId == userId) {
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      _vipUserInfo = await _vipService.getVipUserInfo(userId);
      
      if (_vipUserInfo != null) {
        // 验证数据
        if (!_vipUserInfo!.validate()) {
          throw Exception('VIP用户信息数据格式错误');
        }
        
        // 同时加载相关数据
        await Future.wait([
          _loadBenefitsSafely(_vipUserInfo!.currentLevel),
          _loadRewardsSafely(userId),
          _loadPointsRecordsSafely(userId),
          _loadExchangeItemsSafely(_vipUserInfo!.currentLevel),
        ]);
        
        _lastRefreshTime = DateTime.now();
        _isInitialized = true;
      } else {
        _setError('无法获取VIP信息');
      }
    } catch (e) {
      _setError('加载VIP信息失败: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  /// 安全加载VIP特权
  Future<void> _loadBenefitsSafely(VipLevel userLevel) async {
    try {
      _benefits = await _vipService.getVipBenefits(userLevel);
      // 过滤无效数据
      _benefits = _benefits.where((benefit) => 
          benefit.id.isNotEmpty && benefit.name.isNotEmpty).toList();
    } catch (e) {
      debugPrint('加载VIP特权失败: $e');
      _benefits = [];
    }
  }
  
  /// 安全加载VIP奖励
  Future<void> _loadRewardsSafely(String userId) async {
    try {
      _rewards = await _vipService.getVipRewards(userId);
      // 过滤无效数据
      _rewards = _rewards.where((reward) => 
          reward.id.isNotEmpty && reward.name.isNotEmpty).toList();
    } catch (e) {
      debugPrint('加载VIP奖励失败: $e');
      _rewards = [];
    }
  }
  
  /// 安全加载积分记录
  Future<void> _loadPointsRecordsSafely(String userId) async {
    try {
      _pointsRecords = await _vipService.getPointsRecords(userId);
      // 过滤无效数据
      _pointsRecords = _pointsRecords.where((record) => 
          record.id.isNotEmpty && record.userId.isNotEmpty).toList();
    } catch (e) {
      debugPrint('加载积分记录失败: $e');
      _pointsRecords = [];
    }
  }
  
  /// 安全加载兑换商品
  Future<void> _loadExchangeItemsSafely(VipLevel userLevel) async {
    try {
      _exchangeItems = await _vipService.getExchangeItems(userLevel);
      // 过滤无效数据
      _exchangeItems = _exchangeItems.where((item) => 
          item.id.isNotEmpty && item.name.isNotEmpty).toList();
    } catch (e) {
      debugPrint('加载兑换商品失败: $e');
      _exchangeItems = [];
    }
  }

  /// 激活VIP特权
  Future<bool> activateBenefit(String benefitId, String userId) async {
    if (benefitId.isEmpty || userId.isEmpty) {
      _setError('参数无效');
      return false;
    }
    
    try {
      final success = await _vipService.activateBenefit(benefitId, userId);
      if (success && _vipUserInfo != null) {
        await _loadBenefitsSafely(_vipUserInfo!.currentLevel);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('激活特权失败: $e');
      return false;
    }
  }

  /// 领取奖励
  Future<bool> claimReward(String rewardId, String userId) async {
    if (rewardId.isEmpty || userId.isEmpty) {
      _setError('参数无效');
      return false;
    }
    
    try {
      final success = await _vipService.claimReward(rewardId);
      if (success) {
        await Future.wait([
          _loadRewardsSafely(userId),
          loadVipUserInfo(userId, forceRefresh: true), // 更新用户信息
        ]);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('领取奖励失败: $e');
      return false;
    }
  }

  /// 兑换商品
  Future<bool> exchangeItem(
    String userId,
    String itemId,
    double pointsCost,
  ) async {
    if (userId.isEmpty || itemId.isEmpty || pointsCost <= 0) {
      _setError('参数无效');
      return false;
    }
    
    // 检查积分是否足够
    if (_vipUserInfo == null || _vipUserInfo!.totalPoints < pointsCost) {
      _setError('积分不足');
      return false;
    }
    
    try {
      final success = await _vipService.exchangePoints(userId, itemId, pointsCost);
      if (success && _vipUserInfo != null) {
        await Future.wait([
          loadVipUserInfo(userId, forceRefresh: true), // 更新用户信息和积分
          _loadExchangeItemsSafely(_vipUserInfo!.currentLevel),
        ]);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('兑换失败: $e');
      return false;
    }
  }

  /// 添加积分
  Future<bool> addPoints(
    String userId,
    double points,
    PointsType type,
    String description,
    {String? referenceId}
  ) async {
    if (userId.isEmpty || points <= 0 || description.isEmpty) {
      _setError('参数无效');
      return false;
    }
    
    try {
      final success = await _vipService.addPoints(
        userId,
        points,
        type,
        description,
        referenceId: referenceId,
      );
      
      if (success) {
        await Future.wait([
          loadVipUserInfo(userId, forceRefresh: true),
          _loadPointsRecordsSafely(userId),
        ]);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('添加积分失败: $e');
      return false;
    }
  }

  /// 扣除积分
  Future<bool> deductPoints(
    String userId,
    double points,
    PointsType type,
    String description,
    {String? referenceId}
  ) async {
    if (userId.isEmpty || points <= 0 || description.isEmpty) {
      _setError('参数无效');
      return false;
    }
    
    // 检查积分是否足够
    if (_vipUserInfo == null || _vipUserInfo!.totalPoints < points) {
      _setError('积分不足');
      return false;
    }
    
    try {
      final success = await _vipService.deductPoints(
        userId,
        points,
        type,
        description,
        referenceId: referenceId,
      );
      
      if (success) {
        await Future.wait([
          loadVipUserInfo(userId, forceRefresh: true),
          _loadPointsRecordsSafely(userId),
        ]);
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('扣除积分失败: $e');
      return false;
    }
  }

  /// 检查VIP等级升级
  Future<VipLevel?> checkLevelUpgrade(String userId) async {
    if (userId.isEmpty) {
      _setError('用户ID无效');
      return null;
    }
    
    try {
      final newLevel = await _vipService.checkLevelUpgrade(userId);
      if (newLevel != null) {
        await loadVipUserInfo(userId, forceRefresh: true); // 重新加载用户信息
        notifyListeners();
      }
      return newLevel;
    } catch (e) {
      _setError('检查等级升级失败: $e');
      return null;
    }
  }

  /// 获取VIP统计信息
  Future<Map<String, dynamic>?> getVipStats() async {
    try {
      return await _vipService.getVipStats();
    } catch (e) {
      _setError('获取VIP统计信息失败: $e');
      return null;
    }
  }

  /// 计算投注积分
  double calculateBetPoints(double betAmount) {
    if (betAmount <= 0) return 0.0;
    return _vipService.calculateBetPoints(betAmount);
  }

  /// 计算充值积分
  double calculateDepositPoints(double depositAmount) {
    if (depositAmount <= 0) return 0.0;
    return _vipService.calculateDepositPoints(depositAmount);
  }
  
  /// 获取VIP用户统计信息
  Map<String, dynamic> getVipUserSummary() {
    if (_vipUserInfo == null) return {};
    
    return {
      'current_level': _vipUserInfo!.currentLevel.name,
      'total_points': _vipUserInfo!.totalPoints,
      'upgrade_progress': _vipUserInfo!.upgradeProgress,
      'can_upgrade': _vipUserInfo!.canUpgrade,
      'points_needed': _vipUserInfo!.pointsNeededForUpgrade,
      'available_benefits_count': _vipUserInfo!.availableBenefitsCount,
      'unclaimed_rewards_count': _vipUserInfo!.unclaimedRewardsCount,
      'total_bet_amount': _vipUserInfo!.totalBetAmount,
      'total_deposit_amount': _vipUserInfo!.totalDepositAmount,
      'days_active': _vipUserInfo!.daysActive,
      'is_lifetime_vip': _vipUserInfo!.isLifetimeVip,
      'vip_valid_days': _vipUserInfo!.vipValidDays,
    };
  }
  
  /// 获取积分使用统计
  Map<String, dynamic> getPointsUsageSummary() {
    if (_pointsRecords.isEmpty) return {};
    
    double totalEarned = 0.0;
    double totalSpent = 0.0;
    final typeDistribution = <String, double>{};
    
    for (final record in _pointsRecords) {
      if (record.isPositive) {
        totalEarned += record.points;
      } else {
        totalSpent += record.points.abs();
      }
      
      final typeName = record.type.displayName;
      typeDistribution[typeName] = (typeDistribution[typeName] ?? 0.0) + record.points;
    }
    
    return {
      'total_earned': totalEarned,
      'total_spent': totalSpent,
      'net_points': totalEarned - totalSpent,
      'type_distribution': typeDistribution,
      'records_count': _pointsRecords.length,
    };
  }

  /// 清除所有数据
  void clearAll() {
    _vipUserInfo = null;
    _benefits.clear();
    _rewards.clear();
    _pointsRecords.clear();
    _exchangeItems.clear();
    _isInitialized = false;
    _lastRefreshTime = null;
    _clearError();
    notifyListeners();
  }

  /// 刷新数据
  Future<void> refresh(String userId) async {
    if (userId.isEmpty) {
      _setError('用户ID无效');
      return;
    }
    
    clearAll();
    await loadVipUserInfo(userId, forceRefresh: true);
  }

  // 私有方法
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    debugPrint('VipProvider Error: $error');
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
    }
  }

  /// 格式化积分数量
  String formatPoints(double points) {
    if (points >= 10000) {
      return '${(points / 10000).toStringAsFixed(1)}万';
    }
    return points.toInt().toString();
  }

  /// 格式化时间
  String formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  /// 获取VIP等级颜色
  int getVipLevelColor(VipLevel level) {
    return level.color;
  }

  /// 获取VIP等级图标
  String getVipLevelIcon(VipLevel level) {
    return level.icon;
  }

  /// 是否可以升级
  bool canUpgrade() {
    return _vipUserInfo?.canUpgrade ?? false;
  }

  /// 获取升级进度
  double getUpgradeProgress() {
    return _vipUserInfo?.upgradeProgress ?? 0.0;
  }

  /// 获取升级所需积分
  double getPointsNeededForUpgrade() {
    return _vipUserInfo?.pointsNeededForUpgrade ?? 0.0;
  }
  
  @override
  void dispose() {
    clearAll();
    super.dispose();
  }
}
