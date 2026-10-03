import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String nameAr;
  final String description;
  final String descriptionAr;
  final double price;
  final double? oldPrice;
  final String categoryId;
  final String categoryName;
  final List<String> imageUrls;
  final List<String> sizes;
  final List<String> colors;
  final String? badge;
  final bool isFeatured;
  final bool isAvailable;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.description,
    required this.descriptionAr,
    required this.price,
    this.oldPrice,
    required this.categoryId,
    required this.categoryName,
    required this.imageUrls,
    required this.sizes,
    required this.colors,
    this.badge,
    required this.isFeatured,
    required this.isAvailable,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> rawMap, String documentId) {
    final map = Map<String, dynamic>.from(rawMap);

    List<String> parseList(dynamic val) {
      if (val == null) return [];
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    double parseDouble(dynamic val) {
      if (val == null) return 0.0;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    double? parseNullableDouble(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val);
      return null;
    }

    DateTime parseDate(dynamic date) {
      if (date is Timestamp) return date.toDate();
      if (date is DateTime) return date;
      if (date is String) return DateTime.tryParse(date) ?? DateTime.now();
      return DateTime.now();
    }

    return ProductModel(
      id: documentId,
      name: map['name']?.toString() ?? '',
      nameAr: map['nameAr']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      descriptionAr: map['descriptionAr']?.toString() ?? '',
      price: parseDouble(map['price']),
      oldPrice: parseNullableDouble(map['oldPrice']),
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
      imageUrls: parseList(map['imageUrls']),
      sizes: parseList(map['sizes']),
      colors: parseList(map['colors']),
      badge: map['badge']?.toString(),
      isFeatured: map['isFeatured'] == true,
      isAvailable: map['isAvailable'] != false,
      isActive: map['isActive'] != false,
      displayOrder: (map['displayOrder'] is num) ? (map['displayOrder'] as num).toInt() : 0,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameAr': nameAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'price': price,
      'oldPrice': oldPrice,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'imageUrls': imageUrls,
      'sizes': sizes,
      'colors': colors,
      'badge': badge,
      'isFeatured': isFeatured,
      'isAvailable': isAvailable,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    double? price,
    double? oldPrice,
    String? categoryId,
    String? categoryName,
    List<String>? imageUrls,
    List<String>? sizes,
    List<String>? colors,
    String? badge,
    bool? isFeatured,
    bool? isAvailable,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      price: price ?? this.price,
      oldPrice: oldPrice ?? this.oldPrice,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrls: imageUrls ?? this.imageUrls,
      sizes: sizes ?? this.sizes,
      colors: colors ?? this.colors,
      badge: badge ?? this.badge,
      isFeatured: isFeatured ?? this.isFeatured,
      isAvailable: isAvailable ?? this.isAvailable,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
