import 'dart:async';
import '../models/customer_service_models.dart';
import '../api/api_service.dart';

/// 客服系统服务类
class CustomerService {
  final ApiService _apiService;
  StreamController<CustomerMessage>? _messageStreamController;
  
  CustomerService(this._apiService);
  
  /// 获取消息流
  Stream<CustomerMessage> get messageStream {
    _messageStreamController ??= StreamController<CustomerMessage>.broadcast();
    return _messageStreamController!.stream;
  }
  
  /// 创建客服会话
  Future<CustomerSession> createSession({
    required String userId,
    required String category,
    String? subject,
    int priority = 3,
  }) async {
    try {
      final response = await _apiService.post('/customer-service/session/create', data: {
        'user_id': userId,
        'category': category,
        'subject': subject,
        'priority': priority,
      });
      return CustomerSession.fromJson(response.data);
    } catch (e) {
      // 返回模拟会话
      return CustomerSession(
        id: 'CS${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        status: SessionStatus.waiting,
        category: category,
        subject: subject,
        createdAt: DateTime.now(),
        priority: priority,
      );
    }
  }
  
  /// 获取用户的客服会话列表
  Future<List<CustomerSession>> getUserSessions(String userId) async {
    try {
      final response = await _apiService.get('/customer-service/sessions', queryParameters: {
        'user_id': userId,
      });
      return (response.data['sessions'] as List)
          .map((json) => CustomerSession.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockSessions(userId);
    }
  }
  
  /// 发送消息
  Future<CustomerMessage> sendMessage({
    required String sessionId,
    required String content,
    MessageType type = MessageType.text,
    List<String>? attachments,
  }) async {
    try {
      final response = await _apiService.post('/customer-service/message/send', data: {
        'session_id': sessionId,
        'content': content,
        'type': type.toString().split('.').last,
        'attachments': attachments,
      });
      final message = CustomerMessage.fromJson(response.data);
      
      // 添加到消息流
      _messageStreamController?.add(message);
      
      return message;
    } catch (e) {
      // 返回模拟消息
      final message = CustomerMessage(
        id: 'MSG${DateTime.now().millisecondsSinceEpoch}',
        userId: 'current_user',
        content: content,
        type: type,
        status: MessageStatus.sent,
        createdAt: DateTime.now(),
        isFromUser: true,
        attachments: attachments,
      );
      
      _messageStreamController?.add(message);
      
      // 模拟客服回复
      Timer(const Duration(seconds: 2), () {
        _simulateAgentReply(sessionId);
      });
      
      return message;
    }
  }
  
  /// 获取会话消息历史
  Future<List<CustomerMessage>> getSessionMessages(String sessionId) async {
    try {
      final response = await _apiService.get('/customer-service/messages', queryParameters: {
        'session_id': sessionId,
      });
      return (response.data['messages'] as List)
          .map((json) => CustomerMessage.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockMessages(sessionId);
    }
  }
  
  /// 获取服务分类
  Future<List<ServiceCategory>> getServiceCategories() async {
    try {
      final response = await _apiService.get('/customer-service/categories');
      return (response.data['categories'] as List)
          .map((json) => ServiceCategory.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockServiceCategories();
    }
  }
  
  /// 获取FAQ列表
  Future<List<FAQ>> getFAQs({
    String? category,
    String? keyword,
  }) async {
    try {
      final response = await _apiService.get('/customer-service/faq', queryParameters: {
        'category': category,
        'keyword': keyword,
      });
      return (response.data['faqs'] as List)
          .map((json) => FAQ.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockFAQs();
    }
  }
  
  /// 获取在线客服代理
  Future<List<CustomerAgent>> getOnlineAgents() async {
    try {
      final response = await _apiService.get('/customer-service/agents/online');
      return (response.data['agents'] as List)
          .map((json) => CustomerAgent.fromJson(json))
          .toList();
    } catch (e) {
      return _getMockAgents();
    }
  }
  
  /// 对服务进行评价
  Future<bool> rateService({
    required String sessionId,
    required double rating,
    String? feedback,
  }) async {
    try {
      final response = await _apiService.post('/customer-service/rate', data: {
        'session_id': sessionId,
        'rating': rating,
        'feedback': feedback,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      return true; // 模拟成功
    }
  }
  
  /// 结束会话
  Future<bool> endSession(String sessionId) async {
    try {
      final response = await _apiService.post('/customer-service/session/end', data: {
        'session_id': sessionId,
      });
      return response.data['success'] ?? false;
    } catch (e) {
      return true; // 模拟成功
    }
  }
  
  /// 搜索FAQ
  Future<List<FAQ>> searchFAQs(String query) async {
    try {
      final response = await _apiService.get('/customer-service/faq/search', queryParameters: {
        'query': query,
      });
      return (response.data['faqs'] as List)
          .map((json) => FAQ.fromJson(json))
          .toList();
    } catch (e) {
      // 返回简单的模拟搜索结果
      final allFAQs = _getMockFAQs();
      return allFAQs.where((faq) => 
        faq.question.toLowerCase().contains(query.toLowerCase()) ||
        faq.answer.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
  }
  
  /// 模拟客服回复
  void _simulateAgentReply(String sessionId) {
    final replies = [
      '您好，我是在线客服小明，很高兴为您服务。',
      '请您详细描述一下遇到的问题，我会尽快帮您解决。',
      '我已经收到您的问题，请稍等，我正在为您查询相关信息。',
      '谢谢您的耐心等待，这个问题我们已经为您处理好了。',
      '还有其他问题需要帮助吗？',
    ];
    
    final reply = CustomerMessage(
      id: 'MSG${DateTime.now().millisecondsSinceEpoch + 1}',
      userId: 'agent_001',
      agentId: 'agent_001',
      content: replies[DateTime.now().millisecond % replies.length],
      type: MessageType.text,
      status: MessageStatus.sent,
      createdAt: DateTime.now(),
      isFromUser: false,
    );
    
    _messageStreamController?.add(reply);
  }
  
  void dispose() {
    _messageStreamController?.close();
  }
  
  List<CustomerSession> _getMockSessions(String userId) {
    return [
      CustomerSession(
        id: 'CS001',
        userId: userId,
        agentId: 'agent_001',
        agentName: '小明',
        status: SessionStatus.closed,
        category: '账户问题',
        subject: '充值失败',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        closedAt: DateTime.now().subtract(const Duration(days: 2, hours: 1)),
        messageCount: 8,
        rating: 4.5,
        feedback: '服务态度很好，解决问题很及时',
      ),
      CustomerSession(
        id: 'CS002',
        userId: userId,
        status: SessionStatus.waiting,
        category: '投注问题',
        subject: '投注异常',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        messageCount: 1,
        priority: 4,
      ),
    ];
  }
  
  List<CustomerMessage> _getMockMessages(String sessionId) {
    return [
      CustomerMessage(
        id: 'MSG001',
        userId: 'current_user',
        content: '你好，我的充值失败了',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        isFromUser: true,
      ),
      CustomerMessage(
        id: 'MSG002',
        userId: 'agent_001',
        agentId: 'agent_001',
        content: '您好，请提供一下您的订单号，我帮您查询',
        type: MessageType.text,
        status: MessageStatus.read,
        createdAt: DateTime.now().subtract(const Duration(minutes: 9)),
        isFromUser: false,
      ),
    ];
  }
  
  List<ServiceCategory> _getMockServiceCategories() {
    return [
      ServiceCategory(
        id: 'account',
        name: '账户问题',
        description: '登录、注册、密码等账户相关问题',
        icon: 'account_circle',
        commonQuestions: ['忘记密码', '账户被锁定', '修改个人信息'],
      ),
      ServiceCategory(
        id: 'finance',
        name: '财务问题',
        description: '充值、提现、转账等财务相关问题',
        icon: 'account_balance_wallet',
        commonQuestions: ['充值失败', '提现延迟', '手续费问题'],
      ),
      ServiceCategory(
        id: 'betting',
        name: '投注问题',
        description: '投注、赔付、游戏规则等问题',
        icon: 'sports_soccer',
        commonQuestions: ['投注异常', '赔付问题', '游戏规则'],
      ),
    ];
  }
  
  List<FAQ> _getMockFAQs() {
    return [
      FAQ(
        id: 'FAQ001',
        question: '如何修改登录密码？',
        answer: '您可以在“我的”-“账户管理”-“安全设置”中修改密码，或者点击登录页面的“忘记密码”进行重置。',
        category: '账户问题',
        tags: ['密码', '修改', '安全'],
        viewCount: 1250,
        helpfulCount: 980,
        updatedAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      FAQ(
        id: 'FAQ002',
        question: '充值多久到账？',
        answer: '一般情况下，充值会在10分钟内到账。如果超过30分钟未到账，请联系在线客服。',
        category: '财务问题',
        tags: ['充值', '到账时间'],
        viewCount: 2150,
        helpfulCount: 1800,
        updatedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
      FAQ(
        id: 'FAQ003',
        question: '最低投注金额是多少？',
        answer: '体育投注的最低金额为10元，不同游戏类型的最低投注金额可能不同。',
        category: '投注问题',
        tags: ['投注金额', '最低限制'],
        viewCount: 1800,
        helpfulCount: 1500,
        updatedAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
    ];
  }
  
  List<CustomerAgent> _getMockAgents() {
    return [
      CustomerAgent(
        id: 'agent_001',
        name: '小明',
        avatar: 'https://avatar.example.com/agent1.jpg',
        status: AgentStatus.online,
        specialties: ['账户问题', '财务问题'],
        rating: 4.8,
        totalSessions: 1250,
        activeSessions: 3,
        lastActiveAt: DateTime.now(),
      ),
      CustomerAgent(
        id: 'agent_002',
        name: '小红',
        avatar: 'https://avatar.example.com/agent2.jpg',
        status: AgentStatus.busy,
        specialties: ['投注问题', 'VIP服务'],
        rating: 4.9,
        totalSessions: 980,
        activeSessions: 5,
        lastActiveAt: DateTime.now(),
      ),
    ];
  }
}
