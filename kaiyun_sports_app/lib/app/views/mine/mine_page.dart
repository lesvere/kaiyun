import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class MinePage extends StatelessWidget {
  const MinePage({super.key});
  
  // 处理菜单项点击
  void _handleMenuItemTap(Map<String, dynamic> item, BuildContext context) {
    final title = item['title'] as String;
    final route = item['route'] as String;
    
    // 添加触觉反馈
    HapticFeedback.lightImpact();
    
    // 客服相关的按钮特殊处理
    if (title == '帮助中心' || title == '意见反馈') {
      _showCustomerServiceDialog(context, title);
      return;
    }
    
    // 其他按钮正常导航
    Get.toNamed(route);
  }
  
  // 显示客服相关的对话框
  void _showCustomerServiceDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              title == '帮助中心' ? MdiIcons.helpCircleOutline : MdiIcons.messageTextOutline,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              title == '帮助中心' ? MdiIcons.headsetIcon : MdiIcons.emailOutline,
              size: 50,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              title == '帮助中心' ? '帮助中心功能正在完善中...' : '意见反馈功能即将上线...',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              '如需帮助，请直接联系在线客服',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('知道了'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // 导航到客服页面
              Get.toNamed(AppRoutes.customer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('联系客服'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(),
        actions: [
          TextButton(
            onPressed: () => Get.toNamed(AppRoutes.login),
            child: const Text(
              '登录/注册',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return SingleChildScrollView(
            child: Column(
              children: [
                // 用户信息区域
                _buildUserSection(context, authProvider),
                
                const SizedBox(height: 16),
                
                // 福利中心区域
                _buildBenefitCenterSection(context),
                
                const SizedBox(height: 16),
                
                // 功能菜单区域
                _buildFunctionMenuSection(context),
                
                const SizedBox(height: 16),
                
                // 金融操作区域
                _buildFinanceSection(context),
                
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }
  
  // 用户信息区域
  Widget _buildUserSection(BuildContext context, AuthProvider authProvider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // 用户头像
          GestureDetector(
            onTap: () {
              if (!authProvider.isLoggedIn) {
                Get.toNamed(AppRoutes.login);
              }
            },
            child: CircleAvatar(
              radius: 32,
              backgroundColor: AppColors.buttonGray,
              child: authProvider.isLoggedIn
                  ? (authProvider.user?.avatar != null
                      ? ClipOval(
                          child: Image.network(
                            authProvider.user!.avatar!,
                            width: 64,
                            height: 64,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 32,
                                color: AppColors.iconGray,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.iconGray,
                        ))
                  : const Icon(
                      Icons.person_outline,
                      size: 32,
                      color: AppColors.iconGray,
                    ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 用户信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authProvider.isLoggedIn
                      ? authProvider.user?.username ?? '用户'
                      : '您还未登录',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                if (authProvider.isLoggedIn) ...[
                  Text(
                    authProvider.user?.getVipLevelName() ?? 'VIP等级',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.vipGold,
                    ),
                  ),
                ] else
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.login),
                    child: const Text(
                      '登录后享受更多服务',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // 设置按钮
          IconButton(
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.iconGray,
            ),
            onPressed: () {
              // TODO: 设置页面
            },
          ),
        ],
      ),
    );
  }
  
  // 福利中心区域
  Widget _buildBenefitCenterSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                AppColors.benefitBlue,
                AppColors.benefitBlueLight,
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '福利中心 尽享优惠',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '加入VIP专享豪礼',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '领取福利',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  // 功能菜单区域
  Widget _buildFunctionMenuSection(BuildContext context) {
    final menuItems = [
      {
        'icon': MdiIcons.fileDocumentOutline,
        'title': '交易记录',
        'route': AppRoutes.transactionRecord,
      },
      {
        'icon': MdiIcons.trophy,
        'title': '投注记录',
        'route': AppRoutes.betRecord,
      },
      {
        'icon': MdiIcons.waterOutline,
        'title': '实时返水',
        'route': AppRoutes.rebate,
      },
      {
        'icon': MdiIcons.accountOutline,
        'title': '账户管理',
        'route': AppRoutes.accountManagement,
      },
      {
        'icon': MdiIcons.shareVariantOutline,
        'title': '分享赚钱',
        'route': AppRoutes.shareEarn,
      },
      {
        'icon': MdiIcons.messageTextOutline,
        'title': '意见反馈',
        'route': AppRoutes.feedback,
      },
      {
        'icon': MdiIcons.helpCircleOutline,
        'title': '帮助中心',
        'route': AppRoutes.helpCenter,
      },
      {
        'icon': MdiIcons.accountPlusOutline,
        'title': '加入我们',
        'route': AppRoutes.agent,
      },
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            crossAxisSpacing: 8,
            mainAxisSpacing: 20,
            children: menuItems.map((item) {
              return _buildMenuItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                onTap: () => _handleMenuItemTap(item, context),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primary.withOpacity(0.2),
        highlightColor: AppColors.primary.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // 金融操作区域
  Widget _buildFinanceSection(BuildContext context) {
    final financeItems = [
      {
        'icon': Icons.account_balance_wallet,
        'title': '存款',
        'route': AppRoutes.deposit,
        'color': AppColors.success,
      },
      {
        'icon': Icons.swap_horiz,
        'title': '转账',
        'route': AppRoutes.transfer,
        'color': AppColors.info,
      },
      {
        'icon': Icons.money,
        'title': '取款',
        'route': AppRoutes.withdrawal,
        'color': AppColors.warning,
      },
      {
        'icon': Icons.filter_list,
        'title': '筛选',
        'route': null,
        'color': AppColors.iconGray,
      },
      {
        'icon': Icons.refresh,
        'title': '实时',
        'route': null,
        'color': AppColors.iconGray,
      },
    ];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: financeItems.map((item) {
              return _buildFinanceItem(
                icon: item['icon'] as IconData,
                title: item['title'] as String,
                color: item['color'] as Color,
                onTap: () {
                  if (item['route'] != null) {
                    Get.toNamed(item['route'] as String);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFinanceItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}