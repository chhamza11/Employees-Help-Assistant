class BreakModel {
  final String id;
  final String attendanceId;
  final String userId;
  final String breakStart;
  final String? breakEnd;
  final String breakType;
  final int? duration;
  final String createdAt;
  final String updatedAt;

  BreakModel({
    required this.id,
    required this.attendanceId,
    required this.userId,
    required this.breakStart,
    this.breakEnd,
    this.breakType = 'lunch',
    this.duration,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory BreakModel.fromMap(Map<String, dynamic> map) {
    return BreakModel(
      id: map['\$id'] ?? '',
      attendanceId: map['attendanceId'] ?? '',
      userId: map['userId'] ?? '',
      breakStart: map['breakStart'] ?? '',
      breakEnd: map['breakEnd'],
      breakType: map['breakType'] ?? 'lunch',
      duration: map['duration'] as int?,
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  bool get isActive => breakEnd == null;
}
