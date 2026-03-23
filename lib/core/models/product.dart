// Product domain model representing Firestore product documents.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.features,
    required this.qualityIndicators,
    required this.imageUrls,
    required this.averageRating,
    required this.reviewCount,
    required this.trustScore,
    required this.sutharaScore,
    required this.sentimentScore,
    required this.authenticityScore,
    required this.brandReputationScore,
    required this.aiSummaryHi,
    required this.aiSummaryEn,
    required this.pros,
    required this.cons,
    required this.fakeReviewRisk,
    required this.platformRatings,
    required this.safeIndicator,
    required this.affiliateUrl,
    required this.trending,
  });

  factory Product.fromMap(String id, Map<String, dynamic> json) {
    return Product(
      id: id,
      name: json['name'] as String? ?? '',
      brand: json['brand'] as String? ?? '',
      category: json['category'] as String? ?? '',
      features: List<String>.from(json['features'] as List? ?? <String>[]),
      qualityIndicators: List<String>.from(
        json['qualityIndicators'] as List? ?? <String>[],
      ),
      imageUrls: List<String>.from(json['imageUrls'] as List? ?? <String>[]),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      trustScore: (json['trustScore'] as num?)?.toDouble() ?? 0,
      sutharaScore: (json['sutharaScore'] as num?)?.toDouble() ?? 0,
      sentimentScore: (json['sentimentScore'] as num?)?.toDouble() ?? 0,
      authenticityScore: (json['authenticityScore'] as num?)?.toDouble() ?? 0,
      brandReputationScore:
          (json['brandReputationScore'] as num?)?.toDouble() ?? 0,
      aiSummaryHi: json['aiSummaryHi'] as String? ?? '',
      aiSummaryEn: json['aiSummaryEn'] as String? ?? '',
      pros: List<String>.from(json['pros'] as List? ?? <String>[]),
      cons: List<String>.from(json['cons'] as List? ?? <String>[]),
      fakeReviewRisk: json['fakeReviewRisk'] as String? ?? 'low',
      platformRatings: Map<String, dynamic>.from(
        json['platformRatings'] as Map? ?? <String, dynamic>{},
      ),
      safeIndicator: json['safeIndicator'] as String? ?? 'review',
      affiliateUrl: json['affiliateUrl'] as String? ?? '',
      trending: json['trending'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String brand;
  final String category;
  final List<String> features;
  final List<String> qualityIndicators;
  final List<String> imageUrls;
  final double averageRating;
  final int reviewCount;
  final double trustScore;
  final double sutharaScore;
  final double sentimentScore;
  final double authenticityScore;
  final double brandReputationScore;
  final String aiSummaryHi;
  final String aiSummaryEn;
  final List<String> pros;
  final List<String> cons;
  final String fakeReviewRisk;
  final Map<String, dynamic> platformRatings;
  final String safeIndicator;
  final String affiliateUrl;
  final bool trending;

  bool get highlyTrusted => trustScore >= 80;
  bool get moderateTrusted => trustScore >= 50 && trustScore < 80;

  String get trustLabel {
    if (highlyTrusted) return 'Highly Trusted';
    if (moderateTrusted) return 'Moderate';
    return 'Low Trust';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'brand': brand,
      'category': category,
      'features': features,
      'qualityIndicators': qualityIndicators,
      'imageUrls': imageUrls,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'trustScore': trustScore,
      'sutharaScore': sutharaScore,
      'sentimentScore': sentimentScore,
      'authenticityScore': authenticityScore,
      'brandReputationScore': brandReputationScore,
      'aiSummaryHi': aiSummaryHi,
      'aiSummaryEn': aiSummaryEn,
      'pros': pros,
      'cons': cons,
      'fakeReviewRisk': fakeReviewRisk,
      'platformRatings': platformRatings,
      'safeIndicator': safeIndicator,
      'affiliateUrl': affiliateUrl,
      'trending': trending,
    };
  }

  Product copyWith({
    String? id,
    String? name,
    String? brand,
    String? category,
    List<String>? features,
    List<String>? qualityIndicators,
    List<String>? imageUrls,
    double? averageRating,
    int? reviewCount,
    double? trustScore,
    double? sutharaScore,
    double? sentimentScore,
    double? authenticityScore,
    double? brandReputationScore,
    String? aiSummaryHi,
    String? aiSummaryEn,
    List<String>? pros,
    List<String>? cons,
    String? fakeReviewRisk,
    Map<String, dynamic>? platformRatings,
    String? safeIndicator,
    String? affiliateUrl,
    bool? trending,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      features: features ?? this.features,
      qualityIndicators: qualityIndicators ?? this.qualityIndicators,
      imageUrls: imageUrls ?? this.imageUrls,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      trustScore: trustScore ?? this.trustScore,
      sutharaScore: sutharaScore ?? this.sutharaScore,
      sentimentScore: sentimentScore ?? this.sentimentScore,
      authenticityScore: authenticityScore ?? this.authenticityScore,
      brandReputationScore:
          brandReputationScore ?? this.brandReputationScore,
      aiSummaryHi: aiSummaryHi ?? this.aiSummaryHi,
      aiSummaryEn: aiSummaryEn ?? this.aiSummaryEn,
      pros: pros ?? this.pros,
      cons: cons ?? this.cons,
      fakeReviewRisk: fakeReviewRisk ?? this.fakeReviewRisk,
      platformRatings: platformRatings ?? this.platformRatings,
      safeIndicator: safeIndicator ?? this.safeIndicator,
      affiliateUrl: affiliateUrl ?? this.affiliateUrl,
      trending: trending ?? this.trending,
    );
  }
}
