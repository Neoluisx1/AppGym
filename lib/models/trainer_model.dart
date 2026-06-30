class TrainerDashboardModel {
  final TrainerInfo trainer;
  final TrainerStats stats;
  final List<TrainerClientModel> clientsPreview;

  TrainerDashboardModel({
    required this.trainer,
    required this.stats,
    required this.clientsPreview,
  });

  factory TrainerDashboardModel.fromJson(Map<String, dynamic> json) {
    return TrainerDashboardModel(
      trainer: TrainerInfo.fromJson(json['trainer']),
      stats: TrainerStats.fromJson(json['stats']),
      clientsPreview: (json['clients_preview'] as List? ?? [])
          .map((e) => TrainerClientModel.fromJson(e))
          .toList(),
    );
  }
}

class TrainerInfo {
  final int id;
  final String name;
  final String? photo;
  final String? specialization;

  TrainerInfo({
    required this.id,
    required this.name,
    this.photo,
    this.specialization,
  });

  factory TrainerInfo.fromJson(Map<String, dynamic> json) => TrainerInfo(
        id: json['id'],
        name: json['name'],
        photo: json['photo'],
        specialization: json['specialization'],
      );
}

class TrainerStats {
  final int totalClients;
  final int activeClients;
  final int inactiveClients;
  final int pendingGoals;
  final int todayAttendances;

  TrainerStats({
    required this.totalClients,
    required this.activeClients,
    required this.inactiveClients,
    required this.pendingGoals,
    required this.todayAttendances,
  });

  factory TrainerStats.fromJson(Map<String, dynamic> json) => TrainerStats(
        totalClients: json['total_clients'] ?? 0,
        activeClients: json['active_clients'] ?? 0,
        inactiveClients: json['inactive_clients'] ?? 0,
        pendingGoals: json['pending_goals'] ?? 0,
        todayAttendances: json['today_attendances'] ?? 0,
      );
}

class TrainerClientModel {
  final int id;
  final String name;
  final String? photo;
  final String? document;
  final String? phone;
  final String? membership;
  final bool isActive;
  final int? daysRemaining;
  final String? endDate;
  final int points;

  TrainerClientModel({
    required this.id,
    required this.name,
    this.photo,
    this.document,
    this.phone,
    this.membership,
    required this.isActive,
    this.daysRemaining,
    this.endDate,
    required this.points,
  });

  factory TrainerClientModel.fromJson(Map<String, dynamic> json) =>
      TrainerClientModel(
        id: json['id'],
        name: json['name'] ?? 'Sin nombre',
        photo: json['photo'],
        document: json['document'],
        phone: json['phone'],
        membership: json['membership'],
        isActive: json['is_active'] == true || json['is_active'] == 1,
        daysRemaining: json['days_remaining'],
        endDate: json['end_date'],
        points: json['points'] ?? 0,
      );
}

class TrainerClientDetailModel {
  final int id;
  final int userId;
  final String name;
  final String? email;
  final String? photo;
  final String? document;
  final String? phone;
  final String? address;
  final String? gender;
  final String? dateOfBirth;
  final int points;
  final String? emergencyContact;
  final String? emergencyPhone;
  final ClientMembershipDetail? membership;
  final ClientDetailStats stats;
  final List<AttendanceEntry> recentAttendances;

  TrainerClientDetailModel({
    required this.id,
    required this.userId,
    required this.name,
    this.email,
    this.photo,
    this.document,
    this.phone,
    this.address,
    this.gender,
    this.dateOfBirth,
    required this.points,
    this.emergencyContact,
    this.emergencyPhone,
    this.membership,
    required this.stats,
    required this.recentAttendances,
  });

  factory TrainerClientDetailModel.fromJson(Map<String, dynamic> json) =>
      TrainerClientDetailModel(
        id:     json['id'],
        userId: json['user_id'] ?? 0,
        name:   json['name'] ?? 'Sin nombre',
        email:  json['email'],
        photo:  json['photo'],
        document: json['document'],
        phone:    json['phone'],
        address:  json['address'],
        gender:   json['gender'],
        dateOfBirth: json['date_of_birth'],
        points: json['points'] ?? 0,
        emergencyContact: json['emergency_contact'],
        emergencyPhone:   json['emergency_phone'],
        membership: json['membership'] != null
            ? ClientMembershipDetail.fromJson(json['membership'])
            : null,
        stats: ClientDetailStats.fromJson(json['stats'] ?? {}),
        recentAttendances: (json['recent_attendances'] as List? ?? [])
            .map((e) => AttendanceEntry.fromJson(e))
            .toList(),
      );
}

class ClientMembershipDetail {
  final String name;
  final bool isActive;
  final String? startDate;
  final String? endDate;
  final int? daysRemaining;

  ClientMembershipDetail({
    required this.name,
    required this.isActive,
    this.startDate,
    this.endDate,
    this.daysRemaining,
  });

  factory ClientMembershipDetail.fromJson(Map<String, dynamic> json) =>
      ClientMembershipDetail(
        name: json['name'] ?? '',
        isActive: json['is_active'] == true || json['is_active'] == 1,
        startDate: json['start_date'],
        endDate: json['end_date'],
        daysRemaining: json['days_remaining'],
      );
}

class ClientDetailStats {
  final int totalAttendances;
  final int monthAttendances;
  final int activeRoutines;
  final int activeGoals;

  ClientDetailStats({
    required this.totalAttendances,
    required this.monthAttendances,
    required this.activeRoutines,
    required this.activeGoals,
  });

  factory ClientDetailStats.fromJson(Map<String, dynamic> json) =>
      ClientDetailStats(
        totalAttendances: json['total_attendances'] ?? 0,
        monthAttendances: json['month_attendances'] ?? 0,
        activeRoutines: json['active_routines'] ?? 0,
        activeGoals: json['active_goals'] ?? 0,
      );
}

class AttendanceEntry {
  final String? checkIn;
  final String? checkOut;
  final String? duration;

  AttendanceEntry({this.checkIn, this.checkOut, this.duration});

  factory AttendanceEntry.fromJson(Map<String, dynamic> json) =>
      AttendanceEntry(
        checkIn: json['check_in'],
        checkOut: json['check_out'],
        duration: json['duration'],
      );
}

class PhysicalEvaluationModel {
  final int id;
  final String? measurementDate;
  final double? weight;
  final double? height;
  final double? bmi;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final double? visceralFat;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? arms;
  final double? thighLeft;
  final double? thighRight;
  final double? calfLeft;
  final double? calfRight;
  final int? pushUps;
  final int? sitUps;
  final double? flexibility;
  final int? bloodPressureSystolic;
  final int? bloodPressureDiastolic;
  final int? restingHeartRate;
  final String? notes;
  final String? goals;

  PhysicalEvaluationModel({
    required this.id,
    this.measurementDate,
    this.weight,
    this.height,
    this.bmi,
    this.bodyFatPercentage,
    this.muscleMass,
    this.visceralFat,
    this.chest,
    this.waist,
    this.hips,
    this.arms,
    this.thighLeft,
    this.thighRight,
    this.calfLeft,
    this.calfRight,
    this.pushUps,
    this.sitUps,
    this.flexibility,
    this.bloodPressureSystolic,
    this.bloodPressureDiastolic,
    this.restingHeartRate,
    this.notes,
    this.goals,
  });

  factory PhysicalEvaluationModel.fromJson(Map<String, dynamic> json) =>
      PhysicalEvaluationModel(
        id: json['id'],
        measurementDate: json['measurement_date'],
        weight: (json['weight'] as num?)?.toDouble(),
        height: (json['height'] as num?)?.toDouble(),
        bmi: (json['bmi'] as num?)?.toDouble(),
        bodyFatPercentage: (json['body_fat_percentage'] as num?)?.toDouble(),
        muscleMass: (json['muscle_mass'] as num?)?.toDouble(),
        visceralFat: (json['visceral_fat'] as num?)?.toDouble(),
        chest: (json['chest'] as num?)?.toDouble(),
        waist: (json['waist'] as num?)?.toDouble(),
        hips: (json['hips'] as num?)?.toDouble(),
        arms: (json['arms'] as num?)?.toDouble(),
        thighLeft: (json['thigh_left'] as num?)?.toDouble(),
        thighRight: (json['thigh_right'] as num?)?.toDouble(),
        calfLeft: (json['calf_left'] as num?)?.toDouble(),
        calfRight: (json['calf_right'] as num?)?.toDouble(),
        pushUps: json['push_ups'] as int?,
        sitUps: json['sit_ups'] as int?,
        flexibility: (json['flexibility'] as num?)?.toDouble(),
        bloodPressureSystolic: json['blood_pressure_systolic'] as int?,
        bloodPressureDiastolic: json['blood_pressure_diastolic'] as int?,
        restingHeartRate: json['resting_heart_rate'] as int?,
        notes: json['notes'],
        goals: json['goals'],
      );
}

class GoalModel {
  final int id;
  final String title;
  final String? description;
  final String goalType;
  final double? targetValue;
  final double? currentValue;
  final String? unit;
  final double progressPercentage;
  final String status;
  final String? startDate;
  final String? endDate;
  final String? notes;

  GoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.goalType,
    this.targetValue,
    this.currentValue,
    this.unit,
    required this.progressPercentage,
    required this.status,
    this.startDate,
    this.endDate,
    this.notes,
  });

  factory GoalModel.fromJson(Map<String, dynamic> json) => GoalModel(
        id: json['id'],
        title: json['title'] ?? '',
        description: json['description'],
        goalType: json['goal_type'] ?? 'custom',
        targetValue: (json['target_value'] as num?)?.toDouble(),
        currentValue: (json['current_value'] as num?)?.toDouble(),
        unit: json['unit'],
        progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0,
        status: json['status'] ?? 'active',
        startDate: json['start_date'],
        endDate: json['end_date'],
        notes: json['notes'],
      );
}

class ProgressModel {
  final int id;
  final String? measurementDate;
  final double? weight;
  final double? height;
  final double? bmi;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? arms;
  final double? thighs;
  final String? notes;
  final String? photoFront;
  final String? photoSide;
  final String? photoBack;

  ProgressModel({
    required this.id,
    this.measurementDate,
    this.weight,
    this.height,
    this.bmi,
    this.bodyFatPercentage,
    this.muscleMass,
    this.chest,
    this.waist,
    this.hips,
    this.arms,
    this.thighs,
    this.notes,
    this.photoFront,
    this.photoSide,
    this.photoBack,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) => ProgressModel(
        id: json['id'],
        measurementDate: json['measurement_date'],
        weight: (json['weight'] as num?)?.toDouble(),
        height: (json['height'] as num?)?.toDouble(),
        bmi: (json['bmi'] as num?)?.toDouble(),
        bodyFatPercentage: (json['body_fat_percentage'] as num?)?.toDouble(),
        muscleMass: (json['muscle_mass'] as num?)?.toDouble(),
        chest: (json['chest'] as num?)?.toDouble(),
        waist: (json['waist'] as num?)?.toDouble(),
        hips: (json['hips'] as num?)?.toDouble(),
        arms: (json['arms'] as num?)?.toDouble(),
        thighs: (json['thighs'] as num?)?.toDouble(),
        notes: json['notes'],
        photoFront: json['photo_front'],
        photoSide: json['photo_side'],
        photoBack: json['photo_back'],
      );
}

class RoutineDayModel {
  final int id;
  final String dayName;
  final int dayOrder;
  final String? focus;

  RoutineDayModel({
    required this.id,
    required this.dayName,
    required this.dayOrder,
    this.focus,
  });

  factory RoutineDayModel.fromJson(Map<String, dynamic> json) => RoutineDayModel(
        id: json['id'],
        dayName: json['day_name'] ?? '',
        dayOrder: json['day_order'] ?? 0,
        focus: json['focus'],
      );
}

class RoutineModel {
  final int id;
  final String name;
  final String? description;
  final String? startDate;
  final String? endDate;
  final bool isActive;
  final List<RoutineDayModel> days;

  RoutineModel({
    required this.id,
    required this.name,
    this.description,
    this.startDate,
    this.endDate,
    required this.isActive,
    this.days = const [],
  });

  factory RoutineModel.fromJson(Map<String, dynamic> json) => RoutineModel(
        id: json['id'],
        name: json['name'] ?? '',
        description: json['description'],
        startDate: json['start_date'],
        endDate: json['end_date'],
        isActive: json['is_active'] == true || json['is_active'] == 1,
        days: (json['days'] as List? ?? [])
            .map((d) => RoutineDayModel.fromJson(d))
            .toList(),
      );
}
