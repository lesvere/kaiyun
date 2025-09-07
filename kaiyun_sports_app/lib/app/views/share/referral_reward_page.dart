import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/referral_models.dart';
import '../../data/services/referral_service.dart';
import '../../data/api/api_service.dart';

class ReferralRewardPage extends StatefulWidget {
  const ReferralRewardPage({super.key});

  @override
  State<ReferralRewardPage> createState() => _ReferralRewardPageState();
}

class _ReferralRewardPageState extends State<ReferralRewardPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ReferralService _referralService;
  
  ReferralStatistics? _statistics;
  List<ReferralReward> _rewards = [];
  ReferralCode? _referralCode;
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _referralService = ReferralService(ApiService());
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _referralService.getReferralStatistics(),
        _referralService.getReferralRewards(),
        _referralService.getReferralCode('current_user'), // 实际使用应从用户状态获取
      ]);
      
      setState(() {
        _statistics = results[0] as ReferralStatistics;
        _rewards = results[1] as List<ReferralReward>;
        _referralCode = results[2] as ReferralCode;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载失败: $e')),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('推荐奖励'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: '推荐统计'),
            Tab(text: '奖励记录'),
            Tab(text: '我的推荐'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatisticsTab(),
                _buildRewardsTab(),
                _buildMyReferralTab(),
              ],
            ),
    );
  }
  
  Widget _buildStatisticsTab() {
    if (_statistics == null) {
      return const Center(child: Text('暂无数据'));
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 总览卡片
          _buildOverviewCard(),
          const SizedBox(height: 16),
          
          // 层级统计
          _buildLevelStatistics(),
          const SizedBox(height: 16),
          
          // 奖励分类统计
          _buildRewardTypeStatistics(),
          const SizedBox(height: 16),
          
          // 最近推荐
          _buildRecentReferrals(),
        ],
      ),
    );
  }
  
  Widget _buildOverviewCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(
                  Icons.group_add,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  '推荐总览',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '总推荐人数',
                    '${_statistics!.totalReferrals}',
                    AppColors.primary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '活跃推荐',
                    '${_statistics!.activeReferrals}',
                    AppColors.success,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '今日奖励',
                    '¥${_statistics!.todayReward.toStringAsFixed(2)}',
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '本月奖励',
                    '¥${_statistics!.monthReward.toStringAsFixed(2)}',
                    AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text('累计奖励'),
                  const SizedBox(height: 4),
                  Text(
                    '¥${_statistics!.totalReward.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLevelStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '层级统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLevelItem('一级推荐', _statistics!.level1Count, Colors.blue),
                ),
                Expanded(
                  child: _buildLevelItem('二级推荐', _statistics!.level2Count, Colors.green),
                ),
                Expanded(
                  child: _buildLevelItem('三级推荐', _statistics!.level3Count, Colors.orange),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLevelItem(String label, int count, Color color) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardTypeStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '奖励分类统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._statistics!.rewardByType.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getRewardTypeColor(entry.key),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(entry.key)),
                    Text(
                      '¥${entry.value.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getRewardTypeColor(String type) {
    switch (type) {
      case '注册奖励':
        return Colors.blue;
      case '首存奖励':
        return Colors.green;
      case '投注分成':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  
  Widget _buildRecentReferrals() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '最近推荐',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            if (_statistics!.recentReferrals.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Text('暂无推荐记录'),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _statistics!.recentReferrals.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final referral = _statistics!.recentReferrals[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: referral.isActive
                          ? AppColors.success.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      child: Text(
                        referral.username.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          color: referral.isActive ? AppColors.success : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(referral.username),
                    subtitle: Text('注册时间: ${_formatDate(referral.registerTime)}'),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '奖励: ¥${referral.totalReward.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                        ),
                        Text(
                          referral.isActive ? '活跃' : '非活跃',
                          style: TextStyle(
                            fontSize: 12,
                            color: referral.isActive ? AppColors.success : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardsTab() {
    return Column(
      children: [
        // 筛选按钮
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: const Icon(Icons.filter_list),
                  label: const Text('筛选'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 奖励列表
        Expanded(
          child: _rewards.isEmpty
              ? const Center(child: Text('暂无奖励记录'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _rewards.length,
                  itemBuilder: (context, index) {
                    final reward = _rewards[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getStatusColor(reward.status).withOpacity(0.1),
                          child: Icon(
                            _getStatusIcon(reward.status),
                            color: _getStatusColor(reward.status),
                          ),
                        ),
                        title: Text(reward.typeText),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('被推荐人: ${reward.refereeUsername}'),
                            Text('层级: ${reward.level}'),
                            Text('创建时间: ${_formatDateTime(reward.createdAt)}'),
                            if (reward.description != null)
                              Text('说明: ${reward.description}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '¥${reward.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor(reward.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                reward.statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getStatusColor(reward.status),
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
    );
  }
  
  Widget _buildMyReferralTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 推荐码卡片
          if (_referralCode != null) _buildReferralCodeCard(),
          const SizedBox(height: 16),
          
          // 推荐规则
          _buildReferralRules(),
          const SizedBox(height: 16),
          
          // 奖励说明
          _buildRewardDescription(),
        ],
      ),
    );
  }
  
  Widget _buildReferralCodeCard() {
    final referralLink = _referralService.getReferralLink(_referralCode!.code);
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.share,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  '我的推荐码',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    _referralCode!.code,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '已使用: ${_referralCode!.usageCount} 次',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(_referralCode!.code),
                    icon: const Icon(Icons.copy),
                    label: const Text('复制码'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      foregroundColor: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _copyToClipboard(referralLink),
                    icon: const Icon(Icons.link),
                    label: const Text('复制链接'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildReferralRules() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '推荐规则',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              '1. 分享您的推荐码给朋友，朋友注册时输入推荐码',
              style: TextStyle(height: 1.5),
            ),
            Text(
              '2. 朋友成功注册后，您将获得注册奖励',
              style: TextStyle(height: 1.5),
            ),
            Text(
              '3. 朋友首次充值后，您将获得额外奖励',
              style: TextStyle(height: 1.5),
            ),
            Text(
              '4. 朋友投注时，您将获得持续的分成奖励',
              style: TextStyle(height: 1.5),
            ),
            Text(
              '5. 推荐奖励支持三级分成，越多朋友推荐越多奖励',
              style: TextStyle(height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardDescription() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '奖励说明',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildRewardItem('注册奖励', '¥50', '被推荐人成功注册'),
            _buildRewardItem('首存奖励', '5%', '被推荐人首次充值金额的 5%'),
            _buildRewardItem('投注分成', '0.8%', '被推荐人投注金额的 0.8%'),
            const SizedBox(height: 8),
            const Text(
              '• 一级推荐: 100% 奖励',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Text(
              '• 二级推荐: 50% 奖励',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const Text(
              '• 三级推荐: 20% 奖励',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRewardItem(String title, String amount, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(RewardStatus status) {
    switch (status) {
      case RewardStatus.pending:
        return AppColors.warning;
      case RewardStatus.approved:
        return AppColors.success;
      case RewardStatus.rejected:
        return AppColors.error;
    }
  }
  
  IconData _getStatusIcon(RewardStatus status) {
    switch (status) {
      case RewardStatus.pending:
        return Icons.schedule;
      case RewardStatus.approved:
        return Icons.check_circle;
      case RewardStatus.rejected:
        return Icons.cancel;
    }
  }
  
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('复制成功')),
    );
  }
  
  void _showFilterDialog() {
    RewardStatus? filterStatus;
    DateTime? startDate;
    DateTime? endDate;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('筛选条件'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<RewardStatus?>(
                  value: filterStatus,
                  decoration: const InputDecoration(
                    labelText: '奖励状态',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('全部'),
                    ),
                    ...RewardStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.toString().split('.').last),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      filterStatus = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: '开始日期',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: startDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              startDate = date;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: startDate != null 
                              ? _formatDate(startDate!)
                              : '',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: '结束日期',
                          border: OutlineInputBorder(),
                        ),
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: endDate ?? DateTime.now(),
                            firstDate: startDate ?? DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              endDate = date;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: endDate != null 
                              ? _formatDate(endDate!)
                              : '',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _applyFilter(filterStatus, startDate, endDate);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('应用'),
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _applyFilter(RewardStatus? status, DateTime? startDate, DateTime? endDate) async {
    try {
      final filteredRewards = await _referralService.getReferralRewards(
        status: status,
        startDate: startDate,
        endDate: endDate,
      );
      
      setState(() {
        _rewards = filteredRewards;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('筛选完成')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('筛选失败: $e')),
      );
    }
  }
}
