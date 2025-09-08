import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/bet_models.dart';
import '../../providers/bet_provider.dart';
import '../../data/services/bet_service.dart';

class BetRecordPage extends StatefulWidget {
  const BetRecordPage({super.key});
  
  @override
  State<BetRecordPage> createState() => _BetRecordPageState();
}

class _BetRecordPageState extends State<BetRecordPage> with TickerProviderStateMixin {

  late TabController _tabController;
  final BetService _betService = BetService();
  
  BetStatistics? _statistics;
  List<BetRecord> _betRecords = [];
  bool _isLoading = true;
  BetStatus? _filterStatus;
  DateTime? _filterStartDate;
  DateTime? _filterEndDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
        _betService.getBetStatistics(),
        _betService.getBetRecords(),
      ]);
      
      setState(() {
        _statistics = results[0] as BetStatistics;
        _betRecords = results[1] as List<BetRecord>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showMessage('加载失败: $e', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('投注记录'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showFilterDialog,
            icon: const Icon(Icons.filter_list),
          ),
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
            Tab(text: '全部'),
            Tab(text: '进行中'),
            Tab(text: '已结算'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildBetListTab(null),
                _buildBetListTab(BetStatus.pending),
                _buildBetListTab(BetStatus.settled),
              ],
            ),
    );
  }
  
  Widget _buildStatisticsCard() {
    if (_statistics == null) return const SizedBox();
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [AppColors.primary.withOpacity(0.1), Colors.white],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.sports_soccer, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text(
                      '投注统计',
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
                        '今日投注',
                        '¥${_statistics!.todayBetAmount.toStringAsFixed(2)}',
                        AppColors.primary,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '今日盈亏',
                        '${_statistics!.todayProfit >= 0 ? '+' : ''}¥${_statistics!.todayProfit.toStringAsFixed(2)}',
                        _statistics!.todayProfit >= 0 ? AppColors.success : AppColors.error,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        '胜率',
                        '${(_statistics!.winRate * 100).toStringAsFixed(1)}%',
                        AppColors.info,
                      ),
                    ),
                    Expanded(
                      child: _buildStatItem(
                        '总盈亏',
                        '${_statistics!.totalProfit >= 0 ? '+' : ''}¥${_statistics!.totalProfit.toStringAsFixed(2)}',
                        _statistics!.totalProfit >= 0 ? AppColors.success : AppColors.error,
                      ),
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
  
  Widget _buildBetListTab(BetStatus? filterStatus) {
    final filteredBets = filterStatus == null 
        ? _betRecords 
        : _betRecords.where((bet) => bet.status == filterStatus).toList();
    
    return Column(
      children: [
        // 统计信息
        _buildStatisticsCard(),
        
        // 投注列表
        Expanded(
          child: _buildBetList(filteredBets),
        ),
      ],
    );
  }
  
  Widget _buildBetList(List<BetRecord> bets) {
    if (bets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: AppColors.divider,
            ),
            SizedBox(height: 16),
            Text(
              '暂无投注记录',
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: bets.length,
      itemBuilder: (context, index) {
        final bet = bets[index];
        return _buildBetCard(bet);
      },
    );
  }
  
  Widget _buildBetCard(BetRecord bet) {
    final statusColor = _getStatusColor(bet.status);
    final statusIcon = _getStatusIcon(bet.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () => _showBetDetail(bet),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    statusIcon,
                    color: statusColor,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    bet.betId,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatDateTime(bet.createdAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                bet.matchName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '${bet.betType} @ ${bet.odds.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '投注: ¥${bet.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      bet.statusText,
                      style: TextStyle(
                        fontSize: 12,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (bet.status == BetStatus.settled)
                    Text(
                      '${bet.profit >= 0 ? '+' : ''}¥${bet.profit.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: bet.profit >= 0 ? AppColors.success : AppColors.error,
                      ),
                    )
                  else if (bet.status == BetStatus.pending)
                    Text(
                      '可赢: ¥${bet.potentialWin.toStringAsFixed(2)}',
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
      ),
    );
  }
  
  Color _getStatusColor(BetStatus status) {
    switch (status) {
      case BetStatus.pending:
        return AppColors.warning;
      case BetStatus.won:
        return AppColors.success;
      case BetStatus.lost:
        return AppColors.error;
      case BetStatus.settled:
        return AppColors.info;
      case BetStatus.cancelled:
        return AppColors.textSecondary;
    }
  }
  
  IconData _getStatusIcon(BetStatus status) {
    switch (status) {
      case BetStatus.pending:
        return Icons.schedule;
      case BetStatus.won:
        return Icons.check_circle;
      case BetStatus.lost:
        return Icons.cancel;
      case BetStatus.settled:
        return Icons.sports_soccer;
      case BetStatus.cancelled:
        return Icons.block;
    }
  }
  
  void _showBetDetail(BetRecord bet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildBetDetailSheet(bet),
    );
  }
  
  Widget _buildBetDetailSheet(BetRecord bet) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 拖拽指示器
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // 标题
                Text(
                  '投注详情',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                
                // 投注信息
                _buildDetailItem('投注单号', bet.betId),
                _buildDetailItem('比赛', bet.matchName),
                _buildDetailItem('投注类型', bet.betType),
                _buildDetailItem('赔率', bet.odds.toStringAsFixed(2)),
                _buildDetailItem('投注金额', '¥${bet.amount.toStringAsFixed(2)}'),
                _buildDetailItem('状态', bet.statusText),
                if (bet.status == BetStatus.settled)
                  _buildDetailItem('盈亏', '${bet.profit >= 0 ? '+' : ''}¥${bet.profit.toStringAsFixed(2)}'),
                if (bet.status == BetStatus.pending)
                  _buildDetailItem('可赢金额', '¥${bet.potentialWin.toStringAsFixed(2)}'),
                _buildDetailItem('下注时间', _formatDateTime(bet.createdAt)),
                if (bet.settledAt != null)
                  _buildDetailItem('结算时间', _formatDateTime(bet.settledAt!)),
                
                const SizedBox(height: 20),
                
                // 操作按钮
                if (bet.status == BetStatus.pending) ..[
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _cancelBet(bet),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('取消投注'),
                    ),
                  ),
                ],
                
                const SizedBox(bottom: 20),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Future<void> _cancelBet(BetRecord bet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认取消'),
        content: const Text('确定要取消这个投注吗？取消后无法恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      try {
        final success = await _betService.cancelBet(bet.id);
        if (success) {
          _showMessage('投注已取消');
          Navigator.pop(context); // 关闭详情页
          _loadData(); // 刷新数据
        } else {
          _showMessage('取消失败，请重试', isError: true);
        }
      } catch (e) {
        _showMessage('取消失败: $e', isError: true);
      }
    }
  }
  
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选条件'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<BetStatus?>(
                  value: _filterStatus,
                  decoration: const InputDecoration(
                    labelText: '状态',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('全部'),
                    ),
                    ...BetStatus.values.map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status.displayName),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _filterStatus = value;
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
                            initialDate: _filterStartDate ?? DateTime.now(),
                            firstDate: DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _filterStartDate = date;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: _filterStartDate != null 
                              ? _formatDate(_filterStartDate!)
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
                            initialDate: _filterEndDate ?? DateTime.now(),
                            firstDate: _filterStartDate ?? DateTime.now().subtract(const Duration(days: 365)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() {
                              _filterEndDate = date;
                            });
                          }
                        },
                        controller: TextEditingController(
                          text: _filterEndDate != null 
                              ? _formatDate(_filterEndDate!)
                              : '',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              setState(() {});
              _applyFilter();
              Navigator.pop(context);
            },
            child: const Text('应用'),
          ),
        ],
      ),
    );
  }
  
  void _applyFilter() {
    // 应用筛选条件
    _loadData();
  }
  
  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}