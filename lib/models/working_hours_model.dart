class WorkingHoursModel {
  final String id;
  final String userId;
  final String date;
  final double regularHours;
  final double overtimeHours;
  final int? breakMinutes;
  final String? scheduledStart;
  final String? scheduledEnd;
  final String? projectName;
  final String? taskDescription;
  final String createdAt;
  final String updatedAt;

  WorkingHoursModel({
    required this.id,
    required this.userId,
    required this.date,
    this.regularHours = 0,
    this.overtimeHours = 0,
    this.breakMinutes,
    this.scheduledStart,
    this.scheduledEnd,
    this.projectName,
    this.taskDescription,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory WorkingHoursModel.fromMap(Map<String, dynamic> map) {
    return WorkingHoursModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      regularHours: (map['regularHours'] as num?)?.toDouble() ?? 0,
      overtimeHours: (map['overtimeHours'] as num?)?.toDouble() ?? 0,
      breakMinutes: map['breakMinutes'] as int?,
      scheduledStart: map['scheduledStart'],
      scheduledEnd: map['scheduledEnd'],
      projectName: map['projectName'],
      taskDescription: map['taskDescription'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  double get totalHours => regularHours + overtimeHours;
}
