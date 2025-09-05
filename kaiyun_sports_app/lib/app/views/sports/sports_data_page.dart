import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/betting_models.dart';
import '../../data/services/betting_service.dart';
import '../../data/api/api_service.dart';

class SportsDataPage extends StatefulWidget {
  const SportsDataPage({super.key});

  @override
  State<SportsDataPage> createState() => _SportsDataPageState();
}

class _SportsDataPageState extends State<SportsDataPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BettingService _bettingService;
  
  List<MatchInfo> _liveMatches = [];
  List<MatchInfo> _upcomingMatches = [];
  List<MatchInfo> _popularMatches = [];
  String _selectedCategory = '全部';
  bool _isLoading = true;
  
  final List<String> _categories = [
    '全部', '足球', '篮球', '网球', '羽毛球', '乒乓球'
  ];
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _bettingService = BettingService(ApiService());
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
        _bettingService.getLiveMatches(),
        _bettingService.getUpcomingMatches(),
        _bettingService.getPopularMatches(),
      ]);
      
      setState(() {
        _liveMatches = results[0] as List<MatchInfo>;
        _upcomingMatches = results[1] as List<MatchInfo>;
        _popularMatches = results[2] as List<MatchInfo>;
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
        title: const Text('体育赛事'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              // 分类选择
              Container(
                height: 50,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final isSelected = category == _selectedCategory;
                    return GestureDetector(
                      onTap: () => _onCategoryChanged(category),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? Colors.transparent : Colors.white54,
                          ),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: isSelected ? AppColors.primary : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Tab标签
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: const [
                  Tab(text: '正在进行'),
                  Tab(text: '即将开始'),
                  Tab(text: '热门赛事'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMatchList(_liveMatches, '正在进行'),
                _buildMatchList(_upcomingMatches, '即将开始'),
                _buildMatchList(_popularMatches, '热门赛事'),
              ],
            ),
    );
  }
  
  Widget _buildMatchList(List<MatchInfo> matches, String type) {
    final filteredMatches = _filterMatches(matches);
    
    if (filteredMatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              '暂无${type}的赛事',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredMatches.length,
        itemBuilder: (context, index) {
          final match = filteredMatches[index];
          return _buildMatchCard(match, type);
        },
      ),
    );
  }
  
  List<MatchInfo> _filterMatches(List<MatchInfo> matches) {
    if (_selectedCategory == '全部') {
      return matches;
    }
    return matches.where((match) => match.category == _selectedCategory).toList();
  }
  
  Widget _buildMatchCard(MatchInfo match, String type) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 赛事头部
            _buildMatchHeader(match),
            const SizedBox(height: 16),
            
            // 队伍信息
            _buildTeamInfo(match),
            const SizedBox(height: 16),
            
            // 投注选项
            if (match.bettingOptions.isNotEmpty)
              _buildBettingOptions(match),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMatchHeader(MatchInfo match) {
    return Row(
      children: [
        // 赛事状态
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(match.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getStatusIcon(match.status),
                size: 12,
                color: _getStatusColor(match.status),
              ),
              const SizedBox(width: 4),
              Text(
                _getStatusText(match.status),
                style: TextStyle(
                  fontSize: 12,
                  color: _getStatusColor(match.status),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // 联赛名称
        Expanded(
          child: Text(
            match.league,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        
        // 时间
        Text(
          _formatMatchTime(match.matchTime),
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildTeamInfo(MatchInfo match) {
    return Row(
      children: [
        // 主队
        Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: match.logoHome != null
                    ? Image.network(
                        match.logoHome!,
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            match.homeTeam.substring(0, 1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      )
                    : Text(
                        match.homeTeam.substring(0, 1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                match.homeTeam,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        
        // 比分或 VS
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              if (match.homeScore != null && match.awayScore != null)
                Text(
                  '${match.homeScore} : ${match.awayScore}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                )
              else
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
                ),
              if (match.status == MatchStatus.live)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // 客队
        Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: match.logoAway != null
                    ? Image.network(
                        match.logoAway!,
                        width: 24,
                        height: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Text(
                            match.awayTeam.substring(0, 1),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      )
                    : Text(
                        match.awayTeam.substring(0, 1),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
              const SizedBox(height: 8),
              Text(
                match.awayTeam,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBettingOptions(MatchInfo match) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '投注选项',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: match.bettingOptions.map((option) {
              return GestureDetector(
                onTap: option.available
                    ? () => _showBetDialog(match, option)
                    : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: option.available ? Colors.white : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: option.available 
                          ? AppColors.primary.withOpacity(0.3)
                          : Colors.grey,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        option.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: option.available 
                              ? AppColors.textPrimary
                              : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        option.odds.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: option.available 
                              ? AppColors.primary
                              : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(MatchStatus status) {
    switch (status) {
      case MatchStatus.live:
        return Colors.red;
      case MatchStatus.scheduled:
        return AppColors.info;
      case MatchStatus.finished:
        return Colors.grey;
      case MatchStatus.cancelled:
        return AppColors.warning;
    }
  }
  
  IconData _getStatusIcon(MatchStatus status) {
    switch (status) {
      case MatchStatus.live:
        return Icons.play_circle_filled;
      case MatchStatus.scheduled:
        return Icons.schedule;
      case MatchStatus.finished:
        return Icons.check_circle;
      case MatchStatus.cancelled:
        return Icons.cancel;
    }
  }
  
  String _getStatusText(MatchStatus status) {
    switch (status) {
      case MatchStatus.live:
        return '进行中';
      case MatchStatus.scheduled:
        return '未开始';
      case MatchStatus.finished:
        return '已结束';
      case MatchStatus.cancelled:
        return '已取消';
    }
  }
  
  String _formatMatchTime(DateTime matchTime) {
    final now = DateTime.now();
    final difference = matchTime.difference(now);
    
    if (difference.isNegative) {
      return '${matchTime.hour.toString().padLeft(2, '0')}:${matchTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays > 0) {
      return '${matchTime.month}/${matchTime.day} ${matchTime.hour.toString().padLeft(2, '0')}:${matchTime.minute.toString().padLeft(2, '0')}';
    } else {
      return '${matchTime.hour.toString().padLeft(2, '0')}:${matchTime.minute.toString().padLeft(2, '0')}';
    }
  }
  
  void _onCategoryChanged(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }
  
  void _showBetDialog(MatchInfo match, BettingOption option) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认投注'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('赛事: ${match.homeTeam} vs ${match.awayTeam}'),
            Text('投注选项: ${option.name}'),
            Text('赔率: ${option.odds}'),
            const SizedBox(height: 12),
            const TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: '投注金额',
                hintText: '请输入投注金额',
                border: OutlineInputBorder(),
              ),
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
              // TODO: 实现投注功能
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('投注功能待实现')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('确认投注'),
          ),
        ],
      ),
    );
  }
}
