// 💳 Membership Plan Model
class MembershipPlanModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int durationDays;
  final String type;
  final List<String> features;
  final bool isPopular;
  final int? availableDays;
  
  MembershipPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.durationDays,
    required this.type,
    required this.features,
    this.isPopular = false,
    this.availableDays,
  });
  
  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) {
    return MembershipPlanModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null ? (json['price'] is double ? json['price'] : double.parse(json['price'].toString())) : 0.0,
      durationDays: json['duration_days'] is int ? json['duration_days'] : int.tryParse(json['duration_days']?.toString() ?? '30') ?? 30,
      type: json['type'] ?? 'calendar_days',
      features: json['features'] != null ? List<String>.from(json['features']) : [],
      isPopular: json['is_popular'] == true || json['is_popular'] == 1,
      availableDays: json['available_days'] is int ? json['available_days'] : int.tryParse(json['available_days']?.toString() ?? ''),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration_days': durationDays,
      'type': type,
      'features': features,
      'is_popular': isPopular,
      'available_days': availableDays,
    };
  }
  
  String get displayDuration {
    if (durationDays >= 365) {
      return '${(durationDays / 365).round()} año${durationDays >= 730 ? 's' : ''}';
    } else if (durationDays >= 30) {
      return '${(durationDays / 30).round()} mes${durationDays >= 60 ? 'es' : ''}';
    }
    return '$durationDays días';
  }
}
