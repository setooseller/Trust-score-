// Immutable filter state used to drive home screen search and filtering.
class HomeFilterState {
  const HomeFilterState({
    this.brand,
    this.category,
    this.minTrustScore = 0,
  });

  final String? brand;
  final String? category;
  final double minTrustScore;

  HomeFilterState copyWith({
    String? brand,
    String? category,
    double? minTrustScore,
    bool clearBrand = false,
    bool clearCategory = false,
  }) {
    return HomeFilterState(
      brand: clearBrand ? null : (brand ?? this.brand),
      category: clearCategory ? null : (category ?? this.category),
      minTrustScore: minTrustScore ?? this.minTrustScore,
    );
  }
}
