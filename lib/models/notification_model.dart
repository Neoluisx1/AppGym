// 🔔 Notification Model
class NotificationModel {
  final int id;
  final String title;
  final String message;
  final String type;
  final bool isRead;
  final String createdAt;
  final Map<String, dynamic>? data;
  
  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });
  
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['type'] ?? 'info',
      isRead: json['is_read'] == true || json['is_read'] == 1,
      createdAt: json['created_at'] ?? '',
      data: json['data'] as Map<String, dynamic>?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'is_read': isRead,
      'created_at': createdAt,
      'data': data,
    };
  }
  
  // Tipos de notificaciones
  bool get isMembershipExpiring => type == 'membership_expiring';
  bool get isMembershipExpired => type == 'membership_expired';
  bool get isGroupClass => type == 'group_class';
  bool get isRoutine => type == 'routine';
  bool get isGoal => type == 'goal';
  bool get isAnnouncement => type == 'announcement';
  bool get isSurvey => type == 'survey';
  
  // Icono según tipo
  String get iconType {
    switch (type) {
      case 'membership_expiring':
      case 'membership_expired':
        return 'card_membership';
      case 'group_class':
        return 'fitness_center';
      case 'routine':
        return 'assignment';
      case 'goal':
        return 'flag';
      case 'announcement':
        return 'campaign';
      default:
        return 'notifications';
    }
  }
}
