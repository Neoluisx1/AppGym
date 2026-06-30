class AdminStats {
  final int totalActiveClients;
  final int todayAttendance;
  final int expiringSoon;
  final int expiredMemberships;
  final int newClientsMonth;
  final double todayRevenue;
  final AdminOpenRegister? openRegister;

  AdminStats({
    required this.totalActiveClients,
    required this.todayAttendance,
    required this.expiringSoon,
    required this.expiredMemberships,
    required this.newClientsMonth,
    required this.todayRevenue,
    this.openRegister,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalActiveClients: json['total_active_clients'] ?? 0,
      todayAttendance: json['today_attendance'] ?? 0,
      expiringSoon: json['expiring_soon'] ?? 0,
      expiredMemberships: json['expired_memberships'] ?? 0,
      newClientsMonth: json['new_clients_month'] ?? 0,
      todayRevenue: (json['today_revenue'] ?? 0).toDouble(),
      openRegister: json['open_register'] != null
          ? AdminOpenRegister.fromJson(json['open_register'])
          : null,
    );
  }
}

class AdminOpenRegister {
  final int id;
  final String? openedAt;
  final double totalSales;

  AdminOpenRegister({required this.id, this.openedAt, required this.totalSales});

  factory AdminOpenRegister.fromJson(Map<String, dynamic> json) {
    return AdminOpenRegister(
      id: json['id'] ?? 0,
      openedAt: json['opened_at'],
      totalSales: (json['total_sales'] ?? 0).toDouble(),
    );
  }
}

class AdminAttendanceRecord {
  final int id;
  final int clientId;
  final String name;
  final String? photo;
  final String checkIn;
  final String? checkOut;
  final int? duration;
  final String? method;

  AdminAttendanceRecord({
    required this.id,
    required this.clientId,
    required this.name,
    this.photo,
    required this.checkIn,
    this.checkOut,
    this.duration,
    this.method,
  });

  factory AdminAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AdminAttendanceRecord(
      id: json['id'] ?? 0,
      clientId: json['client_id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      photo: json['photo'],
      checkIn: json['check_in'] ?? '',
      checkOut: json['check_out'],
      duration: json['duration'],
      method: json['method'],
    );
  }
}

class AdminExpiringClient {
  final int id;
  final String name;
  final String? photo;
  final String? phone;
  final String? membershipEnd;
  final int daysRemaining;

  AdminExpiringClient({
    required this.id,
    required this.name,
    this.photo,
    this.phone,
    this.membershipEnd,
    required this.daysRemaining,
  });

  factory AdminExpiringClient.fromJson(Map<String, dynamic> json) {
    return AdminExpiringClient(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      photo: json['photo'],
      phone: json['phone'],
      membershipEnd: json['membership_end'],
      daysRemaining: json['days_remaining'] ?? 0,
    );
  }
}

class AdminSearchClient {
  final int id;
  final String name;
  final String? document;
  final String? phone;
  final String? photo;
  final bool isActive;
  final String? membershipEnd;

  AdminSearchClient({
    required this.id,
    required this.name,
    this.document,
    this.phone,
    this.photo,
    required this.isActive,
    this.membershipEnd,
  });

  factory AdminSearchClient.fromJson(Map<String, dynamic> json) {
    return AdminSearchClient(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Sin nombre',
      document: json['document'],
      phone: json['phone'],
      photo: json['photo'],
      isActive: json['is_active'] == true || json['is_active'] == 1,
      membershipEnd: json['membership_end'],
    );
  }
}
