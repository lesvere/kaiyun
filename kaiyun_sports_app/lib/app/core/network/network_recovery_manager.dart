import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../offline/offline_data_manager.dart';
import '../../data/api/api_service.dart';

/// 网络恢复管理器
class NetworkRecoveryManager {
  static final NetworkRecoveryManager _instance = NetworkRecoveryManager._internal();
  factory NetworkRecoveryManager() => _instance;
  NetworkRecoveryManager._internal();
  
  final ApiService _apiService = ApiService();
  final OfflineDataManager _offlineManager = OfflineDataManager();
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _recoveryTimer;
  Timer? _healthCheckTimer;
  
  bool _isRecovering = false;
  bool _isOnline = true;
  DateTime? _lastOfflineTime;
  int _recoveryAttempts = 0;
  
  final StreamController<NetworkRecoveryEvent> _eventController = 
      StreamController<NetworkRecoveryEvent>.broadcast();
  
  // 配置
  static const Duration healthCheckInterval = Duration(seconds: 30);
  static const Duration recoveryRetryInterval = Duration(seconds: 5);
  static const int maxRecoveryAttempts = 10;
  static const List<String> testUrls = [
    'https://www.google.com',
    'https://www.baidu.com',
    'https://httpbin.org/status/200',
  ];
  
  /// 事件流
  Stream<NetworkRecoveryEvent> get eventStream => _eventController.stream;
  
  /// 是否在线
  bool get isOnline => _isOnline;
  
  /// 是否正在恢复
  bool get isRecovering => _isRecovering;
  
  /// 最后一次离线时间
  DateTime? get lastOfflineTime => _lastOfflineTime;
  
  /// 初始化网络恢复管理器
  Future<void> initialize() async {
    try {
      // 初始化离线数据管理器
      await _offlineManager.initialize();
      
      // 检查初始网络状态
      await _checkInitialNetworkStatus();
      
      // 启动网络监听
      _startNetworkMonitoring();
      
      // 启动健康检查
      _startHealthCheck();
      
      if (kDebugMode) {
        debugPrint('🔄 网络恢复管理器初始化完成');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 网络恢复管理器初始化失败: $e');
      }
    }
  }
  
  /// 检查初始网络状态
  Future<void> _checkInitialNetworkStatus() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    final hasInternet = await _testInternetConnectivity();
    
    _isOnline = connectivityResult != ConnectivityResult.none && hasInternet;
    
    if (!_isOnline) {
      _lastOfflineTime = DateTime.now();
      _eventController.add(NetworkRecoveryEvent(
        type: NetworkRecoveryEventType.offline,
        message: '检测到网络离线',
      ));
    } else {
      _eventController.add(NetworkRecoveryEvent(
        type: NetworkRecoveryEventType.online,
        message: '网络连接正常',
      ));
    }
  }
  
  /// 启动网络监听
  void _startNetworkMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }
  
  /// 网络状态变化处理
  void _onConnectivityChanged(ConnectivityResult result) async {
    if (kDebugMode) {
      debugPrint('🔄 网络状态变化: $result');
    }
    
    if (result == ConnectivityResult.none) {
      await _handleNetworkOffline();
    } else {
      // 等待一下再检查，避免连接不稳定
      await Future.delayed(const Duration(seconds: 2));
      
      final hasInternet = await _testInternetConnectivity();
      if (hasInternet) {
        await _handleNetworkOnline();
      } else {
        await _handleNetworkOffline();
      }
    }
  }
  
  /// 处理网络离线
  Future<void> _handleNetworkOffline() async {
    if (_isOnline) {
      _isOnline = false;
      _lastOfflineTime = DateTime.now();
      _recoveryAttempts = 0;
      
      _eventController.add(NetworkRecoveryEvent(
        type: NetworkRecoveryEventType.offline,
        message: '网络连接中断',
      ));
      
      if (kDebugMode) {
        debugPrint('🚫 网络已离线');
      }
    }
  }
  
  /// 处理网络上线
  Future<void> _handleNetworkOnline() async {
    if (!_isOnline) {
      _isOnline = true;
      
      _eventController.add(NetworkRecoveryEvent(
        type: NetworkRecoveryEventType.online,
        message: '网络连接恢复',
      ));
      
      if (kDebugMode) {
        debugPrint('✅ 网络已恢复');
      }
      
      // 开始数据恢复
      await _startDataRecovery();
    }
  }
  
  /// 开始数据恢复
  Future<void> _startDataRecovery() async {
    if (_isRecovering) {
      return;
    }
    
    _isRecovering = true;
    
    try {
      _eventController.add(NetworkRecoveryEvent(
        type: NetworkRecoveryEventType.recoveryStarted,
        message: '开始数据恢复',
      ));
      
      // 处理待处理请求
      await _processPendingRequests();
      
      // 清理过期数据
      await _offlineManager.cleanExpiredData();
      
      _eventController.add(NetworkRecoveryEvent(
        type: NetworkRecoveryEventType.recoveryCompleted,
        message: '数据恢复完成',
      ));
      
      if (kDebugMode) {
        debugPrint('✅ 数据恢复完成');
      }
    } catch (e) {
      _eventController.add(NetworkRecoveryEvent(
        type: NetworkRecoveryEventType.recoveryFailed,
        message: '数据恢复失败: $e',
        error: e,
      ));
      
      if (kDebugMode) {
        debugPrint('❌ 数据恢复失败: $e');
      }
    } finally {
      _isRecovering = false;
    }
  }
  
  /// 处理待处理请求
  Future<void> _processPendingRequests() async {
    final pendingRequests = _offlineManager.getPendingRequests();
    
    if (pendingRequests.isEmpty) {
      return;
    }
    
    if (kDebugMode) {
      debugPrint('🔄 开始处理 ${pendingRequests.length} 个待处理请求');
    }
    
    // 按优先级和时间排序
    pendingRequests.sort((a, b) {
      final priorityCompare = b.priority.compareTo(a.priority);
      if (priorityCompare != 0) return priorityCompare;
      return a.createdAt.compareTo(b.createdAt);
    });
    
    int successCount = 0;
    int failedCount = 0;
    
    for (final request in pendingRequests) {
      try {
        await _executeOfflineRequest(request);
        await _offlineManager.removePendingRequest(request.id);
        successCount++;
        
        if (kDebugMode) {
          debugPrint('✅ 待处理请求执行成功: ${request.id}');
        }
        
        // 防止过快发送请求
        await Future.delayed(const Duration(milliseconds: 100));
      } catch (e) {
        failedCount++;
        
        if (request.currentRetries < request.maxRetries) {
          // 重试
          final retryRequest = request.copyWithRetry();
          await _offlineManager.removePendingRequest(request.id);
          await _offlineManager.addPendingRequest(retryRequest);
          
          if (kDebugMode) {
            debugPrint('🔄 待处理请求将重试: ${request.id}');
          }
        } else {
          // 放弃
          await _offlineManager.removePendingRequest(request.id);
          
          if (kDebugMode) {
            debugPrint('❌ 待处理请求执行失败: ${request.id}');
          }
        }
      }
    }
    
    _eventController.add(NetworkRecoveryEvent(
      type: NetworkRecoveryEventType.requestsProcessed,
      message: '待处理请求处理完成: 成功 $successCount, 失败 $failedCount',
      data: {
        'success': successCount,
        'failed': failedCount,
        'total': pendingRequests.length,
      },
    ));
  }
  
  /// 执行离线请求
  Future<void> _executeOfflineRequest(OfflineRequest request) async {
    switch (request.method.toUpperCase()) {
      case 'GET':
        await _apiService.get(
          request.url,
          queryParameters: request.queryParameters,
        );
        break;
      case 'POST':
        await _apiService.post(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
        );
        break;
      case 'PUT':
        await _apiService.put(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
        );
        break;
      case 'DELETE':
        await _apiService.delete(
          request.url,
          data: request.data,
          queryParameters: request.queryParameters,
        );
        break;
      default:
        throw Exception('不支持的HTTP方法: ${request.method}');
    }
  }
  
  /// 启动健康检查
  void _startHealthCheck() {
    _healthCheckTimer = Timer.periodic(healthCheckInterval, (_) {
      _performHealthCheck();
    });
  }
  
  /// 执行健康检查
  Future<void> _performHealthCheck() async {
    if (_isRecovering) {
      return;
    }
    
    final hasInternet = await _testInternetConnectivity();
    
    if (!_isOnline && hasInternet) {
      // 网络恢复
      await _handleNetworkOnline();
    } else if (_isOnline && !hasInternet) {
      // 网络断开
      await _handleNetworkOffline();
    }
  }
  
  /// 测试互联网连接
  Future<bool> _testInternetConnectivity() async {
    for (final url in testUrls) {
      try {
        final socket = await Socket.connect(
          Uri.parse(url).host, 
          80,
          timeout: const Duration(seconds: 5),
        );
        socket.destroy();
        return true;
      } catch (e) {
        // 尝试下一个URL
        continue;
      }
    }
    return false;
  }
  
  /// 手动触发恢复
  Future<void> triggerRecovery() async {
    if (_isRecovering) {
      return;
    }
    
    if (kDebugMode) {
      debugPrint('🔄 手动触发网络恢复');
    }
    
    final hasInternet = await _testInternetConnectivity();
    if (hasInternet) {
      _isOnline = true;
      await _startDataRecovery();
    } else {
      _eventController.add(NetworkRecoveryEvent(
        type: NetworkRecoveryEventType.recoveryFailed,
        message: '无法连接到互联网',
      ));
    }
  }
  
  /// 获取网络状态
  NetworkStatus getNetworkStatus() {
    return NetworkStatus(
      isOnline: _isOnline,
      isRecovering: _isRecovering,
      lastOfflineTime: _lastOfflineTime,
      recoveryAttempts: _recoveryAttempts,
      pendingRequestsCount: _offlineManager.getPendingRequests().length,
    );
  }
  
  /// 销毁资源
  void dispose() {
    _connectivitySubscription?.cancel();
    _recoveryTimer?.cancel();
    _healthCheckTimer?.cancel();
    _eventController.close();
  }
}

/// 网络恢复事件
class NetworkRecoveryEvent {
  final NetworkRecoveryEventType type;
  final String message;
  final dynamic data;
  final dynamic error;
  final DateTime timestamp;
  
  NetworkRecoveryEvent({
    required this.type,
    required this.message,
    this.data,
    this.error,
  }) : timestamp = DateTime.now();
}

/// 网络恢复事件类型
enum NetworkRecoveryEventType {
  online,
  offline,
  recoveryStarted,
  recoveryCompleted,
  recoveryFailed,
  requestsProcessed,
}

/// 网络状态
class NetworkStatus {
  final bool isOnline;
  final bool isRecovering;
  final DateTime? lastOfflineTime;
  final int recoveryAttempts;
  final int pendingRequestsCount;
  
  NetworkStatus({
    required this.isOnline,
    required this.isRecovering,
    this.lastOfflineTime,
    required this.recoveryAttempts,
    required this.pendingRequestsCount,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'isOnline': isOnline,
      'isRecovering': isRecovering,
      'lastOfflineTime': lastOfflineTime?.toIso8601String(),
      'recoveryAttempts': recoveryAttempts,
      'pendingRequestsCount': pendingRequestsCount,
    };
  }
  
  @override
  String toString() {
    return 'NetworkStatus(online: $isOnline, recovering: $isRecovering, pending: $pendingRequestsCount)';
  }
}