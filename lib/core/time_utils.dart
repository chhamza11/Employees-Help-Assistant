import 'package:intl/intl.dart';

/// Pakistan Standard Time offset: UTC+5
const Duration _pktOffset = Duration(hours: 5);

/// Convert a UTC ISO string to PKT DateTime
DateTime toPKT(String isoString) {
  try {
    final dt = DateTime.parse(isoString);
    // If already local, just return it; if UTC, add PKT offset
    if (dt.isUtc) {
      return dt.add(_pktOffset);
    }
    return dt;
  } catch (_) {
    return DateTime.now();
  }
}

/// Format an ISO timestamp as time in PKT (e.g., "1:07 PM")
String formatTimePKT(String isoString) {
  try {
    final dt = toPKT(isoString);
    return DateFormat('h:mm a').format(dt);
  } catch (_) {
    return isoString;
  }
}

/// Format an ISO date string (e.g., "Wed, Apr 23")
String formatDateShort(String date) {
  try {
    final dt = DateTime.parse(date);
    return DateFormat('EEE, MMM d').format(dt);
  } catch (_) {
    return date;
  }
}

/// Format an ISO date string (e.g., "Wednesday, April 23, 2026")
String formatDateFull(String date) {
  try {
    final dt = DateTime.parse(date);
    return DateFormat('EEEE, MMMM d, y').format(dt);
  } catch (_) {
    return date;
  }
}

/// Format date as "MMM d" (e.g., "Apr 23")
String formatDateCompact(String date) {
  try {
    return DateFormat('MMM d').format(DateTime.parse(date));
  } catch (_) {
    return date;
  }
}

/// Get current time in PKT
DateTime nowPKT() {
  return DateTime.now().toUtc().add(_pktOffset);
}
