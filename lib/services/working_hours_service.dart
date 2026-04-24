import 'package:appwrite/appwrite.dart';
import 'appwrite_client.dart';
import '../config/app_config.dart';
import '../models/working_hours_model.dart';

class WorkingHoursService {
  final _client = AppwriteClient();

  Future<List<WorkingHoursModel>> getWeeklyHours(String userId) async {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartStr = weekStart.toIso8601String().split('T')[0];

    // Try working_hours collection first
    var results = await _fetchFromWorkingHours(userId, queries: [
      Query.equal('userId', userId),
      Query.greaterThanEqual('date', weekStartStr),
      Query.orderAsc('date'),
    ]);

    // Fallback: derive from attendance records if working_hours is empty
    if (results.isEmpty) {
      results = await _fetchFromAttendance(userId, queries: [
        Query.equal('userId', userId),
        Query.greaterThanEqual('date', weekStartStr),
        Query.orderAsc('date'),
      ]);
    }

    return results;
  }

  Future<List<WorkingHoursModel>> getHoursHistory(String userId, {int limit = 30}) async {
    // Try working_hours collection first
    var results = await _fetchFromWorkingHours(userId, queries: [
      Query.equal('userId', userId),
      Query.orderDesc('date'),
      Query.limit(limit),
    ]);

    // Fallback: derive from attendance records
    if (results.isEmpty) {
      results = await _fetchFromAttendance(userId, queries: [
        Query.equal('userId', userId),
        Query.orderDesc('date'),
        Query.limit(limit),
      ]);
    }

    return results;
  }

  Future<List<WorkingHoursModel>> _fetchFromWorkingHours(
    String userId, {
    required List<String> queries,
  }) async {
    try {
      final response = await _client.databases.listDocuments(
        databaseId: _client.databaseId,
        collectionId: Collections.workingHours,
        queries: queries,
      );
      return response.documents
          .map((doc) => WorkingHoursModel.fromMap(doc.data))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<WorkingHoursModel>> _fetchFromAttendance(
    String userId, {
    required List<String> queries,
  }) async {
    try {
      final response = await _client.databases.listDocuments(
        databaseId: _client.databaseId,
        collectionId: Collections.attendance,
        queries: queries,
      );
      return response.documents
          .where((doc) => doc.data['clockOut'] != null)
          .map((doc) {
        final data = doc.data;
        // Calculate hours from clockIn/clockOut if totalHours not available
        double total = (data['totalHours'] as num?)?.toDouble() ?? 0;
        if (total == 0 && data['clockIn'] != null && data['clockOut'] != null) {
          try {
            final clockIn = DateTime.parse(data['clockIn']);
            final clockOut = DateTime.parse(data['clockOut']);
            final diff = clockOut.difference(clockIn);
            total = diff.inMinutes / 60.0;
            // Subtract 1h break if session > 1h (same as web)
            if (total > 1) total -= 1;
          } catch (_) {}
        }
        return WorkingHoursModel(
          id: data['\$id'] ?? '',
          userId: data['userId'] ?? '',
          date: data['date'] ?? '',
          regularHours: total,
          overtimeHours: (data['overtimeHours'] as num?)?.toDouble() ?? 0,
          breakMinutes: data['breakMinutes'] as int? ?? (total > 0 ? 60 : 0),
          createdAt: data['createdAt'] ?? '',
          updatedAt: data['updatedAt'] ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
