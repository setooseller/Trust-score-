// Product detail page with AI insights, trust breakdowns, bookmarks, and platform ratings.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/models/product.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/score_utils.dart';
import '../../../l10n/app_strings.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Product>> products = ref.watch(productsProvider);

    return Scaffold(
      appBar: AppBar(),
      body: products.when(
        data: (List<Product> items) {
          final Product product = items.firstWhere((Product item) => item.id == productId);
          final bool hindi = ref.watch(appLocaleProvider).languageCode == 'hi';
          final bool isBookmarked = ref.watch(bookmarkIdsProvider).contains(product.id);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: <Widget>[
              SizedBox(
                height: 248,
                child: Stack(
                  children: <Widget>[
                    PageView(
                      children: product.imageUrls
                          .map(
                            (String url) => ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Image.network(url, fit: BoxFit.cover),
                            ),
                          )
                          .toList(),
                    ),
                    Positioned(
                      top: 12,
                      right: 12,
                      child: FilledButton.tonalIcon(
                        onPressed: () => ref.read(bookmarkIdsProvider.notifier).toggle(product.id),
                        icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                        label: Text(isBookmarked ? 'Saved' : 'Save'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text('${product.brand} • ${product.category} • ${product.reviewCount} reviews'),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: <Widget>[
                      CircularPercentIndicator(
                        radius: 56,
                        lineWidth: 10,
                        percent: product.trustScore / 100,
                        center: Text(product.trustScore.toStringAsFixed(0)),
                        progressColor: ScoreUtils.trustColor(product.trustScore),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              ScoreUtils.trustLabel(product.trustScore),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 6),
                            Text(hindi ? product.aiSummaryHi : product.aiSummaryEn),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: <Widget>[
                                Chip(label: Text('Suthara ${product.sutharaScore.toStringAsFixed(0)}')),
                                Chip(label: Text('Avg ${product.averageRating.toStringAsFixed(1)}★')),
                                Chip(label: Text(product.fakeReviewRisk.toUpperCase())),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _FeatureGrid(product: product),
              const SizedBox(height: 16),
              _ScoreBreakdown(product: product),
              const SizedBox(height: 16),
              _ProsConsCard(product: product),
              const SizedBox(height: 16),
              _PlatformRatingsCard(product: product),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: Icon(
                    product.fakeReviewRisk == 'low' ? Icons.verified : Icons.warning_amber,
                    color: product.fakeReviewRisk == 'low' ? Colors.green : Colors.orange,
                  ),
                  title: Text(AppStrings.of(
                    context,
                    hi: 'फेक रिव्यू जोखिम: ${product.fakeReviewRisk}',
                    en: 'Fake review risk: ${product.fakeReviewRisk}',
                  )),
                  subtitle: Text(AppStrings.of(
                    context,
                    hi: 'दोहराव, पैटर्न और बॉट संकेतों के आधार पर स्कैन किया गया।',
                    en: 'Scanned for repetition, bot patterns, and unnatural review bursts.',
                  )),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.health_and_safety_outlined),
                  title: const Text('Safety signal'),
                  subtitle: Text(product.safeIndicator),
                ),
              ),
              const SizedBox(height: 16),
              if (product.affiliateUrl.isNotEmpty)
                FilledButton.icon(
                  onPressed: () async {
                    await launchUrl(Uri.parse(product.affiliateUrl));
                  },
                  icon: const Icon(Icons.shopping_bag_outlined),
                  label: Text(AppStrings.of(context, hi: 'खरीदें', en: 'Buy Now')),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (Object e, StackTrace s) => Center(child: Text('$e')),
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Features & Quality', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                ...product.features.map((String feature) => Chip(label: Text(feature))),
                ...product.qualityIndicators.map((String item) => Chip(label: Text(item))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('AI Score Breakdown', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _MetricRow(label: 'Average Rating', value: product.averageRating * 20),
            _MetricRow(label: 'Sentiment Score', value: product.sentimentScore),
            _MetricRow(label: 'Authenticity Score', value: product.authenticityScore),
            _MetricRow(label: 'Brand Reputation', value: product.brandReputationScore),
            const Divider(height: 24),
            _MetricRow(label: 'Suthara Score', value: product.sutharaScore),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  const _MetricRow({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label)),
          SizedBox(width: 120, child: LinearProgressIndicator(value: value / 100)),
          const SizedBox(width: 12),
          Text(value.toStringAsFixed(0)),
        ],
      ),
    );
  }
}

class _ProsConsCard extends StatelessWidget {
  const _ProsConsCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: _BulletList(title: 'Pros', items: product.pros)),
            const SizedBox(width: 16),
            Expanded(child: _BulletList(title: 'Cons', items: product.cons)),
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...items.map(
          (String item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text('• '),
                Expanded(child: Text(item)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PlatformRatingsCard extends StatelessWidget {
  const _PlatformRatingsCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Platform Ratings', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            ...product.platformRatings.entries.map((MapEntry<String, dynamic> entry) {
              final Map<String, dynamic> platformData = Map<String, dynamic>.from(entry.value as Map);
              final double rating = (platformData['rating'] as num).toDouble();
              final double weight = (platformData['weight'] as num).toDouble();
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(entry.key),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    LinearProgressIndicator(value: rating / 5),
                    const SizedBox(height: 4),
                    Text('Weight ${(weight * 100).toStringAsFixed(0)}%'),
                  ],
                ),
                trailing: Text('${rating.toStringAsFixed(1)} ★'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
