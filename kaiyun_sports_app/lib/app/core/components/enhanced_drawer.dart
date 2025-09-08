import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../theme/app_colors.dart';
import '../navigation/navigation_controller.dart';
import '../../routes/app_routes.dart';
import '../../providers/auth_provider.dart';

/// 增强版侧边抽屉菜单
class EnhancedDrawer extends StatefulWidget {
  final String? userName;
  final String? userAvatar;
  final String? userLevel;
  final bool isLoggedIn;
  final VoidCallback? onLogin;
  final VoidCallback? onLogout;
  
  const EnhancedDrawer({
    super.key,
    this.userName,
    this.userAvatar,
    this.userLevel,
    this.isLoggedIn = false,
    this.onLogin,
    this.onLogout,
  });
  
  @override
  State<EnhancedDrawer> createState() => _EnhancedDrawerState();
}

class _EnhancedDrawerState extends State<EnhancedDrawer>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  
  final NavigationController _navController = Get.find<NavigationController>();
  
  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    // 启动动画
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _slideController.forward();
        _fadeController.forward();
      }
    });
  }
  
  @override
  void dispose() {
    _slideController.dispose();
    _fadeController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _buildMenuList(),
              ),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // 用户头像
              GestureDetector(
                onTap: widget.isLoggedIn ? null : widget.onLogin,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 38,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    backgroundImage: widget.userAvatar != null
                        ? NetworkImage(widget.userAvatar!)
                        : null,
                    child: widget.userAvatar == null
                        ? Icon(
                            widget.isLoggedIn 
                                ? Icons.person
                                : Icons.person_outline,
                            size: 40,
                            color: Colors.white.withOpacity(0.8),
                          )
                        : null,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 用户信息
              Text(
                widget.isLoggedIn
                    ? widget.userName ?? '用户'
                    : '未登录',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              if (widget.isLoggedIn && widget.userLevel != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.vipGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.vipGold.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    widget.userLevel!,
                    style: const TextStyle(
                      color: AppColors.vipGold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              
              if (!widget.isLoggedIn) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: widget.onLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: const Text(
                      '登录/注册',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildMenuList() {
    final menuItems = _getMenuItems();
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final item = menuItems[index];
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1.0, 0.0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _slideController,
            curve: Interval(
              0.1 + (index * 0.1),
              0.8 + (index * 0.1),
              curve: Curves.easeOutCubic,
            ),
          )),
          child: FadeTransition(
            opacity: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(CurvedAnimation(
              parent: _fadeController,
              curve: Interval(
                0.2 + (index * 0.1),
                0.9 + (index * 0.1),
                curve: Curves.easeInOut,
              ),
            )),
            child: _buildMenuItem(item),
          ),
        );
      },
    );
  }
  
  Widget _buildMenuItem(DrawerMenuItem item) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            
            if (item.route != null) {
              _navController.navigateTo(item.route!);
            } else if (item.onTap != null) {
              item.onTap!();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: Colors.white.withOpacity(0.9),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (item.badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      item.badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooter() {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              if (widget.isLoggedIn)
                GestureDetector(
                  onTap: widget.onLogout,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '退出登录',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                '开云体育 v1.0.0',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  List<DrawerMenuItem> _getMenuItems() {
    return [
      DrawerMenuItem(
        icon: Icons.home,
        title: '首页',
        route: AppRoutes.home,
      ),
      DrawerMenuItem(
        icon: MdiIcons.giftOutline,
        title: '优惠活动',
        route: AppRoutes.activity,
      ),
      DrawerMenuItem(
        icon: MdiIcons.crown,
        title: 'VIP特权',
        route: AppRoutes.vip,
      ),
      DrawerMenuItem(
        icon: Icons.account_balance_wallet,
        title: '资金管理',
        route: AppRoutes.deposit,
      ),
      DrawerMenuItem(
        icon: MdiIcons.fileDocumentOutline,
        title: '交易记录',
        route: AppRoutes.transactionRecord,
      ),
      DrawerMenuItem(
        icon: MdiIcons.trophy,
        title: '投注记录',
        route: AppRoutes.betRecord,
      ),
      DrawerMenuItem(
        icon: MdiIcons.shareVariantOutline,
        title: '分享赚钱',
        route: AppRoutes.shareEarn,
      ),
      DrawerMenuItem(
        icon: MdiIcons.accountOutline,
        title: '账户管理',
        route: AppRoutes.accountManagement,
      ),
      DrawerMenuItem(
        icon: MdiIcons.headsetIcon,
        title: '客服中心',
        route: AppRoutes.customer,
      ),
      DrawerMenuItem(
        icon: MdiIcons.helpCircleOutline,
        title: '帮助中心',
        route: AppRoutes.helpCenter,
      ),
      DrawerMenuItem(
        icon: MdiIcons.messageTextOutline,
        title: '意见反馈',
        route: AppRoutes.feedback,
      ),
      DrawerMenuItem(
        icon: MdiIcons.cog,
        title: '设置',
        onTap: () {
          // TODO: 打开设置页面
        },
      ),
    ];
  }
}

/// 抽屉菜单项
class DrawerMenuItem {
  final IconData icon;
  final String title;
  final String? route;
  final VoidCallback? onTap;
  final String? badge;
  final bool isEnabled;
  
  const DrawerMenuItem({
    required this.icon,
    required this.title,
    this.route,
    this.onTap,
    this.badge,
    this.isEnabled = true,
  });
}
