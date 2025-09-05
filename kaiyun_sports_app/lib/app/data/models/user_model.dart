class UserModel {
  final String id;
  final String username;
  final String email;
  final String? avatar;
  final int vipLevel;
  final double balance;
  final bool isVip;
  final String? phone;
  final DateTime? createdAt;
  final DateTime? lastLoginAt;
  
  UserModel({
    required this.id,
    required this.username,
    required this.email,
    this.avatar,
    this.vipLevel = 0,
    this.balance = 0.0,
    this.isVip = false,
    this.phone,
    this.createdAt,
    this.lastLoginAt,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    try {
      return UserModel(
        id: _parseString(json['id']),
        username: _parseString(json['username']),
        email: _parseString(json['email']),
        avatar: _parseStringNullable(json['avatar']),
        vipLevel: _parseInt(json['vip_level'], defaultValue: 0),
        balance: _parseDouble(json['balance'], defaultValue: 0.0),
        isVip: _parseBool(json['is_vip'], defaultValue: false),
        phone: _parseStringNullable(json['phone']),
        createdAt: _parseDateTime(json['created_at']),
        lastLoginAt: _parseDateTime(json['last_login_at']),
      );
    } catch (e) {
      throw FormatException('UserModel.fromJson: 数据解析失败 - $e');
    }
  }
  
  // 静态解析方法
  static String _parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }
  
  static String? _parseStringNullable(dynamic value) {
    if (value == null || value.toString().isEmpty) return null;
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
      // 日期解析失败时返回null
    }
    return null;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'avatar': avatar,
      'vip_level': vipLevel,
      'balance': balance,
      'is_vip': isVip,
      'phone': phone,
      'created_at': createdAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }
  
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? avatar,
    int? vipLevel,
    double? balance,
    bool? isVip,
    String? phone,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      vipLevel: vipLevel ?? this.vipLevel,
      balance: balance ?? this.balance,
      isVip: isVip ?? this.isVip,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
  
  // 数据验证方法
  bool validate() {
    if (id.isEmpty || username.isEmpty || email.isEmpty) {
      return false;
    }
    if (vipLevel < 0 || vipLevel > 5) {
      return false;
    }
    if (balance < 0) {
      return false;
    }
    return true;
  }
  
  // 格式化余额显示
  String get formattedBalance {
    return '¥${balance.toStringAsFixed(2)}';
  }
  
  // 获取头像或默认头像
  String get displayAvatar {
    return avatar?.isNotEmpty == true ? avatar! : 'assets/images/default_avatar.png';
  }
  
  // 获取显示名称
  String get displayName {
    if (username.length > 10) {
      return '${username.substring(0, 8)}...';
    }
    return username;
  }
  
  // 脱敏手机号
  String get maskedPhone {
    if (phone == null || phone!.length < 11) return phone ?? '';
    return '${phone!.substring(0, 3)}****${phone!.substring(7)}';
  }
  
  // 脱敏邮箱
  String get maskedEmail {
    final atIndex = email.indexOf('@');
    if (atIndex <= 3) return email;
    final username = email.substring(0, atIndex);
    final domain = email.substring(atIndex);
    final maskedUsername = '${username.substring(0, 2)}***${username.substring(username.length - 1)}';
    return '$maskedUsername$domain';
  }
  
  String getVipLevelName() {
    switch (vipLevel) {
      case 0:
        return '普通用户';
      case 1:
        return '青铜 VIP';
      case 2:
        return '白银 VIP';
      case 3:
        return '黄金 VIP';
      case 4:
        return '钻石 VIP';
      case 5:
        return '黑金 VIP';
      default:
        return '普通用户';
    }
  }
}