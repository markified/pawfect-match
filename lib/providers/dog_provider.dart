import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/dog_profile.dart';
import '../services/firestore_service.dart';

class DogProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  StreamSubscription? _userDogsSubscription;
  StreamSubscription? _availableDogsSubscription;
  
  List<DogProfile> _userDogs = [];
  List<DogProfile> _availableDogs = [];
  DogProfile? _selectedDog;
  bool _isLoading = false;
  String? _errorMessage;

  List<DogProfile> get userDogs => _userDogs;
  List<DogProfile> get availableDogs => _availableDogs;
  List<DogProfile> get allDogs => [..._userDogs, ..._availableDogs];
  DogProfile? get selectedDog => _selectedDog;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setSelectedDog(DogProfile? dog) {
    _selectedDog = dog;
    notifyListeners();
  }

  void listenToUserDogs(String userId) {
    final normalizedUserId = userId.trim();
    if (normalizedUserId.isEmpty) return;

    _userDogsSubscription?.cancel();
    _userDogsSubscription = _firestoreService.getUserDogs(normalizedUserId).listen(
      (dogs) {
        _userDogs = dogs;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void listenToAvailableDogs(String currentUserId) {
    final normalizedUserId = currentUserId.trim();
    if (normalizedUserId.isEmpty) return;

    _availableDogsSubscription?.cancel();
    _availableDogsSubscription = _firestoreService
        .getAvailableDogsForMatching(normalizedUserId)
        .listen(
      (dogs) {
        _availableDogs = dogs;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  Future<bool> createDogProfile(DogProfile dog) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.createDogProfile(dog);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDogProfile(DogProfile dog) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateDogProfile(dog);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDogProfile(String dogId, String ownerId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteDogProfile(dogId, ownerId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<DogProfile?> getDogProfile(String dogId) async {
    try {
      return await _firestoreService.getDogProfile(dogId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userDogsSubscription?.cancel();
    _availableDogsSubscription?.cancel();
    super.dispose();
  }
}
