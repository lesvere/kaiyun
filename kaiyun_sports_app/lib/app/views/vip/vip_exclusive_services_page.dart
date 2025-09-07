import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/vip_models.dart';
import '../../data/services/vip_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VipExclusiveServicesPage extends StatefulWidget {
  const VipExclusiveServicesPage({super.key});

  @override
  State<VipExclusiveServicesPage> createState() => _VipExclusiveServicesPageState();
}

class _VipExclusiveServicesPageState extends State<VipExclusiveServicesPage> {
  final VipService _vipService = VipService();
  
  VipUserInfo? _vipUserInfo;
  List<ExclusiveService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadServicesData();
  }

  Future<void> _loadServicesData() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id ?? '';
      
      if (userId.isNotEmpty) {
        _vipUserInfo = await _vipService.getVipUserInfo(userId);
      }
      
      _services = _createExclusiveServices();
    } catch (e) {
      // 使用默认数据
      _vipUserInfo = VipUserInfo(
        userId: 'demo_user',
        currentLevel: VipLevel.gold,
        totalPoints: 250000,
        currentLevelPoints: 200000,
        nextLevelPoints: 500000,
        totalBetAmount: 2500000,
        totalDepositAmount: 500000,
        daysActive: 180,
      );
      _services = _createExclusiveServices();
    }
    
    setState(() => _isLoading = false);
  }

  List<ExclusiveService> _createExclusiveServices() {
    return [
      ExclusiveService(
        id: 'vip_customer_service',
        name: 'VIP专属客服',
        description: '7*24小时专属客服团队，即时解答您的疑问',
        iconName: 'support_agent',
        isAvailable: _vipUserInfo != null && _vipUserInfo!.currentLevel.level >= 3,
        requiredLevel: VipLevel.gold,
        category: ServiceCategory.support,
        features: const [
          '专属客服代表',
          '优先处理问题',
          '即时在线解答',
          '一对一专属服务',
        ],
      ),
      ExclusiveService(
        id: 'fast_withdrawal',
        name: '快速提现',
        description: 'VIP用户享受快速提现通道，2小时内到账',
        iconName: 'flash_on',
        isAvailable: _vipUserInfo != null && _vipUserInfo!.currentLevel.level >= 2,
        requiredLevel: VipLevel.silver,
        category: ServiceCategory.financial,
        features: const [
          '2小时快速到账',
          '无手续费',
          '优先处理',
          '高额度提现',
        ],
      ),
      ExclusiveService(
        id: 'birthday_bonus',
        name: '生日专属礼金',
        description: '生日当天可领取专属礼金奖励',
        iconName: 'cake',
        isAvailable: _vipUserInfo != null && _vipUserInfo!.currentLevel.level >= 1,
        requiredLevel: VipLevel.bronze,
        category: ServiceCategory.reward,
        features: const [
          '生日当天可领取',
          '金额随等级递增',
          '无投注要求',
          '自动发放到账户',
        ],
      ),
      ExclusiveService(
        id: 'exclusive_promotions',
        name: 'VIP专属活动',
        description: '专为VIP用户定制的高价值活动',
        iconName: 'local_activity',
        isAvailable: _vipUserInfo != null && _vipUserInfo!.currentLevel.level >= 3,
        requiredLevel: VipLevel.gold,
        category: ServiceCategory.promotion,
        features: const [
          '高价值活动',
          '独家参与机会',
          '优先通知',
          '定制化服务',
        ],
      ),
      ExclusiveService(
        id: 'personal_manager',
        name: '个人客户经理',
        description: '专属个人客户经理，提供一对一服务',
        iconName: 'person_pin',
        isAvailable: _vipUserInfo != null && _vipUserInfo!.currentLevel.level >= 4,
        requiredLevel: VipLevel.diamond,
        category: ServiceCategory.premium,
        features: const [
          '专属客户经理',
          '个性化服务',
          '投注建议和分析',
          '定期回访和关怀',
        ],
      ),
      ExclusiveService(
        id: 'luxury_gifts',
        name: '奢华礼品',
        description: '高端实物礼品兑换和特殊节日礼品',
        iconName: 'card_giftcard',
        isAvailable: _vipUserInfo != null && _vipUserInfo!.currentLevel.level >= 5,
        requiredLevel: VipLevel.black,
        category: ServiceCategory.exclusive,
        features: const [
          '奢华实物礼品',
          '个性化定制',
          '免费快递配送',
          '特殊节日惊喜',
        ],
      ),
      ExclusiveService(
        id: 'event_invitations',
        name: '线下派对邀请',
        description: '参加高端线下派对和体育赛事观看',
        iconName: 'event',
        isAvailable: _vipUserInfo != null && _vipUserInfo!.currentLevel.level >= 5,
        requiredLevel: VipLevel.black,
        category: ServiceCategory.exclusive,
        features: const [
          '高端线下派对',
          '体育赛事观看',
          '交通住宿全包',
          '精英用户交流',
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('VIP专属服务'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildVipStatusHeader(),
                _buildServicesGrid(),
              ],
            ),
    );
  }

  Widget _buildVipStatusHeader() {
    if (_vipUserInfo == null) return const SliverToBoxAdapter();
    
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  Color(_vipUserInfo!.currentLevel.color),
                  Color(_vipUserInfo!.currentLevel.color).withOpacity(0.8),
                ],
              ),
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getLevelIcon(_vipUserInfo!.currentLevel),
                        size: 28,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '您的VIP等级：${_vipUserInfo!.currentLevel.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '可享受${_getAvailableServicesCount()}项专属服务',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 打开VIP等级对比页面
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(_vipUserInfo!.currentLevel.color),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('查看等级'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServicesGrid() {
    // 按类别分组
    final groupedServices = <ServiceCategory, List<ExclusiveService>>{};
    for (final service in _services) {
      if (!groupedServices.containsKey(service.category)) {
        groupedServices[service.category] = [];
      }
      groupedServices[service.category]!.add(service);
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final categories = groupedServices.keys.toList();
          final category = categories[index];
          final services = groupedServices[category]!;
          
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  _getCategoryName(category),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ...services.map((service) => _buildServiceCard(service)),
            ],
          );
        },
        childCount: groupedServices.length,
      ),
    );
  }

  Widget _buildServiceCard(ExclusiveService service) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Card(
        elevation: service.isAvailable ? 3 : 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: service.isAvailable ? Colors.white : Colors.grey[50],
            border: service.isAvailable
                ? Border.all(color: AppColors.primary.withOpacity(0.3), width: 1)
                : null,
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: service.isAvailable
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.divider.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getServiceIcon(service.iconName),
                    color: service.isAvailable
                        ? AppColors.primary
                        : AppColors.textSecondary,
                    size: 24,
                  ),
                ),
                title: Text(
                  service.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: service.isAvailable
                        ? AppColors.textPrimary
                        : AppColors.textSecondary,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      service.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: service.isAvailable
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: service.isAvailable
                                ? Color(service.requiredLevel.color).withOpacity(0.1)
                                : AppColors.divider.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            service.requiredLevel.name,
                            style: TextStyle(
                              color: service.isAvailable
                                  ? Color(service.requiredLevel.color)
                                  : AppColors.textSecondary,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (!service.isAvailable) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              '未解锁',
                              style: TextStyle(
                                color: AppColors.warning,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                trailing: service.isAvailable
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.success,
                        size: 20,
                      )
                    : const Icon(
                        Icons.lock,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
              ),
              if (service.features.isNotEmpty)
                ExpansionTile(
                  title: Text(
                    '服务特色',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: service.isAvailable
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                  ),
                  childrenPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: service.features
                      .map((feature) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: service.isAvailable
                                      ? AppColors.success
                                      : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: service.isAvailable
                                          ? AppColors.textPrimary
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              if (service.isAvailable)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _useService(service),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('使用服务'),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _useService(ExclusiveService service) {
    // 根据不同的服务类型进行不同操作
    switch (service.id) {
      case 'vip_customer_service':
        _openCustomerService();
        break;
      case 'fast_withdrawal':
        _openWithdrawal();
        break;
      case 'birthday_bonus':
        _claimBirthdayBonus();
        break;
      case 'exclusive_promotions':
        _openPromotions();
        break;
      case 'personal_manager':
        _contactPersonalManager();
        break;
      case 'luxury_gifts':
        _openGiftCatalog();
        break;
      case 'event_invitations':
        _viewEventInvitations();
        break;
      default:
        _showServiceDialog(service);
    }
  }

  void _openCustomerService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('VIP专属客服'),
        content: const Text('正在为您转接VIP专属客服代表…'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现客服转接功能
            },
            child: const Text('立即转接'),
          ),
        ],
      ),
    );
  }

  void _openWithdrawal() {
    // TODO: 导航到快速提现页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在跳转到快速提现页面…')),
    );
  }

  void _claimBirthdayBonus() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('生日礼金'),
        content: const Text('您的生日礼金将在生日当天自动发放到账户。'),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('了解'),
          ),
        ],
      ),
    );
  }

  void _openPromotions() {
    // TODO: 导航到VIP专属活动页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在跳转到VIP专属活动页面…')),
    );
  }

  void _contactPersonalManager() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('个人客户经理'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary,
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 16),
            Text('您的专属客户经理'),
            Text('李经理'),
            SizedBox(height: 8),
            Text('服务时间：9:00-21:00'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: 实现联系功能
            },
            child: const Text('立即联系'),
          ),
        ],
      ),
    );
  }

  void _openGiftCatalog() {
    // TODO: 导航到奢华礼品目录页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在跳转到奢华礼品目录…')),
    );
  }

  void _viewEventInvitations() {
    // TODO: 导航到事件邀请页面
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('正在跳转到事件邀请页面…')),
    );
  }

  void _showServiceDialog(ExclusiveService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(service.name),
        content: Text(service.description),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 辅助方法
  int _getAvailableServicesCount() {
    return _services.where((service) => service.isAvailable).length;
  }

  IconData _getLevelIcon(VipLevel level) {
    switch (level) {
      case VipLevel.regular:
        return Icons.person;
      case VipLevel.bronze:
        return Icons.workspace_premium;
      case VipLevel.silver:
        return Icons.military_tech;
      case VipLevel.gold:
        return Icons.stars;
      case VipLevel.diamond:
        return Icons.diamond;
      case VipLevel.black:
        return Icons.auto_awesome;
    }
  }

  IconData _getServiceIcon(String iconName) {
    switch (iconName) {
      case 'support_agent':
        return Icons.support_agent;
      case 'flash_on':
        return Icons.flash_on;
      case 'cake':
        return Icons.cake;
      case 'local_activity':
        return Icons.local_activity;
      case 'person_pin':
        return Icons.person_pin;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'event':
        return Icons.event;
      default:
        return Icons.star;
    }
  }

  String _getCategoryName(ServiceCategory category) {
    switch (category) {
      case ServiceCategory.support:
        return '客户支持';
      case ServiceCategory.financial:
        return '金融服务';
      case ServiceCategory.reward:
        return '奖励福利';
      case ServiceCategory.promotion:
        return '优惠活动';
      case ServiceCategory.premium:
        return '高级服务';
      case ServiceCategory.exclusive:
        return '专属特权';
    }
  }
}

/// 专属服务模型
class ExclusiveService {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final bool isAvailable;
  final VipLevel requiredLevel;
  final ServiceCategory category;
  final List<String> features;

  const ExclusiveService({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.isAvailable,
    required this.requiredLevel,
    required this.category,
    this.features = const [],
  });
}

/// 服务类别枚举
enum ServiceCategory {
  support,
  financial,
  reward,
  promotion,
  premium,
  exclusive,
}
