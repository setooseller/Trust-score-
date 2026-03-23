// Bookmarks screen displaying locally tracked saved products with access to detail pages.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/product.dart';
import '../../../core/providers/app_providers.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Product>> bookmarks = ref.watch(bookmarkedProductsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bookmarks')),
      body: bookmarks.when(
        data: (List<Product> items) {
          if (items.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No bookmarked products yet. Save products from the home or detail screen.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (BuildContext context, int index) {
              final Product product = items[index];
              return Card(
                child: ListTile(
                  onTap: () => context.push('/product/${product.id}'),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(product.imageUrls.first, width: 52, height: 52, fit: BoxFit.cover),
                  ),
                  title: Text(product.name),
                  subtitle: Text('${product.brand} • Trust ${product.trustScore.toStringAsFixed(0)}'),
                  trailing: IconButton(
                    onPressed: () => ref.read(bookmarkIdsProvider.notifier).toggle(product.id),
                    icon: const Icon(Icons.delete_outline),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('$e')),
      ),
    );
  }
}
