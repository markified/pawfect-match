import '../models/dog_profile.dart';

class CompatibilityService {
  static const double breedWeight = 0.35;
  static const double ageWeight = 0.25;
  static const double sexWeight = 0.15;
  static const double temperamentWeight = 0.25;

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

    final overallScore = (breedScore * breedWeight) +
        (ageScore * ageWeight) +
        (sexScore * sexWeight) +
        (temperamentScore * temperamentWeight);

    return overallScore;
  }

  
  
  static double _calculateBreedCompatibility(String breed1, String breed2) {
    if (breed1.toLowerCase() == breed2.toLowerCase()) {
      return 1.0;
    }
    
    return 0.3;
  }

  
  
  static double _calculateAgeCompatibility(int age1InMonths, int age2InMonths) {
    final ageDifference = (age1InMonths - age2InMonths).abs();
    
    
    if (ageDifference <= 12) {
      return 1.0;
    }
    
    else if (ageDifference <= 24) {
      return 0.8;
    }
    
    else if (ageDifference <= 36) {
      return 0.6;
    }
    
    else if (ageDifference <= 48) {
      return 0.4;
    }
    
    else {
      return 0.2;
    }
  }

  
  
  
  static double _calculateSexCompatibility(Sex sex1, Sex sex2) {
    return sex1 != sex2 ? 1.0 : 0.0;
  }

  
  
  static double _calculateTemperamentCompatibility(
    List<Temperament> temperaments1,
    List<Temperament> temperaments2,
  ) {
    if (temperaments1.isEmpty || temperaments2.isEmpty) {
      return 0.5; 
    }

    
    int matchCount = 0;
    for (var temp in temperaments1) {
      if (temperaments2.contains(temp)) {
        matchCount++;
      }
    }

    
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

    
    final maxPossibleMatches = temperaments1.length < temperaments2.length
        ? temperaments1.length
        : temperaments2.length;
    
    final matchScore = maxPossibleMatches > 0 ? matchCount / maxPossibleMatches : 0.0;
    final complementaryScore = complementaryCount * 0.2;

    
    return (matchScore * 0.6) + (complementaryScore * 0.4).clamp(0.0, 0.4);
  }

  
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

  
  static String getCompatibilityPercentage(double score) {
    return '${(score * 100).toStringAsFixed(0)}%';
  }

  
  static String getCompatibilityRating(double score) {
    if (score >= 0.8) return 'Excellent';
    if (score >= 0.65) return 'Good';
    if (score >= 0.5) return 'Fair';
    return 'Poor';
  }
}
