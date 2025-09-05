import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/vip_models.dart';
import '../../data/services/vip_service.dart';

class VipLevelsComparisonPage extends StatefulWidget {
  const VipLevelsComparisonPage({super.key});

  @override
  State<VipLevelsComparisonPage> createState() => _VipLevelsComparisonPageState();
}

class _VipLevelsComparisonPageState extends State<VipLevelsComparisonPage> {
  final VipService _vipService = VipService();
  final PageController _pageController = PageController();
  
  int _currentPageIndex = 0;
  final List<VipLevel> _vipLevels = VipLevel.values;
  Map<VipLevel, List<VipBenefit>> _levelBenefits = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLevelBenefits();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadLevelBenefits() async {
    setState(() => _isLoading = true);
    
    try {
      for (final level in _vipLevels) {
        final benefits = await _vipService.getVipBenefits(level);
        _levelBenefits[level] = benefits;
      }
    } catch (e) {
      // 使用默认数据
      _levelBenefits = _createDefaultLevelBenefits();
    }
    
    setState(() => _isLoading = false);
  }

  Map<VipLevel, List<VipBenefit>> _createDefaultLevelBenefits() {
    return {
      VipLevel.regular: [],
      VipLevel.bronze: [
        VipBenefit(
          id: 'bronze_weekly',
          name: '每周红包',
          description: '每周可领取100元红包',
          iconName: 'card_giftcard',
          requiredLevel: VipLevel.bronze,
          type: BenefitType.bonus,
          value: 100,
          unit: 'CNY',
        ),
      ],
      VipLevel.silver: [
        VipBenefit(
          id: 'silver_weekly',
          name: '每周红包',
          description: '每周可领取200元红包',
          iconName: 'card_giftcard',
          requiredLevel: VipLevel.silver,
          type: BenefitType.bonus,
          value: 200,
          unit: 'CNY',
        ),
        VipBenefit(
          id: 'silver_cashback',
          name: '投注返现',
          description: '0.5%投注返现',
          iconName: 'attach_money',
          requiredLevel: VipLevel.silver,
          type: BenefitType.cashback,
          value: 0.5,
          unit: '%',
        ),
      ],
      VipLevel.gold: [
        VipBenefit(
          id: 'gold_weekly',
          name: '每周红包',
          description: '每周可领取500元红包',
          iconName: 'card_giftcard',
          requiredLevel: VipLevel.gold,
          type: BenefitType.bonus,
          value: 500,
          unit: 'CNY',
        ),
        VipBenefit(
          id: 'gold_cashback',
          name: '投注返现',
          description: '1.0%投注返现',
          iconName: 'attach_money',
          requiredLevel: VipLevel.gold,
          type: BenefitType.cashback,
          value: 1.0,
          unit: '%',
        ),
        VipBenefit(
          id: 'gold_upgrade',
          name: '晋级礼金',
          description: '升级获得1000元奖金',
          iconName: 'trending_up',
          requiredLevel: VipLevel.gold,
          type: BenefitType.bonus,
          value: 1000,
          unit: 'CNY',
        ),
      ],
      VipLevel.diamond: [
        VipBenefit(
          id: 'diamond_weekly',
          name: '每周红包',
          description: '每周可领取1000元红包',
          iconName: 'card_giftcard',
          requiredLevel: VipLevel.diamond,
          type: BenefitType.bonus,
          value: 1000,
          unit: 'CNY',
        ),
        VipBenefit(
          id: 'diamond_cashback',
          name: '投注返现',
          description: '1.5%投注返现',
          iconName: 'attach_money',
          requiredLevel: VipLevel.diamond,
          type: BenefitType.cashback,
          value: 1.5,
          unit: '%',
        ),
        VipBenefit(
          id: 'diamond_service',
          name: '专属客服',
          description: '7*24小时专属客服',
          iconName: 'support_agent',
          requiredLevel: VipLevel.diamond,
          type: BenefitType.exclusive,
        ),
      ],
      VipLevel.black: [
        VipBenefit(
          id: 'black_weekly',
          name: '每周红包',
          description: '每周可领取2000元红包',
          iconName: 'card_giftcard',
          requiredLevel: VipLevel.black,
          type: BenefitType.bonus,
          value: 2000,
          unit: 'CNY',
        ),
        VipBenefit(
          id: 'black_cashback',
          name: '投注返现',
          description: '2.0%投注返现',
          iconName: 'attach_money',
          requiredLevel: VipLevel.black,
          type: BenefitType.cashback,
          value: 2.0,
          unit: '%',
        ),
        VipBenefit(
          id: 'black_birthday',
          name: '生日礼金',
          description: '生日当天获得5000元特别奖金',
          iconName: 'cake',
          requiredLevel: VipLevel.black,
          type: BenefitType.bonus,
          value: 5000,
          unit: 'CNY',
        ),
        VipBenefit(
          id: 'black_exclusive',
          name: '专属经理',
          description: '一对一专属客户经理服务',
          iconName: 'person',
          requiredLevel: VipLevel.black,
          type: BenefitType.exclusive,
        ),
      ],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('VIP等级对比'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildLevelTabs(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _vipLevels.length,
                    onPageChanged: (index) {
                      setState(() => _currentPageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return _buildLevelDetailPage(_vipLevels[index]);
                    },
                  ),
                ),
                _buildComparisonTable(),
              ],
            ),
    );
  }

  Widget _buildLevelTabs() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _vipLevels.length,
        itemBuilder: (context, index) {
          final level = _vipLevels[index];
          final isSelected = _currentPageIndex == index;
          
          return GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? Color(level.color) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Color(level.color) : AppColors.divider,
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Color(level.color).withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getLevelIcon(level),
                    size: 24,
                    color: isSelected ? Colors.white : Color(level.color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLevelDetailPage(VipLevel level) {
    final benefits = _levelBenefits[level] ?? [];
    final requiredPoints = _vipService.getCurrentLevelPoints(level);
    final nextLevelPoints = _vipService.getNextLevelPoints(level);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLevelHeader(level, requiredPoints, nextLevelPoints),
          const SizedBox(height: 24),
          _buildBenefitsSection(benefits),
          const SizedBox(height: 24),
          _buildUpgradeRequirements(level, nextLevelPoints),
        ],
      ),
    );
  }

  Widget _buildLevelHeader(VipLevel level, double requiredPoints, double nextLevelPoints) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Color(level.color),
              Color(level.color).withOpacity(0.8),
            ],
          ),
        ),
        padding: const EdgeInsets.all(24),
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
                    _getLevelIcon(level),
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        level.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem('所需积分', '${_formatPoints(requiredPoints)}'),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.white.withOpacity(0.3),
                ),
                Expanded(
                  child: _buildStatItem(
                    '下一级需求',
                    level == VipLevel.black ? '最高级' : '${_formatPoints(nextLevelPoints)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitsSection(List<VipBenefit> benefits) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'VIP特权',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (benefits.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text(
                    '该等级暂无特权',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...benefits.map((benefit) => _buildBenefitItem(benefit)),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(VipBenefit benefit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getBenefitIcon(benefit.iconName),
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  benefit.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  benefit.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (benefit.value != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${benefit.value}${benefit.unit ?? ''}',
                style: const TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUpgradeRequirements(VipLevel level, double nextLevelPoints) {
    if (level == VipLevel.black) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.vipGold.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.vipGold,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Text(
                  '最高VIP级别，尊享无上特权！',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final nextLevel = VipLevel.fromLevel(level.level + 1);
    
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '升级条件',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('下一级: ${nextLevel.name}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.stars,
                  color: AppColors.vipGold,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('需要积分: ${_formatPoints(nextLevelPoints)}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.sports_soccer,
                  color: AppColors.success,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text('需要投注: ${_formatPoints(nextLevelPoints)} 元'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable() {
    return Container(
      height: 120,
      margin: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '快速对比',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _vipLevels.length,
                  itemBuilder: (context, index) {
                    final level = _vipLevels[index];
                    final benefits = _levelBenefits[level] ?? [];
                    
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color(level.color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Color(level.color).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            _getLevelIcon(level),
                            color: Color(level.color),
                            size: 16,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            level.name,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(level.color),
                            ),
                          ),
                          Text(
                            '${benefits.length}项特权',
                            style: const TextStyle(
                              fontSize: 8,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
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

  // 辅助方法
  String _formatPoints(double points) {
    if (points >= 10000) {
      return '${(points / 10000).toStringAsFixed(1)}万';
    }
    return points.toInt().toString();
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

  IconData _getBenefitIcon(String iconName) {
    switch (iconName) {
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'attach_money':
        return Icons.attach_money;
      case 'trending_up':
        return Icons.trending_up;
      case 'support_agent':
        return Icons.support_agent;
      case 'cake':
        return Icons.cake;
      case 'person':
        return Icons.person;
      default:
        return Icons.star;
    }
  }
}