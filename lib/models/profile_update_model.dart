class ProfileUpdateModel {
  final String id;
  final String userId;
  final String userName;
  final String field;
  final String oldValue;
  final String newValue;
  final String status;
  final String? approvedBy;
  final String createdAt;
  final String updatedAt;

  ProfileUpdateModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.field,
    required this.oldValue,
    required this.newValue,
    this.status = 'pending',
    this.approvedBy,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory ProfileUpdateModel.fromMap(Map<String, dynamic> map) {
    return ProfileUpdateModel(
      id: map['\$id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      field: map['field'] ?? '',
      oldValue: map['oldValue'] ?? '',
      newValue: map['newValue'] ?? '',
      status: map['status'] ?? 'pending',
      approvedBy: map['approvedBy'],
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'field': field,
      'oldValue': oldValue,
      'newValue': newValue,
      'status': status,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }
}
