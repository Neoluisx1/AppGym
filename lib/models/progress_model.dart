// 📈 Progress Models
class ProgressModel {
  final int id;
  final String date;
  final double? weight;
  final double? bodyFatPercentage;
  final double? muscleMass;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? leftArm;
  final double? rightArm;
  final double? leftThigh;
  final double? rightThigh;
  final String? notes;
  final String createdAt;

  ProgressModel({
    required this.id,
    required this.date,
    this.weight,
    this.bodyFatPercentage,
    this.muscleMass,
    this.chest,
    this.waist,
    this.hips,
    this.leftArm,
    this.rightArm,
    this.leftThigh,
    this.rightThigh,
    this.notes,
    required this.createdAt,
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    return ProgressModel(
      id: json['id'],
      date: json['date'],
      weight: json['weight']?.toDouble(),
      bodyFatPercentage: json['body_fat_percentage']?.toDouble(),
      muscleMass: json['muscle_mass']?.toDouble(),
      chest: json['chest']?.toDouble(),
      waist: json['waist']?.toDouble(),
      hips: json['hips']?.toDouble(),
      leftArm: json['left_arm']?.toDouble(),
      rightArm: json['right_arm']?.toDouble(),
      leftThigh: json['left_thigh']?.toDouble(),
      rightThigh: json['right_thigh']?.toDouble(),
      notes: json['notes'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      if (weight != null) 'weight': weight,
      if (bodyFatPercentage != null) 'body_fat_percentage': bodyFatPercentage,
      if (muscleMass != null) 'muscle_mass': muscleMass,
      if (chest != null) 'chest': chest,
      if (waist != null) 'waist': waist,
      if (hips != null) 'hips': hips,
      if (leftArm != null) 'left_arm': leftArm,
      if (rightArm != null) 'right_arm': rightArm,
      if (leftThigh != null) 'left_thigh': leftThigh,
      if (rightThigh != null) 'right_thigh': rightThigh,
      if (notes != null) 'notes': notes,
    };
  }
}

class GoalModel {
  final int id;
  final String title;
  final String? description;
  final double targetValue;
  final double currentValue;
  final String? unit;
  final double progressPercentage;
  final String status;
  final String? deadline;
  final int? pointsReward;
  final String? completedAt;
  final bool isCompleted;
  final bool isOverdue;
  final int? daysRemaining;
  final String? assignedBy;

  GoalModel({
    required this.id,
    required this.title,
    this.description,
    required this.targetValue,
    required this.currentValue,
    this.unit,
    required this.progressPercentage,
    required this.status,
    this.deadline,
    this.pointsReward,
    this.completedAt,
    required this.isCompleted,
    required this.isOverdue,
    this.daysRemaining,
    this.assignedBy,
  });
  
  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted' || status == 'in_progress';
  bool get isRejected => status == 'rejected';

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      targetValue: (json['target_value'] ?? 0).toDouble(),
      currentValue: (json['current_value'] ?? 0).toDouble(),
      unit: json['unit'],
      progressPercentage: (json['progress_percentage'] ?? 0).toDouble(),
      status: json['status'] ?? 'in_progress',
      deadline: json['deadline'],
      pointsReward: json['points_reward'],
      completedAt: json['completed_at'],
      isCompleted: json['is_completed'] ?? false,
      isOverdue: json['is_overdue'] ?? false,
      daysRemaining: json['days_remaining'],
      assignedBy: json['assigned_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (description != null) 'description': description,
      'target_value': targetValue,
      'current_value': currentValue,
      if (unit != null) 'unit': unit,
      if (deadline != null) 'deadline': deadline,
      if (pointsReward != null) 'points_reward': pointsReward,
    };
  }
}
