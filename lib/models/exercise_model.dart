class ExerciseModel {
  final int id;
  final String name;
  final String? description;
  final String category;
  final String? muscleGroup;
  final String difficulty;
  final String? equipment;
  final String? videoUrl;
  final String? imageUrl;
  final double? caloriesPerRep;

  const ExerciseModel({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    this.muscleGroup,
    required this.difficulty,
    this.equipment,
    this.videoUrl,
    this.imageUrl,
    this.caloriesPerRep,
  });

  factory ExerciseModel.fromJson(Map<String, dynamic> j) => ExerciseModel(
        id: j['id'],
        name: j['name'] ?? '',
        description: j['description'],
        category: j['category'] ?? '',
        muscleGroup: j['muscle_group'],
        difficulty: j['difficulty'] ?? 'beginner',
        equipment: j['equipment'],
        videoUrl: j['video_url'],
        imageUrl: j['image_url'],
        caloriesPerRep: j['calories_per_rep'] != null
            ? double.tryParse(j['calories_per_rep'].toString())
            : null,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'category': category,
        'muscle_group': muscleGroup,
        'difficulty': difficulty,
        'equipment': equipment,
        'video_url': videoUrl,
        'image_url': imageUrl,
        'calories_per_rep': caloriesPerRep,
      };

  String get difficultyLabel => switch (difficulty) {
        'beginner'     => 'Principiante',
        'intermediate' => 'Intermedio',
        'advanced'     => 'Avanzado',
        _              => difficulty,
      };
}
