import 'dart:async';
import 'package:flutter/material.dart';
import '../models/store_settings_model.dart';
import '../services/firestore_service.dart';

class SettingsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;

  StoreSettingsModel _settings = StoreSettingsModel.defaultSettings();
  bool _isLoading = true;
  StreamSubscription? _subscription;

  SettingsProvider(this._firestoreService) {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.getStoreSettingsStream().listen((data) {
      _settings = data;
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Settings stream error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  StoreSettingsModel get settings => _settings;
  bool get isLoading => _isLoading;

  Future<void> saveSettings(StoreSettingsModel newSettings) async {
    await _firestoreService.updateStoreSettings(newSettings);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
