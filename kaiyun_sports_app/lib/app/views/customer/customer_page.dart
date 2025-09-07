import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/customer_service_models.dart';
import '../../data/services/customer_service.dart';
import '../../data/api/api_service.dart';

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late CustomerService _customerService;
  
  List<ServiceCategory> _categories = [];
  List<FAQ> _faqs = [];
  List<CustomerAgent> _agents = [];
  List<CustomerSession> _sessions = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _customerService = CustomerService(ApiService());
    _loadData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _customerService.dispose();
    super.dispose();
  }
  
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final results = await Future.wait([
        _customerService.getServiceCategories(),
        _customerService.getFAQs(),
        _customerService.getOnlineAgents(),
        _customerService.getUserSessions('current_user'), // 实际使用应从用户状态获取
      ]);
      
      setState(() {
        _categories = results[0] as List<ServiceCategory>;
        _faqs = results[1] as List<FAQ>;
        _agents = results[2] as List<CustomerAgent>;
        _sessions = results[3] as List<CustomerSession>;
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
        title: const Text('客服中心'),
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
          isScrollable: true,
          tabs: const [
            Tab(text: '在线客服'),
            Tab(text: '常见问题'),
            Tab(text: '客服历史'),
            Tab(text: '帮助中心'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOnlineServiceTab(),
                _buildFAQTab(),
                _buildSessionHistoryTab(),
                _buildHelpCenterTab(),
              ],
            ),
    );
  }
  
  Widget _buildOnlineServiceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 在线客服状态
          _buildServiceStatus(),
          const SizedBox(height: 16),
          
          // 客服代理列表
          _buildAgentList(),
          const SizedBox(height: 16),
          
          // 快速问题分类
          _buildQuickCategories(),
        ],
      ),
    );
  }
  
  Widget _buildServiceStatus() {
    final onlineAgents = _agents.where((agent) => agent.status == AgentStatus.online).length;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(
                  Icons.support_agent,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  '在线客服',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: onlineAgents > 0 ? AppColors.success : AppColors.warning,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        onlineAgents > 0 ? Icons.circle : Icons.schedule,
                        size: 8,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        onlineAgents > 0 ? '在线 $onlineAgents 人' : '繁忙',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                child: ElevatedButton.icon(
                  onPressed: onlineAgents > 0 ? _startNewChat : null,
                  icon: const Icon(Icons.chat),
                  label: const Text('开始对话'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: onlineAgents > 0 ? 4 : 1,
                    shadowColor: AppColors.primary.withOpacity(0.4),
                  ).copyWith(
                    overlayColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return Colors.white.withOpacity(0.2);
                      }
                      return null;
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAgentList() {
    if (_agents.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '客服代理',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _agents.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final agent = _agents[index];
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(agent.avatar),
                        onBackgroundImageError: (exception, stackTrace) {},
                        child: agent.avatar.isEmpty
                            ? Text(
                                agent.name.substring(0, 1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: _getAgentStatusColor(agent.status),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                  title: Text(agent.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(agent.statusText),
                      Text('专业领域: ${agent.specialties.join('、')}'),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 14,
                            color: Colors.amber[600],
                          ),
                          const SizedBox(width: 2),
                          Text('${agent.rating}'),
                          const SizedBox(width: 8),
                          Text('服务次数: ${agent.totalSessions}'),
                        ],
                      ),
                    ],
                  ),
                  trailing: agent.status == AgentStatus.online
                      ? AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => _chatWithAgent(agent),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: const Icon(
                                  Icons.chat_bubble,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.chat_bubble_outline,
                          color: Colors.grey,
                        ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getAgentStatusColor(AgentStatus status) {
    switch (status) {
      case AgentStatus.online:
        return Colors.green;
      case AgentStatus.busy:
        return Colors.orange;
      case AgentStatus.away:
        return Colors.yellow;
      case AgentStatus.offline:
        return Colors.grey;
    }
  }
  
  Widget _buildQuickCategories() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '快速咨询',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _quickConsult(category),
                      borderRadius: BorderRadius.circular(8),
                      splashColor: AppColors.primary.withOpacity(0.2),
                      highlightColor: AppColors.primary.withOpacity(0.1),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getCategoryIcon(category.icon),
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category.name,
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
  
  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'account_circle':
        return Icons.account_circle;
      case 'account_balance_wallet':
        return Icons.account_balance_wallet;
      case 'sports_soccer':
        return Icons.sports_soccer;
      default:
        return Icons.help;
    }
  }
  
  Widget _buildFAQTab() {
    return Column(
      children: [
        // 搜索框
        Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            decoration: const InputDecoration(
              hintText: '搜索常见问题...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onSubmitted: _searchFAQ,
          ),
        ),
        
        // FAQ列表
        Expanded(
          child: _faqs.isEmpty
              ? const Center(child: Text('暂无常见问题'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _faqs.length,
                  itemBuilder: (context, index) {
                    final faq = _faqs[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ExpansionTile(
                        title: Text(
                          faq.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          faq.category,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  faq.answer,
                                  style: const TextStyle(
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    const Text(
                                      '这个回答有帮助吗？',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    TextButton(
                                      onPressed: () => _rateFAQ(faq, true),
                                      child: const Text('有帮助'),
                                    ),
                                    TextButton(
                                      onPressed: () => _rateFAQ(faq, false),
                                      child: const Text('没帮助'),
                                    ),
                                  ],
                                ),
                                Text(
                                  '查看次数: ${faq.viewCount} | 有帮助: ${faq.helpfulCount}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        onExpansionChanged: (expanded) {
                          if (expanded) {
                            // TODO: 记录查看次数
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Widget _buildSessionHistoryTab() {
    return Column(
      children: [
        // 筛选按钮
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showSessionFilter,
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
        
        // 会话历史列表
        Expanded(
          child: _sessions.isEmpty
              ? const Center(child: Text('暂无客服记录'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _sessions.length,
                  itemBuilder: (context, index) {
                    final session = _sessions[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getSessionStatusColor(session.status).withOpacity(0.1),
                          child: Icon(
                            _getSessionStatusIcon(session.status),
                            color: _getSessionStatusColor(session.status),
                          ),
                        ),
                        title: Text(session.subject ?? session.category),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (session.agentName != null)
                              Text('服务人员: ${session.agentName}'),
                            Text('创建时间: ${_formatDateTime(session.createdAt)}'),
                            if (session.rating != null)
                              Row(
                                children: [
                                  const Text('评价: '),
                                  ...List.generate(5, (i) {
                                    return Icon(
                                      i < session.rating!
                                          ? Icons.star
                                          : Icons.star_border,
                                      size: 14,
                                      color: Colors.amber,
                                    );
                                  }),
                                ],
                              ),
                          ],
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getSessionStatusColor(session.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                session.statusText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getSessionStatusColor(session.status),
                                ),
                              ),
                            ),
                            if (session.messageCount > 0)
                              Text(
                                '${session.messageCount}条消息',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        onTap: () => _viewSessionDetails(session),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
  
  Color _getSessionStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.waiting:
        return AppColors.warning;
      case SessionStatus.active:
        return AppColors.success;
      case SessionStatus.closed:
        return Colors.grey;
      case SessionStatus.transferred:
        return AppColors.info;
    }
  }
  
  IconData _getSessionStatusIcon(SessionStatus status) {
    switch (status) {
      case SessionStatus.waiting:
        return Icons.schedule;
      case SessionStatus.active:
        return Icons.chat;
      case SessionStatus.closed:
        return Icons.check_circle;
      case SessionStatus.transferred:
        return Icons.transfer_within_a_station;
    }
  }
  
  Widget _buildHelpCenterTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 帮助分类
        ..._categories.map((category) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ExpansionTile(
              leading: Icon(
                _getCategoryIcon(category.icon),
                color: AppColors.primary,
              ),
              title: Text(category.name),
              subtitle: Text(category.description),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '常见问题:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...category.commonQuestions.map(
                        (question) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Text('• '),
                              Expanded(child: Text(question)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _quickConsult(category),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppColors.primary.withOpacity(0.3),
                        ).copyWith(
                          overlayColor: MaterialStateProperty.resolveWith((states) {
                            if (states.contains(MaterialState.pressed)) {
                              return Colors.white.withOpacity(0.2);
                            }
                            return null;
                          }),
                        ),
                        child: const Text('快速咨询'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
        
        // 联系方式
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '其他联系方式',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.email, color: AppColors.primary),
                  title: const Text('邮箱客服'),
                  subtitle: const Text('support@kaiyun-sports.com'),
                  trailing: const Icon(Icons.copy),
                  onTap: () {
                    HapticFeedback.selectionClick();
                    _copyEmailToClipboard();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.primary),
                  title: const Text('电话客服'),
                  subtitle: const Text('400-888-8888'),
                  trailing: const Icon(Icons.call),
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    _showPhoneCallDialog();
                  },
                ),
                const ListTile(
                  leading: Icon(Icons.access_time, color: AppColors.primary),
                  title: Text('服务时间'),
                  subtitle: Text('24小时在线服务'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
  
  void _startNewChat() async {
    // 添加点击反馈动画
    HapticFeedback.lightImpact();
    
    // 显示加载动画
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在连接客服...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // 模拟加载时间
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context); // 关闭加载对话框
      
      // 显示提示信息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              Text('客服功能暂未开通，敬请期待'),
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _chatWithAgent(CustomerAgent agent) async {
    // 添加点击反馈动画
    HapticFeedback.lightImpact();
    
    // 显示动画效果的加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('正在连接 ${agent.name}...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // 模拟连接时间
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context);
      
      // 显示特定客服的提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.person, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${agent.name} 暂时不在线，请稍后再试'),
              ),
            ],
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _quickConsult(ServiceCategory category) async {
    // 添加点击反馈
    HapticFeedback.mediumImpact();
    
    // 显示带动画的对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getCategoryIcon(category.icon),
                  size: 40,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('正在为您匹配 ${category.name} 专家...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // 模拟匹配时间
    await Future.delayed(const Duration(seconds: 3));
    
    if (mounted) {
      Navigator.pop(context);
      
      // 显示分类相关提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                _getCategoryIcon(category.icon),
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text('${category.name} 咨询服务正在升级中，敬请期待'),
              ),
            ],
          ),
          backgroundColor: AppColors.info,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
  
  void _openChatPage(CustomerSession session) {
    // 不再实际导航，显示提示信息
    HapticFeedback.selectionClick();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: Colors.white),
            SizedBox(width: 8),
            Text('聊天功能开发中，敬请期待'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
  
  void _searchFAQ(String query) async {
    if (query.trim().isEmpty) {
      return;
    }
    
    // 添加触觉反馈
    HapticFeedback.lightImpact();
    
    // 显示搜索动画
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('正在搜索 "$query"...'),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // 模拟搜索延迟
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.search_off, color: Colors.white),
              SizedBox(width: 8),
              Text('搜索功能正在完善中'),
            ],
          ),
          backgroundColor: AppColors.info,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  void _rateFAQ(FAQ faq, bool helpful) {
    // TODO: 实现FAQ评价功能
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(helpful ? '感谢您的反馈' : '已记录您的反馈')),
    );
  }
  
  void _showSessionFilter() {
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
  
  void _viewSessionDetails(CustomerSession session) {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.chat_bubble_outline, color: AppColors.primary),
            SizedBox(width: 8),
            Text('会话详情'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('主题: ${session.subject ?? session.category}'),
            const SizedBox(height: 8),
            if (session.agentName != null)
              Text('客服: ${session.agentName}'),
            const SizedBox(height: 8),
            Text('时间: ${_formatDateTime(session.createdAt)}'),
            const SizedBox(height: 8),
            Text('状态: ${session.statusText}'),
            const SizedBox(height: 16),
            const Text(
              '详细记录功能正在开发中...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  // 复制邮箱地址
  void _copyEmailToClipboard() async {
    const email = 'support@kaiyun-sports.com';
    
    // 显示复制动画
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.content_copy, size: 40, color: AppColors.primary),
                SizedBox(height: 16),
                Text('正在复制邮箱地址...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // 模拟复制时间
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (mounted) {
      Navigator.pop(context);
      
      // 实际复制到剪贴板（模拟）
      await Clipboard.setData(const ClipboardData(text: email));
      
      // 显示成功提示
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('邮箱地址已复制到剪贴板'),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // 显示拨打电话对话框
  void _showPhoneCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.phone, color: AppColors.primary),
            SizedBox(width: 8),
            Text('客服电话'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.phone_in_talk, size: 50, color: AppColors.primary),
            SizedBox(height: 16),
            Text('400-888-8888'),
            SizedBox(height: 12),
            Text(
              '服务时间：24小时在线服务',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _simulatePhoneCall();
            },
            icon: const Icon(Icons.call),
            label: const Text('拨打电话'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // 模拟拨打电话
  void _simulatePhoneCall() async {
    // 显示拨号动画
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.phone_callback, size: 40, color: AppColors.primary),
                SizedBox(height: 16),
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在拨号...'),
              ],
            ),
          ),
        ),
      ),
    );
    
    // 模拟拨号时间
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pop(context);
      
      // 显示提示信息
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.info, color: Colors.white),
              SizedBox(width: 8),
              Text('电话功能暂未开通，请使用在线客服'),
            ],
          ),
          backgroundColor: AppColors.info,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }
}
