import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../models/dog_profile.dart';
import '../../providers/auth_provider.dart' as app_auth;
import '../../providers/dog_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../design_system/components/index.dart';

class AddDogScreen extends StatefulWidget {
  final DogProfile? dogToEdit;

  const AddDogScreen({super.key, this.dogToEdit});

  @override
  State<AddDogScreen> createState() => _AddDogScreenState();
}

class _AddDogScreenState extends State<AddDogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _colorController = TextEditingController();
  final _healthInfoController = TextEditingController();
  final StorageService _storageService = StorageService();

  String? _selectedBreed;
  Sex? _selectedSex;
  String? _selectedSize;
  List<Temperament> _selectedTemperaments = [];
  List<File> _selectedImages = [];
  bool _isAvailable = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.dogToEdit != null) {
      _loadDogData();
    }
    
    _nameController.addListener(() => setState(() {}));
    _ageController.addListener(() => setState(() {}));
  }

  void _loadDogData() {
    final dog = widget.dogToEdit!;
    _nameController.text = dog.name;
    _ageController.text = dog.ageInMonths.toString();
    _colorController.text = dog.color;
    _healthInfoController.text = dog.healthInfo ?? '';
    _selectedBreed = dog.breed;
    _selectedSex = dog.sex;
    _selectedSize = dog.size;
    _selectedTemperaments = List.from(dog.temperaments);
    _isAvailable = dog.isAvailableForBreeding;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _colorController.dispose();
    _healthInfoController.dispose();
    super.dispose();
  }



  Future<void> _saveDogProfile() async {
    if (!_formKey.currentState!.validate()) {
      
      PawSnackbar.error(
        context,
        message: 'Please fix the errors in the form',
      );
      return;
    }

    if (_selectedBreed == null) {
      _showError('Please select a breed');
      return;
    }

    if (_selectedSex == null) {
      _showError('Please select sex');
      return;
    }

    if (_selectedSize == null) {
      _showError('Please select size');
      return;
    }

    if (_selectedTemperaments.isEmpty) {
      _showError('Please select at least one temperament');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final authProvider = context.read<app_auth.AuthProvider>();
      final dogProvider = context.read<DogProvider>();
      
      String? userId = authProvider.currentUser?.uid;

      if (userId == null || userId.trim().isEmpty) {
        final firebaseUser = FirebaseAuth.instance.currentUser;
        if (firebaseUser != null && firebaseUser.uid.trim().isNotEmpty) {
          userId = firebaseUser.uid;
        } else {
          _showError('User not authenticated. Please log in again.');
          setState(() {
            _isUploading = false;
          });
          return;
        }
      }

      final dogId = (widget.dogToEdit?.id ?? '').trim().isNotEmpty
          ? widget.dogToEdit!.id
          : '${userId}_${DateTime.now().millisecondsSinceEpoch}';

      
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        imageUrls = await _storageService.uploadMultipleDogImages(
          _selectedImages,
          dogId,
        );
      }

      final dogProfile = DogProfile(
        id: dogId,
        ownerId: userId,
        name: _nameController.text.trim(),
        breed: _selectedBreed!,
        ageInMonths: int.parse(_ageController.text),
        sex: _selectedSex!,
        size: _selectedSize!,
        color: _colorController.text.trim(),
        temperaments: _selectedTemperaments,
        imageUrls: imageUrls.isNotEmpty ? imageUrls : widget.dogToEdit?.imageUrls ?? [],
        healthInfo: _healthInfoController.text.trim().isEmpty
            ? null
            : _healthInfoController.text.trim(),
        isAvailableForBreeding: _isAvailable,
        createdAt: widget.dogToEdit?.createdAt ?? DateTime.now(),
        lastUpdated: DateTime.now(),
        rating: widget.dogToEdit?.rating ?? 0.0,
        ratingCount: widget.dogToEdit?.ratingCount ?? 0,
      );

      final success = widget.dogToEdit == null
          ? await dogProvider.createDogProfile(dogProfile)
          : await dogProvider.updateDogProfile(dogProfile);

      if (success && mounted) {
        await authProvider.loadUserData(userId);
      }

      setState(() {
        _isUploading = false;
      });

      if (success && mounted) {
        
        PawSnackbar.success(
          context,
          message: widget.dogToEdit != null 
              ? 'Dog profile updated successfully'
              : 'Dog profile added successfully',
        );
        
        
        await Future.delayed(const Duration(milliseconds: 1500));
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (mounted) {
        _showError(dogProvider.errorMessage ?? 'Failed to save dog profile');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showError('Error: $e');
    }
  }

  void _showError(String message) {
    PawSnackbar.error(
      context,
      message: message,
      actionLabel: 'Dismiss',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: PawAppBar(
        title: widget.dogToEdit == null ? 'Add Dog Profile' : 'Edit Dog Profile',
        backgroundColor: PawColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(PawSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              
              _buildImagePicker(),
              const SizedBox(height: PawSpacing.lg),
              
              
              PawTextField(
                controller: _nameController,
                label: 'Dog Name',
                hint: 'Enter dog name',
                validator: (value) => Validators.validateRequired(value, 'Name'),
                showSuccessState: _nameController.text.trim().isNotEmpty && 
                                 Validators.validateRequired(_nameController.text, 'Name') == null,
                showClearButton: true,
                maxLength: 50,
                prefixIcon: const Icon(Icons.pets),
              ),
              const SizedBox(height: PawSpacing.md),
              
              
              _buildBreedDropdown(),
              const SizedBox(height: PawSpacing.md),
              
              
              PawTextField(
                controller: _ageController,
                label: 'Age (in months)',
                hint: 'Enter age in months',
                keyboardType: TextInputType.number,
                validator: Validators.validateAge,
                showSuccessState: int.tryParse(_ageController.text) != null && 
                                 int.parse(_ageController.text) > 0,
                prefixIcon: const Icon(Icons.calendar_today),
              ),
              const SizedBox(height: PawSpacing.md),
              
              
              _buildSexSelector(),
              const SizedBox(height: PawSpacing.md),
              
              
              _buildSizeDropdown(),
              const SizedBox(height: PawSpacing.md),
              
              
              PawTextField(
                controller: _colorController,
                label: 'Color',
                hint: 'Enter dog color',
                validator: (value) => Validators.validateRequired(value, 'Color'),
                showClearButton: true,
                prefixIcon: const Icon(Icons.palette),
              ),
              const SizedBox(height: PawSpacing.md),
              
              
              _buildTemperamentSelector(),
              const SizedBox(height: PawSpacing.md),
              
              
              PawTextField(
                controller: _healthInfoController,
                label: 'Health Information',
                hint: 'Enter health details (optional)',
                maxLines: 4,
                showClearButton: true,
                prefixIcon: const Icon(Icons.medical_services),
              ),
              const SizedBox(height: PawSpacing.md),
              
              
              _buildAvailabilitySwitch(),
              const SizedBox(height: PawSpacing.xl),
              
              
              PawButton(
                text: widget.dogToEdit == null ? 'Add Dog Profile' : 'Update Dog Profile',
                onPressed: _isUploading ? null : _saveDogProfile,
                type: PawButtonType.primary,
                size: PawButtonSize.large,
                isLoading: _isUploading,
                icon: widget.dogToEdit == null ? Icons.add : Icons.save,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Dog Photos', style: PawTypography.h3),
        const SizedBox(height: PawSpacing.sm),
        PawImagePicker(
          images: _selectedImages,
          onImagesChanged: (images) {
            setState(() {
              _selectedImages = images;
            });
          },
          maxImages: 10,
        ),
      ],
    );
  }

  Widget _buildBreedDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedBreed,
      decoration: InputDecoration(
        labelText: 'Breed',
        prefixIcon: const Icon(Icons.pets),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawRadius.md),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: DogBreeds.breeds.map((breed) {
        return DropdownMenuItem(value: breed, child: Text(breed));
      }).toList(),
      onChanged: (value) => setState(() => _selectedBreed = value),
      validator: (value) => value == null ? 'Please select a breed' : null,
    );
  }

  Widget _buildSizeDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedSize,
      decoration: InputDecoration(
        labelText: 'Size',
        prefixIcon: const Icon(Icons.straighten),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PawRadius.md),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
      items: DogSizes.sizes.map((size) {
        return DropdownMenuItem(value: size, child: Text(size));
      }).toList(),
      onChanged: (value) => setState(() => _selectedSize = value),
      validator: (value) => value == null ? 'Please select a size' : null,
    );
  }

  Widget _buildSexSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Sex *', style: PawTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: PawSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _RadioOption(
                label: 'Male',
                icon: Icons.male,
                selected: _selectedSex == Sex.male,
                onTap: () => setState(() => _selectedSex = Sex.male),
              ),
            ),
            const SizedBox(width: PawSpacing.sm),
            Expanded(
              child: _RadioOption(
                label: 'Female',
                icon: Icons.female,
                selected: _selectedSex == Sex.female,
                onTap: () => setState(() => _selectedSex = Sex.female),
              ),
            ),
          ],
        ),
        if (_selectedSex == null)
          Padding(
            padding: const EdgeInsets.only(top: PawSpacing.xs),
            child: Text(
              'Please select sex',
              style: PawTypography.bodySmall.copyWith(
                color: PawColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTemperamentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Temperament *', style: PawTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: PawSpacing.sm),
        ChipInput(
          items: Temperament.values.map((temp) {
            final tempName = temp.name;
            return tempName.isEmpty 
                ? 'Unknown' 
                : '${tempName[0].toUpperCase()}${tempName.substring(1)}';
          }).toList(),
          selectedItems: _selectedTemperaments.map((temp) {
            final tempName = temp.name;
            return tempName.isEmpty 
                ? 'Unknown' 
                : '${tempName[0].toUpperCase()}${tempName.substring(1)}';
          }).toList(),
          onItemTap: (displayName) {
            setState(() {
              final temp = Temperament.values.firstWhere(
                (t) => t.name.toLowerCase() == displayName.toLowerCase() ||
                       '${t.name[0].toUpperCase()}${t.name.substring(1)}' == displayName,
              );
              
              if (_selectedTemperaments.contains(temp)) {
                _selectedTemperaments.remove(temp);
              } else {
                _selectedTemperaments.add(temp);
              }
            });
          },
          maxVisible: 10,
        ),
        if (_selectedTemperaments.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: PawSpacing.xs),
            child: Text(
              'Select at least one temperament',
              style: PawTypography.bodySmall.copyWith(
                color: PawColors.error,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAvailabilitySwitch() {
    return PawCard(
      child: SwitchListTile(
        title: Text(
          'Available for Breeding',
          style: PawTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          'Make this dog profile visible to potential breeding partners',
          style: PawTypography.bodySmall.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        value: _isAvailable,
        onChanged: (value) => setState(() => _isAvailable = value),
        activeThumbColor: Colors.white,
        activeTrackColor: PawColors.primary,
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey.shade600,
      ),
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: PawDurations.short,
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(PawSpacing.md),
        decoration: BoxDecoration(
          color: selected 
              ? PawColors.primary.withValues(alpha: 0.1) 
              : Theme.of(context).cardColor,
          border: Border.all(
            color: selected
                ? PawColors.primary
                : Theme.of(context).colorScheme.primary,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(PawRadius.md),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected ? PawColors.primary : Theme.of(context).colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: PawSpacing.xs),
            Text(
              label,
              style: PawTypography.bodyMedium.copyWith(
                color: selected
                  ? PawColors.primary
                  : Theme.of(context).colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}



