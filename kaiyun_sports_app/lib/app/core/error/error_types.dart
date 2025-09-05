/// 应用错误类型定义
enum ErrorType {
  // 网络相关错误
  networkUnavailable,     // 网络不可用
  connectionTimeout,      // 连接超时
  sendTimeout,           // 发送超时
  receiveTimeout,        // 接收超时
  sslError,              // SSL错误
  
  // HTTP状态错误
  badRequest,            // 400 - 请求错误
  unauthorized,          // 401 - 未授权
  forbidden,             // 403 - 禁止访问
  notFound,              // 404 - 未找到
  tooManyRequests,       // 429 - 请求过多
  serverError,           // 5xx - 服务器错误
  clientError,           // 4xx - 客户端错误
  
  // 应用逻辑错误
  dataFormat,            // 数据格式错误
  businessLogic,         // 业务逻辑错误
  validation,            // 数据验证错误
  
  // 系统错误
  timeout,               // 通用超时
  requestCancelled,      // 请求取消
  unknown,               // 未知错误
}

/// 应用错误类
class AppError extends Error {
  final ErrorType type;
  final String message;
  final dynamic originalError;
  final int? statusCode;
  final bool isRecoverable;
  final bool retryable;
  final bool requiresAuth;
  final int retryCount;
  final Map<String, dynamic>? extras;
  
  AppError({
    required this.type,
    required this.message,
    this.originalError,
    this.statusCode,
    this.isRecoverable = false,
    this.retryable = false,
    this.requiresAuth = false,
    this.retryCount = 0,
    this.extras,
  });
  
  @override
  String toString() {
    return 'AppError(type: $type, message: $message, statusCode: $statusCode)';
  }
  
  /// 复制并更新重试次数
  AppError copyWithRetryCount(int newRetryCount) {
    return AppError(
      type: type,
      message: message,
      originalError: originalError,
      statusCode: statusCode,
      isRecoverable: isRecoverable,
      retryable: retryable,
      requiresAuth: requiresAuth,
      retryCount: newRetryCount,
      extras: extras,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'message': message,
      'statusCode': statusCode,
      'isRecoverable': isRecoverable,
      'retryable': retryable,
      'requiresAuth': requiresAuth,
      'retryCount': retryCount,
      'extras': extras,
    };
  }
  
  /// 从JSON创建
  static AppError fromJson(Map<String, dynamic> json) {
    return AppError(
      type: ErrorType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ErrorType.unknown,
      ),
      message: json['message'] ?? '未知错误',
      statusCode: json['statusCode'],
      isRecoverable: json['isRecoverable'] ?? false,
      retryable: json['retryable'] ?? false,
      requiresAuth: json['requiresAuth'] ?? false,
      retryCount: json['retryCount'] ?? 0,
      extras: json['extras'],
    );
  }
}

/// 业务逻辑错误
class BusinessError extends AppError {
  final String errorCode;
  
  BusinessError({
    required this.errorCode,
    required super.message,
    super.originalError,
    super.extras,
  }) : super(
    type: ErrorType.businessLogic,
    isRecoverable: false,
    retryable: false,
  );
  
  @override
  String toString() {
    return 'BusinessError(code: $errorCode, message: $message)';
  }
}

/// 验证错误
class ValidationError extends AppError {
  final Map<String, List<String>> fieldErrors;
  
  ValidationError({
    required super.message,
    required this.fieldErrors,
    super.originalError,
  }) : super(
    type: ErrorType.validation,
    isRecoverable: false,
    retryable: false,
  );
  
  @override
  String toString() {
    return 'ValidationError(message: $message, fieldErrors: $fieldErrors)';
  }
}

/// 网络错误
class NetworkError extends AppError {
  final bool isOffline;
  final String? networkType;
  
  NetworkError({
    required super.type,
    required super.message,
    super.originalError,
    this.isOffline = false,
    this.networkType,
  }) : super(
    isRecoverable: true,
    retryable: true,
  );
  
  @override
  String toString() {
    return 'NetworkError(type: $type, message: $message, isOffline: $isOffline)';
  }
}