import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'crypto_service.dart';

/// 安全存储服务
class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      groupId: 'com.kaiyun.sports.group',
      accountName: 'kaiyun_account',
      accessibility: IOSAccessibility.first_unlock_this_device,
    ),
  );
  
  // 存储常量
  static const String _keyAuthToken = 'auth_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUserData = 'user_data';
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyPinCode = 'pin_code';
  static const String _keyDeviceId = 'device_id';
  static const String _keyLoginAttempts = 'login_attempts';
  static const String _keyLastLoginTime = 'last_login_time';
  static const String _keySecurityQuestions = 'security_questions';
  
  /// 保存认证Token
  static Future<void> saveAuthToken(String token) async {
    await _secureStorage.write(key: _keyAuthToken, value: token);
  }
  
  /// 获取认证Token
  static Future<String?> getAuthToken() async {
    return await _secureStorage.read(key: _keyAuthToken);
  }
  
  /// 保存刷新Token
  static Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(key: _keyRefreshToken, value: token);
  }
  
  /// 获取刷新Token
  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }
  
  /// 保存用户ID
  static Future<void> saveUserId(String userId) async {
    await _secureStorage.write(key: _keyUserId, value: userId);
  }
  
  /// 获取用户ID
  static Future<String?> getUserId() async {
    return await _secureStorage.read(key: _keyUserId);
  }
  
  /// 保存加密的用户数据
  static Future<void> saveUserData(Map<String, dynamic> userData) async {
    final jsonString = CryptoService.encryptData(userData.toString());
    await _secureStorage.write(key: _keyUserData, value: jsonString);
  }
  
  /// 获取用户数据
  static Future<String?> getUserData() async {
    final encryptedData = await _secureStorage.read(key: _keyUserData);
    if (encryptedData != null) {
      try {
        return CryptoService.decryptData(encryptedData);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// 设置生物认证状态
  static Future<void> setBiometricEnabled(bool enabled) async {
    await _secureStorage.write(key: _keyBiometricEnabled, value: enabled.toString());
  }
  
  /// 获取生物认证状态
  static Future<bool> isBiometricEnabled() async {
    final value = await _secureStorage.read(key: _keyBiometricEnabled);
    return value == 'true';
  }
  
  /// 保存PIN码（哈希后）
  static Future<void> savePinCode(String pin) async {
    final salt = CryptoService.generateSalt();
    final hashedPin = CryptoService.hashPassword(pin, salt);
    await _secureStorage.write(key: _keyPinCode, value: '$salt:$hashedPin');
  }
  
  /// 验证PIN码
  static Future<bool> verifyPinCode(String pin) async {
    final storedPin = await _secureStorage.read(key: _keyPinCode);
    if (storedPin == null) return false;
    
    final parts = storedPin.split(':');
    if (parts.length != 2) return false;
    
    final salt = parts[0];
    final hashedPin = parts[1];
    final inputHashedPin = CryptoService.hashPassword(pin, salt);
    
    return hashedPin == inputHashedPin;
  }
  
  /// 保存设备ID
  static Future<void> saveDeviceId(String deviceId) async {
    await _secureStorage.write(key: _keyDeviceId, value: deviceId);
  }
  
  /// 获取设备ID
  static Future<String?> getDeviceId() async {
    return await _secureStorage.read(key: _keyDeviceId);
  }
  
  /// 记录登录尝试次数
  static Future<void> incrementLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = prefs.getInt(_keyLoginAttempts) ?? 0;
    await prefs.setInt(_keyLoginAttempts, attempts + 1);
  }
  
  /// 获取登录尝试次数
  static Future<int> getLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLoginAttempts) ?? 0;
  }
  
  /// 清除登录尝试次数
  static Future<void> clearLoginAttempts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoginAttempts);
  }
  
  /// 保存最后登录时间
  static Future<void> saveLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastLoginTime, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// 获取最后登录时间
  static Future<DateTime?> getLastLoginTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_keyLastLoginTime);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }
  
  /// 保存安全问题
  static Future<void> saveSecurityQuestions(List<Map<String, String>> questions) async {
    final encrypted = CryptoService.encryptData(questions.toString());
    await _secureStorage.write(key: _keySecurityQuestions, value: encrypted);
  }
  
  /// 获取安全问题
  static Future<String?> getSecurityQuestions() async {
    final encrypted = await _secureStorage.read(key: _keySecurityQuestions);
    if (encrypted != null) {
      try {
        return CryptoService.decryptData(encrypted);
      } catch (e) {
        return null;
      }
    }
    return null;
  }
  
  /// 清除所有认证数据
  static Future<void> clearAllAuthData() async {
    await _secureStorage.delete(key: _keyAuthToken);
    await _secureStorage.delete(key: _keyRefreshToken);
    await _secureStorage.delete(key: _keyUserId);
    await _secureStorage.delete(key: _keyUserData);
    await _secureStorage.delete(key: _keyBiometricEnabled);
    await _secureStorage.delete(key: _keyPinCode);
    await _secureStorage.delete(key: _keySecurityQuestions);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLoginAttempts);
    await prefs.remove(_keyLastLoginTime);
  }
  
  /// 检查是否被锁定（登录尝试次数过多）
  static Future<bool> isAccountLocked() async {
    const maxAttempts = 5;
    final attempts = await getLoginAttempts();
    return attempts >= maxAttempts;
  }
  
  /// 检查需要重新登录（长时间未操作）
  static Future<bool> needsReauth() async {
    const maxIdleTime = 30 * 60 * 1000; // 30分钟
    final lastLoginTime = await getLastLoginTime();
    if (lastLoginTime == null) return true;
    
    final now = DateTime.now();
    final idleTime = now.difference(lastLoginTime).inMilliseconds;
    return idleTime > maxIdleTime;
  }
}
