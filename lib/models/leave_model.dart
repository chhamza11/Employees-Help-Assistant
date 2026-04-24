import '../core/constants.dart';

class LeaveModel {
  final String id;
  final String userId;
  final String userName;
  final String leaveType;
  final String startDate;
  final String endDate;
  final int days;
  final String reason;
  final String status;
  final bool isPaid;
  final bool isOverride;
  final String? overrideReason;
  final int monthlyUsageAtRequest;
  final int yearlyUsageAtRequest;
  final String? approvedBy;
  final String? approvedAt;
  final String? rejectionReason;
  final String createdAt;
  final String updatedAt;

  LeaveModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.days,
    required this.reason,
    this.status = 'pending',
    this.isPaid = true,
    this.isOverride = false,
    this.overrideReason,
    this.monthlyUsageAtRequest = 0,
    this.yearlyUsageAtRequest = 0,
    this.approvedBy,
    this.approvedAt,
    this.rejectionReason,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory LeaveModel.fromMap(Map<String, dynamic> map) {
    return LeaveModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      leaveType: map['leaveType'] ?? 'casual',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      days: map['days'] ?? 1,
      reason: map['reason'] ?? '',
      status: map['status'] ?? 'pending',
      isPaid: map['isPaid'] ?? true,
      isOverride: map['isOverride'] ?? false,
      overrideReason: map['overrideReason'],
      monthlyUsageAtRequest: map['monthlyUsageAtRequest'] ?? 0,
      yearlyUsageAtRequest: map['yearlyUsageAtRequest'] ?? 0,
      approvedBy: map['approvedBy'],
      approvedAt: map['approvedAt'],
      rejectionReason: map['rejectionReason'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'days': days,
      'reason': reason,
      'status': status,
      'isPaid': isPaid,
      'isOverride': isOverride,
      'monthlyUsageAtRequest': monthlyUsageAtRequest,
      'yearlyUsageAtRequest': yearlyUsageAtRequest,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  LeaveStatus get leaveStatus => LeaveStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => LeaveStatus.pending,
      );

  LeaveType get leaveTypeEnum => LeaveType.values.firstWhere(
        (e) => e.name == leaveType,
        orElse: () => LeaveType.casual,
      );
}
