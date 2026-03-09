
class WasteEntry{
final String dayOfWeek;
final String pickupTime;
const WasteEntry({
  required this.dayOfWeek,
  required this.pickupTime
});
factory WasteEntry.fromJson(Map<String, dynamic>j) => WasteEntry(
  dayOfWeek: j['day_of_week'] as String,
   pickupTime: j['pickup_time'] as String
   );
   String get dayLabel {
    switch (dayOfWeek) {
      case 'monday':    return 'Mon';
      case 'tuesday':   return 'Tue';
      case 'wednesday': return 'Wed';
      case 'thursday':  return 'Thu';
      case 'friday':    return 'Fri';
      case 'saturday':  return 'Sat';
      case 'sunday':    return 'Sun';
      default:          return dayOfWeek;
    }
  }
}
class NextPickup {
  final String dayOfWeek;
  final String pickupTime;
  final String date;
  final int daysFromNow;
  const NextPickup({
    required this.dayOfWeek,
    required this.pickupTime,
    required this.date,
    required this.daysFromNow
  });
  factory NextPickup.fromJson(Map<String, dynamic> j) => NextPickup(
    dayOfWeek: j['dayOfWeek'] as String,
    pickupTime: j['pickupTime'] as String,
    date: j['date'] as String,
    daysFromNow: j['daysFromNow'] as int
    );
  String get formattedDate {
    try {
      final parts = date.split('-');
      final dt    = DateTime(
          int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      const months = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
      return '${days[dt.weekday % 7]}, ${months[dt.month]} ${dt.day}';
    } catch (_) {
      return date;
    }
  }
}
class WasteScheduleModal {
  final String zone;
  final List<WasteEntry> schedule;
  final NextPickup? nextPickup;
  const WasteScheduleModal({
    required this.zone,
    required this.schedule,
    this.nextPickup
  });
  factory WasteScheduleModal.fromJson(Map<String, dynamic> j) {
    final scheduleList = (j['schedule'] as List? ?? [])
        .map((e) => WasteEntry.fromJson(e as Map<String, dynamic>))
        .toList();
    final np = j['nextPickup'] != null
        ? NextPickup.fromJson(j['nextPickup'] as Map<String, dynamic>)
        : null;

    return WasteScheduleModal(
      zone: j['zone'] as String? ?? '',
      schedule: scheduleList,
      nextPickup: np,
    );
  }
  Map<String, List<WasteEntry>> get byDay {
    final map = <String, List<WasteEntry>>{};
    for (final e in schedule) {
      map.putIfAbsent(e.dayLabel, () => []).add(e);
    }
    return map;
  }
}
class MunicipalityStats {
  final int totalRequests;
  final int openIssues;
  final int resolved;
  const MunicipalityStats({
    required this.totalRequests,
    required this.openIssues,
    required this.resolved
  });
  factory MunicipalityStats.fromJson(Map<String, dynamic> j) =>
      MunicipalityStats(
        totalRequests: j['totalRequests'] as int? ?? 0,
        openIssues: j['openIssues']    as int? ?? 0,
        resolved: j['resolved']      as int? ?? 0,
      );
}
class MunicipalityInfo{
  final String name;
  final String nameArabic;
  final String district;
  final String phone;
  final String workingHours;
  final bool isOpenNow;
  const MunicipalityInfo({
    required this.name,
    required this.nameArabic,
    required this.district,
    required this.phone,
    required this.workingHours,
    required this.isOpenNow
  });
  factory MunicipalityInfo.fromJson(Map<String, dynamic> j) =>
      MunicipalityInfo(
        name: j['name'] as String? ?? '',
        nameArabic: j['nameArabic'] as String? ?? '',
        district: j['district'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
        workingHours: j['workingHours'] as String? ?? '',
        isOpenNow: j['isOpenNow'] as bool? ?? false,
      );
}
class HomeData{
  final String firstName;
  final String zone;
  final MunicipalityInfo municipality;
  final WasteScheduleModal wasteSchedule;
  final MunicipalityStats stats;
  final int unreadNotifications;
  const HomeData({
    required this.firstName,
    required this.zone,
    required this.municipality,
    required this.wasteSchedule,
    required this.stats,
    required this.unreadNotifications
  });
  factory HomeData.fromJson(Map<String, dynamic> j) {
    final data = j['data'] as Map<String, dynamic>;
    return HomeData(
      firstName:(data['citizen'] as Map)['firstName'] as String,
      zone:(data['citizen'] as Map)['zone']      as String? ?? '',
      municipality:MunicipalityInfo.fromJson(data['municipality'] as Map<String, dynamic>),
      wasteSchedule:WasteScheduleModal.fromJson(data['wasteSchedule'] as Map<String, dynamic>),
      stats:MunicipalityStats.fromJson(data['stats'] as Map<String, dynamic>),
      unreadNotifications: data['unreadNotifications'] as int? ?? 0,
    );
  }
}