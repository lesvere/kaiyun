import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/finance_provider.dart';
import '../../data/models/finance_models.dart';

class TransactionRecordsPage extends StatefulWidget {
  const TransactionRecordsPage({super.key});

  @override
  State<TransactionRecordsPage> createState() => _TransactionRecordsPageState();
}

class _TransactionRecordsPageState extends State<TransactionRecordsPage>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;
  
  bool _isFilterExpanded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FinanceProvider>().getTransactionRecords(refresh: true);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<FinanceProvider>().getTransactionRecords(loadMore: true);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('交易记录'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: AnimatedRotation(
              turns: _isFilterExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: _toggleFilter,
          ),
        ],
      ),
      body: Column(
        children: [
          // 筛选器
          AnimatedBuilder(
            animation: _filterAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _filterAnimation,
                child: _buildFilterSection(),
              );
            },
          ),
          
          // 交易记录列表
          Expanded(
            child: Consumer<FinanceProvider>(
              builder: (context, financeProvider, child) {
                return RefreshIndicator(
                  onRefresh: () async {
                    await financeProvider.getTransactionRecords(refresh: true);
                  },
                  child: _buildTransactionList(financeProvider),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFilter() {
    setState(() {
      _isFilterExpanded = !_isFilterExpanded;
    });
    if (_isFilterExpanded) {
      _filterAnimationController.forward();
    } else {
      _filterAnimationController.reverse();
    }
  }

  Widget _buildFilterSection() {
    return Consumer<FinanceProvider>(
      builder: (context, financeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      label: '交易类型',
                      value: financeProvider.filterType?.getTypeDisplayName(),
                      onTap: () => _showTypeFilter(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      label: '状态',
                      value: financeProvider.filterStatus?.getStatusDisplayName(),
                      onTap: () => _showStatusFilter(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      label: '开始时间',
                      value: financeProvider.filterStartDate?.toString().substring(0, 10),
                      onTap: () => _selectStartDate(context),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildFilterChip(
                      label: '结束时间',
                      value: financeProvider.filterEndDate?.toString().substring(0, 10),
                      onTap: () => _selectEndDate(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        financeProvider.clearFilter();
                        financeProvider.applyFilter();
                      },
                      child: const Text('清除筛选'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        financeProvider.applyFilter();
                        _toggleFilter();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('应用筛选'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    String? value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: value != null ? AppColors.primary : AppColors.divider,
          ),
          borderRadius: BorderRadius.circular(8),
          color: value != null ? AppColors.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    value ?? '全部',
                    style: TextStyle(
                      fontSize: 14,
                      color: value != null ? AppColors.primary : AppColors.textSecondary,
                      fontWeight: value != null ? FontWeight.w500 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: value != null ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList(FinanceProvider financeProvider) {
    if (financeProvider.isLoading && financeProvider.transactionRecords.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (financeProvider.error != null && financeProvider.transactionRecords.isEmpty) {
      return _buildErrorView(financeProvider.error!);
    }

    if (financeProvider.transactionRecords.isEmpty) {
      return _buildEmptyView();
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: financeProvider.transactionRecords.length + 
          (financeProvider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == financeProvider.transactionRecords.length) {
          return _buildLoadingIndicator(financeProvider.isLoadingMore);
        }
        
        final record = financeProvider.transactionRecords[index];
        return _buildTransactionItem(record);
      },
    );
  }

  Widget _buildTransactionItem(TransactionRecord record) {
    Color statusColor;
    IconData statusIcon;
    Color typeColor;
    IconData typeIcon;

    // 状态颜色和图标
    switch (record.status) {
      case TransactionStatus.completed:
        statusColor = AppColors.success;
        statusIcon = Icons.check_circle;
        break;
      case TransactionStatus.pending:
        statusColor = AppColors.warning;
        statusIcon = Icons.schedule;
        break;
      case TransactionStatus.processing:
        statusColor = AppColors.info;
        statusIcon = Icons.autorenew;
        break;
      case TransactionStatus.failed:
        statusColor = AppColors.error;
        statusIcon = Icons.cancel;
        break;
      case TransactionStatus.cancelled:
        statusColor = AppColors.textSecondary;
        statusIcon = Icons.block;
        break;
    }

    // 交易类型颜色和图标
    switch (record.type) {
      case TransactionType.deposit:
        typeColor = AppColors.success;
        typeIcon = Icons.add_circle_outline;
        break;
      case TransactionType.withdrawal:
        typeColor = AppColors.warning;
        typeIcon = Icons.remove_circle_outline;
        break;
      case TransactionType.transfer:
        typeColor = AppColors.info;
        typeIcon = Icons.swap_horiz;
        break;
      case TransactionType.bonus:
        typeColor = AppColors.primary;
        typeIcon = Icons.card_giftcard;
        break;
      case TransactionType.refund:
        typeColor = AppColors.success;
        typeIcon = Icons.undo;
        break;
      case TransactionType.fee:
        typeColor = AppColors.error;
        typeIcon = Icons.receipt;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showTransactionDetail(record),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      typeIcon,
                      color: typeColor,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              record.getTypeDisplayName(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              '￥${record.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: record.type == TransactionType.deposit ||
                                       record.type == TransactionType.bonus ||
                                       record.type == TransactionType.refund
                                    ? AppColors.success
                                    : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              statusIcon,
                              color: statusColor,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              record.getStatusDisplayName(),
                              style: TextStyle(
                                fontSize: 12,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (record.paymentMethod != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '• ${record.getPaymentMethodDisplayName()}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    record.createdAt.toString().substring(0, 19),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (record.orderId != null)
                    Text(
                      '订单号: ${record.orderId}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                ],
              ),
              if (record.description != null && record.description!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    record.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
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

  Widget _buildLoadingIndicator(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: isLoading
          ? const CircularProgressIndicator()
          : const Text(
              '没有更多数据了',
              style: TextStyle(color: AppColors.textSecondary),
            ),
    );
  }

  Widget _buildErrorView(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            error,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<FinanceProvider>().getTransactionRecords(refresh: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          const Text(
            '暂无交易记录',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showTypeFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择交易类型',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('全部'),
                onTap: () {
                  context.read<FinanceProvider>().setFilter(type: null);
                  Navigator.pop(context);
                },
              ),
              ...TransactionType.values.map((type) => ListTile(
                title: Text(type.getTypeDisplayName()),
                onTap: () {
                  context.read<FinanceProvider>().setFilter(type: type);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showStatusFilter(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '选择状态',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                title: const Text('全部'),
                onTap: () {
                  context.read<FinanceProvider>().setFilter(status: null);
                  Navigator.pop(context);
                },
              ),
              ...TransactionStatus.values.map((status) => ListTile(
                title: Text(status.getStatusDisplayName()),
                onTap: () {
                  context.read<FinanceProvider>().setFilter(status: status);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      context.read<FinanceProvider>().setFilter(startDate: date);
    }
  }

  void _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      context.read<FinanceProvider>().setFilter(endDate: date);
    }
  }

  void _showTransactionDetail(TransactionRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildTransactionDetailSheet(record),
    );
  }

  Widget _buildTransactionDetailSheet(TransactionRecord record) {
    return Container(
      padding: const EdgeInsets.all(20),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '交易详情',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildDetailItem('交易ID', record.id),
          _buildDetailItem('交易类型', record.getTypeDisplayName()),
          _buildDetailItem('交易状态', record.getStatusDisplayName()),
          _buildDetailItem('交易金额', '￥${record.amount.toStringAsFixed(2)}'),
          if (record.fee != null)
            _buildDetailItem('手续费', '￥${record.fee!.toStringAsFixed(2)}'),
          if (record.paymentMethod != null)
            _buildDetailItem('支付方式', record.getPaymentMethodDisplayName()),
          if (record.paymentAccount != null)
            _buildDetailItem('支付账户', record.paymentAccount!),
          if (record.orderId != null)
            _buildDetailItem('订单号', record.orderId!),
          _buildDetailItem('创建时间', record.createdAt.toString().substring(0, 19)),
          if (record.processedAt != null)
            _buildDetailItem('处理时间', record.processedAt!.toString().substring(0, 19)),
          if (record.description != null && record.description!.isNotEmpty)
            _buildDetailItem('描述', record.description!),
          if (record.remark != null && record.remark!.isNotEmpty)
            _buildDetailItem('备注', record.remark!),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 扩展方法，添加到 finance_models.dart 中的方法
extension TransactionTypeExtension on TransactionType {
  String getTypeDisplayName() {
    switch (this) {
      case TransactionType.deposit:
        return '存款';
      case TransactionType.withdrawal:
        return '取款';
      case TransactionType.transfer:
        return '转账';
      case TransactionType.bonus:
        return '奖金';
      case TransactionType.refund:
        return '退款';
      case TransactionType.fee:
        return '手续费';
    }
  }
}

extension TransactionStatusExtension on TransactionStatus {
  String getStatusDisplayName() {
    switch (this) {
      case TransactionStatus.pending:
        return '待处理';
      case TransactionStatus.processing:
        return '处理中';
      case TransactionStatus.completed:
        return '已完成';
      case TransactionStatus.failed:
        return '失败';
      case TransactionStatus.cancelled:
        return '已取消';
    }
  }
}