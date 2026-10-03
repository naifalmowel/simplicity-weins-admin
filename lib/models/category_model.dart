class CategoryModel {
  final String id;
  final String name;
  final String nameAr;
  final String imageUrl;
  final int displayOrder;
  final bool isActive;

  CategoryModel({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.imageUrl,
    required this.displayOrder,
    required this.isActive,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> rawMap, String documentId) {
    final map = Map<String, dynamic>.from(rawMap);
    return CategoryModel(
      id: documentId,
      name: map['name']?.toString() ?? '',
      nameAr: map['nameAr']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      displayOrder: (map['displayOrder'] is num) ? (map['displayOrder'] as num).toInt() : 0,
      isActive: map['isActive'] != false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameAr': nameAr,
      'imageUrl': imageUrl,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? nameAr,
    String? imageUrl,
    int? displayOrder,
    bool? isActive,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      imageUrl: imageUrl ?? this.imageUrl,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
    );
  }
}
