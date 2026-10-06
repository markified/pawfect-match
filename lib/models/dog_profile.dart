import 'package:cloud_firestore/cloud_firestore.dart';

enum Sex { male, female }

enum Temperament {
  friendly,
  aggressive,
  calm,
  energetic,
  shy,
  playful,
  protective,
  gentle
}

class DogProfile {
  final String id;
  final String ownerId;
  final String name;
  final String breed;
  final int ageInMonths;
  final Sex sex;
  final String size; 
  final String color;
  final List<Temperament> temperaments;
  final List<String> imageUrls;
  final String? healthInfo;
  final double rating;
  final int ratingCount;
  final bool isAvailableForBreeding;
  final DateTime createdAt;
  final DateTime? lastUpdated;

  DogProfile({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.breed,
    required this.ageInMonths,
    required this.sex,
    required this.size,
    required this.color,
    required this.temperaments,
    this.imageUrls = const [],
    this.healthInfo,
    this.rating = 0.0,
    this.ratingCount = 0,
    this.isAvailableForBreeding = false,
    required this.createdAt,
    this.lastUpdated,
  });

  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'breed': breed,
      'ageInMonths': ageInMonths,
      'sex': sex.name,
      'size': size,
      'color': color,
      'temperaments': temperaments.map((t) => t.name).toList(),
      'imageUrls': imageUrls,
      'healthInfo': healthInfo,
      'rating': rating,
      'ratingCount': ratingCount,
      'isAvailableForBreeding': isAvailableForBreeding,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastUpdated': lastUpdated != null ? Timestamp.fromDate(lastUpdated!) : null,
    };
  }

  
  factory DogProfile.fromMap(Map<String, dynamic> map) {
    return DogProfile(
      id: map['id'] ?? '',
      ownerId: map['ownerId'] ?? '',
      name: map['name'] ?? '',
      breed: map['breed'] ?? '',
      ageInMonths: map['ageInMonths'] ?? 0,
      sex: Sex.values.firstWhere(
        (e) => e.name == map['sex'],
        orElse: () => Sex.male,
      ),
      size: map['size'] ?? '',
      color: map['color'] ?? '',
      temperaments: (map['temperaments'] as List<dynamic>?)
              ?.map((t) => Temperament.values.firstWhere(
                    (e) => e.name == t,
                    orElse: () => Temperament.friendly,
                  ))
              .toList() ??
          [],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      healthInfo: map['healthInfo'],
      rating: (map['rating'] ?? 0.0).toDouble(),
      ratingCount: map['ratingCount'] ?? 0,
      isAvailableForBreeding: map['isAvailableForBreeding'] ?? false,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastUpdated: map['lastUpdated'] != null
          ? (map['lastUpdated'] as Timestamp).toDate()
          : null,
    );
  }

  DogProfile copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? breed,
    int? ageInMonths,
    Sex? sex,
    String? size,
    String? color,
    List<Temperament>? temperaments,
    List<String>? imageUrls,
    String? healthInfo,
    double? rating,
    int? ratingCount,
    bool? isAvailableForBreeding,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return DogProfile(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      ageInMonths: ageInMonths ?? this.ageInMonths,
      sex: sex ?? this.sex,
      size: size ?? this.size,
      color: color ?? this.color,
      temperaments: temperaments ?? this.temperaments,
      imageUrls: imageUrls ?? this.imageUrls,
      healthInfo: healthInfo ?? this.healthInfo,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      isAvailableForBreeding: isAvailableForBreeding ?? this.isAvailableForBreeding,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  
  String get ageDisplay {
    if (ageInMonths < 12) {
      return '$ageInMonths months';
    } else {
      final years = ageInMonths ~/ 12;
      final months = ageInMonths % 12;
      if (months == 0) {
        return '$years ${years == 1 ? 'year' : 'years'}';
      } else {
        return '$years ${years == 1 ? 'year' : 'years'} $months months';
      }
    }
  }
}
