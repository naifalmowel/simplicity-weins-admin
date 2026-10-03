import 'dart:async';
import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../core/constants/supabase_config.dart';

class CategoriesProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  StreamSubscription? _subscription;

  CategoriesProvider(this._firestoreService, this._storageService) {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.getCategoriesStream().listen((data) {
      _categories = List.from(data);
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Categories stream error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  int get totalCategories => _categories.length;

  Future<void> saveCategory(CategoryModel category) async {
    if (category.id.isEmpty) {
      await _firestoreService.addCategory(category);
    } else {
      await _firestoreService.updateCategory(category);
    }
    notifyListeners();
  }

  Future<void> deleteCategory(CategoryModel category) async {
    if (category.imageUrl.isNotEmpty) {
      await _storageService.deleteImageByUrl(category.imageUrl, SupabaseConfig.mainBucket);
    }
    await _firestoreService.deleteCategory(category.id);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
