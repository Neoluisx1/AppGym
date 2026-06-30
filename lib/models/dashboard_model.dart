// 📊 Dashboard Model
class DashboardModel {
  final ClientInfo client;
  final MembershipInfo? membership;
  final Stats stats;
  final List<AttendanceItem> recentAttendances;
  final List<ClassItem> upcomingClasses;
  final List<RoutineItem> activeRoutines;
  final List<GoalItem> activeGoals;

  DashboardModel({
    required this.client,
    this.membership,
    required this.stats,
    required this.recentAttendances,
    required this.upcomingClasses,
    required this.activeRoutines,
    required this.activeGoals,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      client: ClientInfo.fromJson(json['client']),
      membership: json['membership'] != null ? MembershipInfo.fromJson(json['membership']) : null,
      stats: Stats.fromJson(json['stats']),
      recentAttendances: (json['recent_attendances'] as List?)
          ?.map((e) => AttendanceItem.fromJson(e))
          .toList() ?? [],
      upcomingClasses: (json['upcoming_classes'] as List?)
          ?.map((e) => ClassItem.fromJson(e))
          .toList() ?? [],
      activeRoutines: (json['active_routines'] as List?)
          ?.map((e) => RoutineItem.fromJson(e))
          .toList() ?? [],
      activeGoals: (json['active_goals'] as List?)
          ?.map((e) => GoalItem.fromJson(e))
          .toList() ?? [],
    );
  }
}

class ClientInfo {
  final String name;
  final String email;
  final int points;
  final String? photoUrl;

  ClientInfo({
    required this.name,
    required this.email,
    required this.points,
    this.photoUrl,
  });

  factory ClientInfo.fromJson(Map<String, dynamic> json) {
    final photoUrl = json['photo'] ?? json['photo_url'];
    
    return ClientInfo(
      name: json['name'],
      email: json['email'],
      points: json['points'] ?? 0,
      photoUrl: photoUrl,
    );
  }
}

class MembershipInfo {
  final String name;
  final String? status;
  final String? startDate;
  final String? endDate;
  final int? daysRemaining;
  final int? daysUsed;
  final int? availableDays;
  final String? type;

  MembershipInfo({
    required this.name,
    this.status,
    this.startDate,
    this.endDate,
    this.daysRemaining,
    this.daysUsed,
    this.availableDays,
    this.type,
  });

  factory MembershipInfo.fromJson(Map<String, dynamic> json) {
    // Prefer explicit is_active flag from API; fall back to status string
    String resolvedStatus;
    if (json['is_active'] != null) {
      resolvedStatus = (json['is_active'] == true || json['is_active'] == 1)
          ? 'active'
          : 'expired';
    } else {
      resolvedStatus = json['status'] ?? 'expired';
    }
    return MembershipInfo(
      name: json['name'],
      status: resolvedStatus,
      startDate: json['start_date'],
      endDate: json['end_date'],
      daysRemaining: json['days_remaining'],
      daysUsed: json['days_used'],
      availableDays: json['available_days'],
      type: json['type'],
    );
  }

  bool get isActive => status == 'active';
  bool get isExpiringSoon => status == 'expiring_soon';
  
  double get usagePercentage {
    if (type == 'business_days' && availableDays != null && availableDays! > 0) {
      return (daysUsed ?? 0) / availableDays!;
    }
    return 0.75; // Default
  }
}

class Stats {
  final int totalAttendances;
  final int thisMonthAttendances;
  final int activeRoutines;
  final int activeGoals;
  final int upcomingClasses;

  Stats({
    required this.totalAttendances,
    required this.thisMonthAttendances,
    required this.activeRoutines,
    required this.activeGoals,
    required this.upcomingClasses,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalAttendances: json['total_attendances'] ?? 0,
      thisMonthAttendances: json['this_month_attendances'] ?? 0,
      activeRoutines: json['active_routines'] ?? 0,
      activeGoals: json['active_goals'] ?? 0,
      upcomingClasses: json['upcoming_classes'] ?? 0,
    );
  }
}

class AttendanceItem {
  final String? checkIn;
  final String? checkOut;
  final String? duration;

  AttendanceItem({
    this.checkIn,
    this.checkOut,
    this.duration,
  });

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      checkIn: json['check_in'],
      checkOut: json['check_out'],
      duration: json['duration'],
    );
  }
  
  String get date => checkIn ?? '';
}

class ClassItem {
  final int id;
  final String name;
  final String date;
  final String startTime;
  final int enrolledCount;
  final int capacity;

  ClassItem({
    required this.id,
    required this.name,
    required this.date,
    required this.startTime,
    required this.enrolledCount,
    required this.capacity,
  });

  factory ClassItem.fromJson(Map<String, dynamic> json) {
    return ClassItem(
      id: json['id'],
      name: json['name'],
      date: json['date'],
      startTime: json['start_time'],
      enrolledCount: json['enrolled_count'] ?? 0,
      capacity: json['capacity'] ?? 0,
    );
  }
}

class RoutineItem {
  final int id;
  final String name;
  final String? description;
  final int exercisesCount;

  RoutineItem({
    required this.id,
    required this.name,
    this.description,
    required this.exercisesCount,
  });

  factory RoutineItem.fromJson(Map<String, dynamic> json) {
    return RoutineItem(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      exercisesCount: json['exercises_count'] ?? 0,
    );
  }
}

class GoalItem {
  final int id;
  final String title;
  final double targetValue;
  final double currentValue;
  final String? unit;
  final double progressPercentage;

  GoalItem({
    required this.id,
    required this.title,
    required this.targetValue,
    required this.currentValue,
    this.unit,
    required this.progressPercentage,
  });

  factory GoalItem.fromJson(Map<String, dynamic> json) {
    return GoalItem(
      id: json['id'],
      title: json['title'],
      targetValue: (json['target_value'] ?? 0).toDouble(),
      currentValue: (json['current_value'] ?? 0).toDouble(),
      unit: json['unit'],
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
    );
  }
}
