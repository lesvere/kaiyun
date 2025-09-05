import 'package:flutter/foundation.dart';
import '../data/api/api_service.dart';
import '../data/services/network_service.dart';
import '../data/services/request_queue_service.dart';
import '../providers/auth_provider.dart';

/// HTTP服务管理器 - 统一管理所有网络相关服务
class HttpServiceManager {
  static final HttpServiceManager _instance = HttpServiceManager._internal();
  factory HttpServiceManager() => _instance;
  HttpServiceManager._internal();
  
  late ApiService _apiService;
  late NetworkService _networkService;
  late RequestQueueService _requestQueueService;
  
  bool _isInitialized = false;
  
  // Getters
  ApiService get apiService => _apiService;
  NetworkService get networkService => _networkService;
  RequestQueueService get requestQueueService => _requestQueueService;
  bool get isInitialized => _isInitialized;
  
  /// 初始化所有网络服务
  Future<void> initialize({AuthProvider? authProvider}) async {
    if (_isInitialized) {
      debugPrint('⚠️ HTTP服务管理器已初始化');
      return;
    }
    
    try {
      debugPrint('🚀 初始化HTTP服务管理器...');
      
      // 初始化网络状态服务
      _networkService = NetworkService();
      await _networkService.initialize();
      
      // 初始化请求队列服务
      _requestQueueService = RequestQueueService();
      
      // 初始化API服务
      _apiService = ApiService();
      _apiService.init(authProvider: authProvider);
      
      // 设置网络监听
      _apiService.setupNetworkListener();
      
      _isInitialized = true;
      debugPrint('✅ HTTP服务管理器初始化完成');
      
    } catch (e) {
      debugPrint('❌ HTTP服务管理器初始化失败: $e');
      rethrow;
    }
  }
  
  /// 检查网络连接
  Future<bool> checkConnection() async {
    if (!_isInitialized) {
      throw StateError('请先初始化HTTP服务管理器');
    }
    
    return await _networkService.hasConnection();
  }
  
  /// 等待网络连接
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (!_isInitialized) {
      throw StateError('请先初始化HTTP服务管理器');
    }
    
    await _networkService.waitForConnection(timeout: timeout);
  }
  
  /// 清除缓存
  Future<void> clearCache() async {
    if (!_isInitialized) {
      throw StateError('请先初始化HTTP服务管理器');
    }
    
    await _apiService.clearCache();
  }
  
  /// 清空请求队列
  void clearRequestQueue() {
    if (!_isInitialized) {
      throw StateError('请先初始化HTTP服务管理器');
    }
    
    _requestQueueService.clearQueue();
  }
  
  /// 获取网络状态信息
  Map<String, dynamic> getNetworkStatus() {
    if (!_isInitialized) {
      return {'error': '未初始化'};
    }
    
    return {
      'network': {
        'connected': _networkService.isConnected,
        'type': _networkService.networkType.name,
        'status_text': _networkService.getStatusText(),
      },
      'request_queue': _requestQueueService.getStatus(),
    };
  }
  
  /// 重置所有服务
  Future<void> reset() async {
    if (_isInitialized) {
      _apiService.stopTokenRefreshTimer();
      _networkService.dispose();
      _requestQueueService.clearQueue();
      _isInitialized = false;
    }
  }
  
  /// 销毁所有资源
  Future<void> dispose() async {
    await reset();
    _apiService.dispose();
  }
}

/// HTTP服务状态
class HttpServiceStatus {
  final bool isInitialized;
  final bool hasNetworkConnection;
  final NetworkService.NetworkType networkType;
  final String networkStatus;
  final Map<String, dynamic> requestQueueStatus;
  
  HttpServiceStatus({
    required this.isInitialized,
    required this.hasNetworkConnection,
    required this.networkType,
    required this.networkStatus,
    required this.requestQueueStatus,
  });
  
  Map<String, dynamic> toJson() => {
    'isInitialized': isInitialized,
    'hasNetworkConnection': hasNetworkConnection,
    'networkType': networkType.name,
    'networkStatus': networkStatus,
    'requestQueueStatus': requestQueueStatus,
  };
  
  @override
  String toString() => 'HttpServiceStatus(${toJson()})';
}
