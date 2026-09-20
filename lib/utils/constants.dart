import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF6C63FF);
  static const Color secondary = Color(0xFFFF6584);
  static const Color accent = Color(0xFFFFA500);
  static const Color background = Color(0xFFF5F5F5);
  static const Color cardBackground = Colors.white;
  static const Color textPrimary = Color(0xFF2D3436);
  static const Color textSecondary = Color(0xFF636E72);
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFD63031);
  static const Color border = Color(0xFFDFE6E9);
}

class AppTextStyles {
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

class AppSizes {
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double borderRadius = 12.0;
  static const double cardElevation = 2.0;
}

class DogBreeds {
  static const List<String> breeds = [
    'Labrador Retriever',
    'German Shepherd',
    'Golden Retriever',
    'French Bulldog',
    'Bulldog',
    'Poodle',
    'Beagle',
    'Rottweiler',
    'German Shorthaired Pointer',
    'Dachshund',
    'Pembroke Welsh Corgi',
    'Australian Shepherd',
    'Yorkshire Terrier',
    'Boxer',
    'Cavalier King Charles Spaniel',
    'Doberman Pinscher',
    'Great Dane',
    'Miniature Schnauzer',
    'Siberian Husky',
    'Bernese Mountain Dog',
    'Pomeranian',
    'Boston Terrier',
    'Havanese',
    'Shetland Sheepdog',
    'Brittany',
    'Shih Tzu',
    'Border Collie',
    'Chihuahua',
    'Maltese',
    'Mastiff',
    'Other',
  ];
}

class DogSizes {
  static const List<String> sizes = [
    'Small (0-20 lbs)',
    'Medium (21-50 lbs)',
    'Large (51-100 lbs)',
    'Extra Large (100+ lbs)',
  ];
}
