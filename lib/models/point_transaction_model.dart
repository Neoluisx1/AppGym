class PointTransactionModel {
  final int id;
  final int points;
  final String type;
  final String description;
  final String createdAt;

  PointTransactionModel({
    required this.id,
    required this.points,
    required this.type,
    required this.description,
    required this.createdAt,
  });

  factory PointTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointTransactionModel(
      id: json['id'],
      points: (json['points'] as num).toInt(),
      type: json['type'] ?? 'earned',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isEarned => points > 0;
}
