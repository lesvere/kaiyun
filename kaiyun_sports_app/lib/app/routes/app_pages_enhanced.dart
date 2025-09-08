import 'package:flutter/material.dart';
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
import '../views/vip/vip_page.dart';
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
import '../core/animations/page_transitions.dart';

class AppPages {
  static final List<GetPage> pages = [
    // 启动页 - 淡入效果
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // 主要页面 - 滑动效果
    GetPage(
      name: AppRoutes.home,
      page: () => const HomePage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.mine,
      page: () => const MinePage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.activity,
      page: () => const ActivityPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.customer,
      page: () => const CustomerPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.sponsor,
      page: () => const SponsorPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // 认证页面 - 向上滑入
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // VIP服务页面 - 缩放效果
    GetPage(
      name: AppRoutes.vip,
      page: () => const VipPage(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
    ),
    
    // 资金操作页面 - 向上滑入
    GetPage(
      name: AppRoutes.deposit,
      page: () => const DepositPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.transfer,
      page: () => const TransferPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
    GetPage(
      name: AppRoutes.withdrawal,
      page: () => const WithdrawalPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
    
    // 记录页面 - 右到左滑入
    GetPage(
      name: AppRoutes.transactionRecord,
      page: () => const TransactionRecordPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.betRecord,
      page: () => const BetRecordPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.realtimeRebate,
      page: () => const RebatePage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    
    // 账户管理 - 右到左滑入
    GetPage(
      name: AppRoutes.accountManagement,
      page: () => const AccountManagementPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.feedback,
      page: () => const FeedbackPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.helpCenter,
      page: () => const HelpCenterPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.agentPage,
      page: () => const AgentPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.shareEarn,
      page: () => const ShareEarnPage(),
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}
