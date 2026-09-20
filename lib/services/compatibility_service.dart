import '../models/dog_profile.dart';

/// Compatibility Scoring Service using Weighted Sum Model
/// Weights: Breed (35%), Age (25%), Sex (15%), Temperament (25%)
class CompatibilityService {
  // Compatibility weights as per documentation
  static const double breedWeight = 0.35;
  static const double ageWeight = 0.25;
  static const double sexWeight = 0.15;
  static const double temperamentWeight = 0.25;

  /// Calculate overall compatibility score between two dog profiles
  static double calculateCompatibilityScore(
    DogProfile dog1,
    DogProfile dog2,
  ) {
    final breedScore = _calculateBreedCompatibility(dog1.breed, dog2.breed);
    final ageScore = _calculateAgeCompatibility(dog1.ageInMonths, dog2.ageInMonths);
    final sexScore = _calculateSexCompatibility(dog1.sex, dog2.sex);
    final temperamentScore = _calculateTemperamentCompatibility(
      dog1.temperaments,
      dog2.temperaments,
    );

    // Weighted Sum Model
    final overallScore = (breedScore * breedWeight) +
        (ageScore * ageWeight) +
        (sexScore * sexWeight) +
        (temperamentScore * temperamentWeight);

    return overallScore;
  }

  /// Calculate breed compatibility score (0.0 to 1.0)
  /// Same breed = 1.0, different breed = 0.3 (allow cross-breeding)
  static double _calculateBreedCompatibility(String breed1, String breed2) {
    if (breed1.toLowerCase() == breed2.toLowerCase()) {
      return 1.0;
    }
    // Different breeds still have some compatibility for cross-breeding
    return 0.3;
  }

  /// Calculate age compatibility score (0.0 to 1.0)
  /// Based on age difference - closer ages are more compatible
  static double _calculateAgeCompatibility(int age1InMonths, int age2InMonths) {
    final ageDifference = (age1InMonths - age2InMonths).abs();
    
    // Ideal range: 0-12 months difference
    if (ageDifference <= 12) {
      return 1.0;
    }
    // 13-24 months difference
    else if (ageDifference <= 24) {
      return 0.8;
    }
    // 25-36 months difference
    else if (ageDifference <= 36) {
      return 0.6;
    }
    // 37-48 months difference
    else if (ageDifference <= 48) {
      return 0.4;
    }
    // More than 48 months difference
    else {
      return 0.2;
    }
  }

  /// Calculate sex compatibility score (0.0 to 1.0)
  /// Different sexes = 1.0 (required for breeding)
  /// Same sex = 0.0 (not compatible for breeding)
  static double _calculateSexCompatibility(Sex sex1, Sex sex2) {
    return sex1 != sex2 ? 1.0 : 0.0;
  }

  /// Calculate temperament compatibility score (0.0 to 1.0)
  /// Based on matching and complementary temperaments
  static double _calculateTemperamentCompatibility(
    List<Temperament> temperaments1,
    List<Temperament> temperaments2,
  ) {
    if (temperaments1.isEmpty || temperaments2.isEmpty) {
      return 0.5; // Neutral score if no temperament data
    }

    // Calculate overlap score
    int matchCount = 0;
    for (var temp in temperaments1) {
      if (temperaments2.contains(temp)) {
        matchCount++;
      }
    }

    // Some complementary temperament combinations
    final complementaryPairs = [
      {Temperament.calm, Temperament.energetic},
      {Temperament.friendly, Temperament.playful},
      {Temperament.gentle, Temperament.protective},
    ];

    int complementaryCount = 0;
    for (var pair in complementaryPairs) {
      if ((temperaments1.any((t) => pair.contains(t)) &&
          temperaments2.any((t) => pair.contains(t)))) {
        complementaryCount++;
      }
    }

    // Score calculation
    final maxPossibleMatches = temperaments1.length < temperaments2.length
        ? temperaments1.length
        : temperaments2.length;
    
    final matchScore = maxPossibleMatches > 0 ? matchCount / maxPossibleMatches : 0.0;
    final complementaryScore = complementaryCount * 0.2;

    // Combine scores (60% match, 40% complementary)
    return (matchScore * 0.6) + (complementaryScore * 0.4).clamp(0.0, 0.4);
  }

  /// Get compatibility breakdown for detailed view
  static Map<String, double> getCompatibilityBreakdown(
    DogProfile dog1,
    DogProfile dog2,
  ) {
    return {
      'breed': _calculateBreedCompatibility(dog1.breed, dog2.breed),
      'age': _calculateAgeCompatibility(dog1.ageInMonths, dog2.ageInMonths),
      'sex': _calculateSexCompatibility(dog1.sex, dog2.sex),
      'temperament': _calculateTemperamentCompatibility(
        dog1.temperaments,
        dog2.temperaments,
      ),
    };
  }

  /// Get compatibility percentage as string
  static String getCompatibilityPercentage(double score) {
    return '${(score * 100).toStringAsFixed(0)}%';
  }

  /// Get compatibility rating (Excellent, Good, Fair, Poor)
  static String getCompatibilityRating(double score) {
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.65) return 'Good';
    if (score >= 0.5) return 'Fair';
    return 'Poor';
  }
}
