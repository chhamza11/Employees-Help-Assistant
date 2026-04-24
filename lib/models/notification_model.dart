class NotificationModel {
  final String id;
  final String userId;
  final String announcementId;
  final String title;
  final String message;
  final String eventType;
  final bool isRead;
  final String createdBy;
  final String createdByName;
  final String createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.announcementId,
    required this.title,
    required this.message,
    this.eventType = 'announcement',
    this.isRead = false,
    this.createdBy = '',
    this.createdByName = '',
    this.createdAt = '',
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      announcementId: map['announcementId'] ?? '',
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      eventType: map['eventType'] ?? 'announcement',
      isRead: map['isRead'] ?? false,
      createdBy: map['createdBy'] ?? '',
      createdByName: map['createdByName'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
