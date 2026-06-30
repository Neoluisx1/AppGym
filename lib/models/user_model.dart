// 👤 User Model
class UserModel {
  final int id;
  final String name;
  final String email;
  final int? roleId;
  final RoleModel? role;
  final String? profilePhotoUrl;
  final ClientModel? client;
  final TrainerModel? trainer;
  
  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.roleId,
    this.role,
    this.profilePhotoUrl,
    this.client,
    this.trainer,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      roleId: json['role_id'] != null ? (json['role_id'] is int ? json['role_id'] : int.tryParse(json['role_id'].toString())) : null,
      role: json['role'] != null ? RoleModel.fromJson(json['role']) : null,
      profilePhotoUrl: json['profile_photo_url'],
      client: json['client'] != null ? ClientModel.fromJson(json['client']) : null,
      trainer: json['trainer'] != null ? TrainerModel.fromJson(json['trainer']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role_id': roleId,
      'role': role?.toJson(),
      'profile_photo_url': profilePhotoUrl,
      'client': client?.toJson(),
      'trainer': trainer?.toJson(),
    };
  }
}

// 🎭 Role Model
class RoleModel {
  final int id;
  final String name;
  final String displayName;
  
  RoleModel({
    required this.id,
    required this.name,
    required this.displayName,
  });
  
  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      displayName: json['display_name'] ?? '',
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'display_name': displayName,
    };
  }
}

// 👥 Client Model
class ClientModel {
  final int id;
  final String? document;
  final String? phone;
  final String? photoUrl;
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final bool isActive;
  final int points;
  final MembershipModel? membership;
  
  ClientModel({
    required this.id,
    this.document,
    this.phone,
    this.photoUrl,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    required this.isActive,
    required this.points,
    this.membership,
  });
  
  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      document: json['document'],
      phone: json['phone'],
      photoUrl: json['photo'] ?? json['photo_url'],
      address: json['address'],
      emergencyContact: json['emergency_contact_name'],
      emergencyPhone: json['emergency_contact_phone'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      points: json['points'] is int ? json['points'] : int.tryParse(json['points']?.toString() ?? '0') ?? 0,
      membership: json['membership'] != null 
        ? MembershipModel.fromJson(json['membership']) 
        : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'document': document,
      'phone': phone,
      'photo_url': photoUrl,
      'address': address,
      'emergency_contact_name': emergencyContact,
      'emergency_contact_phone': emergencyPhone,
      'is_active': isActive,
      'points': points,
      'membership': membership?.toJson(),
    };
  }
}

// 💪 Trainer Model
class TrainerModel {
  final int id;
  final String? specialty;
  final String? bio;
  final String? certification;
  final bool isActive;
  
  TrainerModel({
    required this.id,
    this.specialty,
    this.bio,
    this.certification,
    required this.isActive,
  });
  
  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      specialty: json['specialty'],
      bio: json['bio'],
      certification: json['certification'],
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'specialty': specialty,
      'bio': bio,
      'certification': certification,
      'is_active': isActive,
    };
  }
}

// 💳 Membership Model
class MembershipModel {
  final int id;
  final String name;
  final double price;
  final int durationDays;
  final String? startDate;
  final String? endDate;
  final String status;
  final String? type;
  final int? availableDays;
  final int? daysUsed;
  final int? daysRemaining;
  final double? usagePercentage;
  
  MembershipModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationDays,
    this.startDate,
    this.endDate,
    required this.status,
    this.type,
    this.availableDays,
    this.daysUsed,
    this.daysRemaining,
    this.usagePercentage,
  });
  
  factory MembershipModel.fromJson(Map<String, dynamic> json) {
    return MembershipModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      price: json['price'] != null ? (json['price'] is double ? json['price'] : double.parse(json['price'].toString())) : 0.0,
      durationDays: json['duration_days'] is int ? json['duration_days'] : int.tryParse(json['duration_days']?.toString() ?? '0') ?? 0,
      startDate: json['start_date'],
      endDate: json['end_date'],
      status: json['status'] ?? 'inactive',
      type: json['type'],
      availableDays: json['available_days'] is int ? json['available_days'] : int.tryParse(json['available_days']?.toString() ?? ''),
      daysUsed: json['days_used'] is int ? json['days_used'] : int.tryParse(json['days_used']?.toString() ?? ''),
      daysRemaining: json['days_remaining'] is int ? json['days_remaining'] : int.tryParse(json['days_remaining']?.toString() ?? ''),
      usagePercentage: json['usage_percentage'] != null ? (json['usage_percentage'] is double ? json['usage_percentage'] : double.tryParse(json['usage_percentage'].toString())) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration_days': durationDays,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'type': type,
      'available_days': availableDays,
      'days_used': daysUsed,
      'days_remaining': daysRemaining,
      'usage_percentage': usagePercentage,
    };
  }
  
  bool get isActive => status == 'active';
  bool get isExpired => status == 'expired';
  bool get isExpiringSoon => status == 'expiring_soon';
}
