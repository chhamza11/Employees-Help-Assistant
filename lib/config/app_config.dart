class AppConfig {
  static const String appwriteEndpoint = 'https://aw.speedforcehosting.com/v1';
  static const String appwriteProjectId = '69ca59b3003324e11a1f';
  static const String appwriteDatabaseId = '69ca5b29000d5c7e60fa';
  static const String appwriteDocumentsBucketId = '69a696ae000e832ef215';

  // Geofence
  static const double officeLatitude = 31.433500;
  static const double officeLongitude = 74.267217;
  static const double officeRadiusMeters = 100.0;
}

class Collections {
  static const String users = 'users';
  static const String attendance = 'attendance';
  static const String leaves = 'leaves';
  static const String workingHours = 'working_hours';
  static const String profileUpdates = 'profile_updates';
  static const String teams = 'teams';
  static const String breaks = 'breaks';
  static const String leaveBalances = 'leave_balances';
  static const String tasks = 'tasks';
  static const String documents = 'documents';
  static const String notifications = 'notifications';
  static const String culturalEvents = 'cultural_events';
}
