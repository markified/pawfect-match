import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/dog_profile.dart';
import '../../providers/dog_provider.dart';
import '../../services/compatibility_service.dart';
import '../../utils/constants.dart';
import '../dogs/add_dog_screen.dart';
import 'compatibility_results_screen.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Find Matches'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: myDogs.isEmpty
          ? _buildEmptyState()
          : Column(
              children: [
                // Dog selector
                _buildDogSelector(myDogs),
                // Filters
                if (_selectedDog != null) _buildFilters(),
                // Results
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingLarge),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 100,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text('No Dogs to Match', style: AppTextStyles.heading2),
            const SizedBox(height: 8),
            Text(
              'Add a dog profile first to start finding matches',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDogScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Dog'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDogSelector(List<DogProfile> dogs) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Your Dog', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
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
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: isSelected ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(AppSizes.borderRadius),
                            ),
                            child: dog.imageUrls.isNotEmpty
                                ? CachedNetworkImage(
                                    imageUrl: dog.imageUrls.first,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                  )
                                : Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.pets, size: 30),
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            dog.name,
                            style: AppTextStyles.bodySmall,
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
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Filters', style: AppTextStyles.bodyMedium),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _breedFilter,
                  decoration: const InputDecoration(
                    labelText: 'Breed',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Breeds')),
                    ...DogBreeds.breeds.map((breed) {
                      return DropdownMenuItem(value: breed, child: Text(breed));
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _breedFilter = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<Sex>(
                  value: _sexFilter,
                  decoration: const InputDecoration(
                    labelText: 'Sex',
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.arrow_upward,
            size: 60,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Select a dog to find matches',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchResults(List<DogProfile> availableDogs) {
    // Apply filters
    var filteredDogs = availableDogs.where((dog) {
      if (_breedFilter != null && dog.breed != _breedFilter) return false;
      if (_sexFilter != null && dog.sex != _sexFilter) return false;
      return true;
    }).toList();

    // Calculate compatibility scores
    final dogsWithScores = filteredDogs.map((dog) {
      final score = CompatibilityService.calculateCompatibilityScore(
        _selectedDog!,
        dog,
      );
      return {'dog': dog, 'score': score};
    }).toList();

    // Sort by compatibility score
    dogsWithScores.sort((a, b) =>
        (b['score'] as double).compareTo(a['score'] as double));

    if (dogsWithScores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingLarge),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 80,
                color: AppColors.textSecondary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No matches found',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
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
      ratingColor = AppColors.success;
    } else if (score >= 0.65) {
      ratingColor = AppColors.primary;
    } else if (score >= 0.5) {
      ratingColor = AppColors.accent;
    } else {
      ratingColor = AppColors.error;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: AppSizes.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompatibilityResultsScreen(
                selectedDog: selectedDog,
                targetDog: dog,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Row(
            children: [
              // Dog image
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                child: dog.imageUrls.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: dog.imageUrls.first,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 80,
                          height: 80,
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      )
                    : Container(
                        width: 80,
                        height: 80,
                        color: Colors.grey[300],
                        child: const Icon(Icons.pets, size: 40),
                      ),
              ),
              const SizedBox(width: 16),
              // Dog info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dog.name,
                            style: AppTextStyles.heading3,
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
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${dog.ageDisplay} • ${dog.size}',
                      style: AppTextStyles.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    // Compatibility badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ratingColor.withOpacity(0.1),
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
                            style: AppTextStyles.bodySmall.copyWith(
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
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
