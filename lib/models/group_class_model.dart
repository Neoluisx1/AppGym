// 🏋️ Group Class Model
class GroupClassModel {
  final int id;
  final String name;
  final String description;
  final String? instructor;
  final String schedule;
  final int capacity;
  final int enrolled;
  final String? imageUrl;
  final String difficulty;
  final int duration;
  
  GroupClassModel({
    required this.id,
    required this.name,
    required this.description,
    this.instructor,
    required this.schedule,
    required this.capacity,
    required this.enrolled,
    this.imageUrl,
    required this.difficulty,
    required this.duration,
  });
  
  factory GroupClassModel.fromJson(Map<String, dynamic> json) {
    return GroupClassModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      instructor: json['instructor'],
      schedule: json['schedule'] ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.tryParse(json['capacity']?.toString() ?? '0') ?? 0,
      enrolled: json['enrolled'] is int ? json['enrolled'] : int.tryParse(json['enrolled']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'],
      difficulty: json['difficulty'] ?? 'medium',
      duration: json['duration'] is int ? json['duration'] : int.tryParse(json['duration']?.toString() ?? '60') ?? 60,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'instructor': instructor,
      'schedule': schedule,
      'capacity': capacity,
      'enrolled': enrolled,
      'image_url': imageUrl,
      'difficulty': difficulty,
      'duration': duration,
    };
  }
  
  bool get isFull => enrolled >= capacity;
  int get availableSpots => capacity - enrolled;
}
