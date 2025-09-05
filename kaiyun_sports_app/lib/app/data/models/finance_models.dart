// 交易类型枚举
enum TransactionType {
  deposit, // 存款
  withdrawal, // 取款
  transfer, // 转账
  bonus, // 奖金
  refund, // 退款
  fee, // 手续费
}

// 交易状态枚举
enum TransactionStatus {
  pending, // 待处理
  processing, // 处理中
  completed, // 已完成
  failed, // 失败
  cancelled, // 已取消
}

// 支付方式枚举
enum PaymentMethod {
  bankCard, // 银行卡
  alipay, // 支付宝
  wechat, // 微信支付
  usdt, // USDT
  paypal, // PayPal
  applePay, // Apple Pay
}

// 账户余额模型
class AccountBalance {
  final double totalBalance; // 总余额
  final double availableBalance; // 可用余额
  final double frozenBalance; // 冻结余额
  final String currency; // 币种
  final DateTime lastUpdatedAt; // 最后更新时间
  
  AccountBalance({
    required this.totalBalance,
    required this.availableBalance,
    required this.frozenBalance,
    this.currency = 'CNY',
    required this.lastUpdatedAt,
  });
  
  factory AccountBalance.fromJson(Map<String, dynamic> json) {
    try {
      return AccountBalance(
        totalBalance: _parseDouble(json['total_balance'], defaultValue: 0.0),
        availableBalance: _parseDouble(json['available_balance'], defaultValue: 0.0),
        frozenBalance: _parseDouble(json['frozen_balance'], defaultValue: 0.0),
        currency: _parseString(json['currency'], defaultValue: 'CNY'),
        lastUpdatedAt: _parseDateTime(json['last_updated_at']) ?? DateTime.now(),
      );
    } catch (e) {
      throw FormatException('AccountBalance.fromJson: 数据解析失败 - $e');
    }
  }
  
  Map<String, dynamic> toJson() {
    return {
      'total_balance': totalBalance,
      'available_balance': availableBalance,
      'frozen_balance': frozenBalance,
      'currency': currency,
      'last_updated_at': lastUpdatedAt.toIso8601String(),
    };
  }
  
  // 验证余额数据的合理性
  bool validate() {
    if (totalBalance < 0 || availableBalance < 0 || frozenBalance < 0) {
      return false;
    }
    if ((availableBalance + frozenBalance - totalBalance).abs() > 0.01) {
      return false;
    }
    return true;
  }
  
  // 获取格式化的总余额
  String get formattedTotalBalance {
    return _formatCurrency(totalBalance, currency);
  }
  
  // 获取格式化的可用余额
  String get formattedAvailableBalance {
    return _formatCurrency(availableBalance, currency);
  }
  
  // 获取格式化的冻结余额
  String get formattedFrozenBalance {
    return _formatCurrency(frozenBalance, currency);
  }
  
  // 判断是否有足够的可用余额
  bool hasSufficientBalance(double amount) {
    return availableBalance >= amount;
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
  
  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
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
  
  static String _formatCurrency(double amount, String currency) {
    final symbol = currency == 'CNY' ? '¥' : '\$';
    return '$symbol${amount.toStringAsFixed(2)}';
  }
}

// 交易记录模型
class TransactionRecord {
  final String id;
  final String userId;
  final TransactionType type;
  final TransactionStatus status;
  final double amount;
  final String currency;
  final PaymentMethod? paymentMethod;
  final String? paymentAccount; // 支付账户
  final String? orderId; // 订单号
  final String? description; // 描述
  final String? remark; // 备注
  final double? fee; // 手续费
  final DateTime createdAt;
  final DateTime? processedAt;
  final Map<String, dynamic>? metadata; // 附加数据
  
  TransactionRecord({
    required this.id,
    required this.userId,
    required this.type,
    required this.status,
    required this.amount,
    this.currency = 'CNY',
    this.paymentMethod,
    this.paymentAccount,
    this.orderId,
    this.description,
    this.remark,
    this.fee,
    required this.createdAt,
    this.processedAt,
    this.metadata,
  });
  
  factory TransactionRecord.fromJson(Map<String, dynamic> json) {
    try {
      return TransactionRecord(
        id: _parseString(json['id']),
        userId: _parseString(json['user_id']),
        type: _parseTransactionType(json['type']),
        status: _parseTransactionStatus(json['status']),
        amount: _parseDouble(json['amount'], defaultValue: 0.0),
        currency: _parseString(json['currency'], defaultValue: 'CNY'),
        paymentMethod: _parsePaymentMethod(json['payment_method']),
        paymentAccount: _parseStringNullable(json['payment_account']),
        orderId: _parseStringNullable(json['order_id']),
        description: _parseStringNullable(json['description']),
        remark: _parseStringNullable(json['remark']),
        fee: _parseDoubleNullable(json['fee']),
        createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
        processedAt: _parseDateTime(json['processed_at']),
        metadata: _parseMetadata(json['metadata']),
      );
    } catch (e) {
      throw FormatException('TransactionRecord.fromJson: 数据解析失败 - $e');
    }
  }
  
  static TransactionType _parseTransactionType(dynamic value) {
    if (value == null) return TransactionType.deposit;
    if (value is String) {
      return TransactionType.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TransactionType.deposit,
      );
    }
    return TransactionType.deposit;
  }
  
  static TransactionStatus _parseTransactionStatus(dynamic value) {
    if (value == null) return TransactionStatus.pending;
    if (value is String) {
      return TransactionStatus.values.firstWhere(
        (e) => e.name == value,
        orElse: () => TransactionStatus.pending,
      );
    }
    return TransactionStatus.pending;
  }
  
  static PaymentMethod? _parsePaymentMethod(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return PaymentMethod.values.firstWhere(
        (e) => e.name == value,
        orElse: () => PaymentMethod.bankCard,
      );
    }
    return null;
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
  
  static double? _parseDoubleNullable(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
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
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.name,
      'status': status.name,
      'amount': amount,
      'currency': currency,
      'payment_method': paymentMethod?.name,
      'payment_account': paymentAccount,
      'order_id': orderId,
      'description': description,
      'remark': remark,
      'fee': fee,
      'created_at': createdAt.toIso8601String(),
      'processed_at': processedAt?.toIso8601String(),
      'metadata': metadata,
    };
  }
  
  String getTypeDisplayName() {
    switch (type) {
      case TransactionType.deposit:
        return '存款';
      case TransactionType.withdrawal:
        return '取款';
      case TransactionType.transfer:
        return '转账';
      case TransactionType.bonus:
        return '奖金';
      case TransactionType.refund:
        return '退款';
      case TransactionType.fee:
        return '手续费';
    }
  }
  
  String getStatusDisplayName() {
    switch (status) {
      case TransactionStatus.pending:
        return '待处理';
      case TransactionStatus.processing:
        return '处理中';
      case TransactionStatus.completed:
        return '已完成';
      case TransactionStatus.failed:
        return '失败';
      case TransactionStatus.cancelled:
        return '已取消';
    }
  }
  
  String getPaymentMethodDisplayName() {
    if (paymentMethod == null) return '';
    switch (paymentMethod!) {
      case PaymentMethod.bankCard:
        return '银行卡';
      case PaymentMethod.alipay:
        return '支付宝';
      case PaymentMethod.wechat:
        return '微信支付';
      case PaymentMethod.usdt:
        return 'USDT';
      case PaymentMethod.paypal:
        return 'PayPal';
      case PaymentMethod.applePay:
        return 'Apple Pay';
    }
  }
  
  // 数据验证方法
  bool validate() {
    if (id.isEmpty || userId.isEmpty) {
      return false;
    }
    if (amount <= 0) {
      return false;
    }
    if (fee != null && fee! < 0) {
      return false;
    }
    return true;
  }
  
  // 获取格式化的金额
  String get formattedAmount {
    final symbol = currency == 'CNY' ? '¥' : '\$';
    return '$symbol${amount.toStringAsFixed(2)}';
  }
  
  // 获取格式化的手续费
  String get formattedFee {
    if (fee == null || fee == 0) return '';
    final symbol = currency == 'CNY' ? '¥' : '\$';
    return '手续费: $symbol${fee!.toStringAsFixed(2)}';
  }
  
  // 获取状态颜色
  int get statusColor {
    switch (status) {
      case TransactionStatus.pending:
        return 0xFFFF9800; // 橙色
      case TransactionStatus.processing:
        return 0xFF2196F3; // 蓝色
      case TransactionStatus.completed:
        return 0xFF4CAF50; // 绿色
      case TransactionStatus.failed:
        return 0xFFF44336; // 红色
      case TransactionStatus.cancelled:
        return 0xFF9E9E9E; // 灰色
    }
  }
  
  // 获取交易类型图标
  String get typeIcon {
    switch (type) {
      case TransactionType.deposit:
        return 'add_circle';
      case TransactionType.withdrawal:
        return 'remove_circle';
      case TransactionType.transfer:
        return 'swap_horiz';
      case TransactionType.bonus:
        return 'card_giftcard';
      case TransactionType.refund:
        return 'refresh';
      case TransactionType.fee:
        return 'receipt';
    }
  }
  
  // 判断是否为收入类型
  bool get isIncome {
    return type == TransactionType.deposit || 
           type == TransactionType.bonus || 
           type == TransactionType.refund;
  }
  
  // 判断是否为支出类型
  bool get isOutcome {
    return type == TransactionType.withdrawal || 
           type == TransactionType.transfer || 
           type == TransactionType.fee;
  }
  
  // 判断交易是否成功
  bool get isSuccessful {
    return status == TransactionStatus.completed;
  }
  
  // 判断交易是否失败
  bool get isFailed {
    return status == TransactionStatus.failed || 
           status == TransactionStatus.cancelled;
  }
  
  // 判断交易是否还在处理中
  bool get isProcessing {
    return status == TransactionStatus.pending || 
           status == TransactionStatus.processing;
  }
}

// 银行卡信息模型
class BankCard {
  final String id;
  final String userId;
  final String bankName;
  final String cardNumber; // 脱敏后的卡号
  final String cardHolder; // 持卡人姓名
  final String cardType; // 卡类型（储蓄卡/信用卡）
  final bool isDefault; // 是否为默认卡
  final bool isActive; // 是否激活
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  BankCard({
    required this.id,
    required this.userId,
    required this.bankName,
    required this.cardNumber,
    required this.cardHolder,
    required this.cardType,
    this.isDefault = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });
  
  factory BankCard.fromJson(Map<String, dynamic> json) {
    try {
      return BankCard(
        id: _parseString(json['id']),
        userId: _parseString(json['user_id']),
        bankName: _parseString(json['bank_name']),
        cardNumber: _parseString(json['card_number']),
        cardHolder: _parseString(json['card_holder']),
        cardType: _parseString(json['card_type']),
        isDefault: _parseBool(json['is_default'], defaultValue: false),
        isActive: _parseBool(json['is_active'], defaultValue: true),
        createdAt: _parseDateTime(json['created_at']) ?? DateTime.now(),
        updatedAt: _parseDateTime(json['updated_at']),
      );
    } catch (e) {
      throw FormatException('BankCard.fromJson: 数据解析失败 - $e');
    }
  }
  
  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
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
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bank_name': bankName,
      'card_number': cardNumber,
      'card_holder': cardHolder,
      'card_type': cardType,
      'is_default': isDefault,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
  
  String getDisplayCardNumber() {
    if (cardNumber.length <= 8) return cardNumber;
    final prefix = cardNumber.substring(0, 4);
    final suffix = cardNumber.substring(cardNumber.length - 4);
    return '$prefix****$suffix';
  }
  
  // 数据验证方法
  bool validate() {
    if (id.isEmpty || userId.isEmpty) {
      return false;
    }
    if (bankName.isEmpty || cardNumber.isEmpty || cardHolder.isEmpty) {
      return false;
    }
    if (cardNumber.length < 16 || cardNumber.length > 19) {
      return false;
    }
    return true;
  }
  
  // 验证卡号格式
  bool isValidCardNumber() {
    // 移除空格和非数字字符
    final cleaned = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    
    // 长度检查
    if (cleaned.length < 13 || cleaned.length > 19) {
      return false;
    }
    
    // Luhn算法验证
    return _luhnCheck(cleaned);
  }
  
  // Luhn算法实现
  static bool _luhnCheck(String cardNumber) {
    int sum = 0;
    bool isEven = false;
    
    for (int i = cardNumber.length - 1; i >= 0; i--) {
      int digit = int.parse(cardNumber[i]);
      
      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit = digit ~/ 10 + digit % 10;
        }
      }
      
      sum += digit;
      isEven = !isEven;
    }
    
    return sum % 10 == 0;
  }
  
  // 获取银行卡类型图标
  String get bankIcon {
    final bankNameLower = bankName.toLowerCase();
    if (bankNameLower.contains('工商')) return 'icbc';
    if (bankNameLower.contains('建设')) return 'ccb';
    if (bankNameLower.contains('农业')) return 'abc';
    if (bankNameLower.contains('中国')) return 'boc';
    if (bankNameLower.contains('招商')) return 'cmb';
    if (bankNameLower.contains('交通')) return 'bcm';
    if (bankNameLower.contains('民生')) return 'cmbc';
    return 'bank_default';
  }
  
  // 获取银行卡类型颜色
  int get bankColor {
    final bankNameLower = bankName.toLowerCase();
    if (bankNameLower.contains('工商')) return 0xFFD32F2F; // 红色
    if (bankNameLower.contains('建设')) return 0xFF1976D2; // 蓝色
    if (bankNameLower.contains('农业')) return 0xFF388E3C; // 绿色
    if (bankNameLower.contains('中国')) return 0xFFE53935; // 红色
    if (bankNameLower.contains('招商')) return 0xFF5D4037; // 棕色
    if (bankNameLower.contains('交通')) return 0xFF7B1FA2; // 紫色
    if (bankNameLower.contains('民生')) return 0xFF00695C; // 青色
    return 0xFF757575; // 灰色
  }
  
  // 获取卡类型中文名称
  String get cardTypeDisplayName {
    switch (cardType.toLowerCase()) {
      case 'debit':
      case 'savings':
        return '储蓄卡';
      case 'credit':
        return '信用卡';
      case 'prepaid':
        return '预付卡';
      default:
        return cardType;
    }
  }
  
  // 复制卡片信息（用于编辑）
  BankCard copyWith({
    String? id,
    String? userId,
    String? bankName,
    String? cardNumber,
    String? cardHolder,
    String? cardType,
    bool? isDefault,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BankCard(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bankName: bankName ?? this.bankName,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      cardType: cardType ?? this.cardType,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// 存款请求模型
class DepositRequest {
  final double amount;
  final PaymentMethod paymentMethod;
  final String? paymentAccount;
  final String? remark;
  final Map<String, dynamic>? extraData;
  
  DepositRequest({
    required this.amount,
    required this.paymentMethod,
    this.paymentAccount,
    this.remark,
    this.extraData,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'payment_method': paymentMethod.name,
      'payment_account': paymentAccount,
      'remark': remark,
      'extra_data': extraData,
    };
  }
}

// 取款请求模型
class WithdrawalRequest {
  final double amount;
  final String bankCardId;
  final String? paymentPassword;
  final String? remark;
  
  WithdrawalRequest({
    required this.amount,
    required this.bankCardId,
    this.paymentPassword,
    this.remark,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'bank_card_id': bankCardId,
      'payment_password': paymentPassword,
      'remark': remark,
    };
  }
}

// 转账请求模型
class TransferRequest {
  final String toUserId;
  final double amount;
  final String? remark;
  final String? paymentPassword;
  
  TransferRequest({
    required this.toUserId,
    required this.amount,
    this.remark,
    this.paymentPassword,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'to_user_id': toUserId,
      'amount': amount,
      'remark': remark,
      'payment_password': paymentPassword,
    };
  }
}

// API响应模型
class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final String? errorCode;
  
  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorCode,
  });
  
  factory ApiResponse.fromJson(Map<String, dynamic> json, T Function(dynamic)? fromJsonT) {
    return ApiResponse<T>(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null && fromJsonT != null ? fromJsonT(json['data']) : json['data'],
      errorCode: json['error_code'],
    );
  }
}
