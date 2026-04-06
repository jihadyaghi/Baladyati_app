class CitizenProfile {
  final int id;
  final String firstName;
  final String lastName;
  final String phone;
  final String? dateOfBirth;
  final bool isVerified;
  final String memberSince;
  final String? zone;
  final String? zoneDesc;

  const CitizenProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    this.dateOfBirth,
    required this.isVerified,
    required this.memberSince,
    this.zone,
    this.zoneDesc,
  });

  String get fullName => '$firstName $lastName';

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  factory CitizenProfile.fromJson(Map<String, dynamic> json) => CitizenProfile(
        id: (json['id'] as num).toInt(),
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        phone: json['phone'] ?? '',
        dateOfBirth: json['dateOfBirth'] as String?,
        isVerified: json['isVerified'] as bool? ?? false,
        memberSince: json['memberSince'] as String? ?? '',
        zone: json['zone'] as String?,
        zoneDesc: json['zoneDesc'] as String?,
      );
}

class CitizenStats {
  final int totalRequests;
  final int resolvedRequests;
  final int totalIssues;
  final int resolvedIssues;
  final int totalAppointments;
  final int totalProposals;
  final int totalVotes;

  const CitizenStats({
    required this.totalRequests,
    required this.resolvedRequests,
    required this.totalIssues,
    required this.resolvedIssues,
    required this.totalAppointments,
    required this.totalProposals,
    required this.totalVotes,
  });

  factory CitizenStats.fromJson(Map<String, dynamic> json) => CitizenStats(
        totalRequests: (json['totalRequests'] as num?)?.toInt() ?? 0,
        resolvedRequests: (json['resolvedRequests'] as num?)?.toInt() ?? 0,
        totalIssues: (json['totalIssues'] as num?)?.toInt() ?? 0,
        resolvedIssues: (json['resolvedIssues'] as num?)?.toInt() ?? 0,
        totalAppointments: (json['totalAppointments'] as num?)?.toInt() ?? 0,
        totalProposals: (json['totalProposals'] as num?)?.toInt() ?? 0,
        totalVotes: (json['totalVotes'] as num?)?.toInt() ?? 0,
      );
}