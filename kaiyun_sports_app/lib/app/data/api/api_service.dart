import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_certificate_pinning/dio_certificate_pinning.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';
import '../../providers/auth_provider.dart';
import '../services/secure_storage_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();
  
  late Dio _dio;
  AuthProvider? _authProvider;
  Timer? _tokenRefreshTimer;
  bool _isRefreshing = false;
  List<RequestOptions> _pendingRequests = [];
  
  // 缓存配置
  final _cacheOptions = CacheOptions(
    store: MemCacheStore(),
    policy: CachePolicy.request,
    hitCacheOnErrorExcept: [401, 403],
    maxStale: const Duration(days: 7),
    priority: CachePriority.normal,
    cipher: null,
    keyBuilder: CacheOptions.defaultCacheKeyBuilder,
    allowPostMethod: false,
  );
  
  void init({AuthProvider? authProvider}) {
    _authProvider = authProvider;
    _initializeDio();
    _setupInterceptors();
    _startTokenRefreshTimer();
  }
  
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: Duration(milliseconds: ApiConfig.connectTimeout),
      receiveTimeout: Duration(milliseconds: ApiConfig.receiveTimeout),
      sendTimeout: Duration(milliseconds: ApiConfig.sendTimeout),
      headers: ApiConfig.headers,
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
  }
  
  void _setupInterceptors() {
    // 网络连接检查拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final connectivityResult = await Connectivity().checkConnectivity();
        if (connectivityResult == ConnectivityResult.none) {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: '网络连接不可用',
              type: DioExceptionType.connectionError,
            ),
          );
        }
        handler.next(options);
      },
    ));
    
    // 缓存拦截器
    _dio.interceptors.add(DioCacheInterceptor(options: _cacheOptions));
    
    // SSL证书固定（生产环境）
    if (kReleaseMode && ApiConfig.enableSSLPinning) {
      _dio.interceptors.add(
        CertificatePinningInterceptor(
          allowedSHAFingerprints: ApiConfig.allowedFingerprints,
        ),
      );
    }
    
    // 请求拦截器
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 添加设备信息
        options.headers['X-Device-Id'] = await SecureStorageService.getDeviceId();
        options.headers['X-App-Version'] = ApiConfig.appVersion;
        options.headers['X-Platform'] = Platform.isAndroid ? 'android' : 'ios';
        options.headers['X-Timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();
        
        // 添加认证Token
        if (_authProvider != null && !options.path.contains('/auth/login')) {
          final token = await _authProvider!.getAuthToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        }
        
        // 请求日志
        if (kDebugMode) {
          debugPrint('🌐 请求: ${options.method} ${options.uri}');
          if (options.data != null) {
            debugPrint('📤 请求数据: ${jsonEncode(options.data)}');
          }
        }
        
        handler.next(options);
      },
      onResponse: (response, handler) {
        // 响应日志
        if (kDebugMode) {
          debugPrint('✅ 响应: ${response.statusCode} ${response.requestOptions.uri}');
          debugPrint('📥 响应数据: ${jsonEncode(response.data)}');
        }
        
        // 统一响应格式处理
        if (response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          
          // 检查业务状态码
          final businessCode = data['code'] ?? data['status_code'];
          if (businessCode != null && businessCode != ApiConfig.successCode) {
            return handler.reject(
              DioException(
                requestOptions: response.requestOptions,
                response: response,
                error: data['message'] ?? data['msg'] ?? '请求失败',
                type: DioExceptionType.badResponse,
              ),
            );
          }
        }
        
        handler.next(response);
      },
      onError: (DioException error, handler) async {
        // 错误日志
        if (kDebugMode) {
          debugPrint('❌ 请求错误: ${error.message}');
          debugPrint('🔗 请求URL: ${error.requestOptions.uri}');
        }
        
        // Token失效处理
        if (error.response?.statusCode == ApiConfig.unauthorizedCode) {
          if (!_isRefreshing && !error.requestOptions.path.contains('/auth/')) {
            await _handleTokenExpired(error.requestOptions, handler);
            return;
          }
        }
        
        // 网络错误重试
        if (_shouldRetry(error) && _getRetryCount(error.requestOptions) < ApiConfig.maxRetryCount) {
          await _retryRequest(error.requestOptions, handler);
          return;
        }
        
        handler.next(error);
      },
    ));
    
    // 日志拦截器（仅开发环境）
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: false,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }
  
  // GET请求
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // POST请求
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // PUT请求
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // DELETE请求
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } catch (e) {
      rethrow;
    }
  }
  
  // 处理响应结果
  Map<String, dynamic> handleResponse(Response response) {
    try {
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // 验证响应数据结构
          if (!_validateResponseStructure(data)) {
            throw Exception('响应数据格式不正确');
          }
          return data;
        } else if (data is String) {
          // 尝试解析字符串响应
          try {
            final parsed = jsonDecode(data);
            if (parsed is Map<String, dynamic>) {
              return parsed;
            }
          } catch (e) {
            // 解析失败，返回包装的字符串响应
            return {
              'success': true,
              'message': '操作成功',
              'data': data,
            };
          }
        }
      }
      
      throw Exception('请求失败：${response.statusCode} - ${response.statusMessage}');
    } catch (e) {
      throw Exception('响应处理失败：$e');
    }
  }
  
  // 验证响应数据结构
  bool _validateResponseStructure(Map<String, dynamic> data) {
    // 检查是否包含必要的字段
    return data.containsKey('success') || 
           data.containsKey('code') || 
           data.containsKey('status') ||
           data.containsKey('data');
  }
  
  // 处理错误
  String handleError(dynamic error) {
    if (error is DioException) {
      // 处理业务错误
      if (error.response?.data is Map<String, dynamic>) {
        final data = error.response!.data as Map<String, dynamic>;
        final message = data['message'] ?? data['msg'] ?? data['error'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
      
      // 处理HTTP错误
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
          return '连接超时，请检查网络后重试';
        case DioExceptionType.sendTimeout:
          return '发送超时，请稍后重试';
        case DioExceptionType.receiveTimeout:
          return '接收超时，请稍后重试';
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          switch (statusCode) {
            case 400:
              return '请求参数错误';
            case 401:
              return '未授权，请重新登录';
            case 403:
              return '权限不足';
            case 404:
              return '请求的资源不存在';
            case 422:
              return '数据验证失败';
            case 429:
              return '请求过于频繁，请稍后重试';
            case 500:
              return '服务器内部错误';
            case 502:
              return '网关错误';
            case 503:
              return '服务暂时不可用';
            default:
              return '服务器错误：$statusCode';
          }
        case DioExceptionType.cancel:
          return '请求已取消';
        case DioExceptionType.connectionError:
          return '网络连接失败，请检查网络设置';
        case DioExceptionType.badCertificate:
          return '证书验证失败';
        case DioExceptionType.unknown:
          if (error.error.toString().contains('SocketException')) {
            return '网络连接失败';
          }
          return '未知错误';
        default:
          return '网络请求失败';
      }
    }
    
    if (error is FormatException) {
      return '数据格式错误：${error.message}';
    }
    
    return error.toString();
  }
  
  /// Token失效处理
  Future<void> _handleTokenExpired(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    if (_isRefreshing) {
      _pendingRequests.add(requestOptions);
      return;
    }
    
    _isRefreshing = true;
    
    try {
      if (_authProvider != null) {
        final refreshed = await _authProvider!.refreshToken();
        if (refreshed) {
          // 重发原始请求
          _retryPendingRequests();
          final token = await _authProvider!.getAuthToken();
          requestOptions.headers['Authorization'] = 'Bearer $token';
          final response = await _dio.request(
            requestOptions.path,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            ),
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
          );
          handler.resolve(response);
        } else {
          await _authProvider!.logout();
          handler.next(DioException(
            requestOptions: requestOptions,
            error: '认证失效，请重新登录',
            type: DioExceptionType.cancel,
          ));
        }
      }
    } catch (e) {
      await _authProvider?.logout();
      handler.next(DioException(
        requestOptions: requestOptions,
        error: '认证失效，请重新登录',
        type: DioExceptionType.cancel,
      ));
    } finally {
      _isRefreshing = false;
      _pendingRequests.clear();
    }
  }
  
  /// 重发待处理的请求
  void _retryPendingRequests() async {
    if (_authProvider != null) {
      final token = await _authProvider!.getAuthToken();
      for (final requestOptions in _pendingRequests) {
        requestOptions.headers['Authorization'] = 'Bearer $token';
        _dio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
          ),
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );
      }
    }
  }
  
  /// 判断是否需要重试
  bool _shouldRetry(DioException error) {
    return error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           (error.type == DioExceptionType.connectionError && error.error is SocketException);
  }
  
  /// 获取重试次数
  int _getRetryCount(RequestOptions options) {
    return (options.extra['retry_count'] as int?) ?? 0;
  }
  
  /// 重试请求
  Future<void> _retryRequest(
    RequestOptions requestOptions,
    ErrorInterceptorHandler handler,
  ) async {
    final retryCount = _getRetryCount(requestOptions);
    final delay = Duration(milliseconds: ApiConfig.retryDelay * (retryCount + 1));
    
    await Future.delayed(delay);
    
    requestOptions.extra['retry_count'] = retryCount + 1;
    
    try {
      final response = await _dio.request(
        requestOptions.path,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          extra: requestOptions.extra,
        ),
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );
      handler.resolve(response);
    } catch (e) {
      handler.next(e as DioException);
    }
  }
  
  /// 启动Token定时刷新
  void _startTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = Timer.periodic(Duration(minutes: ApiConfig.tokenRefreshInterval), (timer) async {
      if (_authProvider != null && await _authProvider!.getAuthToken() != null) {
        try {
          await _authProvider!.refreshToken();
        } catch (e) {
          debugPrint('Token自动刷新失败: $e');
        }
      }
    });
  }
  
  /// 停止Token刷新定时器
  void stopTokenRefreshTimer() {
    _tokenRefreshTimer?.cancel();
    _tokenRefreshTimer = null;
  }
  
  /// 清除缓存
  Future<void> clearCache() async {
    await _cacheOptions.store?.clean();
  }
  
  /// 设置网络监听
  void setupNetworkListener() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        debugPrint('网络已连接: $result');
        // 重试待处理的请求
        _retryPendingRequests();
      } else {
        debugPrint('网络连接断开');
      }
    });
  }
  
  /// 销毁资源
  void dispose() {
    stopTokenRefreshTimer();
    _dio.close();
  }
}