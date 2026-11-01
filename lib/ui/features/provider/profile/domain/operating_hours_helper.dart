import 'package:servis_ku/ui/features/provider/profile/domain/shop_profile.dart';

class OperatingHoursGroup {
  final String dayRange; // e.g. "Senin - Jumat", "Sabtu", "Minggu"
  final String hoursText; // e.g. "08.00 - 17.00", "Tutup"

  const OperatingHoursGroup({
    required this.dayRange,
    required this.hoursText,
  });
}

class OperatingHoursHelper {
  OperatingHoursHelper._();

  /// Format string time "HH:mm:ss" atau "HH:mm" menjadi "HH.mm"
  static String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '00.00';
    final parts = timeStr.split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}.${parts[1].padLeft(2, '0')}';
    }
    return timeStr;
  }

  /// Format string time "HH:mm:ss" atau "HH:mm" menjadi "HH:mm" untuk Supabase time
  static String normalizeTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '08:00:00';
    final parts = timeStr.replaceAll('.', ':').split(':');
    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}:00';
    }
    return timeStr;
  }

  /// Kelompokkan hari berurutan dengan jam sama menjadi baris ramah pengguna:
  /// Contoh:
  /// - Senin-Jumat 08.00 - 17.00
  /// - Sabtu 08.00 - 15.00
  /// - Minggu Tutup
  static List<OperatingHoursGroup> groupHours(List<OperatingHour> hours) {
    if (hours.isEmpty) return const [];

    // Pastikan urut day_of_week 1 s.d 7
    final sorted = List<OperatingHour>.from(hours)
      ..sort((a, b) => a.dayOfWeek.compareTo(b.dayOfWeek));

    final List<OperatingHoursGroup> result = [];

    int startIdx = 0;
    while (startIdx < sorted.length) {
      int endIdx = startIdx;
      final current = sorted[startIdx];
      final currentScheduleKey = _scheduleKey(current);

      while (endIdx + 1 < sorted.length &&
          _scheduleKey(sorted[endIdx + 1]) == currentScheduleKey &&
          sorted[endIdx + 1].dayOfWeek == sorted[endIdx].dayOfWeek + 1) {
        endIdx++;
      }

      final startDayName = OperatingHour.dayName(sorted[startIdx].dayOfWeek);
      final endDayName = OperatingHour.dayName(sorted[endIdx].dayOfWeek);

      final String dayRange = (startIdx == endIdx)
          ? startDayName
          : '$startDayName – $endDayName';

      final String hoursText = current.isClosed
          ? 'Tutup'
          : '${formatTime(current.openTime)} – ${formatTime(current.closeTime)}';

      result.add(OperatingHoursGroup(dayRange: dayRange, hoursText: hoursText));

      startIdx = endIdx + 1;
    }

    return result;
  }

  static String _scheduleKey(OperatingHour h) {
    if (h.isClosed) return 'closed';
    return '${formatTime(h.openTime)}-${formatTime(h.closeTime)}';
  }
}
