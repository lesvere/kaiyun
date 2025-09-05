import 'package:get/get.dart';
import '../routes/app_routes.dart';
import '../views/splash/splash_page.dart';
import '../views/home/home_page.dart';
import '../views/mine/mine_page.dart';
import '../views/activity/activity_page.dart';
import '../views/customer/customer_page.dart';
import '../views/sponsor/sponsor_page.dart';
import '../views/auth/login_page.dart';
import '../views/auth/register_page.dart';
import '../views/auth/forgot_password_page.dart';
import '../views/auth/biometric_setup_page.dart';
import '../views/auth/pin_setup_page.dart';
import '../views/auth/security_settings_page.dart';
import '../views/vip/vip_page.dart';
import '../views/vip/vip_points_detail_page.dart';
import '../views/vip/vip_levels_comparison_page.dart';
import '../views/vip/vip_exclusive_services_page.dart';
import '../views/finance/deposit_page.dart';
import '../views/finance/transfer_page.dart';
import '../views/finance/withdrawal_page.dart';
import '../views/records/transaction_record_page.dart';
import '../views/records/bet_record_page.dart';
import '../views/records/rebate_page.dart';
import '../views/account/account_management_page.dart';
import '../views/account/feedback_page.dart';
import '../views/account/help_center_page.dart';
import '../views/account/agent_page.dart';
import '../views/share/share_earn_page.dart';
import '../views/share/referral_reward_page.dart';
import '../views/sports/sports_data_page.dart';
import '../views/components/navigation_test_page.dart';

class AppPages {
  static final List<GetPage> pages = [
    // 启动页
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
    ),
    
    // 主要页面
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
    ),
    GetPage(
      name: AppRoutes.mine,
      page: () => const MinePage(),
    ),
    GetPage(
      name: AppRoutes.activity,
      page: () => const ActivityPage(),
    ),
    GetPage(
      name: AppRoutes.customer,
      page: () => const CustomerPage(),
    ),
    GetPage(
      name: AppRoutes.sponsor,
      page: () => const SponsorPage(),
    ),
    
    // 认证页面
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordPage(),
    ),
    GetPage(
      name: AppRoutes.biometricSetup,
      page: () => const BiometricSetupPage(),
    ),
    GetPage(
      name: AppRoutes.pinSetup,
      page: () => const PinSetupPage(),
    ),
    GetPage(
      name: AppRoutes.securitySettings,
      page: () => const SecuritySettingsPage(),
    ),
    
    // VIP服务页面
    GetPage(
      name: AppRoutes.vip,
      page: () => const VipPage(),
    ),
    GetPage(
      name: AppRoutes.vipPointsDetail,
      page: () => const VipPointsDetailPage(),
    ),
    GetPage(
      name: AppRoutes.vipLevelsComparison,
      page: () => const VipLevelsComparisonPage(),
    ),
    GetPage(
      name: AppRoutes.vipExclusiveServices,
      page: () => const VipExclusiveServicesPage(),
    ),
    
    // 资金操作页面
    GetPage(
      name: AppRoutes.deposit,
      page: () => const DepositPage(),
    ),
    GetPage(
      name: AppRoutes.transfer,
      page: () => const TransferPage(),
    ),
    GetPage(
      name: AppRoutes.withdrawal,
      page: () => const WithdrawalPage(),
    ),
    
    // 记录页面
    GetPage(
      name: AppRoutes.transactionRecord,
      page: () => const TransactionRecordPage(),
    ),
    GetPage(
      name: AppRoutes.betRecord,
      page: () => const BetRecordPage(),
    ),
    GetPage(
      name: AppRoutes.realtimeRebate,
      page: () => const RebatePage(),
    ),
    
    // 账户管理
    GetPage(
      name: AppRoutes.accountManagement,
      page: () => const AccountManagementPage(),
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackPage(),
    ),
    GetPage(
      name: AppRoutes.helpCenter,
      page: () => const HelpCenterPage(),
    ),
    GetPage(
      name: AppRoutes.agentPage,
      page: () => const AgentPage(),
    ),
    GetPage(
      name: AppRoutes.shareEarn,
      page: () => const ShareEarnPage(),
    ),
    
    // 推荐奖励页面
    GetPage(
      name: '/referral-reward',
      page: () => const ReferralRewardPage(),
    ),
    
    // 体育赛事页面
    GetPage(
      name: '/sports-data',
      page: () => const SportsDataPage(),
    ),
    
    // 测试页面
    GetPage(
      name: AppRoutes.navigationTest,
      page: () => const NavigationTestPage(),
    ),
  ];
}