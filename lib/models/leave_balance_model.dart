import 'dart:convert';

class LeaveBalanceModel {
  final String id;
  final String userId;
  final int totalLeaves;
  final int casualLeaves;
  final int sickLeaves;
  final int annualLeaves;
  final UsedLeaves usedLeaves;
  final String createdAt;
  final String updatedAt;

  LeaveBalanceModel({
    required this.id,
    required this.userId,
    this.totalLeaves = 20,
    this.casualLeaves = 5,
    this.sickLeaves = 5,
    this.annualLeaves = 10,
    UsedLeaves? usedLeaves,
    this.createdAt = '',
    this.updatedAt = '',
  }) : usedLeaves = usedLeaves ?? UsedLeaves();

  factory LeaveBalanceModel.fromMap(Map<String, dynamic> map) {
    UsedLeaves used = UsedLeaves();
    if (map['usedLeaves'] != null) {
      if (map['usedLeaves'] is String) {
        try {
          final decoded = json.decode(map['usedLeaves']);
          used = UsedLeaves.fromMap(decoded);
        } catch (_) {}
      } else if (map['usedLeaves'] is Map) {
        used = UsedLeaves.fromMap(map['usedLeaves']);
      }
    }

    return LeaveBalanceModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      totalLeaves: map['totalLeaves'] ?? 20,
      casualLeaves: map['casualLeaves'] ?? 5,
      sickLeaves: map['sickLeaves'] ?? 5,
      annualLeaves: map['annualLeaves'] ?? 10,
      usedLeaves: used,
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  int get remainingCasual => casualLeaves - usedLeaves.casual;
  int get remainingSick => sickLeaves - usedLeaves.sick;
  int get remainingAnnual => annualLeaves - usedLeaves.annual;
  int get totalUsed => usedLeaves.casual + usedLeaves.sick + usedLeaves.annual;
  int get totalRemaining => totalLeaves - totalUsed;
}

class UsedLeaves {
  final int casual;
  final int sick;
  final int annual;

  UsedLeaves({this.casual = 0, this.sick = 0, this.annual = 0});

  factory UsedLeaves.fromMap(Map<String, dynamic> map) {
    return UsedLeaves(
      casual: map['casual'] ?? 0,
      sick: map['sick'] ?? 0,
      annual: map['annual'] ?? 0,
    );
  }
}
