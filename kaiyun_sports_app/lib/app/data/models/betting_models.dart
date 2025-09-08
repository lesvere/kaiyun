// 投注相关数据模型

enum BetType {
  single, // 单式投注
  combo, // 串关投注
}

class BetOption {
  final String id;
  final String title;
  final String description;
  final double odds;
  final String matchId;
  final String optionType;
  final bool isAvailable;

  BetOption({
    required this.id,
    required this.title,
    required this.description,
    required this.odds,
    required this.matchId,
    required this.optionType,
    this.isAvailable = true,
  });

  factory BetOption.fromJson(Map<String, dynamic> json) {
    return BetOption(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      odds: (json['odds'] ?? 0).toDouble(),
      matchId: json['matchId'] ?? '',
      optionType: json['optionType'] ?? '',
      isAvailable: json['isAvailable'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'odds': odds,
      'matchId': matchId,
      'optionType': optionType,
      'isAvailable': isAvailable,
    };
  }
}

class BetRequest {
  final List<BetOption> options;
  final double amount;
  final BetType betType;
  final String userId;
  final String? remark;
  final DateTime timestamp;

  BetRequest({
    required this.options,
    required this.amount,
    required this.betType,
    required this.userId,
    this.remark,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'options': options.map((o) => o.toJson()).toList(),
      'amount': amount,
      'betType': betType.name,
      'userId': userId,
      'remark': remark,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

class BetRecord {
  final String id;
  final String userId;
  final List<BetOption> options;
  final double amount;
  final BetType betType;
  final BetStatus status;
  final double? winAmount;
  final DateTime createdAt;
  final DateTime? settledAt;
  final String? remark;

  BetRecord({
    required this.id,
    required this.userId,
    required this.options,
    required this.amount,
    required this.betType,
    required this.status,
    this.winAmount,
    required this.createdAt,
    this.settledAt,
    this.remark,
  });

  factory BetRecord.fromJson(Map<String, dynamic> json) {
    return BetRecord(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      options: (json['options'] as List<dynamic>? ?? [])
          .map((o) => BetOption.fromJson(o))
          .toList(),
      amount: (json['amount'] ?? 0).toDouble(),
      betType: BetType.values.firstWhere(
        (type) => type.name == json['betType'],
        orElse: () => BetType.single,
      ),
      status: BetStatus.values.firstWhere(
        (status) => status.name == json['status'],
        orElse: () => BetStatus.pending,
      ),
      winAmount: json['winAmount']?.toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      settledAt:
          json['settledAt'] != null ? DateTime.parse(json['settledAt']) : null,
      remark: json['remark'],
    );
  }
}

enum BetStatus {
  pending, // 等待结算
  won, // 中奖
  lost, // 未中奖
  cancelled, // 已取消
  void_, // 无效
}

extension BetRecordExtension on BetRecord {
  String get mainTitle => options.isNotEmpty ? options.first.title : '未知比赛';
  String get matchName => options.map((o) => o.title).join(', ');
  double get totalOdds {
    if (options.isEmpty) return 0;
    if (betType == BetType.single) return options.first.odds;
    return options.fold(1.0, (acc, opt) => acc * opt.odds);
  }

  double get potentialWinnings => amount * totalOdds;
  double get profit => (winAmount ?? 0.0) - amount;
}

extension BetStatusExtension on BetStatus {
  String get displayName {
    switch (this) {
      case BetStatus.pending:
        return '进行中';
      case BetStatus.won:
        return '已中奖';
      case BetStatus.lost:
        return '未中奖';
      case BetStatus.cancelled:
        return '已取消';
      case BetStatus.void_:
        return '无效';
    }
  }
}

class BetStatistics {
  final double todayBetAmount;
  final double todayProfit;
  final double winRate;
  final double totalProfit;

  BetStatistics({
    this.todayBetAmount = 0.0,
    this.todayProfit = 0.0,
    this.winRate = 0.0,
    this.totalProfit = 0.0,
  });
}