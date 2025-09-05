import 'package:local_auth/local_auth.dart';
import 'package:flutter/services.dart';

/// 生物认证服务
class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();
  
  /// 检查设备是否支持生物认证
  static Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }
  
  /// 检查是否已设置生物认证
  static Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }
  
  /// 获取可用的生物认证类型
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }
  
  /// 执行生物认证
  static Future<bool> authenticate({
    required String reason,
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      return await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      if (e.code == 'NotEnrolled') {
        // 用户未设置生物认证
        return false;
      } else if (e.code == 'LockedOut') {
        // 认证被锁定（多次失败）
        throw BiometricException('认证已被锁定，请稍后再试');
      } else if (e.code == 'PermanentlyLockedOut') {
        // 永久锁定
        throw BiometricException('生物认证已被永久锁定，请使用其他方式登录');
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  /// 停止认证
  static Future<void> stopAuthentication() async {
    try {
      await _localAuth.stopAuthentication();
    } catch (e) {
      // 忽略停止认证的错误
    }
  }
}

/// 生物认证异常类
class BiometricException implements Exception {
  final String message;
  
  BiometricException(this.message);
  
  @override
  String toString() {
    return 'BiometricException: $message';
  }
}
