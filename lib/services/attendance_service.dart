import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/attendance_model.dart';
import '../models/break_model.dart';

class AttendanceService {
  final _client = AppwriteClient();

  Future<AttendanceModel?> getTodayAttendance(String userId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.attendance,
      queries: [
        Query.equal('userId', userId),
        Query.equal('date', today),
      ],
    );

    if (response.documents.isEmpty) return null;
    return AttendanceModel.fromMap(response.documents.first.data);
  }

  Future<AttendanceModel> clockIn(String userId, double latitude, double longitude) async {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];

    // Check if already clocked in today — same behavior as web app
    final existing = await getTodayAttendance(userId);
    if (existing != null && existing.clockIn != null) {
      // Already clocked in today, return existing record (no duplicate)
      return existing;
    }

    if (existing != null) {
      // Record exists but no clockIn — update it
      final doc = await _client.databases.updateDocument(
        databaseId: _client.databaseId,
        collectionId: Collections.attendance,
        documentId: existing.id,
        data: {
          'clockIn': now.toIso8601String(),
          'status': 'present',
          'updatedAt': now.toIso8601String(),
        },
      );
      return AttendanceModel.fromMap(doc.data);
    }

    // No record for today — create new
    final doc = await _client.databases.createDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.attendance,
      documentId: ID.unique(),
      data: {
        'userId': userId,
        'date': today,
        'clockIn': now.toIso8601String(),
        'status': 'present',
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
    );
    return AttendanceModel.fromMap(doc.data);
  }

  Future<AttendanceModel> clockOut(String attendanceId, double latitude, double longitude) async {
    final now = DateTime.now();
    // Update same record — just update clockOut time (like web app)
    final doc = await _client.databases.updateDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.attendance,
      documentId: attendanceId,
      data: {
        'clockOut': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
    );
    return AttendanceModel.fromMap(doc.data);
  }

  Future<List<AttendanceModel>> getAttendanceHistory(String userId, {int limit = 100}) async {
    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.attendance,
      queries: [
        Query.equal('userId', userId),
        Query.orderDesc('date'),
        Query.limit(limit),
      ],
    );

    return response.documents
        .map((doc) => AttendanceModel.fromMap(doc.data))
        .toList();
  }

  Future<List<AttendanceModel>> getAttendanceForMonth(String userId, int year, int month) async {
    final startDate = DateTime(year, month, 1).toIso8601String().split('T')[0];
    final endDate = DateTime(year, month + 1, 0).toIso8601String().split('T')[0];

    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.attendance,
      queries: [
        Query.equal('userId', userId),
        Query.greaterThanEqual('date', startDate),
        Query.lessThanEqual('date', endDate),
        Query.orderDesc('date'),
        Query.limit(100),
      ],
    );

    return response.documents
        .map((doc) => AttendanceModel.fromMap(doc.data))
        .toList();
  }

  Future<BreakModel> startBreak(String attendanceId, String userId, String breakType) async {
    final now = DateTime.now();
    final doc = await _client.databases.createDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.breaks,
      documentId: ID.unique(),
      data: {
        'attendanceId': attendanceId,
        'userId': userId,
        'breakStart': now.toIso8601String(),
        'breakType': breakType,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
    );
    return BreakModel.fromMap(doc.data);
  }

  Future<BreakModel> endBreak(String breakId) async {
    final now = DateTime.now();
    final doc = await _client.databases.updateDocument(
      databaseId: _client.databaseId,
      collectionId: Collections.breaks,
      documentId: breakId,
      data: {
        'breakEnd': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      },
    );
    return BreakModel.fromMap(doc.data);
  }

  Future<List<BreakModel>> getTodayBreaks(String userId) async {
    final attendance = await getTodayAttendance(userId);
    if (attendance == null) return [];

    final response = await _client.databases.listDocuments(
      databaseId: _client.databaseId,
      collectionId: Collections.breaks,
      queries: [
        Query.equal('attendanceId', attendance.id),
        Query.orderDesc('breakStart'),
      ],
    );

    return response.documents
        .map((doc) => BreakModel.fromMap(doc.data))
        .toList();
  }
}
