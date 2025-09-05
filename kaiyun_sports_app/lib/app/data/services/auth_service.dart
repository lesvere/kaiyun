import '../api/api_service.dart';
import '../api/api_config.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  
  // 登录
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiService.post(
        ApiConfig.login,
        data: {
          'username': username,
          'password': password,
        },
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'token': result['token'] ?? '',
        'user': result['user'] ?? {},
        'message': result['message'] ?? '登录成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  // 注册
  Future<Map<String, dynamic>> register(
    String username, 
    String password, 
    String email,
  ) async {
    try {
      final response = await _apiService.post(
        ApiConfig.register,
        data: {
          'username': username,
          'password': password,
          'email': email,
        },
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'message': result['message'] ?? '注册成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  // 退出登录
  Future<Map<String, dynamic>> logout() async {
    try {
      final response = await _apiService.post(ApiConfig.logout);
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'message': result['message'] ?? '退出成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  // 刷新Token
  Future<Map<String, dynamic>> refreshToken() async {
    try {
      final response = await _apiService.post(ApiConfig.refreshToken);
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'token': result['token'] ?? '',
        'message': result['message'] ?? 'Token刷新成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  // 获取用户资料
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final response = await _apiService.get(ApiConfig.userProfile);
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'user': result['user'] ?? {},
        'message': result['message'] ?? '获取成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  // 获取用户余额
  Future<Map<String, dynamic>> getUserBalance() async {
    try {
      final response = await _apiService.get(ApiConfig.userBalance);
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'balance': result['balance'] ?? 0.0,
        'message': result['message'] ?? '获取成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
}