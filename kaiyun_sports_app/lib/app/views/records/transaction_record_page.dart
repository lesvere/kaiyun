import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class TransactionRecordPage extends StatelessWidget {
  const TransactionRecordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('交易记录'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 筛选条
          _buildFilterBar(),
          
          // 交易列表
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: AppColors.background,
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: 日期筛选
              },
              child: const Text('选择日期'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                // TODO: 类型筛选
              },
              child: const Text('交易类型'),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionList() {
    // 模拟数据
    final transactions = [
      {
        'id': 'T20240905001',
        'type': '存款',
        'amount': '+1000.00',
        'status': '成功',
        'time': '2024-09-05 14:30:25',
        'color': AppColors.success,
      },
      {
        'id': 'T20240905002',
        'type': '取款',
        'amount': '-500.00',
        'status': '处理中',
        'time': '2024-09-05 16:15:10',
        'color': AppColors.warning,
      },
      {
        'id': 'T20240904001',
        'type': '转账',
        'amount': '-200.00',
        'status': '成功',
        'time': '2024-09-04 10:20:33',
        'color': AppColors.info,
      },
    ];
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: transaction['color'] as Color,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                _getTransactionIcon(transaction['type'] as String),
                color: Colors.white,
              ),
            ),
            title: Text(
              transaction['type'] as String,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${transaction['id']}'),
                Text(
                  transaction['time'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            trailing: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '¥${transaction['amount']}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: (transaction['amount'] as String).startsWith('+')
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: (transaction['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction['status'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: transaction['color'] as Color,
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
  
  IconData _getTransactionIcon(String type) {
    switch (type) {
      case '存款':
        return Icons.add;
      case '取款':
        return Icons.remove;
      case '转账':
        return Icons.swap_horiz;
      default:
        return Icons.monetization_on;
    }
  }
}