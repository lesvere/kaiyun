import 'package:flutter/foundation.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import '../data/services/biometric_service.dart';
import '../data/services/crypto_service.dart';
import '../data/services/secure_storage_service.dart';
import '../data/services/password_reset_service.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;
  String? _deviceId;
  bool _biometricEnabled = false;
  bool _biometricSupported = false;
  int _loginAttempts = 0;
  bool _accountLocked = false;
  
  final AuthService _authService = AuthService();
  final PasswordResetService _resetService = PasswordResetService();
  
  // Getters
  UserModel? get user => _user;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get errorMessage => _errorMessage;
  String? get deviceId => _deviceId;
  bool get biometricEnabled => _biometricEnabled;
  bool get biometricSupported => _biometricSupported;
  int get loginAttempts => _loginAttempts;
  bool get accountLocked => _accountLocked;
  
  AuthProvider() {
    _initializeAuth();
  }
  
  /// 初始化认证系统
  Future<void> _initializeAuth() async {
    try {
      // 检查生物认证支持
      _biometricSupported = await BiometricService.isDeviceSupported() && 
                           await BiometricService.isBiometricAvailable();
      
      // 获取或生成设备ID
      _deviceId = await SecureStorageService.getDeviceId();
      if (_deviceId == null) {
        _deviceId = await _generateDeviceId();
        await SecureStorageService.saveDeviceId(_deviceId!);
      }
      
      // 检查生物认证设置
      _biometricEnabled = await SecureStorageService.isBiometricEnabled();
      
      // 检查登录状态
      await _checkLoginStatus();
      
      // 检查账户锁定状态
      _accountLocked = await SecureStorageService.isAccountLocked();
      _loginAttempts = await SecureStorageService.getLoginAttempts();
      
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Auth initialization failed: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// 生成设备ID
  Future<String> _generateDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      String identifier = '';
      
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await deviceInfo.androidInfo;
        identifier = '${androidInfo.brand}_${androidInfo.model}_${androidInfo.id}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await deviceInfo.iosInfo;
        identifier = '${iosInfo.name}_${iosInfo.model}_${iosInfo.identifierForVendor}';
      }
      
      return CryptoService.generateDeviceFingerprint();
    } catch (e) {
      return CryptoService.generateSecureToken(32);
    }
  }
  
  /// 检查登录状态
  Future<void> _checkLoginStatus() async {
    final token = await SecureStorageService.getAuthToken();
    if (token != null) {
      // 检查是否需要重新认证
      final needsReauth = await SecureStorageService.needsReauth();
      if (!needsReauth) {
        _isLoggedIn = true;
        
        // 尝试获取用户信息
        try {
          final result = await _authService.getUserProfile();
          if (result['success']) {
            _user = UserModel.fromJson(result['user']);
          }
        } catch (e) {
          debugPrint('Failed to get user profile: $e');
        }
      } else {
        // 需要重新登录
        await logout();
      }
    }
  }
  
  /// 常规登录
  Future<bool> login(String username, String password, {String? captcha}) async {
    if (_accountLocked) {
      _setError('账户已被锁定，请稍后再试');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      // 检查网络连接
      final connectivity = await Connectivity().checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw Exception('网络连接不可用');
      }
      
      final result = await _authService.login(username, password);
      if (result['success']) {
        await _handleSuccessfulLogin(result);
        _setLoading(false);
        return true;
      } else {
        await _handleFailedLogin(result['message'] ?? '登录失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      await _handleFailedLogin('网络错误，请稍后重试');
      _setLoading(false);
      return false;
    }
  }
  
  /// 生物认证登录
  Future<bool> biometricLogin() async {
    if (!_biometricSupported || !_biometricEnabled) {
      _setError('生物认证不可用');
      return false;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final authenticated = await BiometricService.authenticate(
        reason: '请进行生物认证以登录开云体育',
      );
      
      if (authenticated) {
        // 获取存储的登录信息
        final token = await SecureStorageService.getAuthToken();
        if (token != null) {
          final result = await _authService.getUserProfile();
          if (result['success']) {
            _user = UserModel.fromJson(result['user']);
            _isLoggedIn = true;
            await SecureStorageService.saveLastLoginTime();
            _setLoading(false);
            return true;
          }
        }
      }
      
      _setError('生物认证失败');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }
  
  /// PIN码登录
  Future<bool> pinLogin(String pin) async {
    _setLoading(true);
    _clearError();
    
    try {
      final isValid = await SecureStorageService.verifyPinCode(pin);
      if (isValid) {
        final token = await SecureStorageService.getAuthToken();
        if (token != null) {
          final result = await _authService.getUserProfile();
          if (result['success']) {
            _user = UserModel.fromJson(result['user']);
            _isLoggedIn = true;
            await SecureStorageService.saveLastLoginTime();
            _setLoading(false);
            return true;
          }
        }
      }
      
      _setError('PIN码错误');
      _setLoading(false);
      return false;
    } catch (e) {
      _setError('PIN码验证失败');
      _setLoading(false);
      return false;
    }
  }
  
  /// 处理成功登录
  Future<void> _handleSuccessfulLogin(Map<String, dynamic> result) async {
    _user = UserModel.fromJson(result['user']);
    _isLoggedIn = true;
    
    // 保存Token
    await SecureStorageService.saveAuthToken(result['token']);
    if (result['refresh_token'] != null) {
      await SecureStorageService.saveRefreshToken(result['refresh_token']);
    }
    
    // 保存用户信息
    await SecureStorageService.saveUserId(_user!.id);
    await SecureStorageService.saveUserData(_user!.toJson());
    
    // 清除失败记录
    await SecureStorageService.clearLoginAttempts();
    _accountLocked = false;
    _loginAttempts = 0;
    
    // 更新最后登录时间
    await SecureStorageService.saveLastLoginTime();
    
    notifyListeners();
  }
  
  /// 处理失败登录
  Future<void> _handleFailedLogin(String message) async {
    await SecureStorageService.incrementLoginAttempts();
    _loginAttempts = await SecureStorageService.getLoginAttempts();
    _accountLocked = await SecureStorageService.isAccountLocked();
    
    if (_accountLocked) {
      _setError('登录失败次数过多，账户已被锁定');
    } else {
      _setError('$message (剩余尝试次数: ${5 - _loginAttempts})');
    }
    
    notifyListeners();
  }
  
  /// 注册
  Future<bool> register(String username, String password, String email, {
    String? phone,
    String? captcha,
  }) async {
    _setLoading(true);
    _clearError();
    
    // 密码强度验证
    if (!CryptoService.isPasswordStrong(password)) {
      _setError('密码强度不足，请包含大小写字母、数字和特殊字符');
      _setLoading(false);
      return false;
    }
    
    try {
      final result = await _authService.register(username, password, email);
      if (result['success']) {
        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] ?? '注册失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('网络错误，请稍后重试');
      _setLoading(false);
      return false;
    }
  }
  
  /// 发送密码重置验证码
  Future<bool> sendResetCode(String identifier, String type) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _resetService.sendResetCode(
        identifier: identifier,
        type: type,
      );
      
      if (result['success']) {
        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] ?? '发送失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('网络错误，请稍后重试');
      _setLoading(false);
      return false;
    }
  }
  
  /// 验证重置验证码
  Future<String?> verifyResetCode(String identifier, String code) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _resetService.verifyResetCode(
        identifier: identifier,
        code: code,
      );
      
      if (result['success']) {
        _setLoading(false);
        return result['reset_token'];
      } else {
        _setError(result['message'] ?? '验证失败');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('网络错误，请稍后重试');
      _setLoading(false);
      return null;
    }
  }
  
  /// 重置密码
  Future<bool> resetPassword(String resetToken, String newPassword, String confirmPassword) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await _resetService.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      if (result['success']) {
        _setLoading(false);
        return true;
      } else {
        _setError(result['message'] ?? '重置失败');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('网络错误，请稍后重试');
      _setLoading(false);
      return false;
    }
  }
  
  /// 启用/禁用生物认证
  Future<bool> toggleBiometric(bool enable) async {
    if (enable && !_biometricSupported) {
      _setError('设备不支持生物认证');
      return false;
    }
    
    if (enable) {
      // 验证生物认证
      try {
        final authenticated = await BiometricService.authenticate(
          reason: '请进行生物认证以启用此功能',
        );
        
        if (!authenticated) {
          _setError('生物认证失败');
          return false;
        }
      } catch (e) {
        _setError('生物认证失败');
        return false;
      }
    }
    
    await SecureStorageService.setBiometricEnabled(enable);
    _biometricEnabled = enable;
    notifyListeners();
    return true;
  }
  
  /// 设置PIN码
  Future<bool> setPinCode(String pin) async {
    if (pin.length != 6 || !RegExp(r'^\d{6}$').hasMatch(pin)) {
      _setError('PIN码必须是6位数字');
      return false;
    }
    
    try {
      await SecureStorageService.savePinCode(pin);
      return true;
    } catch (e) {
      _setError('PIN码设置失败');
      return false;
    }
  }
  
  /// 退出登录
  Future<void> logout({bool clearAllData = false}) async {
    try {
      // 调用服务器退出接口
      await _authService.logout();
    } catch (e) {
      debugPrint('Logout API call failed: $e');
    }
    
    _user = null;
    _isLoggedIn = false;
    
    if (clearAllData) {
      await SecureStorageService.clearAllAuthData();
    } else {
      // 保留部分设置，只清除敏感数据
      await SecureStorageService.saveAuthToken('');
      await SecureStorageService.saveRefreshToken('');
      await SecureStorageService.saveUserData({});
    }
    
    notifyListeners();
  }
  
  /// 获取认证Token
  Future<String?> getAuthToken() async {
    return await SecureStorageService.getAuthToken();
  }
  
  /// 刷新Token
  Future<bool> refreshToken() async {
    try {
      final result = await _authService.refreshToken();
      if (result['success']) {
        await SecureStorageService.saveAuthToken(result['token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// 检查认证状态
  Future<bool> isTokenValid() async {
    final token = await SecureStorageService.getAuthToken();
    if (token == null || token.isEmpty) return false;
    
    try {
      final result = await _authService.getUserProfile();
      return result['success'];
    } catch (e) {
      return false;
    }
  }
  
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }
  
  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }
  
  /// 清除账户锁定
  Future<void> clearAccountLock() async {
    await SecureStorageService.clearLoginAttempts();
    _accountLocked = false;
    _loginAttempts = 0;
    notifyListeners();
  }
  
  /// 获取安全状态
  Map<String, dynamic> getSecurityStatus() {
    return {
      'biometric_supported': _biometricSupported,
      'biometric_enabled': _biometricEnabled,
      'device_id': _deviceId,
      'login_attempts': _loginAttempts,
      'account_locked': _accountLocked,
      'last_login': null, // TODO: 获取最后登录时间
    };
  }
}