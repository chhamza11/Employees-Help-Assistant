enum UserRole {
  employee,
  teamLead,
  hr,
  executive,
  admin,
  softwareEngineer,
  aiEngineer,
  developer,
  designer,
  sqa;

  String get value {
    switch (this) {
      case UserRole.teamLead:
        return 'team_lead';
      case UserRole.softwareEngineer:
        return 'software_engineer';
      case UserRole.aiEngineer:
        return 'ai_engineer';
      default:
        return name;
    }
  }

  static UserRole fromString(String value) {
    switch (value) {
      case 'team_lead':
        return UserRole.teamLead;
      case 'software_engineer':
        return UserRole.softwareEngineer;
      case 'ai_engineer':
        return UserRole.aiEngineer;
      default:
        return UserRole.values.firstWhere(
          (e) => e.name == value,
          orElse: () => UserRole.employee,
        );
    }
  }
}

enum LeaveType {
  annual,
  casual,
  sick,
  unpaid,
  special,
  exempt;

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

enum LeaveStatus {
  pending,
  approved,
  rejected,
  cancelled;

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

enum AttendanceStatus {
  present,
  absent,
  halfDay,
  halfDayNoLeave,
  onLeave;

  String get value {
    switch (this) {
      case AttendanceStatus.halfDay:
        return 'half-day';
      case AttendanceStatus.halfDayNoLeave:
        return 'half-day-no-leave';
      case AttendanceStatus.onLeave:
        return 'on-leave';
      default:
        return name;
    }
  }

  String get label {
    switch (this) {
      case AttendanceStatus.halfDay:
        return 'Half Day';
      case AttendanceStatus.halfDayNoLeave:
        return 'Half Day (No Leave)';
      case AttendanceStatus.onLeave:
        return 'On Leave';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  static AttendanceStatus fromString(String value) {
    switch (value) {
      case 'half-day':
        return AttendanceStatus.halfDay;
      case 'half-day-no-leave':
        return AttendanceStatus.halfDayNoLeave;
      case 'on-leave':
        return AttendanceStatus.onLeave;
      default:
        return AttendanceStatus.values.firstWhere(
          (e) => e.name == value,
          orElse: () => AttendanceStatus.absent,
        );
    }
  }
}

enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled;

  String get value {
    switch (this) {
      case TaskStatus.inProgress:
        return 'in_progress';
      default:
        return name;
    }
  }

  String get label {
    switch (this) {
      case TaskStatus.inProgress:
        return 'In Progress';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  static TaskStatus fromString(String value) {
    switch (value) {
      case 'in_progress':
        return TaskStatus.inProgress;
      default:
        return TaskStatus.values.firstWhere(
          (e) => e.name == value,
          orElse: () => TaskStatus.pending,
        );
    }
  }
}

enum TaskPriority {
  low,
  medium,
  high,
  urgent;

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

enum BreakType {
  lunch,
  short,
  other;

  String get label {
    return name[0].toUpperCase() + name.substring(1);
  }
}

enum DocumentType {
  idCard,
  contract,
  certificate,
  taxDocument,
  bankDetails,
  other;

  String get value {
    switch (this) {
      case DocumentType.idCard:
        return 'id_card';
      case DocumentType.taxDocument:
        return 'tax_document';
      case DocumentType.bankDetails:
        return 'bank_details';
      default:
        return name;
    }
  }

  String get label {
    switch (this) {
      case DocumentType.idCard:
        return 'ID Card';
      case DocumentType.taxDocument:
        return 'Tax Document';
      case DocumentType.bankDetails:
        return 'Bank Details';
      default:
        return name[0].toUpperCase() + name.substring(1);
    }
  }

  static DocumentType fromString(String value) {
    switch (value) {
      case 'id_card':
        return DocumentType.idCard;
      case 'tax_document':
        return DocumentType.taxDocument;
      case 'bank_details':
        return DocumentType.bankDetails;
      default:
        return DocumentType.values.firstWhere(
          (e) => e.name == value,
          orElse: () => DocumentType.other,
        );
    }
  }
}
