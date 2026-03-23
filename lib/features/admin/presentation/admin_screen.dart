// Admin screen for reviewing products and creating simple product updates for Firestore.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/app_providers.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Product>> products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog<void>(
          context: context,
          builder: (BuildContext context) => const _ProductDialog(),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
      body: products.when(
        data: (List<Product> items) => ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            const Card(
              child: ListTile(
                title: Text('Firebase admin workflow'),
                subtitle: Text('Use Firestore-backed product documents to store AI summaries, ratings, and score metadata.'),
              ),
            ),
            const SizedBox(height: 12),
            ...items.take(12).map(
              (Product product) => Card(
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(product.imageUrls.first, width: 48, height: 48, fit: BoxFit.cover),
                  ),
                  title: Text(product.name),
                  subtitle: Text('${product.brand} • Trust ${product.trustScore.toStringAsFixed(0)}'),
                  trailing: IconButton(
                    onPressed: () => showDialog<void>(
                      context: context,
                      builder: (BuildContext context) => _ProductDialog(seedProduct: product),
                    ),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                ),
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('$e')),
      ),
    );
  }
}

class _ProductDialog extends ConsumerStatefulWidget {
  const _ProductDialog({this.seedProduct});

  final Product? seedProduct;

  @override
  ConsumerState<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends ConsumerState<_ProductDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _brandController;
  late final TextEditingController _categoryController;
  late final TextEditingController _summaryController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.seedProduct?.name ?? '');
    _brandController = TextEditingController(text: widget.seedProduct?.brand ?? AppConstants.brands.first);
    _categoryController = TextEditingController(text: widget.seedProduct?.category ?? AppConstants.categories.first);
    _summaryController = TextEditingController(text: widget.seedProduct?.aiSummaryHi ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final Product base = widget.seedProduct ??
        Product(
          id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text.trim(),
          brand: _brandController.text.trim(),
          category: _categoryController.text.trim(),
          features: const <String>['Admin added product'],
          qualityIndicators: const <String>['Needs review enrichment'],
          imageUrls: const <String>['https://images.unsplash.com/photo-1542838132-92c53300491e?auto=format&fit=crop&w=900&q=80'],
          averageRating: 4,
          reviewCount: 0,
          trustScore: 70,
          sutharaScore: 70,
          sentimentScore: 70,
          authenticityScore: 70,
          brandReputationScore: 70,
          aiSummaryHi: _summaryController.text.trim(),
          aiSummaryEn: _summaryController.text.trim(),
          pros: const <String>['Awaiting AI analysis'],
          cons: const <String>['Awaiting AI analysis'],
          fakeReviewRisk: 'medium',
          platformRatings: const <String, dynamic>{
            'Google Reviews': <String, dynamic>{'rating': 4.0, 'weight': 0.3},
            'Amazon': <String, dynamic>{'rating': 4.0, 'weight': 0.3},
            'Flipkart': <String, dynamic>{'rating': 4.0, 'weight': 0.2},
            'YouTube Comments': <String, dynamic>{'rating': 4.0, 'weight': 0.2},
          },
          safeIndicator: 'Pending admin review',
          affiliateUrl: '',
          trending: false,
        );

    final Product updated = base.copyWith(
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      category: _categoryController.text.trim(),
      aiSummaryHi: _summaryController.text.trim(),
      aiSummaryEn: _summaryController.text.trim(),
    );

    try {
      await ref.read(productRepositoryProvider).upsertProduct(updated);
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product saved to Firestore.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connect Firebase to persist admin updates.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.seedProduct == null ? 'Add Product' : 'Edit Product'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
            const SizedBox(height: 12),
            TextField(controller: _brandController, decoration: const InputDecoration(labelText: 'Brand')),
            const SizedBox(height: 12),
            TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category')),
            const SizedBox(height: 12),
            TextField(
              controller: _summaryController,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Hindi Summary'),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(onPressed: _isSaving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _isSaving ? null : _save, child: Text(_isSaving ? 'Saving...' : 'Save')),
      ],
    );
  }
}
