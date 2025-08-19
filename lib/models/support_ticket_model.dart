class SupportTicketModel {
  final String id;
  final String userId;
  final String userEmail;
  final String userName;
  final String subject;
  final String message;
  final TicketStatus status;
  final TicketPriority priority;
  final String? adminResponse;
  final String? adminId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  SupportTicketModel({
    required this.id,
    required this.userId,
    required this.userEmail,
    required this.userName,
    required this.subject,
    required this.message,
    required this.status,
    required this.priority,
    this.adminResponse,
    this.adminId,
    required this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  factory SupportTicketModel.fromMap(Map<String, dynamic> map, String id) {
    return SupportTicketModel(
      id: id,
      userId: map['userId'] ?? '',
      userEmail: map['userEmail'] ?? '',
      userName: map['userName'] ?? '',
      subject: map['subject'] ?? '',
      message: map['message'] ?? '',
      status: TicketStatus.values.firstWhere(
            (status) => status.name == (map['status'] ?? 'open'),
        orElse: () => TicketStatus.open,
      ),
      priority: TicketPriority.values.firstWhere(
            (priority) => priority.name == (map['priority'] ?? 'medium'),
        orElse: () => TicketPriority.medium,
      ),
      adminResponse: map['adminResponse'],
      adminId: map['adminId'],
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
      resolvedAt: map['resolvedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userEmail': userEmail,
      'userName': userName,
      'subject': subject,
      'message': message,
      'status': status.name,
      'priority': priority.name,
      'adminResponse': adminResponse,
      'adminId': adminId,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'resolvedAt': resolvedAt,
    };
  }

  SupportTicketModel copyWith({
    String? id,
    String? userId,
    String? userEmail,
    String? userName,
    String? subject,
    String? message,
    TicketStatus? status,
    TicketPriority? priority,
    String? adminResponse,
    String? adminId,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userEmail: userEmail ?? this.userEmail,
      userName: userName ?? this.userName,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      adminResponse: adminResponse ?? this.adminResponse,
      adminId: adminId ?? this.adminId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }
}

enum TicketStatus {
  open,
  inProgress,
  resolved,
  closed,
}

enum TicketPriority {
  low,
  medium,
  high,
  urgent,
}