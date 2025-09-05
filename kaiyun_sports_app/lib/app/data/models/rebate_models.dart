// 返水记录模型
class RebateRecord {
  final String id;
  final String userId;
  final double amount;
  final double betAmount;
  final double rebateRate;
  final RebateType type;
  final RebateStatus status;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? category; // 体育、真人、电子等
  final String period; // 返水周期，如每日、每周
  
  RebateRecord({
    required this.id,
    required this.userId,
    required this.amount,
    required this.betAmount,
    required this.rebateRate,
    required this.type,
    required this.status,
    required this.createdAt,
    this.processedAt,
    this.category,
    required this.period,
  });
  
  factory RebateRecord.fromJson(Map<String, dynamic> json) {
    return RebateRecord(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      amount: (json['amount'] ?? 0.0).toDouble(),
      betAmount: (json['bet_amount'] ?? 0.0).toDouble(),
      rebateRate: (json['rebate_rate'] ?? 0.0).toDouble(),
      type: RebateType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => RebateType.betting,
      ),
      status: RebateStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => RebateStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at']),
      processedAt: json['processed_at'] != null 
          ? DateTime.parse(json['processed_at']) 
          : null,
      category: json['category'],
      period: json['period'] ?? 'daily',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'amount': amount,
      'bet_amount': betAmount,
      'rebate_rate': rebateRate,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'category': category,
      'period': period,
    };
  }
  
  String get statusText {
    switch (status) {
      case RebateStatus.pending:
        return '待处理';
      case RebateStatus.processed:
        return '已发放';
      case RebateStatus.cancelled:
        return '已取消';
    }
  }
  
  String get typeText {
    switch (type) {
      case RebateType.betting:
        return '投注返水';
      case RebateType.deposit:
        return '充值返水';
      case RebateType.vip:
        return 'VIP返水';
    }
  }
}

enum RebateType { betting, deposit, vip }
enum RebateStatus { pending, processed, cancelled }

// 返水配置模型
class RebateConfig {
  final String category;
  final double minBetAmount;
  final double maxRebateAmount;
  final double rebateRate;
  final String period;
  final bool enabled;
  final int vipLevelRequired;
  
  RebateConfig({
    required this.category,
    required this.minBetAmount,
    required this.maxRebateAmount,
    required this.rebateRate,
    required this.period,
    this.enabled = true,
    this.vipLevelRequired = 0,
  });
  
  factory RebateConfig.fromJson(Map<String, dynamic> json) {
    return RebateConfig(
      category: json['category'] ?? '',
      minBetAmount: (json['min_bet_amount'] ?? 0.0).toDouble(),
      maxRebateAmount: (json['max_rebate_amount'] ?? 0.0).toDouble(),
      rebateRate: (json['rebate_rate'] ?? 0.0).toDouble(),
      period: json['period'] ?? 'daily',
      enabled: json['enabled'] ?? true,
      vipLevelRequired: json['vip_level_required'] ?? 0,
    );
  }
}

// 返水统计模型
class RebateStatistics {
  final double todayRebate;
  final double weekRebate;
  final double monthRebate;
  final double totalRebate;
  final int todayCount;
  final int totalCount;
  final double avgRebateRate;
  final Map<String, double> categoryRebates;
  
  RebateStatistics({
    required this.todayRebate,
    required this.weekRebate,
    required this.monthRebate,
    required this.totalRebate,
    required this.todayCount,
    required this.totalCount,
    required this.avgRebateRate,
    required this.categoryRebates,
  });
  
  factory RebateStatistics.fromJson(Map<String, dynamic> json) {
    return RebateStatistics(
      todayRebate: (json['today_rebate'] ?? 0.0).toDouble(),
      weekRebate: (json['week_rebate'] ?? 0.0).toDouble(),
      monthRebate: (json['month_rebate'] ?? 0.0).toDouble(),
      totalRebate: (json['total_rebate'] ?? 0.0).toDouble(),
      todayCount: json['today_count'] ?? 0,
      totalCount: json['total_count'] ?? 0,
      avgRebateRate: (json['avg_rebate_rate'] ?? 0.0).toDouble(),
      categoryRebates: Map<String, double>.from(
        json['category_rebates'] ?? {},
      ),
    );
  }
}
