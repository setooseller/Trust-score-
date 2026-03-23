// Home screen showing search, brand/category filters, summary cards, trending products, and product discovery.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/models/product.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/utils/score_utils.dart';
import '../../../l10n/app_strings.dart';
import '../application/home_filters.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Product>> filtered = ref.watch(filteredProductsProvider);
    final AsyncValue<List<Product>> trending = ref.watch(trendingProductsProvider);
    final HomeFilterState filters = ref.watch(homeFilterProvider);
    final Locale locale = ref.watch(appLocaleProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trust Score India (Beta)'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              ref.read(themeModeProvider.notifier).state =
                  Theme.of(context).brightness == Brightness.dark
                      ? ThemeMode.light
                      : ThemeMode.dark;
            },
            icon: const Icon(Icons.dark_mode_outlined),
          ),
          TextButton(
            onPressed: () {
              ref.read(appLocaleProvider.notifier).state =
                  locale.languageCode == 'hi' ? const Locale('en') : const Locale('hi');
            },
            child: Text(locale.languageCode.toUpperCase()),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            _HeroSection(filtered: filtered),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: AppStrings.of(
                  context,
                  hi: 'उत्पाद, ब्रांड या सेवा खोजें',
                  en: 'Search products, brands, or services',
                ),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (String value) =>
                  ref.read(searchQueryProvider.notifier).state = value,
            ),
            const SizedBox(height: 16),
            _FilterSection(filters: filters),
            const SizedBox(height: 20),
            Text(
              AppStrings.of(context, hi: 'ट्रेंडिंग उत्पाद', en: 'Trending Products'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            trending.when(
              data: (List<Product> items) => SizedBox(
                height: 246,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (BuildContext context, int index) {
                    final Product product = items[index];
                    return SizedBox(width: 286, child: _TrendingCard(product: product));
                  },
                ),
              ),
              loading: () => const LinearProgressIndicator(),
              error: (Object e, StackTrace s) => Text('$e'),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  AppStrings.of(context, hi: 'सभी उत्पाद', en: 'All Products'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                TextButton.icon(
                  onPressed: () => ref.read(homeFilterProvider.notifier).state = const HomeFilterState(),
                  icon: const Icon(Icons.restart_alt),
                  label: Text(AppStrings.of(context, hi: 'रीसेट', en: 'Reset')),
                ),
              ],
            ),
            const SizedBox(height: 12),
            filtered.when(
              data: (List<Product> items) {
                if (items.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        AppStrings.of(
                          context,
                          hi: 'कोई उत्पाद नहीं मिला। फ़िल्टर बदलकर दोबारा खोजें।',
                          en: 'No products found. Update the filters and try again.',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                return Column(
                  children: items
                      .map(
                        (Product product) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _ProductCard(product: product),
                        ),
                      )
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (Object e, StackTrace s) => Text('$e'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: ref.watch(selectedNavIndexProvider),
        destinations: const <NavigationDestination>[
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), label: 'Bookmarks'),
          NavigationDestination(icon: Icon(Icons.admin_panel_settings_outlined), label: 'Admin'),
          NavigationDestination(icon: Icon(Icons.feedback_outlined), label: 'Feedback'),
        ],
        onDestinationSelected: (int index) {
          ref.read(selectedNavIndexProvider.notifier).state = index;
          if (index == 1) {
            context.push('/bookmarks');
            return;
          }
          if (index == 2) {
            context.push('/admin');
            return;
          }
          if (index == 3) {
            context.push('/feedback');
          }
        },
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({required this.filtered});

  final AsyncValue<List<Product>> filtered;

  @override
  Widget build(BuildContext context) {
    return filtered.when(
      data: (List<Product> items) {
        final int safeCount = items.where((Product product) => product.highlyTrusted).length;
        final double avgTrust = items.isEmpty
            ? 0
            : items.map((Product item) => item.trustScore).reduce((double a, double b) => a + b) /
                items.length;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: const LinearGradient(
              colors: <Color>[Color(0xFF0E7A53), Color(0xFF091C18)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                AppStrings.of(
                  context,
                  hi: 'खरीदने से पहले भरोसा जांचें',
                  en: 'Check trust before you buy',
                ),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.of(
                  context,
                  hi: 'AI समीक्षाओं, ब्रांड प्रतिष्ठा और प्रामाणिकता संकेतों के आधार पर Trust Score और Suthara Score देखें।',
                  en: 'Review AI-powered Trust Score and Suthara Score backed by reviews, brand reputation, and authenticity signals.',
                ),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(child: _StatTile(label: 'Avg Trust', value: avgTrust.toStringAsFixed(0))),
                  const SizedBox(width: 12),
                  Expanded(child: _StatTile(label: 'Highly Trusted', value: '$safeCount')),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const LinearProgressIndicator(),
      error: (Object e, StackTrace s) => Text('$e'),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withOpacity(0.12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class _FilterSection extends ConsumerWidget {
  const _FilterSection({required this.filters});

  final HomeFilterState filters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              AppStrings.of(context, hi: 'फ़िल्टर', en: 'Filters'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.brands
                  .map(
                    (String brand) => FilterChip(
                      label: Text(brand),
                      selected: filters.brand == brand,
                      onSelected: (_) => ref.read(homeFilterProvider.notifier).state =
                          filters.brand == brand ? filters.copyWith(clearBrand: true) : filters.copyWith(brand: brand),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.categories
                  .map(
                    (String category) => ChoiceChip(
                      label: Text(category),
                      selected: filters.category == category,
                      onSelected: (_) => ref.read(homeFilterProvider.notifier).state = filters.category == category
                          ? filters.copyWith(clearCategory: true)
                          : filters.copyWith(category: category),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),
            Text('Min Trust Score: ${filters.minTrustScore.toInt()}'),
            Slider(
              min: 0,
              max: 100,
              divisions: 10,
              value: filters.minTrustScore,
              onChanged: (double value) =>
                  ref.read(homeFilterProvider.notifier).state = filters.copyWith(minTrustScore: value),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrendingCard extends ConsumerWidget {
  const _TrendingCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isBookmarked = ref.watch(bookmarkIdsProvider).contains(product.id);

    return InkWell(
      onTap: () => context.push('/product/${product.id}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: Image.network(product.imageUrls.first, fit: BoxFit.cover, width: double.infinity),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: CircleAvatar(
                        backgroundColor: Colors.black54,
                        child: IconButton(
                          onPressed: () => ref.read(bookmarkIdsProvider.notifier).toggle(product.id),
                          icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: ScoreUtils.trustColor(product.trustScore),
                    child: Text(product.trustScore.toStringAsFixed(0)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(product.brand)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isBookmarked = ref.watch(bookmarkIdsProvider).contains(product.id);

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.push('/product/${product.id}'),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  product.imageUrls.first,
                  width: 92,
                  height: 92,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(product.name, style: Theme.of(context).textTheme.titleMedium),
                        ),
                        IconButton(
                          onPressed: () => ref.read(bookmarkIdsProvider.notifier).toggle(product.id),
                          icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                        ),
                      ],
                    ),
                    Text('${product.brand} • ${product.category}'),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: product.trustScore / 100,
                      color: ScoreUtils.trustColor(product.trustScore),
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        Chip(label: Text('Trust ${product.trustScore.toStringAsFixed(0)}')),
                        Chip(label: Text('Suthara ${product.sutharaScore.toStringAsFixed(0)}')),
                        Chip(label: Text(product.trustLabel)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(product.aiSummaryHi, maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
