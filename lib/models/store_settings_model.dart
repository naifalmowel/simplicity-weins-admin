import '../core/constants/app_constants.dart';

class StoreSettingsModel {
  final String storeName;
  final String storeNameAr;
  final String logoUrl;
  final String mobileLogoUrl;
  final String storeImageUrl;
  final String phone;
  final String whatsapp;
  final String instagram;
  final String addressAr;
  final double latitude;
  final double longitude;
  final String googleMapsUrl;
  final String deliveryTextAr;
  final String slogan;
  final String sloganAr;

  // Store Status & Hours
  final bool isClosed;
  final bool isBusy;
  final String openingHours;
  final bool whatsappAlwaysActive;

  StoreSettingsModel({
    required this.storeName,
    required this.storeNameAr,
    required this.logoUrl,
    required this.mobileLogoUrl,
    required this.storeImageUrl,
    required this.phone,
    required this.whatsapp,
    required this.instagram,
    required this.addressAr,
    required this.latitude,
    required this.longitude,
    required this.googleMapsUrl,
    required this.deliveryTextAr,
    required this.slogan,
    required this.sloganAr,
    this.isClosed = false,
    this.isBusy = false,
    this.openingHours = '10:00 ص - 10:00 م',
    this.whatsappAlwaysActive = true,
  });

  factory StoreSettingsModel.defaultSettings() {
    return StoreSettingsModel(
      storeName: AppConstants.storeNameEn,
      storeNameAr: AppConstants.storeNameAr,
      logoUrl: '',
      mobileLogoUrl: '',
      storeImageUrl: '',
      phone: AppConstants.phone,
      whatsapp: AppConstants.whatsapp,
      instagram: AppConstants.instagram,
      addressAr: AppConstants.addressAr,
      latitude: AppConstants.defaultLat,
      longitude: AppConstants.defaultLng,
      googleMapsUrl: 'https://maps.google.com/?q=${AppConstants.defaultLat},${AppConstants.defaultLng}',
      deliveryTextAr: AppConstants.deliveryTextAr,
      slogan: AppConstants.sloganEn,
      sloganAr: AppConstants.sloganAr,
      isClosed: false,
      isBusy: false,
      openingHours: '10:00 ص - 10:00 م',
      whatsappAlwaysActive: true,
    );
  }

  factory StoreSettingsModel.fromMap(Map<String, dynamic> rawMap) {
    final map = Map<String, dynamic>.from(rawMap);
    return StoreSettingsModel(
      storeName: map['storeName']?.toString() ?? AppConstants.storeNameEn,
      storeNameAr: map['storeNameAr']?.toString() ?? AppConstants.storeNameAr,
      logoUrl: map['logoUrl']?.toString() ?? '',
      mobileLogoUrl: map['mobileLogoUrl']?.toString() ?? '',
      storeImageUrl: map['storeImageUrl']?.toString() ?? '',
      phone: map['phone']?.toString() ?? AppConstants.phone,
      whatsapp: map['whatsapp']?.toString() ?? AppConstants.whatsapp,
      instagram: map['instagram']?.toString() ?? AppConstants.instagram,
      addressAr: map['addressAr']?.toString() ?? AppConstants.addressAr,
      latitude: (map['latitude'] is num) ? (map['latitude'] as num).toDouble() : AppConstants.defaultLat,
      longitude: (map['longitude'] is num) ? (map['longitude'] as num).toDouble() : AppConstants.defaultLng,
      googleMapsUrl: map['googleMapsUrl']?.toString() ?? '',
      deliveryTextAr: map['deliveryTextAr']?.toString() ?? AppConstants.deliveryTextAr,
      slogan: map['slogan']?.toString() ?? AppConstants.sloganEn,
      sloganAr: map['sloganAr']?.toString() ?? AppConstants.sloganAr,
      isClosed: map['isClosed'] == true,
      isBusy: map['isBusy'] == true,
      openingHours: map['openingHours']?.toString() ?? '10:00 ص - 10:00 م',
      whatsappAlwaysActive: map['whatsappAlwaysActive'] != false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'storeName': storeName,
      'storeNameAr': storeNameAr,
      'logoUrl': logoUrl,
      'mobileLogoUrl': mobileLogoUrl,
      'storeImageUrl': storeImageUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'instagram': instagram,
      'addressAr': addressAr,
      'latitude': latitude,
      'longitude': longitude,
      'googleMapsUrl': googleMapsUrl,
      'deliveryTextAr': deliveryTextAr,
      'slogan': slogan,
      'sloganAr': sloganAr,
      'isClosed': isClosed,
      'isBusy': isBusy,
      'openingHours': openingHours,
      'whatsappAlwaysActive': whatsappAlwaysActive,
    };
  }

  StoreSettingsModel copyWith({
    String? storeName,
    String? storeNameAr,
    String? logoUrl,
    String? mobileLogoUrl,
    String? storeImageUrl,
    String? phone,
    String? whatsapp,
    String? instagram,
    String? addressAr,
    double? latitude,
    double? longitude,
    String? googleMapsUrl,
    String? deliveryTextAr,
    String? slogan,
    String? sloganAr,
    bool? isClosed,
    bool? isBusy,
    String? openingHours,
    bool? whatsappAlwaysActive,
  }) {
    return StoreSettingsModel(
      storeName: storeName ?? this.storeName,
      storeNameAr: storeNameAr ?? this.storeNameAr,
      logoUrl: logoUrl ?? this.logoUrl,
      mobileLogoUrl: mobileLogoUrl ?? this.mobileLogoUrl,
      storeImageUrl: storeImageUrl ?? this.storeImageUrl,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      instagram: instagram ?? this.instagram,
      addressAr: addressAr ?? this.addressAr,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      googleMapsUrl: googleMapsUrl ?? this.googleMapsUrl,
      deliveryTextAr: deliveryTextAr ?? this.deliveryTextAr,
      slogan: slogan ?? this.slogan,
      sloganAr: sloganAr ?? this.sloganAr,
      isClosed: isClosed ?? this.isClosed,
      isBusy: isBusy ?? this.isBusy,
      openingHours: openingHours ?? this.openingHours,
      whatsappAlwaysActive: whatsappAlwaysActive ?? this.whatsappAlwaysActive,
    );
  }
}
