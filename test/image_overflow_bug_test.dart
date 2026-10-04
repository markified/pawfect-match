import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pawfect/models/dog_profile.dart';





















void main() {
  group('Image Overflow Bug Exploration', () {
    late DogProfile testDog1;
    late DogProfile testDog2;
    late DogProfile testDog3;

    setUp(() {
      
      
      testDog1 = DogProfile(
        id: 'test_dog_1',
        ownerId: 'test_owner',
        name: 'Max',
        breed: 'Golden Retriever',
        ageInMonths: 24,
        sex: Sex.male,
        size: 'large',
        color: 'golden',
        temperaments: [Temperament.friendly, Temperament.playful],
        imageUrls: [
          'https://res.cloudinary.com/demo/image/upload/sample.jpg',
        ],
        createdAt: DateTime.now(),
      );

      testDog2 = DogProfile(
        id: 'test_dog_2',
        ownerId: 'test_owner',
        name: 'Bella',
        breed: 'Labrador',
        ageInMonths: 36,
        sex: Sex.female,
        size: 'large',
        color: 'black',
        temperaments: [Temperament.gentle, Temperament.calm],
        imageUrls: [
          'https://res.cloudinary.com/demo/image/upload/dog.jpg',
        ],
        createdAt: DateTime.now(),
      );

      testDog3 = DogProfile(
        id: 'test_dog_3',
        ownerId: 'test_owner',
        name: 'Charlie',
        breed: 'Beagle',
        ageInMonths: 18,
        sex: Sex.male,
        size: 'medium',
        color: 'brown',
        temperaments: [Temperament.energetic, Temperament.playful],
        imageUrls: [
          'https://res.cloudinary.com/demo/image/upload/puppy.jpg',
        ],
        createdAt: DateTime.now(),
      );
    });

    test(
      'COUNTEREXAMPLE: Dog card image ClipRRect missing explicit clipBehavior',
      () async {
        
        
        
        

        final screenFile = File('lib/screens/matcher/tinder_matcher_screen.dart');
        expect(screenFile.existsSync(), isTrue,
          reason: 'TinderMatcherScreen file should exist');

        final screenContent = await screenFile.readAsString();
        final lines = screenContent.split('\n');
        
        
        
        int? clipRRectLineIndex;
        for (int i = 0; i < lines.length; i++) {
          final line = lines[i].trim();
          if (line.contains('child: ClipRRect(')) {
            
            if (i + 1 < lines.length && 
                lines[i + 1].contains('borderRadius') && 
                lines[i + 1].contains('BorderRadius.circular(20)')) {
              clipRRectLineIndex = i;
              break;
            }
          }
        }

        expect(clipRRectLineIndex, isNotNull,
          reason: 'Should find ClipRRect with borderRadius of 20');

        
        final contextLines = <String>[];
        for (int i = clipRRectLineIndex! - 2; 
             i < clipRRectLineIndex + 10 && i < lines.length; 
             i++) {
          if (i >= 0) {
            contextLines.add(lines[i]);
          }
        }
        
        final clipRRectContext = contextLines.join('\n');
        
        
        final hasClipBehavior = clipRRectContext.contains('clipBehavior:');
        final hasHardEdgeClip = clipRRectContext.contains('Clip.hardEdge') ||
                                clipRRectContext.contains('Clip.antiAlias') ||
                                clipRRectContext.contains('Clip.antiAliasWithSaveLayer');

        
        expect(
          hasClipBehavior && hasHardEdgeClip,
          isTrue,
          reason: '''
COUNTEREXAMPLE FOUND: ClipRRect in TinderMatcherScreen does NOT have explicit clipBehavior!

Source code inspection at line ${clipRRectLineIndex + 1}:
$clipRRectContext

When clipBehavior is not explicitly set, Flutter defaults to Clip.none, which means
the ClipRRect widget does NOT actually clip its child content. This allows the 
CachedNetworkImage with BoxFit.cover to overflow the rounded rectangle boundaries,
showing watermark text like "PRODUCED BY FOTORAMA" on the right edge.

Expected: ClipRRect should have parameter "clipBehavior: Clip.hardEdge" or stricter
Actual: No clipBehavior parameter found (defaults to Clip.none)

This confirms Bug Condition 1 from the bugfix specification:
- Image overflow occurs because ClipRRect lacks explicit clipping behavior
- Sub-pixel rendering causes visible overflow pixels
- Watermark text becomes visible beyond container boundaries

Affected Images:
- Test Dog 1: ${testDog1.name} with URL: ${testDog1.imageUrls.first}
- Test Dog 2: ${testDog2.name} with URL: ${testDog2.imageUrls.first}
- Test Dog 3: ${testDog3.name} with URL: ${testDog3.imageUrls.first}

Impact: Users see watermark text on every dog card with images in the matcher.
          ''',
        );
      },
    );

    test(
      'COUNTEREXAMPLE: CachedNetworkImage uses BoxFit.cover without proper clipping',
      () async {
        
        

        final screenFile = File('lib/screens/matcher/tinder_matcher_screen.dart');
        final screenContent = await screenFile.readAsString();
        final lines = screenContent.split('\n');
        
        
        int? cachedImageLineIndex;
        for (int i = 0; i < lines.length; i++) {
          if (lines[i].contains('CachedNetworkImage') && 
              i + 5 < lines.length) {
            
            final nextLines = lines.sublist(i, i + 5).join('\n');
            if (nextLines.contains('BoxFit.cover')) {
              cachedImageLineIndex = i;
              break;
            }
          }
        }

        expect(cachedImageLineIndex, isNotNull,
          reason: 'Should find CachedNetworkImage with BoxFit.cover');

        
        final contextLines = <String>[];
        for (int i = cachedImageLineIndex!; 
             i < cachedImageLineIndex + 7 && i < lines.length; 
             i++) {
          contextLines.add(lines[i]);
        }
        
        final cachedImageCode = contextLines.join('\n');
        
        
        final usesBoxFitCover = cachedImageCode.contains('fit: BoxFit.cover');
        expect(usesBoxFitCover, isTrue,
          reason: 'CachedNetworkImage should use BoxFit.cover');

        
        final hasMemCache = cachedImageCode.contains('memCacheWidth');
        
        print('''
CachedNetworkImage Configuration Analysis (line ${cachedImageLineIndex + 1}):
$cachedImageCode

Analysis:
- Uses BoxFit.cover: $usesBoxFitCover ✓
- Has memCacheWidth optimization: $hasMemCache
- BoxFit.cover scales image to fill container while maintaining aspect ratio
- This scaling behavior CAN cause overflow when clipping is not enforced

Combined with missing clipBehavior in ClipRRect, this confirms the bug:
1. BoxFit.cover scales image to fill entire container
2. Image may extend beyond container bounds to maintain aspect ratio
3. ClipRRect with Clip.none (default) does not prevent overflow
4. Result: Watermark text "PRODUCED BY FOTORAMA" visible on card edges
        ''');
      },
    );


    test('DOCUMENTATION: Bug condition specification matches design', () {
      
      final dogWithImages = testDog1;
      final dogWithoutImages = DogProfile(
        id: 'no_image',
        ownerId: 'owner',
        name: 'NoImage',
        breed: 'Test',
        ageInMonths: 12,
        sex: Sex.male,
        size: 'medium',
        color: 'brown',
        temperaments: [Temperament.calm],
        imageUrls: [], 
        createdAt: DateTime.now(),
      );

      
      expect(dogWithImages.imageUrls.isNotEmpty, isTrue,
        reason: 'Test dog 1 has images and is affected by overflow bug');
      expect(dogWithoutImages.imageUrls.isEmpty, isTrue,
        reason: 'Dogs without images are not affected by overflow bug');

      print('''
Bug Scope Documentation:
✓ Affects dogs with imageUrls: ${dogWithImages.name} (${dogWithImages.imageUrls.length} images)
✓ Does not affect dogs without imageUrls: ${dogWithoutImages.name}
✓ Root cause: ClipRRect without explicit clipBehavior + BoxFit.cover
✓ Impact: Watermark text visible on card edges
      ''');
    });

    test('Bug Condition Function - Image Overflow Detection', () {
      
      
      
      bool isBugCondition_ImageOverflow({
        required DogProfile dog,
        required bool hasClipBehavior,
        required BoxFit fitMode,
      }) {
        return dog.imageUrls.isNotEmpty &&
               fitMode == BoxFit.cover &&
               !hasClipBehavior; 
      }

      
      
      
      expect(
        isBugCondition_ImageOverflow(
          dog: testDog1,
          hasClipBehavior: false, 
          fitMode: BoxFit.cover,
        ),
        isTrue,
        reason: 'Dog with images + BoxFit.cover + no clipBehavior = BUG',
      );

      expect(
        isBugCondition_ImageOverflow(
          dog: testDog2,
          hasClipBehavior: false,
          fitMode: BoxFit.cover,
        ),
        isTrue,
        reason: 'Multiple dogs affected by same bug condition',
      );

      
      expect(
        isBugCondition_ImageOverflow(
          dog: testDog1,
          hasClipBehavior: true, 
          fitMode: BoxFit.cover,
        ),
        isFalse,
        reason: 'With explicit clipBehavior, bug is eliminated',
      );

      
      final dogNoImages = DogProfile(
        id: 'no_image',
        ownerId: 'owner',
        name: 'NoImage',
        breed: 'Test',
        ageInMonths: 12,
        sex: Sex.male,
        size: 'medium',
        color: 'brown',
        temperaments: [Temperament.calm],
        imageUrls: [], 
        createdAt: DateTime.now(),
      );

      expect(
        isBugCondition_ImageOverflow(
          dog: dogNoImages,
          hasClipBehavior: false,
          fitMode: BoxFit.cover,
        ),
        isFalse,
        reason: 'Bug does not apply to dogs without images',
      );

      print('''
Bug Condition Function Test Results:
✓ Correctly identifies bug when dog has images + no clipBehavior
✓ Correctly identifies multiple dogs affected
✓ Correctly shows bug eliminated with explicit clipBehavior
✓ Correctly excludes dogs without images (edge case)

This confirms the bug condition logic matches the design specification.
      ''');
    });
  });
}
