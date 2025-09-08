/// VIP等级枚举
enum VipLevel {
  regular(0, '普通用户', '新用户初始等级'),
  bronze(1, '青铜VIP', '首次达成的VIP等级'),
  silver(2, '白银VIP', '中级VIP用户'),
  gold(3, '黄金VIP', '高级VIP用户'),
  diamond(4, '钻石VIP', '尊贵VIP用户'),
  black(5, '黑金VIP', '至尊VIP用户');

  const VipLevel(this.level, this.name, this.description);

  final int level;
  final String name;
  final String description;

  static VipLevel fromLevel(int level) {
    return VipLevel.values.firstWhere(
      (vip) => vip.level == level,
      orElse: () => VipLevel.regular,
    );
  }

  /// 获取等级颜色
  int get color {
    switch (this) {
      case VipLevel.regular:
        return 0xFF9E9E9E;
      case VipLevel.bronze:
        return 0xFFCD7F32;
      case VipLevel.silver:
        return 0xFFC0C0C0;
      case VipLevel.gold:
        return 0xFFFFD700;
      case VipLevel.diamond:
        return 0xFF0073E6;
      case VipLevel.black:
        return 0xFF1C1C1C;
    }
  }

  /// 获取等级图标
  String get icon {
    switch (this) {
      case VipLevel.regular:
        return 'person';
      case VipLevel.bronze:
        return 'workspace_premium';
      case VipLevel.silver:
        return 'military_tech';
      case VipLevel.gold:
        return 'stars';
      case VipLevel.diamond:
        return 'diamond';
      case VipLevel.black:
        return 'auto_awesome';
    }
  }
}

/// VIP用户详细信息模型
class VipUserInfo {
  final String userId;
  final VipLevel currentLevel;
  final double totalPoints;
  final double currentLevelPoints;
  final double nextLevelPoints;
  final double totalBetAmount;
  final double totalDepositAmount;
  final int daysActive;
  final DateTime? vipStartDate;
  final DateTime? vipEndDate;
  final bool isLifetimeVip;
  final List<VipBenefit> availableBenefits;
  final List<VipReward> unclaimedRewards;

  VipUserInfo({
    required this.userId,
    required this.currentLevel,
    required this.totalPoints,
    required this.currentLevelPoints,
    required this.nextLevelPoints,
    required this.totalBetAmount,
    required this.totalDepositAmount,
    required this.daysActive,
    this.vipStartDate,
    this.vipEndDate,
    this.isLifetimeVip = false,
    this.availableBenefits = const [],
    this.unclaimedRewards = const [],
  });

  factory VipUserInfo.fromJson(Map<String, dynamic> json) {
    try {
      return VipUserInfo(
        userId: _parseString(json['user_id']),
        currentLevel: VipLevel.fromLevel(_parseInt(json['current_level'], defaultValue: 0)),
        totalPoints: _parseDouble(json['total_points'], defaultValue: 0.0),
        currentLevelPoints: _parseDouble(json['current_level_points'], defaultValue: 0.0),
        nextLevelPoints: _parseDouble(json['next_level_points'], defaultValue: 0.0),
        totalBetAmount: _parseDouble(json['total_bet_amount'], defaultValue: 0.0),
        totalDepositAmount: _parseDouble(json['total_deposit_amount'], defaultValue: 0.0),
        daysActive: _parseInt(json['days_active'], defaultValue: 0),
        vipStartDate: _parseDateTime(json['vip_start_date']),
        vipEndDate: _parseDateTime(json['vip_end_date']),
        isLifetimeVip: _parseBool(json['is_lifetime_vip'], defaultValue: false),
        availableBenefits: _parseBenefitsList(json['available_benefits']),
        unclaimedRewards: _parseRewardsList(json['unclaimed_rewards']),
      );
    } catch (e) {
      throw FormatException('VipUserInfo.fromJson: 数据解析失败 - $e');
    }
  }
  
  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }
  
  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
  
  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }
  
  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }
  
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) {
        return DateTime.parse(value);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      // 解析失败返回null
    }
    return null;
  }
  
  static List<VipBenefit> _parseBenefitsList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      try {
        return value.map((e) => VipBenefit.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }
  
  static List<VipReward> _parseRewardsList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      try {
        return value.map((e) => VipReward.fromJson(e)).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'current_level': currentLevel.level,
      'total_points': totalPoints,
      'current_level_points': currentLevelPoints,
      'next_level_points': nextLevelPoints,
      'total_bet_amount': totalBetAmount,
      'total_deposit_amount': totalDepositAmount,
      'days_active': daysActive,
      'vip_start_date': vipStartDate?.toIso8601String(),
      'vip_end_date': vipEndDate?.toIso8601String(),
      'is_lifetime_vip': isLifetimeVip,
      'available_benefits': availableBenefits.map((e) => e.toJson()).toList(),
      'unclaimed_rewards': unclaimedRewards.map((e) => e.toJson()).toList(),
    };
  }

  /// 获取升级进度百分比
  double get upgradeProgress {
    if (currentLevel == VipLevel.black) return 1.0;
    if (nextLevelPoints <= currentLevelPoints) return 1.0;
    return (totalPoints - currentLevelPoints) /
        (nextLevelPoints - currentLevelPoints);
  }

  /// 获取升级所需积分
  double get pointsNeededForUpgrade {
    if (currentLevel == VipLevel.black) return 0.0;
    return nextLevelPoints - totalPoints;
  }

  /// 是否可以升级
  bool get canUpgrade {
    return totalPoints >= nextLevelPoints && currentLevel != VipLevel.black;
  }

  VipUserInfo copyWith({
    String? userId,
    VipLevel? currentLevel,
    double? totalPoints,
    double? currentLevelPoints,
    double? nextLevelPoints,
    double? totalBetAmount,
    double? totalDepositAmount,
    int? daysActive,
    DateTime? vipStartDate,
    DateTime? vipEndDate,
    bool? isLifetimeVip,
    List<VipBenefit>? availableBenefits,
    List<VipReward>? unclaimedRewards,
  }) {
    return VipUserInfo(
      userId: userId ?? this.userId,
      currentLevel: currentLevel ?? this.currentLevel,
      totalPoints: totalPoints ?? this.totalPoints,
      currentLevelPoints: currentLevelPoints ?? this.currentLevelPoints,
      nextLevelPoints: nextLevelPoints ?? this.nextLevelPoints,
      totalBetAmount: totalBetAmount ?? this.totalBetAmount,
      totalDepositAmount: totalDepositAmount ?? this.totalDepositAmount,
      daysActive: daysActive ?? this.daysActive,
      vipStartDate: vipStartDate ?? this.vipStartDate,
      vipEndDate: vipEndDate ?? this.vipEndDate,
      isLifetimeVip: isLifetimeVip ?? this.isLifetimeVip,
      availableBenefits: availableBenefits ?? this.availableBenefits,
      unclaimedRewards: unclaimedRewards ?? this.unclaimedRewards,
    );
  }
  
  // 数据验证方法
  bool validate() {
    if (userId.isEmpty) return false;
    if (totalPoints < 0 || currentLevelPoints < 0 || nextLevelPoints < 0) return false;
    if (totalBetAmount < 0 || totalDepositAmount < 0) return false;
    if (daysActive < 0) return false;
    return true;
  }
  
  // 格式化积分显示
  String get formattedTotalPoints {
    if (totalPoints >= 10000) {
      return '${(totalPoints / 10000).toStringAsFixed(1)}万';
    }
    return totalPoints.toInt().toString();
  }
  
  // 格式化投注金额
  String get formattedTotalBetAmount {
    return '¥${totalBetAmount.toStringAsFixed(2)}';
  }
  
  // 格式化充值金额
  String get formattedTotalDepositAmount {
    return '¥${totalDepositAmount.toStringAsFixed(2)}';
  }
  
  // 获取VIP有效天数
  int get vipValidDays {
    if (isLifetimeVip) return -1; // -1表示终身VIP
    if (vipEndDate == null) return 0;
    final now = DateTime.now();
    final difference = vipEndDate!.difference(now);
    return difference.inDays > 0 ? difference.inDays : 0;
  }
  
  // 判断VIP是否已过期
  bool get isVipExpired {
    if (isLifetimeVip) return false;
    if (vipEndDate == null) return true;
    return DateTime.now().isAfter(vipEndDate!);
  }
  
  // 获取有效的特权数量
  int get availableBenefitsCount {
    return availableBenefits.where((benefit) => benefit.isAvailable).length;
  }
  
  // 获取未领取奖励数量
  int get unclaimedRewardsCount {
    return unclaimedRewards.where((reward) => reward.canClaim).length;
  }
  
  // 获取升级进度文本描述
  String get upgradeProgressText {
    if (currentLevel == VipLevel.black) {
      return '已达到最高等级';
    }
    final progress = (upgradeProgress * 100).toInt();
    final needed = pointsNeededForUpgrade.toInt();
    return '升级进度: $progress% (还需$needed积分)';
  }
  
  // 计算VIP等级权重（用于排序）
  double get vipWeight {
    return currentLevel.level * 1000000 + 
           totalPoints * 100 + 
           totalBetAmount * 0.1 + 
           daysActive * 10;
  }
}

/// VIP特权模型
class VipBenefit {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final VipLevel requiredLevel;
  final BenefitType type;
  final double? value;
  final String? unit;
  final bool isActive;
  final DateTime? expiryDate;
  final int? usageLimit;
  final int? usedCount;

  VipBenefit({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.requiredLevel,
    required this.type,
    this.value,
    this.unit,
    this.isActive = true,
    this.expiryDate,
    this.usageLimit,
    this.usedCount = 0,
  });

  factory VipBenefit.fromJson(Map<String, dynamic> json) {
    return VipBenefit(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconName: json['icon_name'] ?? 'star',
      requiredLevel: VipLevel.fromLevel(json['required_level'] ?? 0),
      type: BenefitType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => BenefitType.discount,
      ),
      value: (json['value'] ?? 0.0).toDouble(),
      unit: json['unit'],
      isActive: json['is_active'] ?? true,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'])
          : null,
      usageLimit: json['usage_limit'],
      usedCount: json['used_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon_name': iconName,
      'required_level': requiredLevel.level,
      'type': type.name,
      'value': value,
      'unit': unit,
      'is_active': isActive,
      'expiry_date': expiryDate?.toIso8601String(),
      'usage_limit': usageLimit,
      'used_count': usedCount,
    };
  }

  /// 是否可用
  bool get isAvailable {
    if (!isActive) return false;
    if (expiryDate != null && DateTime.now().isAfter(expiryDate!)) return false;
    if (usageLimit != null && (usedCount ?? 0) >= usageLimit!) return false;
    return true;
  }

  /// 剩余使用次数
  int? get remainingUses {
    if (usageLimit == null) return null;
    return usageLimit! - (usedCount ?? 0);
  }
}

/// 特权类型枚举
enum BenefitType {
  discount('折扣'),
  cashback('返现'),
  bonus('奖金'),
  freebet('免费投注'),
  upgrade('升级加速'),
  exclusive('专属服务');

  const BenefitType(this.displayName);
  final String displayName;
}

/// VIP奖励模型
class VipReward {
  final String id;
  final String name;
  final String description;
  final RewardType type;
  final double value;
  final String? currency;
  final DateTime expiryDate;
  final bool isClaimed;
  final DateTime? claimedAt;
  final VipLevel? minLevel;
  final String? imageUrl;

  VipReward({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.value,
    this.currency,
    required this.expiryDate,
    this.isClaimed = false,
    this.claimedAt,
    this.minLevel,
    this.imageUrl,
  });

  factory VipReward.fromJson(Map<String, dynamic> json) {
    return VipReward(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: RewardType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RewardType.cash,
      ),
      value: (json['value'] ?? 0.0).toDouble(),
      currency: json['currency'],
      expiryDate: DateTime.parse(json['expiry_date']),
      isClaimed: json['is_claimed'] ?? false,
      claimedAt: json['claimed_at'] != null
          ? DateTime.parse(json['claimed_at'])
          : null,
      minLevel: json['min_level'] != null
          ? VipLevel.fromLevel(json['min_level'])
          : null,
      imageUrl: json['image_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'value': value,
      'currency': currency,
      'expiry_date': expiryDate.toIso8601String(),
      'is_claimed': isClaimed,
      'claimed_at': claimedAt?.toIso8601String(),
      'min_level': minLevel?.level,
      'image_url': imageUrl,
    };
  }

  /// 是否已过期
  bool get isExpired => DateTime.now().isAfter(expiryDate);

  /// 是否可领取
  bool get canClaim => !isClaimed && !isExpired;
}

/// 奖励类型枚举
enum RewardType {
  cash('现金'),
  bonus('奖金'),
  points('积分'),
  freeSpins('免费转动'),
  merchandise('实物奖品');

  const RewardType(this.displayName);
  final String displayName;
}

/// VIP积分记录模型
class VipPointsRecord {
  final String id;
  final String userId;
  final double points;
  final PointsType type;
  final String description;
  final String? referenceId;
  final DateTime createdAt;

  VipPointsRecord({
    required this.id,
    required this.userId,
    required this.points,
    required this.type,
    required this.description,
    this.referenceId,
    required this.createdAt,
  });

  factory VipPointsRecord.fromJson(Map<String, dynamic> json) {
    return VipPointsRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      points: (json['points'] ?? 0.0).toDouble(),
      type: PointsType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => PointsType.bet,
      ),
      description: json['description'] ?? '',
      referenceId: json['reference_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points': points,
      'type': type.name,
      'description': description,
      'reference_id': referenceId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// 是否为正积分
  bool get isPositive => points > 0;
}

/// 积分类型枚举
enum PointsType {
  bet('投注获得'),
  deposit('充值获得'),
  login('登录奖励'),
  referral('推荐奖励'),
  birthday('生日奖励'),
  promotion('活动奖励'),
  compensation('补偿积分'),
  exchange('兑换消耗');

  const PointsType(this.displayName);
  final String displayName;
}

/// VIP兑换商品模型
class VipExchangeItem {
  final String id;
  final String name;
  final String description;
  final double pointsCost;
  final String? imageUrl;
  final String? category;
  final VipLevel? minLevel;
  final bool isActive;
  final bool canExchange;
  final int? stock;
  final DateTime? expiryDate;
  final Map<String, dynamic>? metadata;

  VipExchangeItem({
    required this.id,
    required this.name,
    required this.description,
    required this.pointsCost,
    this.imageUrl,
    this.category,
    this.minLevel,
    this.isActive = true,
    this.canExchange = true,
    this.stock,
    this.expiryDate,
    this.metadata,
  });

  factory VipExchangeItem.fromJson(Map<String, dynamic> json) {
    try {
      return VipExchangeItem(
        id: _parseString(json['id']),
        name: _parseString(json['name']),
        description: _parseString(json['description']),
        pointsCost: _parseDouble(json['points_cost'], defaultValue: 0.0),
        imageUrl: _parseStringNullable(json['image_url']),
        category: _parseStringNullable(json['category']),
        minLevel: json['min_level'] != null
            ? VipLevel.fromLevel(_parseInt(json['min_level'], defaultValue: 0))
            : null,
        isActive: _parseBool(json['is_active'], defaultValue: true),
        canExchange: _parseBool(json['can_exchange'], defaultValue: true),
        stock: _parseIntNullable(json['stock']),
        expiryDate: _parseDateTime(json['expiry_date']),
        metadata: _parseMetadata(json['metadata']),
      );
    } catch (e) {
      throw FormatException('VipExchangeItem.fromJson: 数据解析失败 - $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'points_cost': pointsCost,
      'image_url': imageUrl,
      'category': category,
      'min_level': minLevel?.level,
      'is_active': isActive,
      'can_exchange': canExchange,
      'stock': stock,
      'expiry_date': expiryDate?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// 是否有库存
  bool get hasStock {
    return stock == null || stock! > 0;
  }

  /// 是否已过期
  bool get isExpired {
    return expiryDate != null && DateTime.now().isAfter(expiryDate!);
  }

  /// 是否可以兑换
  bool get isAvailableForExchange {
    return isActive && canExchange && hasStock && !isExpired;
  }

  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static String? _parseStringNullable(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
    return value.toString();
  }

  static double _parseDouble(dynamic value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  static int? _parseIntNullable(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    return null;
  }

  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    try {
      if (value is String) {
        return DateTime.parse(value);
      }
      if (value is int) {
        return DateTime.fromMillisecondsSinceEpoch(value);
      }
    } catch (e) {
      // 解析失败返回null
    }
    return null;
  }

  static Map<String, dynamic>? _parseMetadata(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, dynamic>) return value;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return null;
  }
}

/// 兑换商品类型枚举
enum ExchangeType {
  cash('现金'),
  bonus('奖金'),
  freebet('免费投注'),
  service('专属服务'),
  merchandise('实物商品');

  const ExchangeType(this.displayName);
  final String displayName;
}
