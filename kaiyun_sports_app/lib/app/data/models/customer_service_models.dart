// 客服消息模型
class CustomerMessage {
  final String id;
  final String userId;
  final String? agentId;
  final String content;
  final MessageType type;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isFromUser;
  final List<String>? attachments;
  final String? category;
  
  CustomerMessage({
    required this.id,
    required this.userId,
    this.agentId,
    required this.content,
    required this.type,
    required this.status,
    required this.createdAt,
    this.readAt,
    required this.isFromUser,
    this.attachments,
    this.category,
  });
  
  factory CustomerMessage.fromJson(Map<String, dynamic> json) {
    return CustomerMessage(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      agentId: json['agent_id'],
      content: json['content'] ?? '',
      type: MessageType.values.firstWhere(
        (t) => t.toString().split('.').last == json['type'],
        orElse: () => MessageType.text,
      ),
      status: MessageStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => MessageStatus.sent,
      ),
      createdAt: DateTime.parse(json['created_at']),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at']) 
          : null,
      isFromUser: json['is_from_user'] ?? true,
      attachments: json['attachments'] != null 
          ? List<String>.from(json['attachments']) 
          : null,
      category: json['category'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'agent_id': agentId,
      'content': content,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'is_from_user': isFromUser,
      'attachments': attachments,
      'category': category,
    };
  }
}

enum MessageType { text, image, file, system }
enum MessageStatus { sent, delivered, read, failed }

// 客服会话模型
class CustomerSession {
  final String id;
  final String userId;
  final String? agentId;
  final String? agentName;
  final SessionStatus status;
  final String category;
  final String? subject;
  final DateTime createdAt;
  final DateTime? closedAt;
  final int messageCount;
  final DateTime? lastMessageAt;
  final int priority; // 1-5, 5为最高优先级
  final double? rating;
  final String? feedback;
  
  CustomerSession({
    required this.id,
    required this.userId,
    this.agentId,
    this.agentName,
    required this.status,
    required this.category,
    this.subject,
    required this.createdAt,
    this.closedAt,
    this.messageCount = 0,
    this.lastMessageAt,
    this.priority = 3,
    this.rating,
    this.feedback,
  });
  
  factory CustomerSession.fromJson(Map<String, dynamic> json) {
    return CustomerSession(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      agentId: json['agent_id'],
      agentName: json['agent_name'],
      status: SessionStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => SessionStatus.waiting,
      ),
      category: json['category'] ?? '',
      subject: json['subject'],
      createdAt: DateTime.parse(json['created_at']),
      closedAt: json['closed_at'] != null 
          ? DateTime.parse(json['closed_at']) 
          : null,
      messageCount: json['message_count'] ?? 0,
      lastMessageAt: json['last_message_at'] != null 
          ? DateTime.parse(json['last_message_at']) 
          : null,
      priority: json['priority'] ?? 3,
      rating: json['rating']?.toDouble(),
      feedback: json['feedback'],
    );
  }
  
  String get statusText {
    switch (status) {
      case SessionStatus.waiting:
        return '排队中';
      case SessionStatus.active:
        return '服务中';
      case SessionStatus.closed:
        return '已结束';
      case SessionStatus.transferred:
        return '已转接';
    }
  }
}

enum SessionStatus { waiting, active, closed, transferred }

// FAQ模型
class FAQ {
  final String id;
  final String question;
  final String answer;
  final String category;
  final List<String> tags;
  final int viewCount;
  final int helpfulCount;
  final DateTime updatedAt;
  final bool isActive;
  
  FAQ({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    required this.tags,
    this.viewCount = 0,
    this.helpfulCount = 0,
    required this.updatedAt,
    this.isActive = true,
  });
  
  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      id: json['id'] ?? '',
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      category: json['category'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      viewCount: json['view_count'] ?? 0,
      helpfulCount: json['helpful_count'] ?? 0,
      updatedAt: DateTime.parse(json['updated_at']),
      isActive: json['is_active'] ?? true,
    );
  }
}

// 客服分类模型
class ServiceCategory {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int sortOrder;
  final bool isActive;
  final List<String> commonQuestions;
  
  ServiceCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.sortOrder = 0,
    this.isActive = true,
    required this.commonQuestions,
  });
  
  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: json['icon'] ?? '',
      sortOrder: json['sort_order'] ?? 0,
      isActive: json['is_active'] ?? true,
      commonQuestions: List<String>.from(json['common_questions'] ?? []),
    );
  }
}

// 客服代理模型
class CustomerAgent {
  final String id;
  final String name;
  final String avatar;
  final AgentStatus status;
  final List<String> specialties;
  final double rating;
  final int totalSessions;
  final int activeSessions;
  final DateTime? lastActiveAt;
  
  CustomerAgent({
    required this.id,
    required this.name,
    required this.avatar,
    required this.status,
    required this.specialties,
    this.rating = 5.0,
    this.totalSessions = 0,
    this.activeSessions = 0,
    this.lastActiveAt,
  });
  
  factory CustomerAgent.fromJson(Map<String, dynamic> json) {
    return CustomerAgent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'] ?? '',
      status: AgentStatus.values.firstWhere(
        (s) => s.toString().split('.').last == json['status'],
        orElse: () => AgentStatus.offline,
      ),
      specialties: List<String>.from(json['specialties'] ?? []),
      rating: (json['rating'] ?? 5.0).toDouble(),
      totalSessions: json['total_sessions'] ?? 0,
      activeSessions: json['active_sessions'] ?? 0,
      lastActiveAt: json['last_active_at'] != null 
          ? DateTime.parse(json['last_active_at']) 
          : null,
    );
  }
  
  String get statusText {
    switch (status) {
      case AgentStatus.online:
        return '在线';
      case AgentStatus.busy:
        return '繁忙';
      case AgentStatus.away:
        return '离开';
      case AgentStatus.offline:
        return '离线';
    }
  }
}

enum AgentStatus { online, busy, away, offline }
