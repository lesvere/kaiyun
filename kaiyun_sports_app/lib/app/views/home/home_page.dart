import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../core/animations/animation_extensions.dart';
import '../../core/components/animated_card.dart';
import '../../core/components/micro_interactions.dart';
import '../../core/components/enhanced_bottom_navigation.dart';
import '../../core/components/enhanced_floating_action_button.dart';
import '../../core/components/enhanced_drawer.dart';
import '../../core/components/enhanced_navigation_buttons.dart';
import '../../core/navigation/navigation_controller.dart';
import '../../providers/auth_provider.dart';
import '../mine/mine_page.dart';
import '../activity/activity_page.dart';
import '../customer/customer_page.dart';
import '../sponsor/sponsor_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _fabController;
  late Animation<double> _fabAnimation;
  final NavigationController _navController = Get.put(NavigationController());
  bool _isFabExpanded = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  final List<Widget> _pages = [
    const _HomeTabPage(),
    const ActivityPage(),
    const CustomerPage(),
    const SponsorPage(),
    const MinePage(),
  ];
  
  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
    _fabController.forward();
  }
  
  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }
  
  final List<BottomNavItem> _bottomNavItems = [
    const BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home,
      label: '首页',
    ),
    BottomNavItem(
      icon: MdiIcons.giftOutline,
      activeIcon: MdiIcons.gift,
      label: '优惠',
    ),
    BottomNavItem(
      icon: MdiIcons.headset,
      activeIcon: MdiIcons.headset,
      label: '客服',
    ),
    BottomNavItem(
      icon: MdiIcons.handshakeOutline,
      activeIcon: MdiIcons.handshake,
      label: '赞助',
    ),
    BottomNavItem(
      icon: MdiIcons.accountOutline,
      activeIcon: MdiIcons.account,
      label: '我的',
    ),
  ];
  
  void _onBottomNavTap(int index) {
    if (index != _currentIndex) {
      _navController.changeTab(index);
      setState(() {
        _currentIndex = index;
      });
      
      // FAB动画
      _fabController.reset();
      _fabController.forward();
    }
  }
  
  void _toggleFab() {
    setState(() {
      _isFabExpanded = !_isFabExpanded;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          key: _scaffoldKey,
          drawer: EnhancedDrawer(
            userName: authProvider.user?.username,
            userAvatar: authProvider.user?.avatar,
            userLevel: authProvider.user?.getVipLevelName(),
            isLoggedIn: authProvider.isLoggedIn,
            onLogin: () => Get.toNamed(AppRoutes.login),
            onLogout: () => authProvider.logout(),
          ),
          body: AnimationLimiter(
            child: IndexedStack(
              index: _currentIndex,
              children: _pages.asMap().entries.map((entry) {
                final index = entry.key;
                final page = entry.value;
                
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 300),
                  child: SlideAnimation(
                    horizontalOffset: index == _currentIndex ? 0 : 50,
                    child: FadeInAnimation(
                      child: page,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          bottomNavigationBar: EnhancedBottomNavigation(
            items: _bottomNavItems,
            currentIndex: _currentIndex,
            onTap: _onBottomNavTap,
            enableAnimation: true,
            showBadge: true,
            badgeCounts: const {
              1: 2, // 优惠活动有2个新活动
              2: 1, // 客服有1条未读消息
            },
          ),
          floatingActionButton: _currentIndex == 0 ? 
            ScaleTransition(
              scale: _fabAnimation,
              child: EnhancedFABStyles.expandableMenu(
                onPressed: _toggleFab,
                isExpanded: _isFabExpanded,
                actions: [
                  FloatingActionButtonAction(
                    icon: Icons.account_balance_wallet,
                    label: '存款',
                    onPressed: () {
                      setState(() => _isFabExpanded = false);
                      Get.toNamed(AppRoutes.deposit);
                    },
                    backgroundColor: AppColors.success,
                  ),
                  FloatingActionButtonAction(
                    icon: Icons.swap_horiz,
                    label: '转账',
                    onPressed: () {
                      setState(() => _isFabExpanded = false);
                      Get.toNamed(AppRoutes.transfer);
                    },
                    backgroundColor: AppColors.info,
                  ),
                  FloatingActionButtonAction(
                    icon: Icons.money,
                    label: '取款',
                    onPressed: () {
                      setState(() => _isFabExpanded = false);
                      Get.toNamed(AppRoutes.withdrawal);
                    },
                    backgroundColor: AppColors.warning,
                  ),
                ],
              ),
            ) : null,
        );
      },
    );
  }
}

// 首页Tab内容
class _HomeTabPage extends StatefulWidget {
  const _HomeTabPage();
  
  @override
  State<_HomeTabPage> createState() => _HomeTabPageState();
}

class _HomeTabPageState extends State<_HomeTabPage> 
    with TickerProviderStateMixin {
  late PageController _pageController;
  int _currentPage = 0;
  late AnimationController _refreshController;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    // 自动轮播
    _startAutoScroll();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _refreshController.dispose();
    super.dispose();
  }
  
  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _pageController.hasClients) {
        int nextPage = (_currentPage + 1) % 3;
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: EnhancedMenuButton(
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
          style: MenuButtonStyle.hamburger,
          color: AppColors.textPrimary,
        ),
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'KY',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).fadeIn(delay: const Duration(milliseconds: 100)),
            const SizedBox(width: 8),
            const Text(
              '开云体育',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ).slideIn(
              delay: const Duration(milliseconds: 200),
              direction: SlideDirection.fromLeft,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        actions: [
          RippleEffect(
            onTap: () {
              // TODO: 搜索功能
            },
            borderRadius: 20,
            child: IconButton(
              icon: const Icon(Icons.search),
              onPressed: null,
            ),
          ).slideIn(
            delay: const Duration(milliseconds: 300),
            direction: SlideDirection.fromRight,
          ),
          RippleEffect(
            onTap: () {
              // TODO: 通知功能
            },
            borderRadius: 20,
            child: IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: null,
            ),
          ).slideIn(
            delay: const Duration(milliseconds: 400),
            direction: SlideDirection.fromRight,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshController.forward().then((_) {
            _refreshController.reset();
          });
          await Future.delayed(const Duration(seconds: 2));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: AnimationLimiter(
            child: Column(
              children: AnimationConfiguration.toStaggeredList(
                duration: const Duration(milliseconds: 375),
                childAnimationBuilder: (widget) => SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: widget,
                  ),
                ),
                children: [
                  // 轮播图
                  _buildCarousel(),
                  
                  // 快速操作
                  _buildQuickActions(context),
                  
                  // 赛事快讯
                  _buildMatchNews(),
                  
                  // VIP特权
                  _buildVipPrivileges(context),
                  
                  // 推荐活动
                  _buildRecommendedActivities(context),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildCarousel() {
    return Container(
      height: 180,
      margin: const EdgeInsets.all(16),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: 3,
            itemBuilder: (context, index) {
              final banners = [
                {
                  'title': '新用户专享',
                  'subtitle': '注册即送888元',
                  'color': AppColors.primary,
                },
                {
                  'title': 'VIP专属',
                  'subtitle': '每周返水无上限',
                  'color': AppColors.vipGold,
                },
                {
                  'title': '欧洲杯专场',
                  'subtitle': '猜球赢大奖',
                  'color': AppColors.success,
                },
              ];
              
              final banner = banners[index];
              return AnimatedCard(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.all(20),
                onTap: () {
                  HapticFeedback.lightImpact();
                  // TODO: 处理轮播图点击
                },
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      colors: [
                        banner['color'] as Color,
                        (banner['color'] as Color).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (banner['color'] as Color).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        banner['title'] as String,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ).slideIn(
                        delay: Duration(milliseconds: 100 * index),
                        direction: SlideDirection.fromLeft,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        banner['subtitle'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ).slideIn(
                        delay: Duration(milliseconds: 200 * index),
                        direction: SlideDirection.fromLeft,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // 页面指示器
          Positioned(
            bottom: 16,
            right: 16,
            child: Row(
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index 
                        ? Colors.white 
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuickActions(BuildContext context) {
    final actions = <Map<String, Object>>[
      {
        'icon': Icons.sports_soccer,
        'title': '体育投注',
        'color': AppColors.primary,
        'route': '',
      },
      {
        'icon': Icons.live_tv,
        'title': '直播中心',
        'color': AppColors.error,
        'route': '',
      },
      {
        'icon': Icons.casino,
        'title': '娱乐城',
        'color': AppColors.warning,
        'route': '',
      },
      {
        'icon': MdiIcons.giftOutline,
        'title': '优惠活动',
        'color': AppColors.success,
        'route': AppRoutes.activity,
      },
      {
        'icon': Icons.account_balance_wallet,
        'title': '存款',
        'color': AppColors.info,
        'route': AppRoutes.deposit,
      },
      {
        'icon': MdiIcons.trophy,
        'title': '投注记录',
        'color': AppColors.primary,
        'route': AppRoutes.betRecord,
      },
      {
        'icon': MdiIcons.headset,
        'title': '客服中心',
        'color': AppColors.secondary,
        'route': AppRoutes.customer,
      },
      {
        'icon': MdiIcons.crown,
        'title': 'VIP特权',
        'color': AppColors.vipGold,
        'route': AppRoutes.vip,
      },
      {
        'icon': Icons.science,
        'title': '导航测试',
        'color': AppColors.secondary,
        'route': AppRoutes.navigationTest,
      },
    ];
    
    return AnimatedCard(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '快速操作',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
            children: actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              return AnimationConfiguration.staggeredGrid(
                position: index,
                duration: const Duration(milliseconds: 375),
                columnCount: 4,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: RippleEffect(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        if (action['route'] != null) {
                          Get.toNamed(action['route'] as String);
                        }
                      },
                      borderRadius: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            AnimatedCard(
                              padding: EdgeInsets.zero,
                              margin: EdgeInsets.zero,
                              enableHover: true,
                              enableScale: true,
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: (action['color'] as Color).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Icon(
                                  action['icon'] as IconData,
                                  color: action['color'] as Color,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              action['title'] as String,
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
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMatchNews() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '赛事快讯',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      // TODO: 查看更多赛事
                    },
                    child: const Text(
                      '查看更多',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ..._buildMatchItems(),
            ],
          ),
        ),
      ),
    );
  }
  
  List<Widget> _buildMatchItems() {
    final matches = [
      {
        '主队': '皇家马德里',
        '客队': '巴塞罗那',
        '时间': '22:00',
        '状态': '直播中',
        '比分': '2:1',
      },
      {
        '主队': '国际米兰',
        '客队': 'AC米兰',
        '时间': '明日 21:30',
        '状态': '即将开始',
        '比分': 'VS',
      },
      {
        '主队': '曼联',
        '客队': '切尔西',
        '时间': '明日 23:00',
        '状态': '即将开始',
        '比分': 'VS',
      },
    ];
    
    return matches.map((match) {
      final isLive = match['状态'] == '直播中';
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
          border: isLive 
              ? Border.all(color: AppColors.error.withOpacity(0.3))
              : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match['主队']} vs ${match['客队']}',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    match['时间']!,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLive ? AppColors.error : AppColors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    match['状态']!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  match['比分']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isLive ? AppColors.error : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
  
  Widget _buildVipPrivileges(BuildContext context) {
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
            gradient: LinearGradient(
              colors: [AppColors.vipGold, AppColors.vipGoldLight],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      MdiIcons.crown,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'VIP专属特权',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.vip);
                      },
                      child: const Text(
                        '了解更多',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '• 每周红包领取\n• 专属客服服务\n• 晋级豪礼\n• 生日特别礼金',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildRecommendedActivities(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    '热门活动',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.activity);
                    },
                    child: const Text(
                      '查看全部',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    final activities = [
                      {
                        '标题': '新手礼包',
                        '描述': '注册送888元',
                        'color': AppColors.primary,
                      },
                      {
                        '标题': '每日签到',
                        '描述': '连续7天送豪礼',
                        'color': AppColors.success,
                      },
                      {
                        '标题': '首存优惠',
                        '描述': '首次存款100%',
                        'color': AppColors.warning,
                      },
                    ];
                    
                    final activity = activities[index];
                    return Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            activity['color'] as Color,
                            (activity['color'] as Color).withOpacity(0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['标题'] as String,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              activity['描述'] as String,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '立即参与',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
