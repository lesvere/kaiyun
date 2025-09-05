import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../error/error_types.dart';
import '../error/error_handler.dart';
import '../error/retry_strategy.dart';
import '../network/network_recovery_manager.dart';
import '../offline/offline_data_manager.dart';
import 'error_display_widget.dart';

/// 错误处理和重试管理器
class ErrorRetryManager {
  static final ErrorRetryManager _instance = ErrorRetryManager._internal();
  factory ErrorRetryManager() => _instance;
  ErrorRetryManager._internal();
  
  final ErrorHandler _errorHandler = ErrorHandler();
  final RetryStrategy _retryStrategy = RetryStrategy();
  final NetworkRecoveryManager _networkRecoveryManager = NetworkRecoveryManager();
  final OfflineDataManager _offlineDataManager = OfflineDataManager();
  
  final Map<String, Timer> _activeRetryTimers = {};
  final Map<String, int> _requestRetryCount = {};
  
  bool _isInitialized = false;
  
  /// 初始化管理器
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      await _networkRecoveryManager.initialize();
      await _offlineDataManager.initialize();
      
      _isInitialized = true;
      
      if (kDebugMode) {
        debugPrint('⚙️ 错误处理和重试管理器初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 错误处理和重试管理器初始化失败: $e');
      }
    }
  }
  
  /// 处理错误并自动重试
  Future<T> handleErrorWithRetry<T>(
    Future<T> Function() operation, {
    String? requestId,
    RetryConfig? retryConfig,
    bool Function(AppError error)? shouldRetry,
    void Function(AppError error)? onError,
    BuildContext? context,
    bool showToast = true,
  }) async {
    requestId ??= DateTime.now().millisecondsSinceEpoch.toString();
    
    try {
      return await _retryStrategy.retry(
        operation,
        config: retryConfig,
        shouldRetry: (error) {
          final appError = _errorHandler.handleError(error);
          
          // 记录错误
          _errorHandler.logError(appError);
          
          // 调用错误回调
          onError?.call(appError);
          
          // 显示错误提示
          if (context != null && showToast) {
            _showErrorToast(context, appError);
          }
          
          // 检查网络状态
          _handleNetworkError(appError);
          
          // 使用自定义判断或默认判断
          if (shouldRetry != null) {
            return shouldRetry(appError);
          }
          
          return appError.retryable && appError.isRecoverable;
        },
      );
    } catch (error) {
      final appError = _errorHandler.handleError(error);
      
      // 记录最终错误
      _errorHandler.logError(appError);
      
      // 调用错误回调
      onError?.call(appError);
      
      // 显示错误提示
      if (context != null && showToast) {
        _showErrorToast(context, appError);
      }
      
      // 如果是网络错误且允许离线缓存，尝试保存请求
      if (_shouldSaveOfflineRequest(appError)) {
        await _saveOfflineRequest(requestId, operation, appError);
      }
      
      rethrow;
    }
  }
  
  /// 显示错误 Toast
  void _showErrorToast(BuildContext context, AppError error) {
    // 避免频繁显示相同错误
    final errorKey = '${error.type}_${error.statusCode}';
    if (_activeRetryTimers.containsKey(errorKey)) {
      return;
    }
    
    ErrorToast.show(
      context,
      error,
      onRetry: error.retryable ? () {
        // 触发网络恢复
        _networkRecoveryManager.triggerRecovery();
      } : null,
    );
    
    // 记录显示时间，防止重复显示
    _activeRetryTimers[errorKey] = Timer(const Duration(seconds: 5), () {
      _activeRetryTimers.remove(errorKey);
    });
  }
  
  /// 处理网络错误
  void _handleNetworkError(AppError error) {
    if (error.type == ErrorType.networkUnavailable ||
        error.type == ErrorType.connectionTimeout) {
      _errorHandler.handleNetworkStatus(error.type);
    }
  }
  
  /// 判断是否应该保存离线请求
  bool _shouldSaveOfflineRequest(AppError error) {
    return (error.type == ErrorType.networkUnavailable ||
            error.type == ErrorType.connectionTimeout) &&
           error.isRecoverable;
  }
  
  /// 保存离线请求
  Future<void> _saveOfflineRequest(
    String requestId,
    Function operation,
    AppError error,
  ) async {
    try {
      // TODO: 实现将操作保存为离线请求的逻辑
      // 这里需要根据具体的操作类型来实现
      if (kDebugMode) {
        debugPrint('💾 尝试保存离线请求: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 保存离线请求失败: $e');
      }
    }
  }
  
  /// 带缓存的请求处理
  Future<T> handleRequestWithCache<T>(
    String cacheKey,
    Future<T> Function() operation, {
    Duration? cacheExpiry,
    bool forceRefresh = false,
    BuildContext? context,
    RetryConfig? retryConfig,
  }) async {
    // 尝试从缓存获取
    if (!forceRefresh) {
      final cachedData = _offlineDataManager.getFromCache<T>(cacheKey);
      if (cachedData != null) {
        if (kDebugMode) {
          debugPrint('💾 从缓存返回数据: $cacheKey');
        }
        return cachedData;
      }
    }
    
    // 从网络获取
    try {
      final result = await handleErrorWithRetry(
        operation,
        context: context,
        retryConfig: retryConfig,
      );
      
      // 保存到缓存
      await _offlineDataManager.saveToCache(
        cacheKey,
        result,
        expiry: cacheExpiry,
      );
      
      return result;
    } catch (error) {
      // 网络失败时尝试从缓存获取过期数据
      final cachedData = _offlineDataManager.getFromCache<T>(cacheKey);
      if (cachedData != null) {
        if (kDebugMode) {
          debugPrint('💾 网络失败，使用缓存数据: $cacheKey');
        }
        return cachedData;
      }
      
      rethrow;
    }
  }
  
  /// 创建错误边界组件
  Widget createErrorBoundary({
    required Widget child,
    Widget Function(BuildContext context, AppError error)? errorBuilder,
    void Function(AppError error)? onError,
  }) {
    return _ErrorBoundary(
      child: child,
      errorBuilder: errorBuilder,
      onError: onError,
    );
  }
  
  /// 创建带重试功能的 Future 构建器
  Widget createRetryFutureBuilder<T>({
    required Future<T> future,
    required Widget Function(BuildContext context, T data) builder,
    Widget Function(BuildContext context, AppError error)? errorBuilder,
    Widget Function(BuildContext context)? loadingBuilder,
    RetryConfig? retryConfig,
  }) {
    return _RetryFutureBuilder<T>(
      future: future,
      builder: builder,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      retryConfig: retryConfig,
    );
  }
  
  /// 获取系统状态
  Map<String, dynamic> getSystemStatus() {
    return {
      'isInitialized': _isInitialized,
      'activeRetryTimers': _activeRetryTimers.length,
      'networkStatus': _networkRecoveryManager.getNetworkStatus().toJson(),
      'cacheStats': _offlineDataManager.getCacheStats().toJson(),
    };
  }
  
  /// 销毁资源
  void dispose() {
    for (final timer in _activeRetryTimers.values) {
      timer.cancel();
    }
    _activeRetryTimers.clear();
    _requestRetryCount.clear();
    
    _networkRecoveryManager.dispose();
    _offlineDataManager.dispose();
    
    _isInitialized = false;
  }
}

/// 错误边界组件
class _ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, AppError error)? errorBuilder;
  final void Function(AppError error)? onError;
  
  const _ErrorBoundary({
    required this.child,
    this.errorBuilder,
    this.onError,
  });
  
  @override
  _ErrorBoundaryState createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<_ErrorBoundary> {
  AppError? _error;
  
  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!);
      }
      
      return ErrorDisplayWidget(
        error: _error!,
        onRetry: _error!.retryable ? () {
          setState(() {
            _error = null;
          });
        } : null,
      );
    }
    
    return widget.child;
  }
  
  // 捕获Flutter框架错误
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    FlutterError.onError = (details) {
      final error = ErrorHandler().handleError(details.exception, details.stack);
      widget.onError?.call(error);
      if (mounted) {
        setState(() {
          _error = error;
        });
      }
    };
  }
}

/// 带重试功能的 Future 构建器
class _RetryFutureBuilder<T> extends StatefulWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context, AppError error)? errorBuilder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final RetryConfig? retryConfig;
  
  const _RetryFutureBuilder({
    required this.future,
    required this.builder,
    this.errorBuilder,
    this.loadingBuilder,
    this.retryConfig,
  });
  
  @override
  _RetryFutureBuilderState<T> createState() => _RetryFutureBuilderState<T>();
}

class _RetryFutureBuilderState<T> extends State<_RetryFutureBuilder<T>> {
  late Future<T> _future;
  
  @override
  void initState() {
    super.initState();
    _future = widget.future;
  }
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return widget.loadingBuilder?.call(context) ??
                 const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          final error = ErrorHandler().handleError(snapshot.error);
          
          if (widget.errorBuilder != null) {
            return widget.errorBuilder!(context, error);
          }
          
          return ErrorDisplayWidget(
            error: error,
            onRetry: error.retryable ? () {
              setState(() {
                _future = ErrorRetryManager().handleErrorWithRetry(
                  () => widget.future,
                  context: context,
                  retryConfig: widget.retryConfig,
                );
              });
            } : null,
          );
        }
        
        if (snapshot.hasData) {
          return widget.builder(context, snapshot.data!);
        }
        
        return const SizedBox.shrink();
      },
    );
  }
}