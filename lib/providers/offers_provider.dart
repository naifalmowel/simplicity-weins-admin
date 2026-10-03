import 'dart:async';
import 'package:flutter/material.dart';
import '../models/offer_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../core/constants/supabase_config.dart';

class OffersProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  List<OfferModel> _offers = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  OffersProvider(this._firestoreService, this._storageService) {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.getOffersStream().listen((data) {
      _offers = List.from(data);
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Offers stream error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  List<OfferModel> get offers => _offers;
  bool get isLoading => _isLoading;
  int get activeOffersCount => _offers.where((o) => o.isActive).length;

  Future<void> saveOffer(OfferModel offer) async {
    if (offer.id.isEmpty) {
      await _firestoreService.addOffer(offer);
    } else {
      await _firestoreService.updateOffer(offer);
    }
    notifyListeners();
  }

  Future<void> deleteOffer(OfferModel offer) async {
    if (offer.imageUrl.isNotEmpty) {
      await _storageService.deleteImageByUrl(offer.imageUrl, SupabaseConfig.mainBucket);
    }
    await _firestoreService.deleteOffer(offer.id);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
