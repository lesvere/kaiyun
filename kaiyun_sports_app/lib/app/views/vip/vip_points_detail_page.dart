import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/vip_models.dart';
import '../../data/services/vip_service.dart';
import '../../providers/auth_provider.dart';
import 'package:provider/provider.dart';

class VipPointsDetailPage extends StatefulWidget {
  const VipPointsDetailPage({super.key});

  @override
  State<VipPointsDetailPage> createState() => _VipPointsDetailPageState();
}

class _VipPointsDetailPageState extends State<VipPointsDetailPage> {
  final VipService _vipService = VipService();
  
  List<VipPointsRecord> _pointsRecords = [];
  bool _isLoading = true;
  PointsType? _selectedType;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMore = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPointsRecords();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && 
        _hasMore && !_isLoading) {
      _loadMoreRecords();
    }
  }

  Future<void> _loadPointsRecords() async {
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      
      if (userId.isNotEmpty) {
        final records = await _vipService.getPointsRecords(
          userId,
          page: 1,
          pageSize: _pageSize,
          type: _selectedType,
        );
        
        _pointsRecords = records;
        _currentPage = 1;
        _hasMore = records.length == _pageSize;
      }
    } catch (e) {
      // 显示默认数据
      _pointsRecords = _createDemoRecords();
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _loadMoreRecords() async {
    if (_isLoading || !_hasMore) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.currentUser?.id ?? '';
      
      if (userId.isNotEmpty) {
        final records = await _vipService.getPointsRecords(
          userId,
          page: _currentPage + 1,
          pageSize: _pageSize,
          type: _selectedType,
        );
        
        if (records.isNotEmpty) {
          _pointsRecords.addAll(records);
          _currentPage++;
          _hasMore = records.length == _pageSize;
        } else {
          _hasMore = false;
        }
      }
    } catch (e) {
      _hasMore = false;
    }
    
    setState(() => _isLoading = false);
  }

  List<VipPointsRecord> _createDemoRecords() {
    final now = DateTime.now();
    return [
      VipPointsRecord(
        id: '1',
        userId: 'demo_user',
        points: 1000,
        type: PointsType.bet,
        description: '体育投注获得积分',
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      VipPointsRecord(
        id: '2',
        userId: 'demo_user',
        points: 500,
        type: PointsType.deposit,
        description: '充值获得积分',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      VipPointsRecord(
        id: '3',
        userId: 'demo_user',
        points: 100,
        type: PointsType.login,
        description: '每日签到奖励',
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      VipPointsRecord(
        id: '4',
        userId: 'demo_user',
        points: -2000,
        type: PointsType.exchange,
        description: '兑换50元现金',
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      VipPointsRecord(
        id: '5',
        userId: 'demo_user',
        points: 2000,
        type: PointsType.promotion,
        description: '参与活动获得积分',
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分明细'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildPointsSummaryCard(),
          _buildTypeFilter(),
          Expanded(
            child: _isLoading && _pointsRecords.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _buildRecordsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsSummaryCard() {
    final totalPoints = _pointsRecords.fold<double>(
        0, (sum, record) => sum + record.points);
    final positivePoints = _pointsRecords
        .where((r) => r.points > 0)
        .fold<double>(0, (sum, record) => sum + record.points);
    final negativePoints = _pointsRecords
        .where((r) => r.points < 0)
        .fold<double>(0, (sum, record) => sum + record.points.abs());
    
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  '总积分变动',
                  '${totalPoints > 0 ? '+' : ''}${_formatPoints(totalPoints)}',
                  Icons.trending_up,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  '获得积分',
                  '+${_formatPoints(positivePoints)}',
                  Icons.add_circle,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildSummaryItem(
                  '消耗积分',
                  '-${_formatPoints(negativePoints)}',
                  Icons.remove_circle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
        const SizedBox(height: 8),
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
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('全部', null),
          ...PointsType.values.map((type) => _buildFilterChip(type.displayName, type)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, PointsType? type) {
    final isSelected = _selectedType == type;
    
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedType = selected ? type : null;
          });
          _loadPointsRecords();
        },
        selectedColor: AppColors.primary,
        backgroundColor: Colors.white,
        side: BorderSide(color: isSelected ? AppColors.primary : AppColors.divider),
      ),
    );
  }

  Widget _buildRecordsList() {
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
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _pointsRecords.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _pointsRecords.length) {
          return _buildLoadingIndicator();
        }
        
        final record = _pointsRecords[index];
        return _buildRecordItem(record);
      },
    );
  }

  Widget _buildRecordItem(VipPointsRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: record.isPositive
              ? AppColors.success.withOpacity(0.1)
              : AppColors.error.withOpacity(0.1),
          child: Icon(
            record.isPositive ? Icons.add : Icons.remove,
            color: record.isPositive ? AppColors.success : AppColors.error,
            size: 20,
          ),
        ),
        title: Text(
          record.description,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTypeColor(record.type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    record.type.displayName,
                    style: TextStyle(
                      color: _getTypeColor(record.type),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(record.createdAt),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${record.isPositive ? '+' : '-'}${_formatPoints(record.points.abs())}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: record.isPositive ? AppColors.success : AppColors.error,
              ),
            ),
            const Text(
              '积分',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('筛选积分记录'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('选择积分类型：'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildDialogFilterChip('全部', null),
                ...PointsType.values.map((type) => 
                    _buildDialogFilterChip(type.displayName, type)),
              ],
            ),
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
              _loadPointsRecords();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogFilterChip(String label, PointsType? type) {
    final isSelected = _selectedType == type;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedType = selected ? type : null;
        });
      },
      selectedColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
    );
  }

  // 辅助方法
  String _formatPoints(double points) {
    if (points.abs() >= 10000) {
      return '${(points / 10000).toStringAsFixed(1)}万';
    }
    return points.toInt().toString();
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}分钟前';
      }
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }

  Color _getTypeColor(PointsType type) {
    switch (type) {
      case PointsType.bet:
        return AppColors.primary;
      case PointsType.deposit:
        return AppColors.success;
      case PointsType.login:
        return AppColors.info;
      case PointsType.referral:
        return AppColors.vipGold;
      case PointsType.birthday:
        return Colors.pink;
      case PointsType.promotion:
        return Colors.purple;
      case PointsType.compensation:
        return Colors.orange;
      case PointsType.exchange:
        return AppColors.error;
    }
  }
}