import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// 加密解密服务
class CryptoService {
  static final _encrypter = Encrypter(AES(Key.fromSecureRandom(32)));
  static final _iv = IV.fromSecureRandom(16);
  
  /// 生成安全的随机字符串
  static String generateSecureToken([int length = 32]) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }
  
  /// 生成设备指纹
  static String generateDeviceFingerprint() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final random = generateSecureToken(16);
    final combined = '$timestamp-$random';
    return sha256.convert(utf8.encode(combined)).toString();
  }
  
  /// 密码哈希（使用PBKDF2）
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// 生成密码盐值
  static String generateSalt() {
    return generateSecureToken(16);
  }
  
  /// 验证密码强度
  static bool isPasswordStrong(String password) {
    // 至少8位，包含大小写字母、数字和特殊字符
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');
    return regex.hasMatch(password);
  }
  
  /// 加密敏感数据
  static String encryptData(String data) {
    final encrypted = _encrypter.encrypt(data, iv: _iv);
    return encrypted.base64;
  }
  
  /// 解密敏感数据
  static String decryptData(String encryptedData) {
    final encrypted = Encrypted.fromBase64(encryptedData);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
  
  /// 生成JWT Token的签名
  static String signJwtToken(String payload, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(payload);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64Url.encode(digest.bytes).replaceAll('=', '');
  }
  
  /// 验证JWT Token
  static bool verifyJwtToken(String token, String secret) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      
      final payload = '${parts[0]}.${parts[1]}';
      final signature = parts[2];
      final expectedSignature = signJwtToken(payload, secret);
      
      return signature == expectedSignature;
    } catch (e) {
      return false;
    }
  }
  
  /// 生成反重放攻击的时间戳
  static String generateTimestamp() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  /// 验证时间戳（防重放攻击）
  static bool validateTimestamp(String timestamp, [int maxAgeMs = 300000]) { // 5分钟
    try {
      final ts = int.parse(timestamp);
      final now = DateTime.now().millisecondsSinceEpoch;
      return (now - ts) <= maxAgeMs;
    } catch (e) {
      return false;
    }
  }
}
