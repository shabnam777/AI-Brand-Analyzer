class BrandMention {
  final String brand;
  final int position;
  final int mentions;

  BrandMention({required this.brand, required this.position, required this.mentions});

  factory BrandMention.fromJson(Map<String, dynamic> json) => BrandMention(
        brand: json['brand'] ?? '',
        position: json['position'] ?? 0,
        mentions: json['mentions'] ?? 1,
      );
}

class ModelResult {
  final String model;
  final String provider;
  final String icon;
  final String text;
  final int latency;
  final String? error;
  final List<BrandMention> topBrands;
  final int? userScore;
  final int? userRank;
  final bool userFound;

  ModelResult({
    required this.model,
    required this.provider,
    required this.icon,
    required this.text,
    required this.latency,
    this.error,
    required this.topBrands,
    this.userScore,
    this.userRank,
    required this.userFound,
  });

  factory ModelResult.fromJson(Map<String, dynamic> json) => ModelResult(
        model: json['model'] ?? '',
        provider: json['provider'] ?? '',
        icon: json['icon'] ?? '🤖',
        text: json['text'] ?? '',
        latency: json['latency'] ?? 0,
        error: json['error'],
        topBrands: (json['topBrands'] as List<dynamic>? ?? [])
            .map((b) => BrandMention.fromJson(b))
            .toList(),
        userScore: json['userScore'],
        userRank: json['userRank'],
        userFound: json['userFound'] ?? false,
      );
}

class Competitor {
  final String brand;
  final int modelCount;
  final int avgPosition;

  Competitor({required this.brand, required this.modelCount, required this.avgPosition});

  factory Competitor.fromJson(Map<String, dynamic> json) => Competitor(
        brand: json['brand'] ?? '',
        modelCount: json['modelCount'] ?? 0,
        avgPosition: json['avgPosition'] ?? 0,
      );
}

class Recommendation {
  final String title;
  final String description;
  final String impact;
  final String effort;

  Recommendation({
    required this.title,
    required this.description,
    required this.impact,
    required this.effort,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        impact: json['impact'] ?? 'medium',
        effort: json['effort'] ?? 'medium',
      );
}

class AnalysisResult {
  final String query;
  final String userBrand;
  final int overallScore;
  final String grade;
  final String gradeLabel;
  final List<ModelResult> modelResults;
  final List<Competitor> topCompetitors;
  final List<Recommendation> recommendations;
  final String analyzedAt;

  AnalysisResult({
    required this.query,
    required this.userBrand,
    required this.overallScore,
    required this.grade,
    required this.gradeLabel,
    required this.modelResults,
    required this.topCompetitors,
    required this.recommendations,
    required this.analyzedAt,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
        query: json['query'] ?? '',
        userBrand: json['userBrand'] ?? '',
        overallScore: json['overallScore'] ?? 0,
        grade: json['grade'] ?? 'F',
        gradeLabel: json['gradeLabel'] ?? 'Not Visible',
        modelResults: (json['modelResults'] as List<dynamic>? ?? [])
            .map((r) => ModelResult.fromJson(r))
            .toList(),
        topCompetitors: (json['topCompetitors'] as List<dynamic>? ?? [])
            .map((c) => Competitor.fromJson(c))
            .toList(),
        recommendations: (json['recommendations'] as List<dynamic>? ?? [])
            .map((r) => Recommendation.fromJson(r))
            .toList(),
        analyzedAt: json['analyzedAt'] ?? '',
      );

  int get modelsFound => modelResults.where((r) => r.userFound).length;

  int? get avgRank {
    final ranks = modelResults.where((r) => r.userRank != null).map((r) => r.userRank!).toList();
    if (ranks.isEmpty) return null;
    return (ranks.reduce((a, b) => a + b) / ranks.length).round();
  }
}
