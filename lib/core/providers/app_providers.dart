// Central Riverpod providers for app settings, Firebase services, demo fallbacks, and UI state.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/home/application/home_filters.dart';
import '../models/product.dart';
import '../services/firebase_auth_service.dart';
import '../services/product_repository.dart';

final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);

final appLocaleProvider = StateProvider<Locale>((_) => const Locale('hi'));

final searchQueryProvider = StateProvider<String>((_) => '');

final homeFilterProvider = StateProvider<HomeFilterState>((_) {
  return const HomeFilterState();
});

final selectedNavIndexProvider = StateProvider<int>((_) => 0);

final productRepositoryProvider = Provider<ProductRepository>((_) {
  return ProductRepository();
});

final authServiceProvider = Provider<FirebaseAuthService>((_) {
  return FirebaseAuthService();
});

final bundledProductsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(productRepositoryProvider).loadBundledProducts();
});

final firebaseProductsProvider = StreamProvider<List<Product>>((ref) {
  return ref.watch(productRepositoryProvider).watchProducts();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final ProductRepository repository = ref.watch(productRepositoryProvider);
  try {
    final List<Product> remote = await repository.getProductsSnapshot();
    if (remote.isNotEmpty) {
      return remote;
    }
  } catch (_) {
    // Fallback to bundled assets when Firestore is not initialized yet.
  }
  return ref.watch(bundledProductsProvider.future);
});

final trendingProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final AsyncValue<List<Product>> products = ref.watch(productsProvider);
  return products.whenData(
    (List<Product> items) => items.where((Product p) => p.trending).take(10).toList(),
  );
});

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final AsyncValue<List<Product>> products = ref.watch(productsProvider);
  final HomeFilterState filter = ref.watch(homeFilterProvider);
  final String query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return products.whenData((List<Product> items) {
    return items.where((Product product) {
      final bool matchesBrand = filter.brand == null || product.brand == filter.brand;
      final bool matchesCategory = filter.category == null || product.category == filter.category;
      final bool matchesScore = product.trustScore >= filter.minTrustScore;
      final bool matchesQuery = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.brand.toLowerCase().contains(query) ||
          product.category.toLowerCase().contains(query);
      return matchesBrand && matchesCategory && matchesScore && matchesQuery;
    }).toList()
      ..sort((Product a, Product b) => b.trustScore.compareTo(a.trustScore));
  });
});

class BookmarkNotifier extends StateNotifier<Set<String>> {
  BookmarkNotifier() : super(<String>{});

  void toggle(String productId) {
    final Set<String> next = Set<String>.from(state);
    if (!next.add(productId)) {
      next.remove(productId);
    }
    state = next;
  }
}

final bookmarkIdsProvider = StateNotifierProvider<BookmarkNotifier, Set<String>>((_) {
  return BookmarkNotifier();
});

final bookmarkedProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final Set<String> ids = ref.watch(bookmarkIdsProvider);
  final AsyncValue<List<Product>> products = ref.watch(productsProvider);

  return products.whenData(
    (List<Product> items) => items.where((Product item) => ids.contains(item.id)).toList(),
  );
});
