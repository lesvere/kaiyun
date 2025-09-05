import 'dart:async';
import 'dart:math';
import '../models/referral_models.dart';
import '../api/api_service.dart';

/// 推荐奖励服务类
class ReferralService {
  final ApiService _apiService;
  
  ReferralService(this._apiService);
  
  /// 获取推荐统计
  Future<ReferralStatistics> getReferralStatistics() async {
    try {
      final response = await _apiService.get('/referral/statistics');
      return ReferralStatistics.fromJson(response.data);
    } catch (e) {
      // 模拟数据
      return ReferralStatistics(
        totalReferrals: 28,
        activeReferrals: 15,
        totalReward: 8950.0,
        monthReward: 1280.0,
        todayReward: 120.0,
        level1Count: 15,
        level2Count: 8,
        level3Count: 5,
        recentReferrals: _getMockReferralDetails(),
        rewardByType: {
          '注册奖励': 2800.0,
          '首存奖励': 3500.0,
          '投注分成': 2650.0,
        },
      );
    }
  }
  
  /// 获取推荐奖励记录
  Future<List<ReferralReward>> getReferralRewards({
    int page = 1,
    int pageSize = 20,
    RewardType? type,
    RewardStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiService.get('/referral/rewards', {
        'page': page,
        'page_size': pageSize,
        'type': type?.toString().split('.').last,
        'status': status?.toString().split('.').last,
        'start_date': startDate?.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
      });
      return (response.data['rewards'] as List)
          .map((json) => ReferralReward.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockReferralRewards();
    }
  }
  
  /// 获取推荐码
  Future<ReferralCode> getReferralCode(String userId) async {
    try {
      final response = await _apiService.get('/referral/code', {
        'user_id': userId,
      });
      return ReferralCode.fromJson(response.data);
    } catch (e) {
      // 返回模拟推荐码
      return ReferralCode(
        code: 'KY${userId.toUpperCase().substring(0, 6)}',
        userId: userId,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        usageCount: Random().nextInt(10),
      );
    }
  }
  
  /// 创建推荐码
  Future<ReferralCode> createReferralCode(String userId) async {
    try {
      final response = await _apiService.post('/referral/code/create', {
        'user_id': userId,
      });
      return ReferralCode.fromJson(response.data);
    } catch (e) {
      // 返回模拟新推荐码
      return ReferralCode(
        code: _generateReferralCode(),
        userId: userId,
        createdAt: DateTime.now(),
        usageCount: 0,
      );
    }
  }
  
  /// 使用推荐码
  Future<bool> useReferralCode(String code, String userId) async {
    try {
      final response = await _apiService.post('/referral/code/use', {
        'code': code,
        'user_id': userId,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      return true; // 模拟成功
    }
  }
  
  /// 获取推荐链接
  String getReferralLink(String referralCode) {
    return 'https://kaiyun-sports.com/register?ref=$referralCode';
  }
  
  /// 获取推荐详情列表
  Future<List<ReferralDetail>> getReferralDetails(
    String userId, {
    int level = 1,
  }) async {
    try {
      final response = await _apiService.get('/referral/details', {
        'user_id': userId,
        'level': level,
      });
      return (response.data['referrals'] as List)
          .map((json) => ReferralDetail.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockReferralDetails();
    }
  }
  
  /// 计算奖励金额
  double calculateRewardAmount(
    RewardType type,
    double amount, {
    int level = 1,
    int vipLevel = 0,
  }) {
    double baseRate = 0.0;
    
    switch (type) {
      case RewardType.register:
        baseRate = 50.0; // 固定奖励
        break;
      case RewardType.deposit:
        baseRate = 0.05; // 5%
        break;
      case RewardType.betting:
        baseRate = 0.008; // 0.8%
        break;
      case RewardType.activity:
        baseRate = 100.0; // 固定奖励
        break;
    }
    
    // 根据层级调整奖励
    double levelMultiplier = 1.0;
    switch (level) {
      case 1:
        levelMultiplier = 1.0;
        break;
      case 2:
        levelMultiplier = 0.5;
        break;
      case 3:
        levelMultiplier = 0.2;
        break;
      default:
        levelMultiplier = 0.0;
    }
    
    // VIP等级加成
    double vipBonus = 1.0 + (vipLevel * 0.1);
    
    if (type == RewardType.register || type == RewardType.activity) {
      return baseRate * levelMultiplier * vipBonus;
    } else {
      return amount * baseRate * levelMultiplier * vipBonus;
    }
  }
  
  /// 生成推荐码
  String _generateReferralCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return 'KY${List.generate(6, (index) => chars[random.nextInt(chars.length)]).join()}';
  }
  
  List<ReferralReward> _getMockReferralRewards() {
    return [
      ReferralReward(
        id: 'RW001',
        referrerId: 'U001',
        refereeId: 'U010',
        refereeUsername: 'user_10',
        amount: 120.0,
        type: RewardType.betting,
        status: RewardStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        processedAt: DateTime.now().subtract(const Duration(hours: 1)),
        level: 1,
        description: '一级推荐投注分成',
      ),
      ReferralReward(
        id: 'RW002',
        referrerId: 'U001',
        refereeId: 'U011',
        refereeUsername: 'user_11',
        amount: 50.0,
        type: RewardType.register,
        status: RewardStatus.approved,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        processedAt: DateTime.now().subtract(const Duration(days: 1)),
        level: 1,
        description: '新用户注册奖励',
      ),
      ReferralReward(
        id: 'RW003',
        referrerId: 'U001',
        refereeId: 'U012',
        refereeUsername: 'user_12',
        amount: 250.0,
        type: RewardType.deposit,
        status: RewardStatus.pending,
        createdAt: DateTime.now(),
        level: 1,
        description: '首次充值奖励',
      ),
    ];
  }
  
  List<ReferralDetail> _getMockReferralDetails() {
    return [
      ReferralDetail(
        id: 'U010',
        username: 'user_10',
        registerTime: DateTime.now().subtract(const Duration(days: 15)),
        isActive: true,
        totalBet: 15000.0,
        totalReward: 560.0,
        level: 1,
      ),
      ReferralDetail(
        id: 'U011',
        username: 'user_11',
        registerTime: DateTime.now().subtract(const Duration(days: 8)),
        isActive: true,
        totalBet: 8500.0,
        totalReward: 320.0,
        level: 1,
      ),
      ReferralDetail(
        id: 'U012',
        username: 'user_12',
        registerTime: DateTime.now().subtract(const Duration(days: 3)),
        isActive: false,
        totalBet: 2000.0,
        totalReward: 100.0,
        level: 1,
      ),
    ];
  }
}
