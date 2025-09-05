import 'dart:async';
import 'dart:collection';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// 请求队列服务，用于管理并发请求
class RequestQueueService {
  static final RequestQueueService _instance = RequestQueueService._internal();
  factory RequestQueueService() => _instance;
  RequestQueueService._internal();
  
  final Queue<_QueuedRequest> _requestQueue = Queue<_QueuedRequest>();
  final Map<String, Timer> _pendingRequests = <String, Timer>{};
  int _currentConcurrency = 0;
  
  // 配置
  static const int maxConcurrency = 5; // 最大并发数
  static const int maxRetries = 3; // 最大重试次数
  static const Duration debounceDelay = Duration(milliseconds: 300); // 防抖延迟
  
  /// 添加请求到队列
  Future<Response> enqueue<T>(
    Future<Response> Function() requestFunction, {
    String? requestId,
    int priority = 0,
    bool debounce = false,
  }) async {
    final completer = Completer<Response>();
    final queuedRequest = _QueuedRequest(
      requestFunction: requestFunction,
      completer: completer,
      requestId: requestId ?? DateTime.now().millisecondsSinceEpoch.toString(),
      priority: priority,
      retryCount: 0,
    );
    
    // 防抖处理
    if (debounce && requestId != null) {
      _pendingRequests[requestId]?.cancel();
      _pendingRequests[requestId] = Timer(debounceDelay, () {
        _pendingRequests.remove(requestId);
        _addToQueue(queuedRequest);
      });
      return completer.future;
    }
    
    _addToQueue(queuedRequest);
    return completer.future;
  }
  
  /// 添加到队列并按优先级排序
  void _addToQueue(_QueuedRequest request) {
    // 按优先级插入队列
    final queue = _requestQueue.toList();
    queue.add(request);
    queue.sort((a, b) => b.priority.compareTo(a.priority));
    
    _requestQueue.clear();
    _requestQueue.addAll(queue);
    
    _processQueue();
  }
  
  /// 处理队列
  void _processQueue() {
    while (_currentConcurrency < maxConcurrency && _requestQueue.isNotEmpty) {
      final request = _requestQueue.removeFirst();
      _currentConcurrency++;
      
      _executeRequest(request);
    }
  }
  
  /// 执行请求
  Future<void> _executeRequest(_QueuedRequest request) async {
    try {
      if (kDebugMode) {
        debugPrint('🚀 执行请求: ${request.requestId}');
      }
      
      final response = await request.requestFunction();
      request.completer.complete(response);
      
    } catch (error) {
      if (request.retryCount < maxRetries && _shouldRetry(error)) {
        // 重试
        request.retryCount++;
        final delay = Duration(milliseconds: 1000 * request.retryCount);
        
        if (kDebugMode) {
          debugPrint('🔄 重试请求: ${request.requestId}, 第${request.retryCount}次');
        }
        
        Timer(delay, () {
          _addToQueue(request);
        });
      } else {
        // 失败
        request.completer.completeError(error);
      }
    } finally {
      _currentConcurrency--;
      _processQueue();
    }
  }
  
  /// 判断是否应该重试
  bool _shouldRetry(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.connectionError:
          return true;
        case DioExceptionType.badResponse:
          // 5xx错误可以重试
          final statusCode = error.response?.statusCode;
          return statusCode != null && statusCode >= 500;
        default:
          return false;
      }
    }
    return false;
  }
  
  /// 取消请求
  void cancelRequest(String requestId) {
    // 取消防抖定时器
    _pendingRequests[requestId]?.cancel();
    _pendingRequests.remove(requestId);
    
    // 从队列中移除
    _requestQueue.removeWhere((request) => request.requestId == requestId);
  }
  
  /// 清空队列
  void clearQueue() {
    // 取消所有防抖定时器
    for (final timer in _pendingRequests.values) {
      timer.cancel();
    }
    _pendingRequests.clear();
    
    // 清空队列
    while (_requestQueue.isNotEmpty) {
      final request = _requestQueue.removeFirst();
      request.completer.completeError(
        DioException(
          requestOptions: RequestOptions(path: ''),
          error: '请求被取消',
          type: DioExceptionType.cancel,
        ),
      );
    }
  }
  
  /// 获取队列状态
  Map<String, dynamic> getStatus() {
    return {
      'queue_size': _requestQueue.length,
      'current_concurrency': _currentConcurrency,
      'max_concurrency': maxConcurrency,
      'pending_requests': _pendingRequests.length,
    };
  }
}

/// 队列中的请求
class _QueuedRequest {
  final Future<Response> Function() requestFunction;
  final Completer<Response> completer;
  final String requestId;
  final int priority;
  int retryCount;
  
  _QueuedRequest({
    required this.requestFunction,
    required this.completer,
    required this.requestId,
    required this.priority,
    required this.retryCount,
  });
}
