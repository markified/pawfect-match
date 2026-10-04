import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'dart:math' as math;

import '../../models/dog_profile.dart';
import '../../providers/dog_provider.dart';
import '../../services/compatibility_service.dart';
import '../dogs/add_dog_screen.dart';
import 'compatibility_results_screen.dart';
import '../../design_system/components/index.dart';
import '../../utils/constants.dart';

class TinderMatcherScreen extends StatefulWidget {
  const TinderMatcherScreen({super.key});

  @override
  State<TinderMatcherScreen> createState() => _TinderMatcherScreenState();
}

class _TinderMatcherScreenState extends State<TinderMatcherScreen>
    with TickerProviderStateMixin {
  DogProfile? _selectedDog;
  List<DogProfile> _matchQueue = [];
  int _currentIndex = 0;
  String? _breedFilter;
  Sex? _sexFilter;

  
  AnimationController? _swipeAnimationController;
  Animation<Offset>? _swipeAnimation;
  AnimationController? _scaleController;
  AnimationController? _returnController;

  
  Offset _dragPosition = Offset.zero;
  bool _isSwiping = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150), 
      vsync: this,
    );
  }

  @override
  void dispose() {
    _swipeAnimationController?.dispose();
    _scaleController?.dispose();
    _returnController?.dispose();
    super.dispose();
  }

  void _onDragStart(DragStartDetails details) {
    if (_isSwiping) return;
    _returnController?.stop();
    _returnController?.dispose();
    _returnController = null;
    _scaleController?.forward();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    if (_isSwiping) return;
    setState(() {
      _dragPosition += details.delta;
    });
  }

  void _onDragEnd(DragEndDetails details) {
    if (_isSwiping) return;
    _scaleController?.reverse();
    final screenWidth = MediaQuery.of(context).size.width;
    final swipeThreshold = screenWidth * 0.2;
    final velocity = details.velocity.pixelsPerSecond;
    final isVelocitySwipe = velocity.dx.abs() > 500;

    if (_dragPosition.dx.abs() > swipeThreshold || isVelocitySwipe) {
      final isLike = isVelocitySwipe ? velocity.dx > 0 : _dragPosition.dx > 0;
      _animateSwipe(isLike);
    } else {
      _animateReturn();
    }
  }

  void _animateReturn() {
    _returnController?.dispose();
    _returnController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    final returnAnimation =
        Tween<Offset>(begin: _dragPosition, end: Offset.zero).animate(
          CurvedAnimation(parent: _returnController!, curve: Curves.elasticOut),
        );

    returnAnimation.addListener(() {
      if (mounted) {
        setState(() {
          _dragPosition = returnAnimation.value;
        });
      }
    });

    _returnController!.forward().then((_) {
      _returnController?.dispose();
      _returnController = null;
    });
  }

  void _animateSwipe(bool isLike) {
    _isSwiping = true;
    final screenWidth = MediaQuery.of(context).size.width;
    final endX = isLike ? screenWidth * 1.5 : -screenWidth * 1.5;

    _swipeAnimationController?.dispose();
    _swipeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _swipeAnimation =
        Tween<Offset>(
          begin: _dragPosition,
          end: Offset(endX, _dragPosition.dy + 50),
        ).animate(
          CurvedAnimation(
            parent: _swipeAnimationController!,
            curve: Curves.easeIn,
          ),
        );

    _swipeAnimation!.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    _swipeAnimationController!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _onSwipeComplete(isLike);
      }
    });

    _swipeAnimationController!.forward();
  }

  void _onSwipeComplete(bool isLike) {
    if (_currentIndex < _matchQueue.length) {
      final dog = _matchQueue[_currentIndex];

      if (isLike) {
        _handleLike(dog);
      }

      setState(() {
        _currentIndex++;
        _dragPosition = Offset.zero;
        _swipeAnimation = null;
        _isSwiping = false;
      });

      _swipeAnimationController?.dispose();
      _swipeAnimationController = null;
    }
  }

  void _handleLike(DogProfile dog) {
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.white),
            const SizedBox(width: 12),
            Text('Liked ${dog.name}!'),
          ],
        ),
        backgroundColor: PawColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CompatibilityResultsScreen(
          selectedDog: _selectedDog!,
          targetDog: dog,
        ),
      ),
    );
  }

  void _handlePass() {
    if (_currentIndex < _matchQueue.length && !_isSwiping) {
      _animateSwipe(false);
    }
  }

  void _handleLikeButton() {
    if (_currentIndex < _matchQueue.length && !_isSwiping) {
      _animateSwipe(true);
    }
  }

  void _rewind() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _dragPosition = Offset.zero;
      });
    }
  }

  Future<void> _showFilters() async {
    var breedFilter = _breedFilter;
    var sexFilter = _sexFilter;

    final result = await showDialog<Map<String, Object?>>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Match Filters'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String?>(
                    initialValue: breedFilter,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Breed'),
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All breeds'),
                      ),
                      ...DogBreeds.breeds.map(
                        (breed) => DropdownMenuItem<String?>(
                          value: breed,
                          child: Text(breed, overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() => breedFilter = value);
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<Sex?>(
                    initialValue: sexFilter,
                    decoration: const InputDecoration(labelText: 'Sex'),
                    items: const [
                      DropdownMenuItem<Sex?>(value: null, child: Text('All')),
                      DropdownMenuItem<Sex?>(
                        value: Sex.male,
                        child: Text('Male'),
                      ),
                      DropdownMenuItem<Sex?>(
                        value: Sex.female,
                        child: Text('Female'),
                      ),
                    ],
                    onChanged: (value) {
                      setDialogState(() => sexFilter = value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, <String, Object?>{
                    'breed': null,
                    'sex': null,
                  }),
                  child: const Text('Clear'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, <String, Object?>{
                    'breed': breedFilter,
                    'sex': sexFilter,
                  }),
                  child: const Text('Apply'),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() {
      _breedFilter = result['breed'] as String?;
      _sexFilter = result['sex'] as Sex?;
      _matchQueue = _getMatchQueue(context.read<DogProvider>().availableDogs);
      _currentIndex = 0;
      _dragPosition = Offset.zero;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dogProvider = context.watch<DogProvider>();
    final myDogs = dogProvider.userDogs;

    if (_selectedDog != null && _matchQueue.isEmpty) {
      _matchQueue = _getMatchQueue(dogProvider.availableDogs);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: myDogs.isEmpty
            ? _buildEmptyState()
            : Column(
                children: [
                  _buildHeader(myDogs),
                  Expanded(
                    child: _selectedDog == null
                        ? _buildSelectDogPrompt()
                        : _buildSwipeStack(),
                  ),
                  if (_selectedDog != null) _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
      ),
    );
  }

  List<DogProfile> _getMatchQueue(List<DogProfile> availableDogs) {
    final filteredDogs = availableDogs.where((dog) {
      if (_breedFilter != null && dog.breed != _breedFilter) return false;
      if (_sexFilter != null && dog.sex != _sexFilter) return false;
      return true;
    });

    final dogsWithScores = filteredDogs.map((dog) {
      final score = CompatibilityService.calculateCompatibilityScore(
        _selectedDog!,
        dog,
      );
      return {'dog': dog, 'score': score};
    }).toList();

    dogsWithScores.sort(
      (a, b) => (b['score'] as double).compareTo(a['score'] as double),
    );

    return dogsWithScores.map((data) => data['dog'] as DogProfile).toList();
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

  Widget _buildHeader(List<DogProfile> dogs) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [PawColors.primary, PawColors.primary.withValues(alpha: 0.8)],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.pets, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                'PawMatch',
                style: PawTypography.h2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(), 
              itemCount: dogs.length,
              itemBuilder: (context, index) {
                final dog = dogs[index];
                final isSelected = _selectedDog?.id == dog.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDog = dog;
                      _matchQueue = _getMatchQueue(
                        context.read<DogProvider>().availableDogs,
                      );
                      _currentIndex = 0;
                      _dragPosition = Offset.zero;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 60,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                        width: isSelected ? 3 : 2,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: dog.imageUrls.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: dog.imageUrls.first,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.white.withValues(alpha: 0.2),
                              child: Icon(Icons.pets, color: Colors.white),
                            ),
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

  Widget _buildSelectDogPrompt() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.arrow_upward, size: 64, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 16),
          Text('Select Your Dog', style: PawTypography.h2),
          const SizedBox(height: 8),
          Text(
            'Choose one of your dogs above\nto start swiping',
            style: PawTypography.bodyMedium.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeStack() {
    if (_matchQueue.isEmpty || _currentIndex >= _matchQueue.length) {
      return _buildNoMoreMatches();
    }

    return Stack(
      children: [
        
        for (
          int i = math.min(_currentIndex + 2, _matchQueue.length - 1);
          i >= _currentIndex;
          i--
        )
          _buildCard(i),
      ],
    );
  }

  Widget _buildCard(int index) {
    final theme = Theme.of(context);
    if (index >= _matchQueue.length) return const SizedBox.shrink();

    final dog = _matchQueue[index];
    final isTopCard = index == _currentIndex;
    final score = CompatibilityService.calculateCompatibilityScore(
      _selectedDog!,
      dog,
    );
    final percentage = CompatibilityService.getCompatibilityPercentage(score);

    
    final stackOffset = (index - _currentIndex) * 10.0;
    final cardScale = 1.0 - (index - _currentIndex) * 0.05;

    Offset position = Offset(0, stackOffset);
    double rotation = 0;

    if (isTopCard) {
      if (_swipeAnimation != null) {
        position = _swipeAnimation!.value;
      } else {
        position = _dragPosition + Offset(0, stackOffset);
      }

      
      rotation = 0; 
    }

    
    final swipeProgress = (position.dx / MediaQuery.of(context).size.width)
        .clamp(-1.0, 1.0);
    final likeOpacity = (swipeProgress > 0 ? swipeProgress : 0.0).clamp(
      0.0,
      1.0,
    );
    final nopeOpacity = (swipeProgress < 0 ? -swipeProgress : 0.0).clamp(
      0.0,
      1.0,
    );

    return Positioned.fill(
      child: RepaintBoundary(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ClipRect(
            clipBehavior: Clip.hardEdge,
            child: Transform.translate(
              offset: position,
              child: Transform.rotate(
                angle: rotation,
                child: Transform.scale(
                  scale: cardScale,
                  child: GestureDetector(
                    onPanStart: isTopCard ? _onDragStart : null,
                    onPanUpdate: isTopCard ? _onDragUpdate : null,
                    onPanEnd: isTopCard ? _onDragEnd : null,
                    child: Container(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        borderRadius: BorderRadius.circular(20),
                        child: Stack(
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          fit: StackFit.expand,
                          children: [
                            
                            dog.imageUrls.isNotEmpty
                                ? Positioned.fill(
                                    child: CachedNetworkImage(
                                      imageUrl: dog.imageUrls.first,
                                      fit: BoxFit.cover,
                                      memCacheWidth: 800, 
                                    ),
                                  )
                                : Container(
                                    color: theme.cardColor,
                                    child: Center(
                                      child: Icon(
                                        Icons.pets,
                                        size: 120,
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                            
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.8),
                                  ],
                                  stops: const [0.5, 1.0],
                                ),
                              ),
                            ),
                            
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  LayoutBuilder(
                                    builder: (context, constraints) {
                                      
                                      
                                      final nameMaxWidth =
                                          constraints.maxWidth - 88;

                                      return Stack(
                                        children: [
                                          
                                          SizedBox(
                                            width: nameMaxWidth,
                                            child: Text(
                                              dog.name,
                                              style: const TextStyle(
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          
                                          Positioned(
                                            right: 0,
                                            top: 0,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 6,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: PawColors.success,
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.favorite,
                                                    color: Colors.white,
                                                    size: 16,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    percentage,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        dog.sex == Sex.male
                                            ? Icons.male
                                            : Icons.female,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${dog.ageDisplay} - ${dog.breed}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    dog.size,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            if (isTopCard && likeOpacity > 0)
                              Positioned(
                                top: 50,
                                left: 50,
                                child: Opacity(
                                  opacity: likeOpacity,
                                  child: Transform.rotate(
                                    angle: -0.3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: PawColors.success,
                                          width: 4,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'LIKE',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: PawColors.success,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            
                            if (isTopCard && nopeOpacity > 0)
                              Positioned(
                                top: 50,
                                right: 50,
                                child: Opacity(
                                  opacity: nopeOpacity,
                                  child: Transform.rotate(
                                    angle: 0.3,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: PawColors.error,
                                          width: 4,
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'NOPE',
                                        style: TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: PawColors.error,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNoMoreMatches() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.celebration, size: 80, color: PawColors.accent),
          const SizedBox(height: 24),
          Text(
            'You\'ve seen all available breeding partners.\nCheck back later for new matches!',
            style: PawTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _currentIndex = 0;
                _dragPosition = Offset.zero;
                
                final dogProvider = context.read<DogProvider>();
                _matchQueue = _getMatchQueue(dogProvider.availableDogs);
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Start Over'),
            style: ElevatedButton.styleFrom(
              backgroundColor: PawColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasMatches = _currentIndex < _matchQueue.length;
    final canRewind = _currentIndex > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          
          _ActionButton(
            icon: Icons.replay,
            color: PawColors.accent,
            size: 50,
            onPressed: canRewind ? _rewind : null,
          ),
          
          _ActionButton(
            icon: Icons.close,
            color: PawColors.error,
            size: 70,
            onPressed: hasMatches ? _handlePass : null,
          ),
          
          _ActionButton(
            icon: Icons.star,
            color: Colors.blue,
            size: 50,
            onPressed: hasMatches
                ? () {
                    if (_currentIndex < _matchQueue.length) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompatibilityResultsScreen(
                            selectedDog: _selectedDog!,
                            targetDog: _matchQueue[_currentIndex],
                          ),
                        ),
                      );
                    }
                  }
                : null,
          ),
          
          _ActionButton(
            icon: Icons.favorite,
            color: PawColors.success,
            size: 70,
            onPressed: hasMatches ? _handleLikeButton : null,
          ),
          
          _ActionButton(
            icon: Icons.bolt,
            color: Colors.purple,
            size: 50,
            onPressed: _showFilters,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.size,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        splashColor: color.withValues(alpha: 0.2),
        highlightColor: color.withValues(alpha: 0.1),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: onPressed != null
                ? Colors.white
                : Colors.white.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            boxShadow: onPressed != null
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Icon(
            icon,
            color: onPressed != null ? color : color.withValues(alpha: 0.3),
            size: size * 0.5,
          ),
        ),
      ),
    );
  }
}
