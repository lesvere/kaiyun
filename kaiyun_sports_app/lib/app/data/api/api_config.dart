import 'dart:io';

class ApiConfig {
  // 环境配置
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'production');
  static const bool isProduction = environment == 'production';
  static const bool isDevelopment = environment == 'development';
  
  // 基础配置
  static String get baseUrl {
    switch (environment) {
      case 'development':
        return 'https://dev-api.kaiyun.com';
      case 'staging':
        return 'https://staging-api.kaiyun.com';
      case 'production':
      default:
        return 'https://www.mf8ezm.com';
    }
  }
  
  static const String apiVersion = 'v1';
  static const String appVersion = '1.0.0';
  static const int connectTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒
  static const int sendTimeout = 30000; // 30秒
  
  // 重试配置
  static const int maxRetryCount = 3;
  static const int retryDelay = 1000; // 1秒
  
  // Token配置
  static const int tokenRefreshInterval = 25; // 25分钟
  
  // SSL配置
  static const bool enableSSLPinning = true;
  static const List<String> allowedFingerprints = [
    'SHA256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=', // 替换为实际的证书指纹
  ];
  
  // 缓存配置
  static const bool enableCache = true;
  static const int cacheMaxAge = 300; // 5分钟
  
  // 日志配置
  static const bool enableRequestLog = !isProduction;
  static const bool enableResponseLog = !isProduction;
  
  // API端点
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String logout = '/api/auth/logout';
  static const String refreshToken = '/api/auth/refresh';
  static const String sendResetCode = '/api/auth/send-reset-code';
  static const String verifyResetCode = '/api/auth/verify-reset-code';
  static const String resetPassword = '/api/auth/reset-password';
  static const String resetPasswordByQuestions = '/api/auth/reset-password-questions';
  static const String securityQuestions = '/api/auth/security-questions';
  static const String setSecurityQuestions = '/api/auth/set-security-questions';
  static const String checkSecurityStatus = '/api/auth/security-status';
  
  // 用户相关
  static const String userProfile = '/api/user/profile';
  static const String updateProfile = '/api/user/update';
  static const String userBalance = '/api/user/balance';
  
  // 财务操作
  static const String deposit = '/api/finance/deposit';
  static const String transfer = '/api/finance/transfer';
  static const String withdraw = '/api/finance/withdraw';
  static const String transactionHistory = '/api/finance/transactions';
  
  // VIP服务
  static const String vipInfo = '/api/vip/info';
  static const String vipBenefits = '/api/vip/benefits';
  static const String weeklyBonus = '/api/vip/weekly-bonus';
  static const String promotionBonus = '/api/vip/promotion-bonus';
  static const String birthdayBonus = '/api/vip/birthday-bonus';
  static const String vipLevelUpgrade = '/api/vip/level-upgrade';
  static const String vipPoints = '/api/vip/points';
  static const String vipPointsHistory = '/api/vip/points/history';
  
  // 记录查询
  static const String betRecords = '/api/records/bet';
  static const String transactionRecords = '/api/records/transaction';
  static const String realtimeRebate = '/api/records/rebate';
  static const String depositRecords = '/api/records/deposit';
  static const String withdrawalRecords = '/api/records/withdrawal';
  static const String transferRecords = '/api/records/transfer';
  
  // 体育相关
  static const String sportsData = '/api/sports/data';
  static const String sportsLive = '/api/sports/live';
  static const String sportsOdds = '/api/sports/odds';
  static const String sportsMatches = '/api/sports/matches';
  static const String sportsLeagues = '/api/sports/leagues';
  static const String sportsTeams = '/api/sports/teams';
  static const String sportsStats = '/api/sports/stats';
  
  // 投注相关
  static const String placeBet = '/api/betting/place';
  static const String betSlip = '/api/betting/slip';
  static const String betHistory = '/api/betting/history';
  static const String betCancel = '/api/betting/cancel';
  static const String betCashout = '/api/betting/cashout';
  
  // 活动相关
  static const String activities = '/api/activity/list';
  static const String friendInvitation = '/api/activity/friend-invitation';
  static const String activityJoin = '/api/activity/join';
  static const String activityRewards = '/api/activity/rewards';
  static const String promotions = '/api/promotions/list';
  static const String promotionDetail = '/api/promotions/detail';
  
  // 推荐相关
  static const String referralInfo = '/api/referral/info';
  static const String referralRewards = '/api/referral/rewards';
  static const String referralHistory = '/api/referral/history';
  static const String referralCode = '/api/referral/code';
  static const String generateReferralLink = '/api/referral/link';
  
  // 客服和帮助
  static const String feedback = '/api/customer/feedback';
  static const String helpCenter = '/api/help/center';
  static const String customerService = '/api/customer/service';
  static const String faq = '/api/help/faq';
  static const String announcement = '/api/announcement/list';
  static const String supportTicket = '/api/support/ticket';
  
  // 银行卡管理
  static const String bankCards = '/api/finance/bank-cards';
  static const String addBankCard = '/api/finance/bank-cards/add';
  static const String deleteBankCard = '/api/finance/bank-cards/delete';
  static const String bankList = '/api/finance/banks';
  
  // 支付方式
  static const String paymentMethods = '/api/finance/payment-methods';
  static const String paymentChannels = '/api/finance/payment-channels';
  static const String paymentLimits = '/api/finance/payment-limits';
  
  // 系统相关
  static const String systemConfig = '/api/system/config';
  static const String appUpdate = '/api/system/app-update';
  static const String maintenance = '/api/system/maintenance';
  static const String serverTime = '/api/system/time';
  
  // 文件上传
  static const String uploadFile = '/api/file/upload';
  static const String uploadAvatar = '/api/file/avatar';
  static const String uploadDocument = '/api/file/document';
  
  // 错误码
  static const int successCode = 0;
  static const int unauthorizedCode = 401;
  static const int forbiddenCode = 403;
  static const int notFoundCode = 404;
  static const int serverErrorCode = 500;
  static const int badRequestCode = 400;
  static const int tooManyRequestsCode = 429;
  static const int serviceUnavailableCode = 503;
  
  // 业务错误码
  static const int businessErrorBase = 10000;
  static const int userNotExistCode = 10001;
  static const int passwordIncorrectCode = 10002;
  static const int accountLockedCode = 10003;
  static const int insufficientBalanceCode = 10004;
  static const int betLimitExceededCode = 10005;
  static const int gameMaintenanceCode = 10006;
  
  // 请求头
  static Map<String, String> get headers {
    final baseHeaders = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'KaiyunSports/$appVersion (${Platform.operatingSystem})',
      'X-Client-Type': 'mobile',
      'X-API-Version': apiVersion,
      'Accept-Language': 'zh-CN,zh;q=0.9,en;q=0.8',
    };
    
    // 根据环境添加不同的头信息
    if (isDevelopment) {
      baseHeaders['X-Debug'] = 'true';
    }
    
    return baseHeaders;
  }
  
  static Map<String, String> authHeaders(String token) => {
    ...headers,
    'Authorization': 'Bearer $token',
  };
  
  /// 获取完整的API URL
  static String getFullUrl(String path) {
    return '$baseUrl$path';
  }
  
  /// 检查是否为成功状态码
  static bool isSuccessStatusCode(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }
  
  /// 检查是否为业务错误码
  static bool isBusinessError(int? errorCode) {
    return errorCode != null && errorCode >= businessErrorBase;
  }
  
  /// 获取错误信息
  static String getErrorMessage(int errorCode) {
    switch (errorCode) {
      case unauthorizedCode:
        return '未授权，请登录';
      case forbiddenCode:
        return '没有权限访问';
      case notFoundCode:
        return '请求的资源不存在';
      case tooManyRequestsCode:
        return '请求过于频繁，请稍后再试';
      case serviceUnavailableCode:
        return '服务暂时不可用';
      case serverErrorCode:
        return '服务器内部错误';
      case userNotExistCode:
        return '用户不存在';
      case passwordIncorrectCode:
        return '密码错误';
      case accountLockedCode:
        return '账户被锁定';
      case insufficientBalanceCode:
        return '余额不足';
      case betLimitExceededCode:
        return '投注金额超过限制';
      case gameMaintenanceCode:
        return '游戏维护中';
      default:
        return '未知错误';
    }
  }
}