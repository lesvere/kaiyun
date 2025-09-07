import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/rebate_models.dart';
import '../../data/services/rebate_service.dart';
import '../../data/api/api_service.dart';

class RebatePage extends StatefulWidget {
  const RebatePage({super.key});

  @override
  State<RebatePage> createState() => _RebatePageState();
}

class _RebatePageState extends State<RebatePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late RebateService _rebateService;
  
  RebateStatistics? _statistics;
  List<RebateRecord> _records = [];
  List<RebateConfig> _configs = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _rebateService = RebateService(ApiService());
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _rebateService.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _rebateService.getRebateStatistics(),
        _rebateService.getRebateRecords(),
        _rebateService.getRebateConfigs(),
      ]);
      
      setState(() {
        _statistics = results[0] as RebateStatistics;
        _records = results[1] as List<RebateRecord>;
        _configs = results[2] as List<RebateConfig>;
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
        title: const Text('实时返水'),
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
            Tab(text: '返水统计'),
            Tab(text: '返水记录'),
            Tab(text: '返水规则'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStatisticsTab(),
                _buildRecordsTab(),
                _buildRulesTab(),
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
          
          // 分类返水统计
          _buildCategoryStatistics(),
          const SizedBox(height: 16),
          
          // 返水趋势图
          _buildRebateTrendChart(),
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
                  Icons.account_balance_wallet,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  '返水总览',
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
                    '今日返水',
                    '¥${_statistics!.todayRebate.toStringAsFixed(2)}',
                    AppColors.success,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '本周返水',
                    '¥${_statistics!.weekRebate.toStringAsFixed(2)}',
                    AppColors.info,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '本月返水',
                    '¥${_statistics!.monthRebate.toStringAsFixed(2)}',
                    AppColors.warning,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '历史返水',
                    '¥${_statistics!.totalRebate.toStringAsFixed(2)}',
                    AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '平均返水率',
                    '${(_statistics!.avgRebateRate * 100).toStringAsFixed(2)}%',
                    AppColors.secondary,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '返水次数',
                    '${_statistics!.totalCount}',
                    AppColors.textSecondary,
                  ),
                ),
              ],
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
  
  Widget _buildCategoryStatistics() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '分类返水统计',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ..._statistics!.categoryRebates.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _getCategoryColor(entry.key),
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
  
  Color _getCategoryColor(String category) {
    switch (category) {
      case '体育投注':
        return AppColors.primary;
      case '真人娱乐':
        return AppColors.success;
      case '电子游戏':
        return AppColors.warning;
      default:
        return AppColors.secondary;
    }
  }
  
  Widget _buildRebateTrendChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '返水趋势',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('返水趋势图表\n（待实现）'),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRecordsTab() {
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
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _applyRebate,
                  icon: const Icon(Icons.add),
                  label: const Text('申请返水'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 记录列表
        Expanded(
          child: _records.isEmpty
              ? const Center(child: Text('暂无返水记录'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _records.length,
                  itemBuilder: (context, index) {
                    final record = _records[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: record.status == RebateStatus.processed
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.warning.withOpacity(0.1),
                          child: Icon(
                            record.status == RebateStatus.processed
                                ? Icons.check
                                : Icons.schedule,
                            color: record.status == RebateStatus.processed
                                ? AppColors.success
                                : AppColors.warning,
                          ),
                        ),
                        title: Text(record.typeText),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('投注金额: ¥${record.betAmount.toStringAsFixed(2)}'),
                            Text('返水率: ${(record.rebateRate * 100).toStringAsFixed(2)}%'),
                            Text('创建时间: ${_formatDateTime(record.createdAt)}'),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '¥${record.amount.toStringAsFixed(2)}',
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
                                color: record.status == RebateStatus.processed
                                    ? AppColors.success.withOpacity(0.1)
                                    : AppColors.warning.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                record.statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: record.status == RebateStatus.processed
                                      ? AppColors.success
                                      : AppColors.warning,
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
  
  Widget _buildRulesTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _configs.length,
      itemBuilder: (context, index) {
        final config = _configs[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ExpansionTile(
            leading: CircleAvatar(
              backgroundColor: config.enabled
                  ? AppColors.success.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              child: Icon(
                config.enabled ? Icons.check_circle : Icons.block,
                color: config.enabled ? AppColors.success : Colors.grey,
              ),
            ),
            title: Text(config.category),
            subtitle: Text('返水率: ${(config.rebateRate * 100).toStringAsFixed(2)}%'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildRuleItem('最低投注金额', '¥${config.minBetAmount}'),
                    _buildRuleItem('最高返水金额', '¥${config.maxRebateAmount}'),
                    _buildRuleItem('返水周期', _getPeriodText(config.period)),
                    _buildRuleItem('VIP等级要求', 'VIP${config.vipLevelRequired}'),
                    _buildRuleItem('状态', config.enabled ? '开启' : '关闭'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildRuleItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
  
  String _getPeriodText(String period) {
    switch (period) {
      case 'daily':
        return '每日';
      case 'weekly':
        return '每周';
      case 'monthly':
        return '每月';
      default:
        return period;
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选条件'),
        content: const Text('筛选功能待实现'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现筛选功能
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
  
  void _applyRebate() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('申请返水'),
        content: const Text('申请返水功能待实现'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: 实现申请返水功能
            },
            child: const Text('申请'),
          ),
        ],
      ),
    );
  }
}
