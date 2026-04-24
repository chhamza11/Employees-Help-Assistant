import '../core/constants.dart';

class AttendanceModel {
  final String id;
  final String userId;
  final String date;
  final String? clockIn;
  final String? clockOut;
  final String status;
  final double? totalHours;
  final double? regularHours;
  final double? overtimeHours;
  final int? breakMinutes;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.date,
    this.clockIn,
    this.clockOut,
    this.status = 'absent',
    this.totalHours,
    this.regularHours,
    this.overtimeHours,
    this.breakMinutes,
    this.notes,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      date: map['date'] ?? '',
      clockIn: map['clockIn'],
      clockOut: map['clockOut'],
      status: map['status'] ?? 'absent',
      totalHours: (map['totalHours'] as num?)?.toDouble(),
      regularHours: (map['regularHours'] as num?)?.toDouble(),
      overtimeHours: (map['overtimeHours'] as num?)?.toDouble(),
      breakMinutes: map['breakMinutes'] as int?,
      notes: map['notes'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  bool get isClockedIn => clockIn != null && clockOut == null;
  bool get isClockedOut => clockIn != null && clockOut != null;

  AttendanceStatus get attendanceStatus => AttendanceStatus.fromString(status);
}
