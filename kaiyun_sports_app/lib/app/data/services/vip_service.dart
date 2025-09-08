import '../api/api_service.dart';
import '../models/vip_models.dart';

/// VIP服务类
class VipService {
  static final VipService _instance = VipService._internal();
  factory VipService() => _instance;
  VipService._internal();

  final ApiService _apiService = ApiService();

  /// 获取VIP用户信息
  Future<VipUserInfo?> getVipUserInfo(String userId) async {
    try {
      final response = await _apiService.get('/vip/user/$userId');
      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true && data['data'] != null) {
        return VipUserInfo.fromJson(data['data']);
      }
      return null;
    } catch (e) {
      throw Exception('获取VIP信息失败: ${_apiService.handleError(e)}');
    }
  }

  /// 计算VIP等级
  VipLevel calculateVipLevel(double totalPoints, double totalBetAmount) {
    // VIP等级计算逻辑
    if (totalPoints >= 1000000 && totalBetAmount >= 10000000) {
      return VipLevel.black;
    } else if (totalPoints >= 500000 && totalBetAmount >= 5000000) {
      return VipLevel.diamond;
    } else if (totalPoints >= 200000 && totalBetAmount >= 2000000) {
      return VipLevel.gold;
    } else if (totalPoints >= 50000 && totalBetAmount >= 500000) {
      return VipLevel.silver;
    } else if (totalPoints >= 10000 && totalBetAmount >= 100000) {
      return VipLevel.bronze;
    } else {
      return VipLevel.regular;
    }
  }

  /// 获取下一等级所需积分
  double getNextLevelPoints(VipLevel currentLevel) {
    switch (currentLevel) {
      case VipLevel.regular:
        return 10000;
      case VipLevel.bronze:
        return 50000;
      case VipLevel.silver:
        return 200000;
      case VipLevel.gold:
        return 500000;
      case VipLevel.diamond:
        return 1000000;
      case VipLevel.black:
        return 1000000; // 最高等级
    }
  }

  /// 获取当前等级起始积分
  double getCurrentLevelPoints(VipLevel currentLevel) {
    switch (currentLevel) {
      case VipLevel.regular:
        return 0;
      case VipLevel.bronze:
        return 10000;
      case VipLevel.silver:
        return 50000;
      case VipLevel.gold:
        return 200000;
      case VipLevel.diamond:
        return 500000;
      case VipLevel.black:
        return 1000000;
    }
  }

  /// 获取VIP特权列表
  Future<List<VipBenefit>> getVipBenefits(VipLevel userLevel) async {
    try {
      final response = await _apiService.get('/vip/benefits', 
          queryParameters: {'level': userLevel.level});
      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((item) => VipBenefit.fromJson(item))
            .toList();
      }
      
      // 如果服务器没有数据，返回默认特权
      return _getDefaultBenefits(userLevel);
    } catch (e) {
      // 如果请求失败，返回默认特权
      return _getDefaultBenefits(userLevel);
    }
  }

  /// 获取默认VIP特权
  List<VipBenefit> _getDefaultBenefits(VipLevel userLevel) {
    final benefits = <VipBenefit>[];
    
    // 根据等级返回不同特权
    if (userLevel.level >= VipLevel.bronze.level) {
      benefits.add(VipBenefit(
        id: 'weekly_bonus',
        name: '每周红包',
        description: '每周可领取红包奖励',
        iconName: 'card_giftcard',
        requiredLevel: VipLevel.bronze,
        type: BenefitType.bonus,
        value: 100,
        unit: 'CNY',
      ));
    }
    
    if (userLevel.level >= VipLevel.silver.level) {
      benefits.add(VipBenefit(
        id: 'cashback_bonus',
        name: '投注返现',
        description: '投注额的一定比例返现',
        iconName: 'attach_money',
        requiredLevel: VipLevel.silver,
        type: BenefitType.cashback,
        value: 0.5,
        unit: '%',
      ));
    }
    
    if (userLevel.level >= VipLevel.gold.level) {
      benefits.add(VipBenefit(
        id: 'upgrade_bonus',
        name: '晋级礼金',
        description: 'VIP等级提升时获得额外奖金',
        iconName: 'trending_up',
        requiredLevel: VipLevel.gold,
        type: BenefitType.bonus,
        value: 1000,
        unit: 'CNY',
      ));
    }
    
    if (userLevel.level >= VipLevel.diamond.level) {
      benefits.add(VipBenefit(
        id: 'exclusive_service',
        name: '专属客服',
        description: '专属VIP客服团队服务',
        iconName: 'support_agent',
        requiredLevel: VipLevel.diamond,
        type: BenefitType.exclusive,
      ));
    }
    
    if (userLevel.level >= VipLevel.black.level) {
      benefits.add(VipBenefit(
        id: 'birthday_bonus',
        name: '生日特别礼金',
        description: '生日当天享受特别奖金',
        iconName: 'cake',
        requiredLevel: VipLevel.black,
        type: BenefitType.bonus,
        value: 5000,
        unit: 'CNY',
      ));
    }
    
    return benefits;
  }

  /// 获取VIP奖励列表
  Future<List<VipReward>> getVipRewards(String userId) async {
    try {
      final response = await _apiService.get('/vip/rewards/$userId');
      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((item) => VipReward.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('获取VIP奖励失败: ${_apiService.handleError(e)}');
    }
  }

  /// 领取VIP奖励
  Future<bool> claimReward(String rewardId) async {
    try {
      final response = await _apiService.post('/vip/rewards/$rewardId/claim');
      final data = _apiService.handleResponse(response);
      return data['success'] == true;
    } catch (e) {
      throw Exception('领取奖励失败: ${_apiService.handleError(e)}');
    }
  }

  /// 获取积分记录
  Future<List<VipPointsRecord>> getPointsRecords(
    String userId, {
    int page = 1,
    int pageSize = 20,
    PointsType? type,
  }) async {
    try {
      final queryParams = {
        'page': page,
        'page_size': pageSize,
        if (type != null) 'type': type.name,
      };
      
      final response = await _apiService.get(
        '/vip/points-records/$userId',
        queryParameters: queryParams,
      );
      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true && data['data'] != null) {
        return (data['data']['records'] as List)
            .map((item) => VipPointsRecord.fromJson(item))
            .toList();
      }
      return [];
    } catch (e) {
      throw Exception('获取积分记录失败: ${_apiService.handleError(e)}');
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
    try {
      final response = await _apiService.post('/vip/points/add', data: {
        'user_id': userId,
        'points': points,
        'type': type.name,
        'description': description,
        if (referenceId != null) 'reference_id': referenceId,
      });
      final data = _apiService.handleResponse(response);
      return data['success'] == true;
    } catch (e) {
      throw Exception('添加积分失败: ${_apiService.handleError(e)}');
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
    try {
      final response = await _apiService.post('/vip/points/deduct', data: {
        'user_id': userId,
        'points': points,
        'type': type.name,
        'description': description,
        if (referenceId != null) 'reference_id': referenceId,
      });
      final data = _apiService.handleResponse(response);
      return data['success'] == true;
    } catch (e) {
      throw Exception('扣除积分失败: ${_apiService.handleError(e)}');
    }
  }

  /// 积分兑换
  Future<bool> exchangePoints(
    String userId,
    String rewardId,
    double pointsCost,
  ) async {
    try {
      final response = await _apiService.post('/vip/points/exchange', data: {
        'user_id': userId,
        'reward_id': rewardId,
        'points_cost': pointsCost,
      });
      final data = _apiService.handleResponse(response);
      return data['success'] == true;
    } catch (e) {
      throw Exception('积分兑换失败: ${_apiService.handleError(e)}');
    }
  }

  /// 检查VIP等级升级
  Future<VipLevel?> checkLevelUpgrade(String userId) async {
    try {
      final response = await _apiService.post('/vip/check-upgrade/$userId');
      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true && data['data']?['new_level'] != null) {
        return VipLevel.fromLevel(data['data']['new_level']);
      }
      return null;
    } catch (e) {
      throw Exception('检查等级升级失败: ${_apiService.handleError(e)}');
    }
  }

  /// 激活VIP特权
  Future<bool> activateBenefit(String benefitId, String userId) async {
    try {
      final response = await _apiService.post(
        '/vip/benefits/$benefitId/activate',
        data: {'user_id': userId},
      );
      final data = _apiService.handleResponse(response);
      return data['success'] == true;
    } catch (e) {
      throw Exception('激活VIP特权失败: ${_apiService.handleError(e)}');
    }
  }

  /// 获取VIP等级统计信息
  Future<Map<String, dynamic>> getVipStats() async {
    try {
      final response = await _apiService.get('/vip/stats');
      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true && data['data'] != null) {
        return data['data'];
      }
      return {};
    } catch (e) {
      throw Exception('获取VIP统计信息失败: ${_apiService.handleError(e)}');
    }
  }

  /// 获取特权兑换商城商品
  Future<List<VipExchangeItem>> getExchangeItems(VipLevel userLevel) async {
    try {
      final response = await _apiService.get(
        '/vip/exchange-items',
        queryParameters: {'level': userLevel.level},
      );
      final data = _apiService.handleResponse(response);
      
      if (data['success'] == true && data['data'] != null) {
        return (data['data'] as List)
            .map((item) => VipExchangeItem.fromJson(item))
            .toList();
      }
      
      // 返回默认兑换商品
      return _getDefaultExchangeItems(userLevel);
    } catch (e) {
      throw Exception('获取兑换商品失败: ${_apiService.handleError(e)}');
    }
  }

  /// 获取默认兑换商品
  List<VipExchangeItem> _getDefaultExchangeItems(VipLevel userLevel) {
    return [
      VipExchangeItem(
        id: 'cash_10',
        name: '10元现金',
        description: '直接充值到账户余额',
        pointsCost: 1000,
        minLevel: VipLevel.bronze,
        stock: 100,
        imageUrl: 'assets/images/cash.png',
        metadata: {'value': 10, 'type': ExchangeType.cash.name},
      ),
      VipExchangeItem(
        id: 'freebet_50',
        name: '50元免费投注',
        description: '可用于任意体育赛事投注',
        pointsCost: 2500,
        minLevel: VipLevel.silver,
        stock: 50,
        imageUrl: 'assets/images/freebet.png',
        metadata: {'value': 50, 'type': ExchangeType.freebet.name},
      ),
      if (userLevel.level >= VipLevel.gold.level)
        VipExchangeItem(
          id: 'premium_support',
          name: '专属客服服务',
          description: '30天7*24小时专属客服支持',
          pointsCost: 5000,
          minLevel: VipLevel.gold,
          stock: 20,
          imageUrl: 'assets/images/support.png',
          metadata: {'value': 1, 'type': ExchangeType.service.name},
        ),
    ];
  }

  /// 计算投注积分
  double calculateBetPoints(double betAmount) {
    // 每1元投注获得1积分
    return betAmount;
  }

  /// 计算充值积分
  double calculateDepositPoints(double depositAmount) {
    // 每10元充值获得1积分
    return depositAmount / 10;
  }
}
