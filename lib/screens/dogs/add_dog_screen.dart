import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/dog_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/dog_provider.dart';
import '../../services/storage_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

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
  bool _isAvailable = true;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    if (widget.dogToEdit != null) {
      _loadDogData();
    }
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

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    
    setState(() {
      _selectedImages = images.map((xFile) => File(xFile.path)).toList();
    });
  }

  Future<void> _saveDogProfile() async {
    if (!_formKey.currentState!.validate()) {
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
      final authProvider = context.read<AuthProvider>();
      final dogProvider = context.read<DogProvider>();
      final userId = authProvider.currentUser!.uid;

      // Upload images
      List<String> imageUrls = [];
      if (_selectedImages.isNotEmpty) {
        final dogId = widget.dogToEdit?.id ??
            '${userId}_${DateTime.now().millisecondsSinceEpoch}';
        imageUrls = await _storageService.uploadMultipleDogImages(
          _selectedImages,
          dogId,
        );
      }

      final dogProfile = DogProfile(
        id: widget.dogToEdit?.id ??
            '${userId}_${DateTime.now().millisecondsSinceEpoch}',
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

      setState(() {
        _isUploading = false;
      });

      if (success && mounted) {
        Navigator.pop(context, true);
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.dogToEdit == null ? 'Add Dog' : 'Edit Dog'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _isUploading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.paddingMedium),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Image picker
                    _buildImagePicker(),
                    const SizedBox(height: 24),
                    // Name
                    CustomTextField(
                      controller: _nameController,
                      label: 'Dog Name',
                      hint: 'Enter dog name',
                      prefixIcon: const Icon(Icons.pets),
                      validator: (value) => Validators.validateRequired(value, 'Name'),
                    ),
                    const SizedBox(height: 16),
                    // Breed
                    _buildBreedDropdown(),
                    const SizedBox(height: 16),
                    // Age
                    CustomTextField(
                      controller: _ageController,
                      label: 'Age (in months)',
                      hint: 'Enter age in months',
                      keyboardType: TextInputType.number,
                      prefixIcon: const Icon(Icons.calendar_today),
                      validator: Validators.validateAge,
                    ),
                    const SizedBox(height: 16),
                    // Sex
                    _buildSexSelector(),
                    const SizedBox(height: 16),
                    // Size
                    _buildSizeDropdown(),
                    const SizedBox(height: 16),
                    // Color
                    CustomTextField(
                      controller: _colorController,
                      label: 'Color',
                      hint: 'Enter dog color',
                      prefixIcon: const Icon(Icons.palette),
                      validator: (value) => Validators.validateRequired(value, 'Color'),
                    ),
                    const SizedBox(height: 16),
                    // Temperaments
                    _buildTemperamentSelector(),
                    const SizedBox(height: 16),
                    // Health Info
                    CustomTextField(
                      controller: _healthInfoController,
                      label: 'Health Information (Optional)',
                      hint: 'Enter health details',
                      maxLines: 3,
                      prefixIcon: const Icon(Icons.medical_services),
                    ),
                    const SizedBox(height: 16),
                    // Available for breeding
                    _buildAvailabilitySwitch(),
                    const SizedBox(height: 24),
                    // Save button
                    CustomButton(
                      text: widget.dogToEdit == null ? 'Add Dog' : 'Update Dog',
                      onPressed: _saveDogProfile,
                      isLoading: _isUploading,
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
        Text('Dog Photos', style: AppTextStyles.heading3),
        const SizedBox(height: 8),
        if (_selectedImages.isEmpty && widget.dogToEdit?.imageUrls.isEmpty != false)
          GestureDetector(
            onTap: _pickImages,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(AppSizes.borderRadius),
                border: Border.all(color: AppColors.border),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate, size: 48, color: AppColors.textSecondary),
                    SizedBox(height: 8),
                    Text('Tap to add photos'),
                  ],
                ),
              ),
            ),
          )
        else
          Column(
            children: [
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Image.file(
                        _selectedImages[index],
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              CustomButton(
                text: 'Change Photos',
                onPressed: _pickImages,
                isOutlined: true,
                height: 40,
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildBreedDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedBreed,
      decoration: InputDecoration(
        labelText: 'Breed',
        prefixIcon: const Icon(Icons.pets),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
      items: DogBreeds.breeds.map((breed) {
        return DropdownMenuItem(value: breed, child: Text(breed));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedBreed = value;
        });
      },
      validator: (value) => value == null ? 'Please select a breed' : null,
    );
  }

  Widget _buildSexSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sex', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RadioOption(
                label: 'Male',
                selected: _selectedSex == Sex.male,
                onTap: () => setState(() => _selectedSex = Sex.male),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _RadioOption(
                label: 'Female',
                selected: _selectedSex == Sex.female,
                onTap: () => setState(() => _selectedSex = Sex.female),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSizeDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSize,
      decoration: InputDecoration(
        labelText: 'Size',
        prefixIcon: const Icon(Icons.straighten),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
      ),
      items: DogSizes.sizes.map((size) {
        return DropdownMenuItem(value: size, child: Text(size));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedSize = value;
        });
      },
      validator: (value) => value == null ? 'Please select a size' : null,
    );
  }

  Widget _buildTemperamentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Temperament', style: AppTextStyles.bodyMedium),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Temperament.values.map((temp) {
            final isSelected = _selectedTemperaments.contains(temp);
            return FilterChip(
              label: Text(temp.name[0].toUpperCase() + temp.name.substring(1)),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedTemperaments.add(temp);
                  } else {
                    _selectedTemperaments.remove(temp);
                  }
                });
              },
              selectedColor: AppColors.primary.withOpacity(0.3),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAvailabilitySwitch() {
    return SwitchListTile(
      title: const Text('Available for Breeding'),
      value: _isAvailable,
      onChanged: (value) {
        setState(() {
          _isAvailable = value;
        });
      },
      activeColor: AppColors.primary,
    );
  }
}

class _RadioOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RadioOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.primary : AppColors.textPrimary,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
