import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/offer_model.dart';
import '../models/store_settings_model.dart';

class FirestoreService {
  FirebaseFirestore? _firestore;

  // Local fallback state (Starts completely empty)
  final List<ProductModel> _mockProducts = [];
  final List<CategoryModel> _mockCategories = [];
  final List<OfferModel> _mockOffers = [];
  StoreSettingsModel _mockSettings = StoreSettingsModel.defaultSettings();

  final _productsController = StreamController<List<ProductModel>>.broadcast();
  final _categoriesController = StreamController<List<CategoryModel>>.broadcast();
  final _offersController = StreamController<List<OfferModel>>.broadcast();
  final _settingsController = StreamController<StoreSettingsModel>.broadcast();

  FirestoreService() {
    try {
      _firestore = FirebaseFirestore.instance;
    } catch (e) {
      debugPrint("Firestore not initialized: $e");
    }
    _initMockData();
  }

  void _initMockData() {
    // Keep initial lists empty so admin starts with fresh data
    _productsController.add(_mockProducts);
    _categoriesController.add(_mockCategories);
    _offersController.add(_mockOffers);
    _settingsController.add(_mockSettings);
  }

  /// Programmatic reset/clear function (kept in code)
  Future<void> clearAllData() async {
    _mockProducts.clear();
    _mockCategories.clear();
    _mockOffers.clear();

    _productsController.add([]);
    _categoriesController.add([]);
    _offersController.add([]);

    if (_firestore != null) {
      try {
        final productsDocs = await _firestore!.collection('products').get();
        for (var doc in productsDocs.docs) {
          await doc.reference.delete();
        }
        final catDocs = await _firestore!.collection('categories').get();
        for (var doc in catDocs.docs) {
          await doc.reference.delete();
        }
        final offerDocs = await _firestore!.collection('offers').get();
        for (var doc in offerDocs.docs) {
          await doc.reference.delete();
        }
      } catch (e) {
        debugPrint("Error clearing Firestore collections: $e");
      }
    }
  }

  // ================= PRODUCTS CRUD =================

  Stream<List<ProductModel>> getProductsStream() {
    if (_firestore != null) {
      try {
        return _firestore!
            .collection('products')
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return <ProductModel>[];
          }
          final list = snapshot.docs
              .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          return list;
        }).handleError((e) {
          debugPrint("Products stream snapshot error: $e");
          return <ProductModel>[];
        });
      } catch (e) {
        debugPrint("Error listening to products stream: $e");
      }
    }
    return _productsController.stream;
  }

  Future<void> addProduct(ProductModel product) async {
    final newId = 'prod_${DateTime.now().millisecondsSinceEpoch}';
    final pToAdd = product.id.isEmpty ? product.copyWith(id: newId) : product;

    _mockProducts.add(pToAdd);
    _productsController.add(List.from(_mockProducts));

    if (_firestore != null) {
      try {
        final docRef = product.id.isEmpty
            ? _firestore!.collection('products').doc()
            : _firestore!.collection('products').doc(product.id);
        
        final finalProduct = pToAdd.copyWith(id: docRef.id);
        await docRef.set(finalProduct.toMap(), SetOptions(merge: true));
        return;
      } catch (e) {
        debugPrint("Error adding product to Firestore: $e");
      }
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    final index = _mockProducts.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _mockProducts[index] = product;
    } else {
      _mockProducts.add(product);
    }
    _productsController.add(List.from(_mockProducts));

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('products')
            .doc(product.id)
            .set(product.toMap(), SetOptions(merge: true));
        return;
      } catch (e) {
        debugPrint("Error updating product in Firestore: $e");
      }
    }
  }

  Future<void> deleteProduct(String productId) async {
    _mockProducts.removeWhere((p) => p.id == productId);
    _productsController.add(List.from(_mockProducts));

    if (_firestore != null) {
      try {
        await _firestore!.collection('products').doc(productId).delete();
        return;
      } catch (e) {
        debugPrint("Error deleting product from Firestore: $e");
      }
    }
  }

  Future<void> toggleProductAvailability(String productId, bool isAvailable) async {
    final index = _mockProducts.indexWhere((p) => p.id == productId);
    if (index != -1) {
      _mockProducts[index] = _mockProducts[index].copyWith(
        isAvailable: isAvailable,
        updatedAt: DateTime.now(),
      );
      _productsController.add(List.from(_mockProducts));
    }

    if (_firestore != null) {
      try {
        await _firestore!.collection('products').doc(productId).update({
          'isAvailable': isAvailable,
          'updatedAt': Timestamp.now(),
        });
        return;
      } catch (e) {
        debugPrint("Error toggling availability: $e");
      }
    }
  }

  // ================= CATEGORIES CRUD =================

  Stream<List<CategoryModel>> getCategoriesStream() {
    if (_firestore != null) {
      try {
        return _firestore!
            .collection('categories')
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return <CategoryModel>[];
          }
          final list = snapshot.docs
              .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          return list;
        }).handleError((e) {
          debugPrint("Categories stream snapshot error: $e");
          return <CategoryModel>[];
        });
      } catch (e) {
        debugPrint("Error listening to categories stream: $e");
      }
    }
    return _categoriesController.stream;
  }

  Future<void> addCategory(CategoryModel category) async {
    final newId = 'cat_${DateTime.now().millisecondsSinceEpoch}';
    final cToAdd = category.id.isEmpty ? category.copyWith(id: newId) : category;

    _mockCategories.add(cToAdd);
    _categoriesController.add(List.from(_mockCategories));

    if (_firestore != null) {
      try {
        final docRef = category.id.isEmpty
            ? _firestore!.collection('categories').doc()
            : _firestore!.collection('categories').doc(category.id);

        final finalCat = cToAdd.copyWith(id: docRef.id);
        await docRef.set(finalCat.toMap(), SetOptions(merge: true));
        return;
      } catch (e) {
        debugPrint("Error adding category to Firestore: $e");
      }
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    final index = _mockCategories.indexWhere((c) => c.id == category.id);
    if (index != -1) {
      _mockCategories[index] = category;
    } else {
      _mockCategories.add(category);
    }
    _categoriesController.add(List.from(_mockCategories));

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('categories')
            .doc(category.id)
            .set(category.toMap(), SetOptions(merge: true));
        return;
      } catch (e) {
        debugPrint("Error updating category: $e");
      }
    }
  }

  Future<void> deleteCategory(String categoryId) async {
    _mockCategories.removeWhere((c) => c.id == categoryId);
    _categoriesController.add(List.from(_mockCategories));

    if (_firestore != null) {
      try {
        await _firestore!.collection('categories').doc(categoryId).delete();
        return;
      } catch (e) {
        debugPrint("Error deleting category: $e");
      }
    }
  }

  // ================= OFFERS CRUD =================

  Stream<List<OfferModel>> getOffersStream() {
    if (_firestore != null) {
      try {
        return _firestore!
            .collection('offers')
            .snapshots()
            .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return <OfferModel>[];
          }
          final list = snapshot.docs
              .map((doc) => OfferModel.fromMap(doc.data(), doc.id))
              .toList();
          list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
          return list;
        }).handleError((e) {
          debugPrint("Offers stream snapshot error: $e");
          return <OfferModel>[];
        });
      } catch (e) {
        debugPrint("Error listening to offers stream: $e");
      }
    }
    return _offersController.stream;
  }

  Future<void> addOffer(OfferModel offer) async {
    final newId = 'offer_${DateTime.now().millisecondsSinceEpoch}';
    final oToAdd = offer.id.isEmpty ? offer.copyWith(id: newId) : offer;

    _mockOffers.add(oToAdd);
    _offersController.add(List.from(_mockOffers));

    if (_firestore != null) {
      try {
        final docRef = offer.id.isEmpty
            ? _firestore!.collection('offers').doc()
            : _firestore!.collection('offers').doc(offer.id);

        final finalOffer = oToAdd.copyWith(id: docRef.id);
        await docRef.set(finalOffer.toMap(), SetOptions(merge: true));
        return;
      } catch (e) {
        debugPrint("Error adding offer: $e");
      }
    }
  }

  Future<void> updateOffer(OfferModel offer) async {
    final index = _mockOffers.indexWhere((o) => o.id == offer.id);
    if (index != -1) {
      _mockOffers[index] = offer;
    } else {
      _mockOffers.add(offer);
    }
    _offersController.add(List.from(_mockOffers));

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('offers')
            .doc(offer.id)
            .set(offer.toMap(), SetOptions(merge: true));
        return;
      } catch (e) {
        debugPrint("Error updating offer: $e");
      }
    }
  }

  Future<void> deleteOffer(String offerId) async {
    _mockOffers.removeWhere((o) => o.id == offerId);
    _offersController.add(List.from(_mockOffers));

    if (_firestore != null) {
      try {
        await _firestore!.collection('offers').doc(offerId).delete();
        return;
      } catch (e) {
        debugPrint("Error deleting offer: $e");
      }
    }
  }

  // ================= STORE SETTINGS =================

  Stream<StoreSettingsModel> getStoreSettingsStream() {
    if (_firestore != null) {
      try {
        return _firestore!
            .collection('settings')
            .doc('store')
            .snapshots()
            .map((doc) {
          if (!doc.exists || doc.data() == null) {
            return _mockSettings;
          }
          return StoreSettingsModel.fromMap(doc.data()!);
        }).handleError((e) {
          debugPrint("Settings stream error: $e");
          return _mockSettings;
        });
      } catch (e) {
        debugPrint("Error listening to settings stream: $e");
      }
    }
    return _settingsController.stream;
  }

  Future<void> updateStoreSettings(StoreSettingsModel settings) async {
    _mockSettings = settings;
    _settingsController.add(_mockSettings);

    if (_firestore != null) {
      try {
        await _firestore!
            .collection('settings')
            .doc('store')
            .set(settings.toMap(), SetOptions(merge: true));
        return;
      } catch (e) {
        debugPrint("Error updating store settings: $e");
      }
    }
  }
}
