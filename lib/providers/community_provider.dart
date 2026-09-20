import 'package:flutter/foundation.dart';
import '../models/community_post.dart';
import '../services/firestore_service.dart';

class CommunityProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  List<CommunityPost> _posts = [];
  PostCategory? _selectedCategory;
  bool _isLoading = false;
  String? _errorMessage;

  List<CommunityPost> get posts => _posts;
  PostCategory? get selectedCategory => _selectedCategory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void listenToCommunityPosts() {
    _firestoreService.getCommunityPosts().listen(
      (posts) {
        _posts = posts;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
  }

  void filterByCategory(PostCategory? category) {
    _selectedCategory = category;
    
    if (category == null) {
      listenToCommunityPosts();
    } else {
      _firestoreService.getCommunityPostsByCategory(category).listen(
        (posts) {
          _posts = posts;
          notifyListeners();
        },
        onError: (error) {
          _errorMessage = error.toString();
          notifyListeners();
        },
      );
    }
  }

  Future<bool> createPost(CommunityPost post) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.createCommunityPost(post);

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

  Future<bool> updatePost(CommunityPost post) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.updateCommunityPost(post);

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

  Future<bool> deletePost(String postId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _firestoreService.deleteCommunityPost(postId);

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

  Future<void> toggleLike(String postId, String userId) async {
    try {
      await _firestoreService.togglePostLike(postId, userId);
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createComment(PostComment comment) async {
    try {
      await _firestoreService.createPostComment(comment);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
