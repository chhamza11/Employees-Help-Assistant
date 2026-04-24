import '../core/constants.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? department;
  final String? position;
  final String? joinDate;
  final String? phone;
  final String? address;
  final String? emergencyContact;
  final String? profilePicture;
  final int leaveBalance;
  final String? scheduledStart;
  final String? scheduledEnd;
  final String? dateOfBirth;
  final String? religion;
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;
  final List<EducationRecord>? education;
  final String? bankAccountNumber;
  final String? bankName;
  final String? taxId;
  final String? employeeId;
  final String? joiningDate;
  final String? probationEndDate;
  final String? confirmationDate;
  final bool isRegistered;
  final String userId;
  final String enrollmentPhase;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    this.department,
    this.position,
    this.joinDate,
    this.phone,
    this.address,
    this.emergencyContact,
    this.profilePicture,
    this.leaveBalance = 20,
    this.scheduledStart,
    this.scheduledEnd,
    this.dateOfBirth,
    this.religion,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.education,
    this.bankAccountNumber,
    this.bankName,
    this.taxId,
    this.employeeId,
    this.joiningDate,
    this.probationEndDate,
    this.confirmationDate,
    this.isRegistered = false,
    this.userId = '',
    this.enrollmentPhase = 'phase1',
    this.isActive = true,
    this.createdAt = '',
    this.updatedAt = '',
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    List<EducationRecord>? educationList;
    if (map['education'] != null) {
      if (map['education'] is List) {
        educationList = (map['education'] as List)
            .map((e) => EducationRecord.fromMap(e is Map<String, dynamic> ? e : {}))
            .toList();
      }
    }

    return UserModel(
      id: map['\$id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: UserRole.fromString(map['role'] ?? 'employee'),
      department: map['department'],
      position: map['position'],
      joinDate: map['joinDate'],
      phone: map['phone'],
      address: map['address'],
      emergencyContact: map['emergencyContact'],
      profilePicture: map['profilePicture'],
      leaveBalance: map['leaveBalance'] ?? 20,
      scheduledStart: map['scheduledStart'],
      scheduledEnd: map['scheduledEnd'],
      dateOfBirth: map['dateOfBirth'],
      religion: map['religion'],
      emergencyContactName: map['emergencyContactName'],
      emergencyContactPhone: map['emergencyContactPhone'],
      emergencyContactRelation: map['emergencyContactRelation'],
      education: educationList,
      bankAccountNumber: map['bankAccountNumber'],
      bankName: map['bankName'],
      taxId: map['taxId'],
      employeeId: map['employeeId'],
      joiningDate: map['joiningDate'],
      probationEndDate: map['probationEndDate'],
      confirmationDate: map['confirmationDate'],
      isRegistered: map['isRegistered'] ?? false,
      userId: map['userId'] ?? '',
      enrollmentPhase: map['enrollmentPhase'] ?? 'phase1',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] ?? '',
      updatedAt: map['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role.value,
      'department': department,
      'position': position,
      'joinDate': joinDate,
      'phone': phone,
      'address': address,
      'emergencyContact': emergencyContact,
      'profilePicture': profilePicture,
      'leaveBalance': leaveBalance,
      'scheduledStart': scheduledStart,
      'scheduledEnd': scheduledEnd,
      'dateOfBirth': dateOfBirth,
      'religion': religion,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'emergencyContactRelation': emergencyContactRelation,
      'bankAccountNumber': bankAccountNumber,
      'bankName': bankName,
      'taxId': taxId,
      'employeeId': employeeId,
      'joiningDate': joiningDate,
      'probationEndDate': probationEndDate,
      'confirmationDate': confirmationDate,
      'isRegistered': isRegistered,
      'userId': userId,
      'enrollmentPhase': enrollmentPhase,
      'isActive': isActive,
    };
  }

  String get firstName => name.split(' ').first;
}

class EducationRecord {
  final String degree;
  final String institution;
  final String year;
  final String? grade;

  EducationRecord({
    required this.degree,
    required this.institution,
    required this.year,
    this.grade,
  });

  factory EducationRecord.fromMap(Map<String, dynamic> map) {
    return EducationRecord(
      degree: map['degree'] ?? '',
      institution: map['institution'] ?? '',
      year: map['year'] ?? '',
      grade: map['grade'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'institution': institution,
      'year': year,
      'grade': grade,
    };
  }
}
