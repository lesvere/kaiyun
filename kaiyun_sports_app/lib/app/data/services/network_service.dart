import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 网络状态监听服务
class NetworkService {
  static final NetworkService _instance = NetworkService._internal();
  factory NetworkService() => _instance;
  NetworkService._internal();
  
  late StreamSubscription<ConnectivityResult> _subscription;
  ConnectivityResult _currentStatus = ConnectivityResult.none;
  final StreamController<NetworkStatus> _networkStatusController = 
      StreamController<NetworkStatus>.broadcast();
  
  /// 网络状态枚举
  enum NetworkStatus {
    connected,
    disconnected,
    slow,
    unstable,
  }
  
  /// 网络类型枚举
  enum NetworkType {
    mobile,
    wifi,
    ethernet,
    none,
  }
  
  // Getters
  ConnectivityResult get currentStatus => _currentStatus;
  Stream<NetworkStatus> get networkStatusStream => _networkStatusController.stream;
  
  /// 初始化网络监听
  Future<void> initialize() async {
    // 获取当前网络状态
    _currentStatus = await Connectivity().checkConnectivity();
    
    // 监听网络状态变化
    _subscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _onConnectivityChanged(result);
      },
    );
    
    if (kDebugMode) {
      debugPrint('🌐 网络服务已初始化，当前状态: $_currentStatus');
    }
  }
  
  /// 处理网络状态变化
  void _onConnectivityChanged(ConnectivityResult result) {
    final oldStatus = _currentStatus;
    _currentStatus = result;
    
    if (kDebugMode) {
      debugPrint('🌐 网络状态变化: $oldStatus -> $result');
    }
    
    // 发送网络状态事件
    NetworkStatus status;
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        status = NetworkStatus.connected;
        break;
      case ConnectivityResult.none:
      default:
        status = NetworkStatus.disconnected;
        break;
    }
    
    _networkStatusController.add(status);
    
    // 如果网络从断开恢复连接，检查网络质量
    if (oldStatus == ConnectivityResult.none && result != ConnectivityResult.none) {
      _checkNetworkQuality();
    }
  }
  
  /// 检查是否有网络连接
  bool get isConnected => _currentStatus != ConnectivityResult.none;
  
  /// 获取网络类型
  NetworkType get networkType {
    switch (_currentStatus) {
      case ConnectivityResult.mobile:
        return NetworkType.mobile;
      case ConnectivityResult.wifi:
        return NetworkType.wifi;
      case ConnectivityResult.ethernet:
        return NetworkType.ethernet;
      case ConnectivityResult.none:
      default:
        return NetworkType.none;
    }
  }
  
  /// 检查网络连接
  Future<bool> hasConnection() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }
  
  /// 检查网络可达性
  Future<bool> isReachable({String host = '8.8.8.8', int port = 53, Duration timeout = const Duration(seconds: 3)}) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      socket.destroy();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// 检查网络质量
  Future<void> _checkNetworkQuality() async {
    try {
      final stopwatch = Stopwatch()..start();
      final reachable = await isReachable();
      stopwatch.stop();
      
      if (reachable) {
        final latency = stopwatch.elapsedMilliseconds;
        NetworkStatus status;
        
        if (latency < 100) {
          status = NetworkStatus.connected;
        } else if (latency < 500) {
          status = NetworkStatus.slow;
        } else {
          status = NetworkStatus.unstable;
        }
        
        _networkStatusController.add(status);
        
        if (kDebugMode) {
          debugPrint('🌐 网络延迟: ${latency}ms, 状态: $status');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('🌐 网络质量检查失败: $e');
      }
    }
  }
  
  /// 获取网络状态文本
  String getStatusText() {
    switch (_currentStatus) {
      case ConnectivityResult.wifi:
        return 'WiFi已连接';
      case ConnectivityResult.mobile:
        return '移动网络已连接';
      case ConnectivityResult.ethernet:
        return '有线网络已连接';
      case ConnectivityResult.none:
      default:
        return '无网络连接';
    }
  }
  
  /// 获取网络图标
  String getNetworkIcon() {
    switch (_currentStatus) {
      case ConnectivityResult.wifi:
        return '📶';
      case ConnectivityResult.mobile:
        return '📱';
      case ConnectivityResult.ethernet:
        return '🌐';
      case ConnectivityResult.none:
      default:
        return '❌';
    }
  }
  
  /// 等待网络连接
  Future<void> waitForConnection({Duration timeout = const Duration(seconds: 30)}) async {
    if (isConnected) return;
    
    final completer = Completer<void>();
    Timer? timeoutTimer;
    StreamSubscription? subscription;
    
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.completeError(TimeoutException('等待网络连接超时', timeout));
      }
    });
    
    subscription = networkStatusStream.listen((status) {
      if (status == NetworkStatus.connected && !completer.isCompleted) {
        timeoutTimer?.cancel();
        subscription?.cancel();
        completer.complete();
      }
    });
    
    await completer.future;
  }
  
  /// 销毁资源
  void dispose() {
    _subscription.cancel();
    _networkStatusController.close();
  }
}

/// 网络状态异常
class NetworkException implements Exception {
  final String message;
  final NetworkService.NetworkStatus status;
  
  NetworkException(this.message, this.status);
  
  @override
  String toString() => 'NetworkException: $message';
}
