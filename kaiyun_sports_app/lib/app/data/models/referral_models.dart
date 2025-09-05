// 推荐奖励模型
class ReferralReward {
  final String id;
  final String referrerId;
  final String refereeId;
  final String refereeUsername;
  final double amount;
  final RewardType type;
  final RewardStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final int level; // 推荐层级
  final String? description;
  
  ReferralReward({
    required this.id,
    required this.referrerId,
    required this.refereeId,
    required this.refereeUsername,
    required this.amount,
    required this.type,
    required this.status,
    required this.createdAt,
    this.processedAt,
    required this.level,
    this.description,
  });
  
  factory ReferralReward.fromJson(Map<String, dynamic> json) {
    return ReferralReward(
      id: json['id'] ?? '',
      referrerId: json['referrer_id'] ?? '',
      refereeId: json['referee_id'] ?? '',
      refereeUsername: json['referee_username'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      type: RewardType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => RewardType.register,
      ),
      status: RewardStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => RewardStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      level: json['level'] ?? 1,
      description: json['description'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'referrer_id': referrerId,
      'referee_id': refereeId,
      'referee_username': refereeUsername,
      'amount': amount,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'level': level,
      'description': description,
    };
  }
  
  String get typeText {
    switch (type) {
      case RewardType.register:
        return '注册奖励';
      case RewardType.deposit:
        return '首存奖励';
      case RewardType.betting:
        return '投注分成';
      case RewardType.activity:
        return '活动奖励';
    }
  }
  
  String get statusText {
    switch (status) {
      case RewardStatus.pending:
        return '待发放';
      case RewardStatus.approved:
        return '已发放';
      case RewardStatus.rejected:
        return '已拒绝';
    }
  }
}

enum RewardType { register, deposit, betting, activity }
enum RewardStatus { pending, approved, rejected }

// 推荐统计模型
class ReferralStatistics {
  final int totalReferrals;
  final int activeReferrals;
  final double totalReward;
  final double monthReward;
  final double todayReward;
  final int level1Count;
  final int level2Count;
  final int level3Count;
  final List<ReferralDetail> recentReferrals;
  final Map<String, double> rewardByType;
  
  ReferralStatistics({
    required this.totalReferrals,
    required this.activeReferrals,
    required this.totalReward,
    required this.monthReward,
    required this.todayReward,
    required this.level1Count,
    required this.level2Count,
    required this.level3Count,
    required this.recentReferrals,
    required this.rewardByType,
  });
  
  factory ReferralStatistics.fromJson(Map<String, dynamic> json) {
    return ReferralStatistics(
      totalReferrals: json['total_referrals'] ?? 0,
      activeReferrals: json['active_referrals'] ?? 0,
      totalReward: (json['total_reward'] ?? 0.0).toDouble(),
      monthReward: (json['month_reward'] ?? 0.0).toDouble(),
      todayReward: (json['today_reward'] ?? 0.0).toDouble(),
      level1Count: json['level1_count'] ?? 0,
      level2Count: json['level2_count'] ?? 0,
      level3Count: json['level3_count'] ?? 0,
      recentReferrals: (json['recent_referrals'] as List<dynamic>? ?? [])
          .map((item) => ReferralDetail.fromJson(item))
          .toList(),
      rewardByType: Map<String, double>.from(
        json['reward_by_type'] ?? {},
      ),
    );
  }
}

// 推荐详情模型
class ReferralDetail {
  final String id;
  final String username;
  final DateTime registerTime;
  final bool isActive;
  final double totalBet;
  final double totalReward;
  final int level;
  
  ReferralDetail({
    required this.id,
    required this.username,
    required this.registerTime,
    required this.isActive,
    required this.totalBet,
    required this.totalReward,
    required this.level,
  });
  
  factory ReferralDetail.fromJson(Map<String, dynamic> json) {
    return ReferralDetail(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      registerTime: DateTime.parse(json['register_time']),
      isActive: json['is_active'] ?? false,
      totalBet: (json['total_bet'] ?? 0.0).toDouble(),
      totalReward: (json['total_reward'] ?? 0.0).toDouble(),
      level: json['level'] ?? 1,
    );
  }
}

// 推荐码模型
class ReferralCode {
  final String code;
  final String userId;
  final DateTime createdAt;
  final DateTime? expiresAt;
  final bool isActive;
  final int usageCount;
  final int maxUsage;
  
  ReferralCode({
    required this.code,
    required this.userId,
    required this.createdAt,
    this.expiresAt,
    this.isActive = true,
    this.usageCount = 0,
    this.maxUsage = -1, // -1 表示无限制
  });
  
  factory ReferralCode.fromJson(Map<String, dynamic> json) {
    return ReferralCode(
      code: json['code'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: DateTime.parse(json['created_at']),
      expiresAt: json['expires_at'] != null 
          ? DateTime.parse(json['expires_at']) 
          : null,
      isActive: json['is_active'] ?? true,
      usageCount: json['usage_count'] ?? 0,
      maxUsage: json['max_usage'] ?? -1,
    );
  }
  
  bool get canUse {
    if (!isActive) return false;
    if (expiresAt != null && DateTime.now().isAfter(expiresAt!)) return false;
    if (maxUsage > 0 && usageCount >= maxUsage) return false;
    return true;
  }
}
