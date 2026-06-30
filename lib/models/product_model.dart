// 🛍️ Product Model
class ProductModel {
  final int id;
  final String name;
  final String description;
  final double price;
  final int pointsPrice;
  final String? imageUrl;
  final String category;
  final int stock;
  final bool isActive;
  final bool isFeatured;
  
  ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.pointsPrice,
    this.imageUrl,
    required this.category,
    required this.stock,
    required this.isActive,
    this.isFeatured = false,
  });
  
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: json['price'] != null 
          ? (json['price'] is double ? json['price'] : double.parse(json['price'].toString())) 
          : 0.0,
      pointsPrice: json['points_price'] is int 
          ? json['points_price'] 
          : int.tryParse(json['points_price']?.toString() ?? '0') ?? 0,
      imageUrl: json['image_url'],
      category: json['category'] ?? 'general',
      stock: json['stock'] is int 
          ? json['stock'] 
          : int.tryParse(json['stock']?.toString() ?? '0') ?? 0,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'points_price': pointsPrice,
      'image_url': imageUrl,
      'category': category,
      'stock': stock,
      'is_active': isActive,
      'is_featured': isFeatured,
    };
  }
  
  bool get isAvailable => isActive && stock > 0;
  bool get isOutOfStock => stock <= 0;
  bool get canRedeemWithPoints => pointsPrice > 0;
}

// 📦 Redemption Model
class RedemptionModel {
  final int id;
  final int productId;
  final String productName;
  final int pointsUsed;
  final String status;
  final String redeemedAt;
  final String? claimedAt;
  
  RedemptionModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.pointsUsed,
    required this.status,
    required this.redeemedAt,
    this.claimedAt,
  });
  
  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    return RedemptionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      productId: json['product_id'] is int 
          ? json['product_id'] 
          : int.parse(json['product_id'].toString()),
      productName: json['product_name'] ?? '',
      pointsUsed: json['points_used'] is int 
          ? json['points_used'] 
          : int.parse(json['points_used'].toString()),
      status: json['status'] ?? 'pending',
      redeemedAt: json['redeemed_at'] ?? '',
      claimedAt: json['claimed_at'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'product_name': productName,
      'points_used': pointsUsed,
      'status': status,
      'redeemed_at': redeemedAt,
      'claimed_at': claimedAt,
    };
  }
  
  bool get isPending => status == 'pending';
  bool get isClaimed => status == 'claimed';
  bool get isCancelled => status == 'cancelled';
}
