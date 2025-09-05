import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../app/data/api/api_config.dart';
import '../../../app/data/services/network_service.dart';
import 'error_types.dart';
import 'retry_strategy.dart';

/// 统一的错误处理器
class ErrorHandler {
  static final ErrorHandler _instance = ErrorHandler._internal();
  factory ErrorHandler() => _instance;
  ErrorHandler._internal();
  
  final RetryStrategy _retryStrategy = RetryStrategy();
  final NetworkService _networkService = NetworkService();
  
  /// 全局错误处理
  AppError handleError(dynamic error, [StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('🚨 错误处理器接收错误: $error');
      if (stackTrace != null) {
        debugPrint('📍 错误堆栈: $stackTrace');
      }
    }
    
    // DIO异常处理
    if (error is DioException) {
      return _handleDioException(error);
    }
    
    // Socket异常处理
    if (error is SocketException) {
      return _handleSocketException(error);
    }
    
    // 超时异常处理
    if (error is TimeoutException) {
      return _handleTimeoutException(error);
    }
    
    // 格式化异常处理
    if (error is FormatException) {
      return AppError(
        type: ErrorType.dataFormat,
        message: '数据格式错误：${error.message}',
        originalError: error,
        isRecoverable: false,
      );
    }
    
    // 通用异常处理
    return AppError(
      type: ErrorType.unknown,
      message: error.toString(),
      originalError: error,
      isRecoverable: false,
    );
  }
  
  /// 处理DIO异常
  AppError _handleDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return AppError(
          type: ErrorType.connectionTimeout,
          message: '连接超时，请检查网络后重试',
          originalError: error,
          isRecoverable: true,
          retryable: true,
          retryCount: _getRetryCount(error),
        );
        
      case DioExceptionType.sendTimeout:
        return AppError(
          type: ErrorType.sendTimeout,
          message: '发送超时，请稍后重试',
          originalError: error,
          isRecoverable: true,
          retryable: true,
          retryCount: _getRetryCount(error),
        );
        
      case DioExceptionType.receiveTimeout:
        return AppError(
          type: ErrorType.receiveTimeout,
          message: '接收超时，请稍后重试',
          originalError: error,
          isRecoverable: true,
          retryable: true,
          retryCount: _getRetryCount(error),
        );
        
      case DioExceptionType.badResponse:
        return _handleBadResponse(error);
        
      case DioExceptionType.cancel:
        return AppError(
          type: ErrorType.requestCancelled,
          message: '请求已取消',
          originalError: error,
          isRecoverable: false,
          retryable: false,
        );
        
      case DioExceptionType.connectionError:
        return AppError(
          type: ErrorType.networkUnavailable,
          message: '网络连接失败，请检查网络设置',
          originalError: error,
          isRecoverable: true,
          retryable: true,
          retryCount: _getRetryCount(error),
        );
        
      case DioExceptionType.badCertificate:
        return AppError(
          type: ErrorType.sslError,
          message: '证书验证失败',
          originalError: error,
          isRecoverable: false,
          retryable: false,
        );
        
      case DioExceptionType.unknown:
      default:
        String message = '未知网络错误';
        ErrorType type = ErrorType.unknown;
        bool retryable = false;
        
        if (error.error is SocketException) {
          message = '网络连接失败';
          type = ErrorType.networkUnavailable;
          retryable = true;
        }
        
        return AppError(
          type: type,
          message: message,
          originalError: error,
          isRecoverable: retryable,
          retryable: retryable,
          retryCount: _getRetryCount(error),
        );
    }
  }
  
  /// 处理HTTP响应错误
  AppError _handleBadResponse(DioException error) {
    final statusCode = error.response?.statusCode;
    final responseData = error.response?.data;
    
    // 提取业务错误消息
    String businessMessage = '';
    if (responseData is Map<String, dynamic>) {
      businessMessage = responseData['message'] ?? 
                       responseData['msg'] ?? 
                       responseData['error'] ?? 
                       '';
    }
    
    switch (statusCode) {
      case ApiConfig.badRequestCode:
        return AppError(
          type: ErrorType.badRequest,
          message: businessMessage.isNotEmpty ? businessMessage : '请求参数错误',
          originalError: error,
          statusCode: statusCode,
          isRecoverable: false,
          retryable: false,
        );
        
      case ApiConfig.unauthorizedCode:
        return AppError(
          type: ErrorType.unauthorized,
          message: businessMessage.isNotEmpty ? businessMessage : '未授权，请重新登录',
          originalError: error,
          statusCode: statusCode,
          isRecoverable: true,
          retryable: false,
          requiresAuth: true,
        );
        
      case ApiConfig.forbiddenCode:
        return AppError(
          type: ErrorType.forbidden,
          message: businessMessage.isNotEmpty ? businessMessage : '权限不足',
          originalError: error,
          statusCode: statusCode,
          isRecoverable: false,
          retryable: false,
        );
        
      case ApiConfig.notFoundCode:
        return AppError(
          type: ErrorType.notFound,
          message: businessMessage.isNotEmpty ? businessMessage : '请求的资源不存在',
          originalError: error,
          statusCode: statusCode,
          isRecoverable: false,
          retryable: false,
        );
        
      case ApiConfig.tooManyRequestsCode:
        return AppError(
          type: ErrorType.tooManyRequests,
          message: businessMessage.isNotEmpty ? businessMessage : '请求过于频繁，请稍后重试',
          originalError: error,
          statusCode: statusCode,
          isRecoverable: true,
          retryable: true,
          retryCount: _getRetryCount(error),
        );
        
      case ApiConfig.serverErrorCode:
      case ApiConfig.serviceUnavailableCode:
        return AppError(
          type: ErrorType.serverError,
          message: businessMessage.isNotEmpty ? businessMessage : '服务器错误，请稍后重试',
          originalError: error,
          statusCode: statusCode,
          isRecoverable: true,
          retryable: true,
          retryCount: _getRetryCount(error),
        );
        
      default:
        final isServerError = statusCode != null && statusCode >= 500;
        return AppError(
          type: isServerError ? ErrorType.serverError : ErrorType.clientError,
          message: businessMessage.isNotEmpty ? businessMessage : '请求失败：$statusCode',
          originalError: error,
          statusCode: statusCode,
          isRecoverable: isServerError,
          retryable: isServerError,
          retryCount: _getRetryCount(error),
        );
    }
  }
  
  /// 处理Socket异常
  AppError _handleSocketException(SocketException error) {
    return AppError(
      type: ErrorType.networkUnavailable,
      message: '网络连接失败：${error.message}',
      originalError: error,
      isRecoverable: true,
      retryable: true,
    );
  }
  
  /// 处理超时异常
  AppError _handleTimeoutException(TimeoutException error) {
    return AppError(
      type: ErrorType.timeout,
      message: '操作超时：${error.message}',
      originalError: error,
      isRecoverable: true,
      retryable: true,
    );
  }
  
  /// 获取重试次数
  int _getRetryCount(DioException error) {
    return (error.requestOptions.extra['retry_count'] as int?) ?? 0;
  }
  
  /// 创建重试请求
  Future<T> retryRequest<T>(
    AppError error,
    Future<T> Function() requestFunction, {
    RetryConfig? config,
  }) async {
    if (!error.retryable || !error.isRecoverable) {
      throw error;
    }
    
    return await _retryStrategy.retry(
      requestFunction,
      config: config,
    );
  }
  
  /// 检查网络状态并处理
  Future<void> handleNetworkStatus(ErrorType errorType) async {
    switch (errorType) {
      case ErrorType.networkUnavailable:
      case ErrorType.connectionTimeout:
        // 等待网络恢复
        if (!_networkService.isConnected) {
          await _networkService.waitForConnection(
            timeout: const Duration(seconds: 30),
          );
        }
        break;
      default:
        break;
    }
  }
  
  /// 创建用户友好的错误消息
  String createUserFriendlyMessage(AppError error) {
    final baseMessage = error.message;
    final suggestions = _getErrorSuggestions(error.type);
    
    if (suggestions.isNotEmpty) {
      return '$baseMessage\n\n建议：$suggestions';
    }
    
    return baseMessage;
  }
  
  /// 获取错误建议
  String _getErrorSuggestions(ErrorType errorType) {
    switch (errorType) {
      case ErrorType.networkUnavailable:
        return '请检查网络连接并确保网络正常';
      case ErrorType.connectionTimeout:
        return '请检查网络速度，尝试切换网络环境';
      case ErrorType.serverError:
        return '服务器临时维护，请稍后再试';
      case ErrorType.unauthorized:
        return '请重新登录以获取访问权限';
      case ErrorType.tooManyRequests:
        return '请稍等片刻再进行操作';
      default:
        return '';
    }
  }
  
  /// 记录错误日志
  void logError(AppError error) {
    if (kDebugMode) {
      debugPrint('📝 错误日志:');
      debugPrint('   类型: ${error.type}');
      debugPrint('   消息: ${error.message}');
      debugPrint('   状态码: ${error.statusCode}');
      debugPrint('   可重试: ${error.retryable}');
      debugPrint('   重试次数: ${error.retryCount}');
      debugPrint('   原始错误: ${error.originalError}');
    }
    
    // TODO: 在生产环境中，可以将错误发送到日志服务
    // _sendToLoggingService(error);
  }
}