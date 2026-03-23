// Firestore repository for reading product summaries and writing product feedback/bookmarks.
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';

class ProductRepository {
  ProductRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<List<Product>> loadBundledProducts() async {
    final String jsonString =
        await rootBundle.loadString('assets/seeds/products_seed.json');
    final List<dynamic> decoded = json.decode(jsonString) as List<dynamic>;
    return decoded
        .map(
          (dynamic item) =>
              Product.fromMap(item['id'] as String, item as Map<String, dynamic>),
        )
        .toList();
  }

  Stream<List<Product>> watchProducts({
    String? brand,
    String? category,
    double? minScore,
  }) {
    return _buildQuery(
      brand: brand,
      category: category,
      minScore: minScore,
    ).snapshots().map(
      (QuerySnapshot<Map<String, dynamic>> snapshot) => snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) => Product.fromMap(doc.id, doc.data()))
          .toList(),
    );
  }

  Future<List<Product>> getProductsSnapshot({
    String? brand,
    String? category,
    double? minScore,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _buildQuery(
      brand: brand,
      category: category,
      minScore: minScore,
    ).get();

    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              Product.fromMap(doc.id, doc.data()),
        )
        .toList();
  }

  Query<Map<String, dynamic>> _buildQuery({
    String? brand,
    String? category,
    double? minScore,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection('products');

    if (brand != null && brand.isNotEmpty) {
      query = query.where('brand', isEqualTo: brand);
    }
    if (category != null && category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }
    if (minScore != null) {
      query = query.where('trustScore', isGreaterThanOrEqualTo: minScore);
    }

    return query.orderBy('trustScore', descending: true);
  }

  Future<void> saveBookmark({required String userId, required Product product}) {
    return _firestore.collection('bookmarks').doc(userId).set(
      <String, dynamic>{
        'items.${product.id}': {
          'productId': product.id,
          'name': product.name,
          'brand': product.brand,
          'trustScore': product.trustScore,
          'savedAt': FieldValue.serverTimestamp(),
        },
      },
      SetOptions(merge: true),
    );
  }

  Stream<Set<String>> watchBookmarkIds({required String userId}) {
    return _firestore.collection('bookmarks').doc(userId).snapshots().map(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) {
        final Map<String, dynamic> data = snapshot.data() ?? <String, dynamic>{};
        final Map<String, dynamic> items =
            Map<String, dynamic>.from(data['items'] as Map? ?? <String, dynamic>{});
        return items.keys.toSet();
      },
    );
  }

  Future<void> removeBookmark({
    required String userId,
    required String productId,
  }) {
    return _firestore.collection('bookmarks').doc(userId).set(
      <String, dynamic>{'items.$productId': FieldValue.delete()},
      SetOptions(merge: true),
    );
  }

  Future<void> upsertProduct(Product product) {
    return _firestore
        .collection('products')
        .doc(product.id)
        .set(product.toMap(), SetOptions(merge: true));
  }

  Future<void> submitFeedback({
    required String userId,
    required String message,
    String? productId,
  }) {
    return _firestore.collection('feedback').add(<String, dynamic>{
      'userId': userId,
      'productId': productId,
      'message': message,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
