import '../api/api_service.dart';
import '../api/api_config.dart';
import 'crypto_service.dart';

/// 找回密码服务
class PasswordResetService {
  final ApiService _apiService = ApiService();
  
  /// 发送密码重置验证码
  Future<Map<String, dynamic>> sendResetCode({
    required String identifier, // 邮箱或手机号
    required String type, // 'email' 或 'sms'
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.sendResetCode,
        data: {
          'identifier': identifier,
          'type': type,
          'timestamp': CryptoService.generateTimestamp(),
          'nonce': CryptoService.generateSecureToken(16),
        },
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'message': result['message'] ?? '验证码已发送',
        'expires_at': result['expires_at'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  /// 验证重置验证码
  Future<Map<String, dynamic>> verifyResetCode({
    required String identifier,
    required String code,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.verifyResetCode,
        data: {
          'identifier': identifier,
          'code': code,
          'timestamp': CryptoService.generateTimestamp(),
        },
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'reset_token': result['reset_token'] ?? '',
        'message': result['message'] ?? '验证成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  /// 重置密码
  Future<Map<String, dynamic>> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      return {
        'success': false,
        'message': '两次输入的密码不一致',
      };
    }
    
    if (!CryptoService.isPasswordStrong(newPassword)) {
      return {
        'success': false,
        'message': '密码强度不足，请包含大小写字母、数字和特殊字符',
      };
    }
    
    try {
      final response = await _apiService.post(
        ApiConfig.resetPassword,
        data: {
          'reset_token': resetToken,
          'new_password': newPassword,
          'timestamp': CryptoService.generateTimestamp(),
        },
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'message': result['message'] ?? '密码重置成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  /// 通过安全问题重置密码
  Future<Map<String, dynamic>> resetPasswordBySecurityQuestions({
    required String identifier,
    required List<Map<String, String>> answers, // [{'question_id': 'xxx', 'answer': 'xxx'}]
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      return {
        'success': false,
        'message': '两次输入的密码不一致',
      };
    }
    
    if (!CryptoService.isPasswordStrong(newPassword)) {
      return {
        'success': false,
        'message': '密码强度不足，请包含大小写字母、数字和特殊字符',
      };
    }
    
    try {
      final response = await _apiService.post(
        ApiConfig.resetPasswordByQuestions,
        data: {
          'identifier': identifier,
          'answers': answers,
          'new_password': newPassword,
          'timestamp': CryptoService.generateTimestamp(),
        },
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'message': result['message'] ?? '密码重置成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  /// 获取安全问题列表
  Future<Map<String, dynamic>> getSecurityQuestions() async {
    try {
      final response = await _apiService.get(ApiConfig.securityQuestions);
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'questions': result['questions'] ?? [],
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  /// 设置安全问题
  Future<Map<String, dynamic>> setSecurityQuestions({
    required List<Map<String, String>> questions, // [{'question_id': 'xxx', 'answer': 'xxx'}]
  }) async {
    try {
      final response = await _apiService.post(
        ApiConfig.setSecurityQuestions,
        data: {
          'questions': questions,
          'timestamp': CryptoService.generateTimestamp(),
        },
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'message': result['message'] ?? '安全问题设置成功',
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
  
  /// 检查用户是否已设置安全问题
  Future<Map<String, dynamic>> checkSecurityQuestionsStatus(String identifier) async {
    try {
      final response = await _apiService.post(
        ApiConfig.checkSecurityStatus,
        data: {
          'identifier': identifier,
        },
      );
      
      final result = _apiService.handleResponse(response);
      return {
        'success': true,
        'has_security_questions': result['has_security_questions'] ?? false,
        'questions': result['questions'] ?? [], // 只返回问题文本，不返回答案
      };
    } catch (e) {
      return {
        'success': false,
        'message': _apiService.handleError(e),
      };
    }
  }
}
