class OfferModel {
  final String id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final String imageUrl;
  final String buttonText;
  final String buttonLink;
  final bool isActive;
  final int displayOrder;

  OfferModel({
    required this.id,
    required this.title,
    required this.titleAr,
    required this.description,
    required this.descriptionAr,
    required this.imageUrl,
    required this.buttonText,
    required this.buttonLink,
    required this.isActive,
    required this.displayOrder,
  });

  factory OfferModel.fromMap(Map<String, dynamic> rawMap, String documentId) {
    final map = Map<String, dynamic>.from(rawMap);
    return OfferModel(
      id: documentId,
      title: map['title']?.toString() ?? '',
      titleAr: map['titleAr']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      descriptionAr: map['descriptionAr']?.toString() ?? '',
      imageUrl: map['imageUrl']?.toString() ?? '',
      buttonText: map['buttonText']?.toString() ?? 'تسوق الآن',
      buttonLink: map['buttonLink']?.toString() ?? '',
      isActive: map['isActive'] != false,
      displayOrder: (map['displayOrder'] is num) ? (map['displayOrder'] as num).toInt() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'titleAr': titleAr,
      'description': description,
      'descriptionAr': descriptionAr,
      'imageUrl': imageUrl,
      'buttonText': buttonText,
      'buttonLink': buttonLink,
      'isActive': isActive,
      'displayOrder': displayOrder,
    };
  }

  OfferModel copyWith({
    String? id,
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    String? imageUrl,
    String? buttonText,
    String? buttonLink,
    bool? isActive,
    int? displayOrder,
  }) {
    return OfferModel(
      id: id ?? this.id,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      imageUrl: imageUrl ?? this.imageUrl,
      buttonText: buttonText ?? this.buttonText,
      buttonLink: buttonLink ?? this.buttonLink,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
