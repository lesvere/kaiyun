import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'error_types.dart';

/// 重试配置
class RetryConfig {
  final int maxAttempts;          // 最大重试次数
  final Duration baseDelay;       // 基础延迟时间
  final Duration maxDelay;        // 最大延迟时间
  final double multiplier;        // 延迟倍数
  final double jitter;            // 抖动因子
  final bool exponentialBackoff; // 是否使用指数退避
  final List<ErrorType> retryableErrors; // 可重试的错误类型
  
  const RetryConfig({
    this.maxAttempts = 3,
    this.baseDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 30),
    this.multiplier = 2.0,
    this.jitter = 0.1,
    this.exponentialBackoff = true,
    this.retryableErrors = const [
      ErrorType.connectionTimeout,
      ErrorType.receiveTimeout,
      ErrorType.sendTimeout,
      ErrorType.networkUnavailable,
      ErrorType.serverError,
      ErrorType.tooManyRequests,
    ],
  });
  
  /// 网络错误重试配置
  static const RetryConfig networkError = RetryConfig(
    maxAttempts: 5,
    baseDelay: Duration(milliseconds: 500),
    maxDelay: Duration(seconds: 10),
    multiplier: 1.5,
    jitter: 0.2,
  );
  
  /// 服务器错误重试配置
  static const RetryConfig serverError = RetryConfig(
    maxAttempts: 3,
    baseDelay: Duration(seconds: 2),
    maxDelay: Duration(seconds: 20),
    multiplier: 2.0,
    jitter: 0.1,
  );
  
  /// 限流错误重试配置
  static const RetryConfig rateLimitError = RetryConfig(
    maxAttempts: 5,
    baseDelay: Duration(seconds: 5),
    maxDelay: Duration(minutes: 2),
    multiplier: 2.0,
    jitter: 0.3,
  );
}

/// 重试策略
class RetryStrategy {
  final Random _random = Random();
  
  /// 执行重试逻辑
  Future<T> retry<T>(
    Future<T> Function() operation, {
    RetryConfig? config,
    bool Function(dynamic error)? shouldRetry,
  }) async {
    config ??= const RetryConfig();
    int attemptCount = 0;
    dynamic lastError;
    
    while (attemptCount < config.maxAttempts) {
      try {
        if (kDebugMode && attemptCount > 0) {
          debugPrint('🔄 重试操作，第 ${attemptCount + 1} 次尝试');
        }
        
        final result = await operation();
        
        if (attemptCount > 0 && kDebugMode) {
          debugPrint('✅ 重试成功，共尝试 ${attemptCount + 1} 次');
        }
        
        return result;
      } catch (error) {
        lastError = error;
        attemptCount++;
        
        if (kDebugMode) {
          debugPrint('❌ 第 $attemptCount 次尝试失败: $error');
        }
        
        // 检查是否应该重试
        if (attemptCount >= config.maxAttempts) {
          if (kDebugMode) {
            debugPrint('🚫 达到最大重试次数，重试失败');
          }
          break;
        }
        
        // 使用自定义重试条件或默认条件
        if (shouldRetry != null) {
          if (!shouldRetry(error)) {
            if (kDebugMode) {
              debugPrint('🚫 错误不可重试: $error');
            }
            break;
          }
        } else if (!_shouldRetryError(error, config)) {
          if (kDebugMode) {
            debugPrint('🚫 错误类型不在重试范围内: $error');
          }
          break;
        }
        
        // 计算延迟时间
        final delay = _calculateDelay(attemptCount, config);
        
        if (kDebugMode) {
          debugPrint('⏳ 等待 ${delay.inMilliseconds}ms 后重试');
        }
        
        await Future.delayed(delay);
      }
    }
    
    // 所有重试都失败，抛出最后一个错误
    throw lastError;
  }
  
  /// 判断错误是否可重试
  bool _shouldRetryError(dynamic error, RetryConfig config) {
    if (error is AppError) {
      return error.retryable && config.retryableErrors.contains(error.type);
    }
    
    // 对于非AppError，使用默认规则
    return _isRetryableException(error);
  }
  
  /// 判断异常是否可重试
  bool _isRetryableException(dynamic error) {
    // 网络相关异常通常可以重试
    if (error.toString().contains('SocketException') ||
        error.toString().contains('TimeoutException') ||
        error.toString().contains('Connection') ||
        error.toString().contains('timeout')) {
      return true;
    }
    
    return false;
  }
  
  /// 计算延迟时间
  Duration _calculateDelay(int attemptCount, RetryConfig config) {
    Duration delay;
    
    if (config.exponentialBackoff) {
      // 指数退避
      final exponentialDelay = config.baseDelay.inMilliseconds * 
          pow(config.multiplier, attemptCount - 1).toInt();
      delay = Duration(milliseconds: exponentialDelay);
    } else {
      // 线性退避
      delay = Duration(
        milliseconds: config.baseDelay.inMilliseconds * attemptCount,
      );
    }
    
    // 限制最大延迟时间
    if (delay > config.maxDelay) {
      delay = config.maxDelay;
    }
    
    // 添加抖动，避免雷群效应
    if (config.jitter > 0) {
      final jitterRange = delay.inMilliseconds * config.jitter;
      final jitterValue = (jitterRange * 2 * _random.nextDouble()) - jitterRange;
      delay = Duration(
        milliseconds: (delay.inMilliseconds + jitterValue).round(),
      );
    }
    
    // 确保延迟时间不小于0
    if (delay.inMilliseconds < 0) {
      delay = Duration.zero;
    }
    
    return delay;
  }
  
  /// 创建错误特定的重试配置
  RetryConfig getConfigForError(dynamic error) {
    if (error is AppError) {
      switch (error.type) {
        case ErrorType.networkUnavailable:
        case ErrorType.connectionTimeout:
          return RetryConfig.networkError;
        case ErrorType.serverError:
          return RetryConfig.serverError;
        case ErrorType.tooManyRequests:
          return RetryConfig.rateLimitError;
        default:
          return const RetryConfig();
      }
    }
    
    return const RetryConfig();
  }
  
  /// 异步重试包装器
  Future<T> wrap<T>(
    Future<T> Function() operation, {
    RetryConfig? config,
  }) async {
    return await retry(operation, config: config);
  }
  
  /// 带条件的重试
  Future<T> retryIf<T>(
    Future<T> Function() operation,
    bool Function(dynamic error) condition, {
    RetryConfig? config,
  }) async {
    return await retry(
      operation,
      config: config,
      shouldRetry: condition,
    );
  }
  
  /// 重试直到成功或条件不满足
  Future<T> retryUntil<T>(
    Future<T> Function() operation,
    bool Function(T result) condition, {
    RetryConfig? config,
    Duration? timeout,
  }) async {
    config ??= const RetryConfig();
    final stopwatch = Stopwatch()..start();
    
    return await retry<T>(() async {
      // 检查超时
      if (timeout != null && stopwatch.elapsed > timeout) {
        throw TimeoutException('重试超时', timeout);
      }
      
      final result = await operation();
      
      // 检查结果是否满足条件
      if (!condition(result)) {
        throw Exception('结果不满足条件，继续重试');
      }
      
      return result;
    }, config: config);
  }
}