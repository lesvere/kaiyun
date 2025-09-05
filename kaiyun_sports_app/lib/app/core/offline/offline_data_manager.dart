import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../../../app/data/services/secure_storage_service.dart';
import 'error_types.dart';

/// 离线数据管理服务
class OfflineDataManager {
  static final OfflineDataManager _instance = OfflineDataManager._internal();
  factory OfflineDataManager() => _instance;
  OfflineDataManager._internal();
  
  static const String _offlineDataKey = 'offline_data';
  static const String _pendingRequestsKey = 'pending_requests';
  static const String _cacheMetadataKey = 'cache_metadata';
  
  final Map<String, dynamic> _memoryCache = {};
  final List<OfflineRequest> _pendingRequests = [];
  final StreamController<OfflineDataEvent> _eventController = 
      StreamController<OfflineDataEvent>.broadcast();
  
  /// 事件流
  Stream<OfflineDataEvent> get eventStream => _eventController.stream;
  
  /// 初始化离线数据管理器
  Future<void> initialize() async {
    try {
      await _loadOfflineData();
      await _loadPendingRequests();
      
      if (kDebugMode) {
        debugPrint('💾 离线数据管理器初始化完成');
        debugPrint('   缓存数据: ${_memoryCache.length} 条');
        debugPrint('   待处理请求: ${_pendingRequests.length} 个');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 离线数据管理器初始化失败: $e');
      }
    }
  }
  
  /// 保存数据到离线缓存
  Future<void> saveToCache(
    String key, 
    dynamic data, {
    Duration? expiry,
    bool persistToDisk = true,
  }) async {
    try {
      final cacheEntry = CacheEntry(
        key: key,
        data: data,
        timestamp: DateTime.now(),
        expiry: expiry,
      );
      
      _memoryCache[key] = cacheEntry;
      
      if (persistToDisk) {
        await _saveToStorage();
      }
      
      _eventController.add(OfflineDataEvent(
        type: OfflineDataEventType.dataCached,
        key: key,
        data: data,
      ));
      
      if (kDebugMode) {
        debugPrint('💾 数据已缓存: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 缓存数据失败: $e');
      }
    }
  }
  
  /// 从离线缓存获取数据
  T? getFromCache<T>(String key) {
    try {
      final cacheEntry = _memoryCache[key] as CacheEntry?;
      
      if (cacheEntry == null) {
        return null;
      }
      
      // 检查是否过期
      if (cacheEntry.isExpired) {
        _memoryCache.remove(key);
        _saveToStorage(); // 异步保存，不阻塞
        return null;
      }
      
      if (kDebugMode) {
        debugPrint('💾 从缓存获取数据: $key');
      }
      
      return cacheEntry.data as T;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 获取缓存数据失败: $e');
      }
      return null;
    }
  }
  
  /// 添加待处理请求
  Future<void> addPendingRequest(OfflineRequest request) async {
    try {
      _pendingRequests.add(request);
      await _savePendingRequests();
      
      _eventController.add(OfflineDataEvent(
        type: OfflineDataEventType.requestQueued,
        key: request.id,
        data: request.toJson(),
      ));
      
      if (kDebugMode) {
        debugPrint('📎 已添加待处理请求: ${request.id}');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 添加待处理请求失败: $e');
      }
    }
  }
  
  /// 获取所有待处理请求
  List<OfflineRequest> getPendingRequests() {
    return List.from(_pendingRequests);
  }
  
  /// 移除待处理请求
  Future<void> removePendingRequest(String requestId) async {
    try {
      _pendingRequests.removeWhere((req) => req.id == requestId);
      await _savePendingRequests();
      
      _eventController.add(OfflineDataEvent(
        type: OfflineDataEventType.requestProcessed,
        key: requestId,
      ));
      
      if (kDebugMode) {
        debugPrint('🗑️ 已移除待处理请求: $requestId');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 移除待处理请求失败: $e');
      }
    }
  }
  
  /// 清理过期数据
  Future<void> cleanExpiredData() async {
    try {
      final keysToRemove = <String>[];
      
      for (final entry in _memoryCache.entries) {
        if (entry.value is CacheEntry && 
            (entry.value as CacheEntry).isExpired) {
          keysToRemove.add(entry.key);
        }
      }
      
      for (final key in keysToRemove) {
        _memoryCache.remove(key);
      }
      
      if (keysToRemove.isNotEmpty) {
        await _saveToStorage();
        
        _eventController.add(OfflineDataEvent(
          type: OfflineDataEventType.dataExpired,
          data: keysToRemove,
        ));
        
        if (kDebugMode) {
          debugPrint('🧽 已清理过期数据: ${keysToRemove.length} 条');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 清理过期数据失败: $e');
      }
    }
  }
  
  /// 清理所有离线数据
  Future<void> clearAllData() async {
    try {
      _memoryCache.clear();
      _pendingRequests.clear();
      
      await SecureStorageService.deleteKey(_offlineDataKey);
      await SecureStorageService.deleteKey(_pendingRequestsKey);
      await SecureStorageService.deleteKey(_cacheMetadataKey);
      
      _eventController.add(OfflineDataEvent(
        type: OfflineDataEventType.dataCleared,
      ));
      
      if (kDebugMode) {
        debugPrint('🧽 已清理所有离线数据');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 清理离线数据失败: $e');
      }
    }
  }
  
  /// 获取缓存统计信息
  CacheStats getCacheStats() {
    int totalEntries = _memoryCache.length;
    int expiredEntries = 0;
    int totalSize = 0;
    
    for (final entry in _memoryCache.values) {
      if (entry is CacheEntry) {
        if (entry.isExpired) {
          expiredEntries++;
        }
        totalSize += _estimateSize(entry.data);
      }
    }
    
    return CacheStats(
      totalEntries: totalEntries,
      expiredEntries: expiredEntries,
      pendingRequests: _pendingRequests.length,
      estimatedSize: totalSize,
    );
  }
  
  /// 估算数据大小
  int _estimateSize(dynamic data) {
    try {
      return jsonEncode(data).length * 2; // 粗略估算UTF-8字节数
    } catch (e) {
      return 0;
    }
  }
  
  /// 从存储加载离线数据
  Future<void> _loadOfflineData() async {
    try {
      final data = await SecureStorageService.getValue(_offlineDataKey);
      if (data != null) {
        final jsonData = jsonDecode(data) as Map<String, dynamic>;
        
        for (final entry in jsonData.entries) {
          try {
            _memoryCache[entry.key] = CacheEntry.fromJson(entry.value);
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ 加载缓存条目失败: ${entry.key}');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 加载离线数据失败: $e');
      }
    }
  }
  
  /// 从存储加载待处理请求
  Future<void> _loadPendingRequests() async {
    try {
      final data = await SecureStorageService.getValue(_pendingRequestsKey);
      if (data != null) {
        final jsonData = jsonDecode(data) as List;
        
        _pendingRequests.clear();
        for (final item in jsonData) {
          try {
            _pendingRequests.add(OfflineRequest.fromJson(item));
          } catch (e) {
            if (kDebugMode) {
              debugPrint('❌ 加载待处理请求失败: $e');
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 加载待处理请求失败: $e');
      }
    }
  }
  
  /// 保存数据到存储
  Future<void> _saveToStorage() async {
    try {
      final jsonData = <String, dynamic>{};
      for (final entry in _memoryCache.entries) {
        if (entry.value is CacheEntry) {
          jsonData[entry.key] = (entry.value as CacheEntry).toJson();
        }
      }
      
      await SecureStorageService.saveValue(
        _offlineDataKey, 
        jsonEncode(jsonData),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 保存离线数据失败: $e');
      }
    }
  }
  
  /// 保存待处理请求
  Future<void> _savePendingRequests() async {
    try {
      final jsonData = _pendingRequests
          .map((req) => req.toJson())
          .toList();
      
      await SecureStorageService.saveValue(
        _pendingRequestsKey,
        jsonEncode(jsonData),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ 保存待处理请求失败: $e');
      }
    }
  }
  
  /// 销毁资源
  void dispose() {
    _eventController.close();
  }
}

/// 缓存条目
class CacheEntry {
  final String key;
  final dynamic data;
  final DateTime timestamp;
  final Duration? expiry;
  
  CacheEntry({
    required this.key,
    required this.data,
    required this.timestamp,
    this.expiry,
  });
  
  bool get isExpired {
    if (expiry == null) return false;
    return DateTime.now().difference(timestamp) > expiry!;
  }
  
  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiry': expiry?.inMilliseconds,
    };
  }
  
  static CacheEntry fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      key: json['key'],
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
      expiry: json['expiry'] != null 
          ? Duration(milliseconds: json['expiry'])
          : null,
    );
  }
}

/// 离线请求
class OfflineRequest {
  final String id;
  final String method;
  final String url;
  final Map<String, dynamic>? headers;
  final dynamic data;
  final Map<String, dynamic>? queryParameters;
  final DateTime createdAt;
  final int priority;
  final int maxRetries;
  final int currentRetries;
  
  OfflineRequest({
    required this.id,
    required this.method,
    required this.url,
    this.headers,
    this.data,
    this.queryParameters,
    required this.createdAt,
    this.priority = 0,
    this.maxRetries = 3,
    this.currentRetries = 0,
  });
  
  OfflineRequest copyWithRetry() {
    return OfflineRequest(
      id: id,
      method: method,
      url: url,
      headers: headers,
      data: data,
      queryParameters: queryParameters,
      createdAt: createdAt,
      priority: priority,
      maxRetries: maxRetries,
      currentRetries: currentRetries + 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'url': url,
      'headers': headers,
      'data': data,
      'queryParameters': queryParameters,
      'createdAt': createdAt.toIso8601String(),
      'priority': priority,
      'maxRetries': maxRetries,
      'currentRetries': currentRetries,
    };
  }
  
  static OfflineRequest fromJson(Map<String, dynamic> json) {
    return OfflineRequest(
      id: json['id'],
      method: json['method'],
      url: json['url'],
      headers: json['headers']?.cast<String, dynamic>(),
      data: json['data'],
      queryParameters: json['queryParameters']?.cast<String, dynamic>(),
      createdAt: DateTime.parse(json['createdAt']),
      priority: json['priority'] ?? 0,
      maxRetries: json['maxRetries'] ?? 3,
      currentRetries: json['currentRetries'] ?? 0,
    );
  }
}

/// 离线数据事件
class OfflineDataEvent {
  final OfflineDataEventType type;
  final String? key;
  final dynamic data;
  final DateTime timestamp;
  
  OfflineDataEvent({
    required this.type,
    this.key,
    this.data,
  }) : timestamp = DateTime.now();
}

/// 离线数据事件类型
enum OfflineDataEventType {
  dataCached,
  dataExpired,
  dataCleared,
  requestQueued,
  requestProcessed,
}

/// 缓存统计信息
class CacheStats {
  final int totalEntries;
  final int expiredEntries;
  final int pendingRequests;
  final int estimatedSize;
  
  CacheStats({
    required this.totalEntries,
    required this.expiredEntries,
    required this.pendingRequests,
    required this.estimatedSize,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'expiredEntries': expiredEntries,
      'pendingRequests': pendingRequests,
      'estimatedSizeKB': (estimatedSize / 1024).round(),
    };
  }
  
  @override
  String toString() {
    return 'CacheStats(total: $totalEntries, expired: $expiredEntries, pending: $pendingRequests, size: ${(estimatedSize / 1024).round()}KB)';
  }
}