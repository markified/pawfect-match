import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dog_profile.dart';
import '../models/match_request.dart';
import '../models/review.dart';
import '../models/user_model.dart';
import '../models/community_post.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============ Dog Profile Operations ============

  // Create dog profile
  Future<void> createDogProfile(DogProfile dog) async {
    try {
      await _firestore.collection('dogs').doc(dog.id).set(dog.toMap());
      
      // Update user's dogIds
      await _firestore.collection('users').doc(dog.ownerId).update({
        'dogIds': FieldValue.arrayUnion([dog.id])
      });
    } catch (e) {
      throw Exception('Failed to create dog profile: $e');
    }
  }

  // Get dog profile
  Future<DogProfile?> getDogProfile(String dogId) async {
    try {
      final doc = await _firestore.collection('dogs').doc(dogId).get();
      if (doc.exists) {
        return DogProfile.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get dog profile: $e');
    }
  }

  // Update dog profile
  Future<void> updateDogProfile(DogProfile dog) async {
    try {
      await _firestore.collection('dogs').doc(dog.id).update(dog.toMap());
    } catch (e) {
      throw Exception('Failed to update dog profile: $e');
    }
  }

  // Delete dog profile
  Future<void> deleteDogProfile(String dogId, String ownerId) async {
    try {
      await _firestore.collection('dogs').doc(dogId).delete();
      
      // Remove from user's dogIds
      await _firestore.collection('users').doc(ownerId).update({
        'dogIds': FieldValue.arrayRemove([dogId])
      });
    } catch (e) {
      throw Exception('Failed to delete dog profile: $e');
    }
  }

  // Get user's dogs
  Stream<List<DogProfile>> getUserDogs(String userId) {
    return _firestore
        .collection('dogs')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DogProfile.fromMap(doc.data()))
            .toList());
  }

  // Get available dogs for matching (excluding user's own dogs)
  Stream<List<DogProfile>> getAvailableDogsForMatching(String currentUserId) {
    return _firestore
        .collection('dogs')
        .where('isAvailableForBreeding', isEqualTo: true)
        .where('ownerId', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DogProfile.fromMap(doc.data()))
            .toList());
  }

  // Search dogs by breed
  Stream<List<DogProfile>> searchDogsByBreed(String breed, String currentUserId) {
    return _firestore
        .collection('dogs')
        .where('breed', isEqualTo: breed)
        .where('isAvailableForBreeding', isEqualTo: true)
        .where('ownerId', isNotEqualTo: currentUserId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DogProfile.fromMap(doc.data()))
            .toList());
  }

  // ============ Match Request Operations ============

  // Create match request
  Future<void> createMatchRequest(MatchRequest matchRequest) async {
    try {
      await _firestore
          .collection('matchRequests')
          .doc(matchRequest.id)
          .set(matchRequest.toMap());
    } catch (e) {
      throw Exception('Failed to create match request: $e');
    }
  }

  // Update match request status
  Future<void> updateMatchRequest(MatchRequest matchRequest) async {
    try {
      await _firestore
          .collection('matchRequests')
          .doc(matchRequest.id)
          .update(matchRequest.toMap());
    } catch (e) {
      throw Exception('Failed to update match request: $e');
    }
  }

  // Get match requests sent by user
  Stream<List<MatchRequest>> getSentMatchRequests(String userId) {
    return _firestore
        .collection('matchRequests')
        .where('requesterId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MatchRequest.fromMap(doc.data()))
            .toList());
  }

  // Get match requests received by user
  Stream<List<MatchRequest>> getReceivedMatchRequests(String userId) {
    return _firestore
        .collection('matchRequests')
        .where('targetOwnerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MatchRequest.fromMap(doc.data()))
            .toList());
  }

  // ============ Review Operations ============

  // Create review
  Future<void> createReview(Review review) async {
    try {
      await _firestore.collection('reviews').doc(review.id).set(review.toMap());
      
      // Update dog's rating
      await _updateDogRating(review.targetDogId);
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  // Get reviews for a dog
  Stream<List<Review>> getDogReviews(String dogId) {
    return _firestore
        .collection('reviews')
        .where('targetDogId', isEqualTo: dogId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data()))
            .toList());
  }

  // Get reviews for an owner's dogs
  Stream<List<Review>> getOwnerReviews(String ownerId) {
    return _firestore
        .collection('reviews')
        .where('targetOwnerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Review.fromMap(doc.data()))
            .toList());
  }

  // Update dog rating after new review
  Future<void> _updateDogRating(String dogId) async {
    try {
      final reviews = await _firestore
          .collection('reviews')
          .where('targetDogId', isEqualTo: dogId)
          .get();

      if (reviews.docs.isNotEmpty) {
        double totalRating = 0;
        for (var doc in reviews.docs) {
          totalRating += (doc.data()['rating'] ?? 0.0);
        }
        
        final averageRating = totalRating / reviews.docs.length;
        
        await _firestore.collection('dogs').doc(dogId).update({
          'rating': averageRating,
          'ratingCount': reviews.docs.length,
        });
      }
    } catch (e) {
      throw Exception('Failed to update dog rating: $e');
    }
  }

  // ============ User Operations ============

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // Get completed matches count for user
  Future<int> getCompletedMatchesCount(String userId) async {
    try {
      final sentMatches = await _firestore
          .collection('matchRequests')
          .where('requesterId', isEqualTo: userId)
          .where('status', isEqualTo: MatchStatus.completed.name)
          .get();
      
      final receivedMatches = await _firestore
          .collection('matchRequests')
          .where('targetOwnerId', isEqualTo: userId)
          .where('status', isEqualTo: MatchStatus.completed.name)
          .get();
      
      return sentMatches.docs.length + receivedMatches.docs.length;
    } catch (e) {
      throw Exception('Failed to get completed matches count: $e');
    }
  }

  // ============ Community Post Operations ============

  // Create community post
  Future<void> createCommunityPost(CommunityPost post) async {
    try {
      await _firestore.collection('communityPosts').doc(post.id).set(post.toMap());
    } catch (e) {
      throw Exception('Failed to create community post: $e');
    }
  }

  // Update community post
  Future<void> updateCommunityPost(CommunityPost post) async {
    try {
      await _firestore.collection('communityPosts').doc(post.id).update(post.toMap());
    } catch (e) {
      throw Exception('Failed to update community post: $e');
    }
  }

  // Delete community post
  Future<void> deleteCommunityPost(String postId) async {
    try {
      // Delete post
      await _firestore.collection('communityPosts').doc(postId).delete();
      
      // Delete associated comments
      final comments = await _firestore
          .collection('postComments')
          .where('postId', isEqualTo: postId)
          .get();
      
      for (var doc in comments.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete community post: $e');
    }
  }

  // Get all community posts
  Stream<List<CommunityPost>> getCommunityPosts() {
    return _firestore
        .collection('communityPosts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityPost.fromMap(doc.data()))
            .toList());
  }

  // Get community posts by category
  Stream<List<CommunityPost>> getCommunityPostsByCategory(PostCategory category) {
    return _firestore
        .collection('communityPosts')
        .where('category', isEqualTo: category.name)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityPost.fromMap(doc.data()))
            .toList());
  }

  // Get user's community posts
  Stream<List<CommunityPost>> getUserCommunityPosts(String userId) {
    return _firestore
        .collection('communityPosts')
        .where('authorId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CommunityPost.fromMap(doc.data()))
            .toList());
  }

  // Like/Unlike post
  Future<void> togglePostLike(String postId, String userId) async {
    try {
      final postRef = _firestore.collection('communityPosts').doc(postId);
      final postDoc = await postRef.get();
      
      if (postDoc.exists) {
        final post = CommunityPost.fromMap(postDoc.data()!);
        
        if (post.likedBy.contains(userId)) {
          // Unlike
          await postRef.update({
            'likes': FieldValue.increment(-1),
            'likedBy': FieldValue.arrayRemove([userId]),
          });
        } else {
          // Like
          await postRef.update({
            'likes': FieldValue.increment(1),
            'likedBy': FieldValue.arrayUnion([userId]),
          });
        }
      }
    } catch (e) {
      throw Exception('Failed to toggle post like: $e');
    }
  }

  // Create comment
  Future<void> createPostComment(PostComment comment) async {
    try {
      await _firestore.collection('postComments').doc(comment.id).set(comment.toMap());
      
      // Increment comment count
      await _firestore.collection('communityPosts').doc(comment.postId).update({
        'commentCount': FieldValue.increment(1),
      });
    } catch (e) {
      throw Exception('Failed to create comment: $e');
    }
  }

  // Get post comments
  Stream<List<PostComment>> getPostComments(String postId) {
    return _firestore
        .collection('postComments')
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PostComment.fromMap(doc.data()))
            .toList());
  }

  // Delete comment
  Future<void> deletePostComment(String commentId, String postId) async {
    try {
      await _firestore.collection('postComments').doc(commentId).delete();
      
      // Decrement comment count
      await _firestore.collection('communityPosts').doc(postId).update({
        'commentCount': FieldValue.increment(-1),
      });
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }
}
