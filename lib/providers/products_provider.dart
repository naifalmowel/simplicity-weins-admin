import 'dart:async';
import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';
import '../services/storage_service.dart';
import '../core/constants/supabase_config.dart';

class ProductsProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  final StorageService _storageService;

  List<ProductModel> _products = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String? _selectedCategoryId;
  StreamSubscription? _subscription;

  ProductsProvider(this._firestoreService, this._storageService) {
    _initStream();
  }

  void _initStream() {
    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService.getProductsStream().listen((data) {
      _products = List.from(data);
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      debugPrint("Products stream error: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String? get selectedCategoryId => _selectedCategoryId;

  int get totalProducts => _products.length;
  int get outOfStockCount => _products.where((p) => !p.isAvailable).length;
  int get activeProductsCount => _products.where((p) => p.isActive).length;

  List<ProductModel> get filteredProducts {
    return _products.where((product) {
      final matchesSearch = _searchQuery.isEmpty ||
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.nameAr.contains(_searchQuery);
      
      final matchesCategory = _selectedCategoryId == null ||
          _selectedCategoryId!.isEmpty ||
          product.categoryId == _selectedCategoryId;

      return matchesSearch && matchesCategory;
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  Future<void> saveProduct(ProductModel product) async {
    if (product.id.isEmpty) {
      await _firestoreService.addProduct(product);
    } else {
      await _firestoreService.updateProduct(product);
    }
    notifyListeners();
  }

  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    await _firestoreService.toggleProductAvailability(productId, isAvailable);
    notifyListeners();
  }

  Future<void> deleteProduct(ProductModel product) async {
    for (final url in product.imageUrls) {
      await _storageService.deleteImageByUrl(url, SupabaseConfig.mainBucket);
    }
    await _firestoreService.deleteProduct(product.id);
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
