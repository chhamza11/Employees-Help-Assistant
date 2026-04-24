import '../core/constants.dart';

class TaskModel {
  final String id;
  final String title;
  final String? description;
  final String assignedTo;
  final String assignedBy;
  final String? teamId;
  final String priority;
  final String status;
  final String? deadline;
  final double? estimatedHours;
  final double? qualityRating;
  final String? feedback;
  final double? deadlineAdherence;
  final String? completedAt;
  final String createdAt;
  final String updatedAt;

  TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.assignedTo,
    required this.assignedBy,
    this.teamId,
    this.priority = 'medium',
    this.status = 'pending',
    this.deadline,
    this.estimatedHours,
    this.qualityRating,
    this.feedback,
    this.deadlineAdherence,
    this.completedAt,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['\$id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      assignedTo: map['assignedTo'] ?? '',
      assignedBy: map['assignedBy'] ?? '',
      teamId: map['teamId'],
      priority: map['priority'] ?? 'medium',
      status: map['status'] ?? 'pending',
      deadline: map['deadline'],
      estimatedHours: (map['estimatedHours'] as num?)?.toDouble(),
      qualityRating: (map['qualityRating'] as num?)?.toDouble(),
      feedback: map['feedback'],
      deadlineAdherence: (map['deadlineAdherence'] as num?)?.toDouble(),
      completedAt: map['completedAt'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  TaskStatus get taskStatus => TaskStatus.fromString(status);

  TaskPriority get taskPriority => TaskPriority.values.firstWhere(
        (e) => e.name == priority,
        orElse: () => TaskPriority.medium,
      );
}

class TaskComment {
  final String id;
  final String taskId;
  final String userId;
  final String userName;
  final String comment;
  final String createdAt;

  TaskComment({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  factory TaskComment.fromMap(Map<String, dynamic> map) {
    return TaskComment(
      id: map['\$id'] ?? '',
      taskId: map['taskId'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      comment: map['comment'] ?? '',
      createdAt: map['createdAt'] ?? '',
    );
  }
}
