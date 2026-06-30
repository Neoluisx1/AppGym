class RoutineModel {
  final int id;
  final String name;
  final String? description;
  final bool isActive;
  final String? trainerName;
  final int? trainerId;
  final int? trainerUserId;
  final List<RoutineDayModel> days;

  RoutineModel({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
    this.trainerName,
    this.trainerId,
    this.trainerUserId,
    required this.days,
  });

  List<ExerciseModel> get exercises =>
      days.expand((d) => d.exercises).toList();

  factory RoutineModel.fromJson(Map<String, dynamic> json) {
    final trainer = json['trainer'] as Map<String, dynamic>?;
    return RoutineModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      trainerName: trainer?['name'] ?? json['trainer_name'],
      trainerId: trainer?['id'],
      trainerUserId: trainer?['user_id'],
      days: (json['days'] as List?)
              ?.map((d) => RoutineDayModel.fromJson(d))
              .toList() ??
          [],
    );
  }
}

class RoutineDayModel {
  final int id;
  final String? dayName;
  final int dayOrder;
  final String? focus;
  final String? notes;
  final List<ExerciseModel> exercises;

  RoutineDayModel({
    required this.id,
    this.dayName,
    required this.dayOrder,
    this.focus,
    this.notes,
    required this.exercises,
  });

  factory RoutineDayModel.fromJson(Map<String, dynamic> json) {
    return RoutineDayModel(
      id: json['id'],
      dayName: json['day_name'],
      dayOrder: json['day_order'] ?? 0,
      focus: json['focus'],
      notes: json['notes'],
      exercises: (json['exercises'] as List?)
              ?.map((e) => ExerciseModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class ExerciseModel {
  final int id;
  final String name;
  final String? description;
  final int sets;
  final int reps;
  final double? weight;
  final int? restSeconds;
  final String? videoUrl;
  final String? instructions;
  final int order;

  ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    required this.sets,
    required this.reps,
    this.weight,
    this.restSeconds,
    this.videoUrl,
    this.instructions,
    required this.order,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> json) {
    return ExerciseModel(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      sets: json['sets'] ?? 0,
      reps: json['reps'] ?? 0,
      weight: json['weight']?.toDouble(),
      restSeconds: json['rest_seconds'],
      videoUrl: json['video_url'],
      instructions: json['instructions'],
      order: json['order'] ?? 0,
    );
  }

  String get restFormatted {
    if (restSeconds == null) return 'N/A';
    final minutes = restSeconds! ~/ 60;
    final seconds = restSeconds! % 60;
    if (minutes > 0) return '${minutes}min ${seconds}s';
    return '${seconds}s';
  }
}
