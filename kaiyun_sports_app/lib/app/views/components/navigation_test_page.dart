import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/components/enhanced_bottom_navigation.dart';
import '../../core/components/enhanced_floating_action_button.dart';
import '../../core/components/enhanced_drawer.dart';
import '../../core/components/enhanced_navigation_buttons.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../routes/app_routes.dart';

/// 导航功能测试页面 - 展示所有导航组件的功能
class NavigationTestPage extends StatefulWidget {
  const NavigationTestPage({super.key});
  
  @override
  State<NavigationTestPage> createState() => _NavigationTestPageState();
}

class _NavigationTestPageState extends State<NavigationTestPage> {
  final NavigationController _navController = Get.find<NavigationController>();
  int _currentIndex = 0;
  bool _isFabExpanded = false;
  bool _isMenuActive = false;
  
  final List<BottomNavItem> _bottomNavItems = [
    const BottomNavItem(
      icon: Icons.explore_outlined,
      activeIcon: Icons.explore,
      label: '测试1',
    ),
    BottomNavItem(
      icon: MdiIcons.testTube,
      activeIcon: MdiIcons.testTube,
      label: '测试2',
    ),
    BottomNavItem(
      icon: MdiIcons.cogOutline,
      activeIcon: MdiIcons.cog,
      label: '设置',
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: EnhancedMenuButton(
          onPressed: () {
            setState(() {
              _isMenuActive = !_isMenuActive;
            });
            Scaffold.of(context).openDrawer();
          },
          style: MenuButtonStyle.hamburger,
          isActive: _isMenuActive,
          color: AppColors.primary,
        ),
        title: const Text(
          '导航测试页面',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 1,
        actions: [
          EnhancedBackButton(
            onPressed: () => Get.back(),
            style: BackButtonStyle.close,
            color: AppColors.primary,
          ),
        ],
      ),
      drawer: const EnhancedDrawer(
        userName: '测试用户',
        userLevel: 'VIP 3',
        isLoggedIn: true,
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildTestContent('功能测试区域 1'),
          _buildTestContent('功能测试区域 2'),
          _buildTestContent('设置测试区域'),
        ],
      ),
      bottomNavigationBar: EnhancedBottomNavigation(
        items: _bottomNavItems,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        enableAnimation: true,
        showBadge: true,
        badgeCounts: {
          0: 3,
          1: 1,
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 可展开FAB
          EnhancedFABStyles.expandableMenu(
            onPressed: () {
              setState(() {
                _isFabExpanded = !_isFabExpanded;
              });
            },
            isExpanded: _isFabExpanded,
            actions: [
              FloatingActionButtonAction(
                icon: Icons.add,
                label: '添加',
                onPressed: () {
                  setState(() => _isFabExpanded = false);
                  _showSnackBar('添加操作');
                },
                backgroundColor: AppColors.success,
              ),
              FloatingActionButtonAction(
                icon: Icons.edit,
                label: '编辑',
                onPressed: () {
                  setState(() => _isFabExpanded = false);
                  _showSnackBar('编辑操作');
                },
                backgroundColor: AppColors.warning,
              ),
              FloatingActionButtonAction(
                icon: Icons.delete,
                label: '删除',
                onPressed: () {
                  setState(() => _isFabExpanded = false);
                  _showSnackBar('删除操作');
                },
                backgroundColor: AppColors.error,
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 普通FAB
          EnhancedFABStyles.quickDeposit(
            onPressed: () {
              _showSnackBar('快速存款');
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildTestContent(String title) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 导航按钮测试
          _buildNavigationButtonsTest(),
          
          const SizedBox(height: 24),
          
          // 页面跳转测试
          _buildPageNavigationTest(),
          
          const SizedBox(height: 24),
          
          // 动画效果说明
          _buildAnimationDemo(),
        ],
      ),
    );
  }
  
  Widget _buildNavigationButtonsTest() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '导航按钮测试',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // 返回按钮样式
            const Text('返回按钮样式:'),
            const SizedBox(height: 8),
            Row(
              children: [
                EnhancedBackButton(
                  style: BackButtonStyle.arrow,
                  onPressed: () => _showSnackBar('Arrow back'),
                ),
                const SizedBox(width: 16),
                EnhancedBackButton(
                  style: BackButtonStyle.arrowIOS,
                  onPressed: () => _showSnackBar('iOS back'),
                ),
                const SizedBox(width: 16),
                EnhancedBackButton(
                  style: BackButtonStyle.close,
                  onPressed: () => _showSnackBar('Close'),
                ),
                const SizedBox(width: 16),
                EnhancedBackButton(
                  style: BackButtonStyle.chevron,
                  onPressed: () => _showSnackBar('Chevron back'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 菜单按钮样式
            const Text('菜单按钮样式:'),
            const SizedBox(height: 8),
            Row(
              children: [
                EnhancedMenuButton(
                  style: MenuButtonStyle.hamburger,
                  onPressed: () => _showSnackBar('Hamburger menu'),
                ),
                const SizedBox(width: 16),
                EnhancedMenuButton(
                  style: MenuButtonStyle.dots,
                  onPressed: () => _showSnackBar('Dots menu'),
                ),
                const SizedBox(width: 16),
                EnhancedMenuButton(
                  style: MenuButtonStyle.grid,
                  onPressed: () => _showSnackBar('Grid menu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPageNavigationTest() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '页面跳转测试',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _navController.navigateTo(AppRoutes.home);
                  },
                  child: const Text('返回首页'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _navController.navigateTo(AppRoutes.activity);
                  },
                  child: const Text('优惠活动'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _navController.navigateTo(AppRoutes.vip);
                  },
                  child: const Text('VIP页面'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _navController.navigateTo(AppRoutes.deposit);
                  },
                  child: const Text('存款页面'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAnimationDemo() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '动画效果说明',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              '本页面展示的动画效果:',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            
            const Text('• 底部导航: 切换时的缩放和弹跳动画'),
            const Text('• 悬浮按钮: 可展开菜单动画'),
            const Text('• 菜单按钮: 汉堡包到X的变形动画'),
            const Text('• 返回按钮: 点击时的缩放和旋转动画'),
            const Text('• 侧边抽屉: 滑入动画和错峰展现'),
            const Text('• 触觉反馈: 所有按钮点击都有震动反馈'),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '提示: 请尝试各种交互操作来体验完整的动画效果！',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
