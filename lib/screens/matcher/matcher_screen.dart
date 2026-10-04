import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/dog_profile.dart';
import '../../providers/dog_provider.dart';
import '../../services/compatibility_service.dart';
import '../../utils/constants.dart';
import '../dogs/add_dog_screen.dart';
import 'compatibility_results_screen.dart';

import '../../design_system/components/index.dart';

class MatcherScreen extends StatefulWidget {
  const MatcherScreen({super.key});

  @override
  State<MatcherScreen> createState() => _MatcherScreenState();
}

class _MatcherScreenState extends State<MatcherScreen> {
  DogProfile? _selectedDog;
  String? _breedFilter;
  Sex? _sexFilter;

  @override
  Widget build(BuildContext context) {
    final dogProvider = context.watch<DogProvider>();
    final myDogs = dogProvider.userDogs;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PawAppBar(
        title: 'Find Matches',
      ),
      body: myDogs.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                
                _buildDogSelector(myDogs),
                
                if (_selectedDog != null) _buildFilters(),
                
                Expanded(
                  child: _selectedDog == null
                      ? _buildSelectDogPrompt()
                      : _buildMatchResults(dogProvider.availableDogs),
                ),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.search_off,
      title: 'No Dogs to Match',
      message: 'Add a dog profile first to start finding matches',
      actionLabel: 'Add Dog',
      onAction: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddDogScreen()),
        );
      },
    );
  }

  Widget _buildDogSelector(List<DogProfile> dogs) {
    return Container(
      padding: const EdgeInsets.all(PawSpacing.md),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Your Dog', style: PawTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: PawSpacing.sm),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dogs.length,
              itemBuilder: (context, index) {
                final dog = dogs[index];
                final isSelected = _selectedDog?.id == dog.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDog = dog;
                      _breedFilter = null;
                      _sexFilter = null;
                    });
                  },
                  child: AnimatedContainer(
                    duration: PawDurations.short,
                    width: 80,
                    margin: const EdgeInsets.only(right: PawSpacing.sm),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? PawColors.primary : PawColors.border,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(PawRadius.md),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(PawRadius.md),
                            ),
                            child: dog.imageUrls.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: dog.imageUrls.first,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Container(
                                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                                    child: Icon(Icons.pets, size: 30, color: Theme.of(context).colorScheme.onSurfaceVariant),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            dog.name,
                            style: PawTypography.bodySmall.copyWith(
                              color: isSelected ? PawColors.primary : PawColors.textPrimary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

    Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PawSpacing.md,
        vertical: PawSpacing.sm,
      ),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: PawTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: PawSpacing.xs),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  initialValue: _breedFilter,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Breed',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PawRadius.md),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null, 
                      child: Text('All Breeds', overflow: TextOverflow.ellipsis),
                    ),
                    ...DogBreeds.breeds.map((breed) {
                      return DropdownMenuItem(
                        value: breed, 
                        child: Text(breed, overflow: TextOverflow.ellipsis),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _breedFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<Sex>(
                  initialValue: _sexFilter,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'Sex',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(PawRadius.md),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).scaffoldBackgroundColor,
                  ),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('All')),
                    DropdownMenuItem(value: Sex.male, child: Text('Male')),
                    DropdownMenuItem(value: Sex.female, child: Text('Female')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _sexFilter = value;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectDogPrompt() {
    return EmptyState(
      icon: Icons.arrow_upward,
      title: 'Select a Dog',
      message: 'Choose one of your dogs above to find compatible breeding partners',
    );
  }

  Widget _buildMatchResults(List<DogProfile> availableDogs) {
    
    var filteredDogs = availableDogs.where((dog) {
      if (_breedFilter != null && dog.breed != _breedFilter) return false;
      if (_sexFilter != null && dog.sex != _sexFilter) return false;
      return true;
    }).toList();

    
    final dogsWithScores = filteredDogs.map((dog) {
      final score = CompatibilityService.calculateCompatibilityScore(
        _selectedDog!,
        dog,
      );
      return {'dog': dog, 'score': score};
    }).toList();

    
    dogsWithScores.sort((a, b) =>
        (b['score'] as double).compareTo(a['score'] as double));

    if (dogsWithScores.isEmpty) {
      return EmptyState(
        icon: Icons.search_off,
        title: 'No Matches Found',
        message: 'Try adjusting your filters to see more breeding partners',
        actionLabel: 'Clear Filters',
        onAction: () {
          setState(() {
            _breedFilter = null;
            _sexFilter = null;
          });
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(PawSpacing.md),
      itemCount: dogsWithScores.length,
      itemBuilder: (context, index) {
        final data = dogsWithScores[index];
        final dog = data['dog'] as DogProfile;
        final score = data['score'] as double;
        return _MatchCard(
          dog: dog,
          score: score,
          selectedDog: _selectedDog!,
        );
      },
    );
  }
}

class _MatchCard extends StatelessWidget {
  final DogProfile dog;
  final double score;
  final DogProfile selectedDog;

  const _MatchCard({
    required this.dog,
    required this.score,
    required this.selectedDog,
  });

  @override
  Widget build(BuildContext context) {
    final rating = CompatibilityService.getCompatibilityRating(score);
    final percentage = CompatibilityService.getCompatibilityPercentage(score);

    Color ratingColor;
    if (score >= 0.8) {
      ratingColor = PawColors.success;
    } else if (score >= 0.65) {
      ratingColor = PawColors.primary;
    } else if (score >= 0.5) {
      ratingColor = PawColors.accent;
    } else {
      ratingColor = PawColors.error;
    }

    return PawCard(
      margin: const EdgeInsets.only(bottom: PawSpacing.md),
      onTap: () {
        Navigator.push(
          context,
          PawPageRoute(
            page: CompatibilityResultsScreen(
              selectedDog: selectedDog,
              targetDog: dog,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(PawSpacing.md),
        child: Row(
          children: [
            
            PawHero(
              tag: 'match-dog-${dog.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PawRadius.md),
                child: dog.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: dog.imageUrls.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const SkeletonBox(
                          width: 80,
                          height: 80,
                          borderRadius: 0,
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        child: Icon(Icons.pets, size: 40, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      ),
              ),
            ),
            const SizedBox(width: PawSpacing.md),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dog.name,
                          style: PawTypography.h3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Icon(
                        dog.sex == Sex.male ? Icons.male : Icons.female,
                        color: dog.sex == Sex.male ? Colors.blue : Colors.pink,
                        size: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dog.breed,
                    style: PawTypography.bodyMedium.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dog.ageDisplay} • ${dog.size}',
                    style: PawTypography.bodySmall,
                  ),
                  const SizedBox(height: PawSpacing.sm),
                  
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: PawSpacing.sm,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: ratingColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ratingColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 14,
                          color: ratingColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$percentage $rating Match',
                          style: PawTypography.bodySmall.copyWith(
                            color: ratingColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

