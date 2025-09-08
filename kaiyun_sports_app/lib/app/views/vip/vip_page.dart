import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/vip_models.dart';
import '../../data/services/vip_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VipPage extends StatefulWidget {
  const VipPage({super.key});

  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final VipService _vipService = VipService();

  VipUserInfo? _vipUserInfo;
  List<VipBenefit> _benefits = [];
  List<VipReward> _rewards = [];
  List<VipPointsRecord> _pointsRecords = [];
  List<VipExchangeItem> _exchangeItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadVipData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadVipData() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      
      if (userId.isNotEmpty) {
        final results = await Future.wait([
          _vipService.getVipUserInfo(userId),
          _vipService.getVipRewards(userId),
          _vipService.getPointsRecords(userId, pageSize: 10),
        ]);

        _vipUserInfo = results[0] as VipUserInfo?;
        _rewards = results[1] as List<VipReward>;
        _pointsRecords = results[2] as List<VipPointsRecord>;

        if (_vipUserInfo != null) {
          _benefits = await _vipService.getVipBenefits(_vipUserInfo!.currentLevel);
          _exchangeItems = await _vipService.getExchangeItems(_vipUserInfo!.currentLevel);
        }
      }
    } catch (e) {
      // 处理错误，显示默认数据
      _vipUserInfo = _createDefaultVipInfo();
      _benefits = await _vipService.getVipBenefits(VipLevel.gold);
      _exchangeItems = await _vipService.getExchangeItems(VipLevel.gold);
    }

    setState(() => _isLoading = false);
  }

  VipUserInfo _createDefaultVipInfo() {
    return VipUserInfo(
      userId: 'demo_user',
      currentLevel: VipLevel.gold,
      totalPoints: 250000,
      currentLevelPoints: 200000,
      nextLevelPoints: 500000,
      totalBetAmount: 2500000,
      totalDepositAmount: 500000,
      daysActive: 180,
      vipStartDate: DateTime.now().subtract(const Duration(days: 180)),
      isLifetimeVip: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                _buildVipAppBar(),
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      _buildVipLevelCard(),
                      _buildTabView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildVipAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'VIP专享服务',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(_vipUserInfo?.currentLevel.color ?? AppColors.vipGold.value),
                Color(_vipUserInfo?.currentLevel.color ?? AppColors.vipGold.value)
                    .withOpacity(0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  'assets/images/vip_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVipLevelCard() {
    if (_vipUserInfo == null) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
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
                      Icons.diamond,
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
                          _vipUserInfo!.currentLevel.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '累计积分: ${_formatPoints(_vipUserInfo!.totalPoints)}',
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
              const SizedBox(height: 24),
              if (_vipUserInfo!.currentLevel != VipLevel.black) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '升级进度',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${(_vipUserInfo!.upgradeProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _vipUserInfo!.upgradeProgress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '还需 ${_formatPoints(_vipUserInfo!.pointsNeededForUpgrade)} 积分升级到 ${VipLevel.fromLevel(_vipUserInfo!.currentLevel.level + 1).name}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '恭喜！您已达到最高VIP等级',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabView() {
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'VIP特权'),
              Tab(text: '积分商城'),
              Tab(text: '我的奖励'),
              Tab(text: '积分记录'),
            ],
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
          ),
        ),
        SizedBox(
          height: 600,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildBenefitsTab(),
              _buildExchangeTab(),
              _buildRewardsTab(),
              _buildPointsRecordTab(),
            ],
          ),
        ),
        // 添加快捷入口
        _buildQuickAccess(),
      ],
    );
  }

  Widget _buildBenefitsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _benefits.length,
      itemBuilder: (context, index) {
        final benefit = _benefits[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getBenefitIcon(benefit.iconName),
                color: AppColors.primary,
              ),
            ),
            title: Text(
              benefit.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(benefit.description),
                if (benefit.value != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '价值: ${benefit.value}${benefit.unit ?? ''}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            trailing: benefit.isAvailable
                ? ElevatedButton(
                    onPressed: () => _activateBenefit(benefit),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text('激活'),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      '已激活',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildExchangeTab() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _exchangeItems.length,
      itemBuilder: (context, index) {
        final item = _exchangeItems[index];
        return Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 60,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getExchangeIcon(item.type),
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_formatPoints(item.pointsCost)} 积分',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '库存: ${item.stock}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: item.canExchange &&
                            (_vipUserInfo?.totalPoints ?? 0) >= item.pointsCost
                        ? () => _exchangeItem(item)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: const Text(
                      '兑换',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRewardsTab() {
    final unclaimedRewards = _rewards.where((r) => r.canClaim).toList();
    final claimedRewards = _rewards.where((r) => r.isClaimed).toList();
    
    if (_rewards.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.card_giftcard,
              size: 64,
              color: AppColors.divider,
            ),
            SizedBox(height: 16),
            Text(
              '暂无奖励',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (unclaimedRewards.isNotEmpty) ...[
          const Text(
            '可领取奖励',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...unclaimedRewards.map((reward) => _buildRewardCard(reward, true)),
          const SizedBox(height: 24),
        ],
        if (claimedRewards.isNotEmpty) ...[
          const Text(
            '已领取奖励',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...claimedRewards.map((reward) => _buildRewardCard(reward, false)),
        ],
      ],
    );
  }

  Widget _buildRewardCard(VipReward reward, bool canClaim) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: canClaim
                ? AppColors.success.withOpacity(0.1)
                : AppColors.divider.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getRewardIcon(reward.type),
            color: canClaim ? AppColors.success : AppColors.textSecondary,
          ),
        ),
        title: Text(
          reward.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(reward.description),
            const SizedBox(height: 4),
            Text(
              '价值: ${reward.value} ${reward.currency ?? ''}',
              style: TextStyle(
                color: canClaim ? AppColors.success : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (!canClaim && reward.claimedAt != null)
              Text(
                '领取时间: ${_formatDateTime(reward.claimedAt!)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
          ],
        ),
        trailing: canClaim
            ? ElevatedButton(
                onPressed: () => _claimReward(reward),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('领取'),
              )
            : const Icon(
                Icons.check_circle,
                color: AppColors.success,
              ),
      ),
    );
  }

  Widget _buildPointsRecordTab() {
    if (_pointsRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: AppColors.divider,
            ),
            SizedBox(height: 16),
            Text(
              '暂无积分记录',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pointsRecords.length,
      itemBuilder: (context, index) {
        final record = _pointsRecords[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: record.isPositive
                  ? AppColors.success.withOpacity(0.1)
                  : AppColors.error.withOpacity(0.1),
              child: Icon(
                record.isPositive ? Icons.add : Icons.remove,
                color: record.isPositive ? AppColors.success : AppColors.error,
              ),
            ),
            title: Text(
              record.description,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              '${record.type.displayName} • ${_formatDateTime(record.createdAt)}',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Text(
              '${record.isPositive ? '+' : '-'}${_formatPoints(record.points.abs())}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: record.isPositive ? AppColors.success : AppColors.error,
              ),
            ),
          ),
        );
      },
    );
  }

  // 激活VIP特权
  void _activateBenefit(VipBenefit benefit) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('激活特权'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要激活以下特权吗？'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    benefit.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    benefit.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (benefit.value != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '价值: ${benefit.value}${benefit.unit ?? ''}',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('激活'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.id ?? '';
        
        final success = await _vipService.activateBenefit(benefit.id, userId);
        if (success) {
          _showMessage('特权激活成功！');
          _loadVipData(); // 重新加载数据
        } else {
          _showMessage('激活失败，请重试', isError: true);
        }
      } catch (e) {
        _showMessage('激活失败: $e', isError: true);
      }
    }
  }

  // 兑换商品
  void _exchangeItem(VipExchangeItem item) async {
    // 检查积分是否足够
    if (_vipUserInfo == null || _vipUserInfo!.totalPoints < item.pointsCost) {
      _showMessage('积分不足，无法兑换', isError: true);
      return;
    }
    
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认兑换'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要兑换以下商品吗？'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '所需积分: ${_formatPoints(item.pointsCost)}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '剩余库存: ${item.stock}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('当前积分: ${_formatPoints(_vipUserInfo!.totalPoints)}'),
                Text('兑换后余额: ${_formatPoints(_vipUserInfo!.totalPoints - item.pointsCost)}'),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认兑换'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final userId = authProvider.user?.id ?? '';
        
        final success = await _vipService.exchangePoints(
          userId,
          item.id,
          item.pointsCost,
        );
        
        if (success) {
          _showMessage('兑换成功！');
          _loadVipData(); // 重新加载数据
        } else {
          _showMessage('兑换失败，请重试', isError: true);
        }
      } catch (e) {
        _showMessage('兑换失败: $e', isError: true);
      }
    }
  }

  // 领取奖励
  void _claimReward(VipReward reward) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('领取奖励'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('确定要领取以下奖励吗？'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reward.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reward.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '奖励价值: ${reward.value} ${reward.currency ?? ''}',
                    style: const TextStyle(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: Colors.white,
            ),
            child: const Text('领取'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final success = await _vipService.claimReward(reward.id);
        if (success) {
          _showMessage('奖励领取成功！');
          _loadVipData(); // 重新加载数据
        } else {
          _showMessage('领取失败，请重试', isError: true);
        }
      } catch (e) {
        _showMessage('领取失败: $e', isError: true);
      }
    }
  }

  // 辅助方法
  String _formatPoints(double points) {
    if (points >= 10000) {
      return '${(points / 10000).toStringAsFixed(1)}万';
    }
    return points.toInt().toString();
  }

  Widget _buildQuickAccess() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '快捷入口',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickAccessItem(
                    '积分明细',
                    Icons.history,
                    AppColors.primary,
                    () => Navigator.pushNamed(context, '/vip/points-detail'),
                  ),
                  _buildQuickAccessItem(
                    '等级对比',
                    Icons.compare,
                    AppColors.vipGold,
                    () => Navigator.pushNamed(context, '/vip/levels-comparison'),
                  ),
                  _buildQuickAccessItem(
                    '专属服务',
                    Icons.star,
                    AppColors.success,
                    () => Navigator.pushNamed(context, '/vip/exclusive-services'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessItem(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
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
      default:
        return Icons.star;
    }
  }

  IconData _getExchangeIcon(ExchangeType type) {
    switch (type) {
      case ExchangeType.cash:
        return Icons.attach_money;
      case ExchangeType.bonus:
        return Icons.card_giftcard;
      case ExchangeType.freebet:
        return Icons.sports_soccer;
      case ExchangeType.service:
        return Icons.support_agent;
      case ExchangeType.merchandise:
        return Icons.inventory;
    }
  }

  IconData _getRewardIcon(RewardType type) {
    switch (type) {
      case RewardType.cash:
        return Icons.attach_money;
      case RewardType.bonus:
        return Icons.card_giftcard;
      case RewardType.points:
        return Icons.stars;
      case RewardType.freeSpins:
        return Icons.casino;
      case RewardType.merchandise:
        return Icons.inventory;
    }
  }
  
  // 显示消息
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
  
  // 刷新数据
  Future<void> _refreshData() async {
    await _loadVipData();
    _showMessage('刷新成功');
  }
  
  // 查看VIP等级对比
  void _showLevelComparison() {
    Navigator.pushNamed(context, '/vip/levels-comparison');
  }
  
  // 查看积分明细
  void _showPointsDetail() {
    Navigator.pushNamed(context, '/vip/points-detail');
  }
  
  // 查看专属服务
  void _showExclusiveServices() {
    Navigator.pushNamed(context, '/vip/exclusive-services');
  }
}