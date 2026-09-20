# 🏗️ Pawfect Match - Architecture Documentation

Complete technical architecture and code structure documentation.

---

## Table of Contents
1. [Architecture Overview](#architecture-overview)
2. [Project Structure](#project-structure)
3. [Design Patterns](#design-patterns)
4. [State Management](#state-management)
5. [Firebase Integration](#firebase-integration)
6. [Data Models](#data-models)
7. [Services Layer](#services-layer)
8. [UI Components](#ui-components)
9. [Navigation](#navigation)
10. [Error Handling](#error-handling)

---

## 1. Architecture Overview

### Architectural Style
**Clean Architecture with Feature-Based Organization**

```
┌─────────────────────────────────────────────┐
│             Presentation Layer              │
│  (Screens, Widgets, UI Components)          │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│           State Management Layer            │
│     (Providers - Business Logic)            │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│             Services Layer                  │
│  (Firebase Services, API Calls)             │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│              Data Layer                     │
│    (Models, DTOs, Serialization)            │
└─────────────────────────────────────────────┘
```

### Key Principles
- **Separation of Concerns:** Each layer has distinct responsibilities
- **Dependency Inversion:** Higher layers don't depend on lower layers
- **Single Responsibility:** Each class has one reason to change
- **DRY (Don't Repeat Yourself):** Reusable components and services
- **SOLID Principles:** Applied throughout the codebase

---

## 2. Project Structure

```
lib/
├── main.dart                    # App entry point, Firebase initialization
├── firebase_options.dart        # Generated Firebase configuration
│
├── models/                      # Data models and DTOs
│   ├── user.dart               # User model
│   ├── dog.dart                # Dog model
│   ├── match_request.dart      # Match request model
│   ├── review.dart             # Review model
│   ├── community_post.dart     # Community post and comment models
│   └── notification.dart       # Notification model
│
├── providers/                   # State management (Provider pattern)
│   ├── auth_provider.dart      # Authentication state
│   ├── dog_provider.dart       # Dog management state
│   ├── match_provider.dart     # Matching system state
│   └── community_provider.dart # Community features state
│
├── services/                    # Business logic and Firebase integration
│   ├── auth_service.dart       # Authentication operations
│   ├── firestore_service.dart  # Firestore database operations
│   └── storage_service.dart    # Firebase Storage operations
│
├── screens/                     # UI screens organized by feature
│   ├── auth/
│   │   ├── login_screen.dart   # Login and registration
│   │   └── splash_screen.dart  # App splash (future)
│   │
│   ├── home/
│   │   ├── home_screen.dart    # Main navigation container
│   │   └── dashboard_tab.dart  # Dashboard/feed
│   │
│   ├── dogs/
│   │   ├── dogs_list_screen.dart    # User's dogs list
│   │   ├── add_edit_dog_screen.dart # Add/Edit dog form
│   │   └── dog_detail_screen.dart   # Dog details view
│   │
│   ├── match/
│   │   ├── browse_matches_screen.dart # Browse available dogs
│   │   └── match_detail_screen.dart   # Match details
│   │
│   ├── requests/
│   │   ├── match_requests_screen.dart # Sent/Received requests
│   │   └── request_detail_screen.dart # Request details
│   │
│   ├── community/
│   │   ├── community_screen.dart      # Community feed
│   │   ├── create_post_screen.dart    # Create new post
│   │   └── post_detail_screen.dart    # Post details and comments
│   │
│   ├── reviews/
│   │   ├── completed_matches_screen.dart # Completed matches list
│   │   └── submit_review_screen.dart     # Submit review form
│   │
│   └── profile/
│       ├── profile_screen.dart        # User profile view
│       └── edit_profile_screen.dart   # Edit profile form
│
├── widgets/                     # Reusable UI components
│   ├── dog_card.dart           # Dog display card
│   ├── match_request_card.dart # Match request card
│   ├── community_post_card.dart # Community post card
│   ├── review_card.dart        # Review display card
│   └── custom_button.dart      # Custom styled button
│
└── utils/                       # Utilities and constants
    ├── constants.dart          # App constants and colors
    ├── validators.dart         # Form validation functions
    └── helpers.dart            # Helper functions
```

---

## 3. Design Patterns

### 3.1 Provider Pattern (State Management)
**Pattern:** Observer/Pub-Sub
**Implementation:** `provider` package

**Why Provider?**
- Simple and lightweight
- Built-in to Flutter ecosystem
- Efficient rebuild management
- Easy to test
- Suitable for app complexity level

**Example:**
```dart
class DogProvider extends ChangeNotifier {
  List<Dog> _dogs = [];
  bool _isLoading = false;
  
  List<Dog> get dogs => _dogs;
  bool get isLoading => _isLoading;
  
  Future<void> fetchDogs(String userId) async {
    _isLoading = true;
    notifyListeners();
    
    _dogs = await FirestoreService().getUserDogs(userId);
    
    _isLoading = false;
    notifyListeners();
  }
}
```

**Usage in UI:**
```dart
Consumer<DogProvider>(
  builder: (context, dogProvider, child) {
    if (dogProvider.isLoading) {
      return CircularProgressIndicator();
    }
    return ListView.builder(
      itemCount: dogProvider.dogs.length,
      itemBuilder: (context, index) {
        return DogCard(dog: dogProvider.dogs[index]);
      },
    );
  },
)
```

---

### 3.2 Service Layer Pattern
**Pattern:** Facade/Service Layer
**Purpose:** Abstract Firebase operations

**Benefits:**
- Centralized data access
- Easy to mock for testing
- Business logic separation
- Consistent error handling

**Example:**
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Single responsibility: Dog operations
  Future<Dog> getDog(String dogId) async {
    DocumentSnapshot doc = await _firestore
        .collection('dogs')
        .doc(dogId)
        .get();
    return Dog.fromFirestore(doc);
  }
  
  Stream<List<Dog>> getAvailableDogsStream() {
    return _firestore
        .collection('dogs')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Dog.fromFirestore(doc))
            .toList());
  }
}
```

---

### 3.3 Repository Pattern (Implicit)
**Pattern:** Data Access Layer
**Implementation:** Through Services

**Structure:**
```
UI Layer → Provider → Service → Firebase
```

**Separation:**
- UI doesn't know about Firebase
- Providers don't know about Firestore details
- Services handle all data operations
- Models handle serialization

---

### 3.4 Factory Pattern
**Pattern:** Object Creation
**Usage:** Model deserialization

**Example:**
```dart
class Dog {
  final String id;
  final String name;
  final String breed;
  
  // Factory constructor for Firestore
  factory Dog.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Dog(
      id: doc.id,
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      // ... other fields
    );
  }
  
  // Factory constructor for JSON
  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      id: json['id'],
      name: json['name'],
      breed: json['breed'],
    );
  }
}
```

---

### 3.5 Builder Pattern (Flutter Widgets)
**Pattern:** UI Construction
**Usage:** Screen building

**Example:**
```dart
class DogDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildBasicInfo(),
          _buildTemperament(),
          _buildHealthInfo(),
          _buildOwnerInfo(),
          _buildReviews(),
        ],
      ),
    );
  }
  
  Widget _buildAppBar() { /* ... */ }
  Widget _buildBasicInfo() { /* ... */ }
}
```

---

## 4. State Management

### 4.1 Provider Architecture

**Provider Hierarchy:**
```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
    ChangeNotifierProvider(create: (_) => DogProvider()),
    ChangeNotifierProvider(create: (_) => MatchProvider()),
    ChangeNotifierProvider(create: (_) => CommunityProvider()),
  ],
  child: MaterialApp(/* ... */),
)
```

### 4.2 State Types

**Local State:**
- Widget-specific state
- Form input values
- UI toggles (expanded/collapsed)
- Managed with `StatefulWidget`

**Provider State:**
- App-wide data
- User authentication
- Dog lists
- Match requests
- Community posts

**Stream State:**
- Real-time Firebase data
- Firestore snapshots
- Managed with `StreamBuilder`

---

### 4.3 Provider Examples

#### AuthProvider
```dart
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  UserModel? _userProfile;
  
  bool get isAuthenticated => _user != null;
  UserModel? get userProfile => _userProfile;
  
  Future<void> signIn(String email, String password) async {
    _user = await _authService.signIn(email, password);
    if (_user != null) {
      _userProfile = await _authService.getUserProfile(_user!.uid);
    }
    notifyListeners();
  }
  
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _userProfile = null;
    notifyListeners();
  }
}
```

#### DogProvider
```dart
class DogProvider extends ChangeNotifier {
  List<Dog> _myDogs = [];
  List<Dog> _availableDogs = [];
  bool _isLoading = false;
  String? _error;
  
  List<Dog> get myDogs => _myDogs;
  List<Dog> get availableDogs => _availableDogs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  Future<void> addDog(Dog dog) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      await FirestoreService().addDog(dog);
      await fetchMyDogs(dog.ownerId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 5. Firebase Integration

### 5.1 Firebase Services Used

**Firebase Authentication:**
- Email/Password authentication
- User session management
- Automatic token refresh

**Cloud Firestore:**
- User profiles
- Dog profiles
- Match requests
- Reviews
- Community posts
- Notifications

**Firebase Storage:**
- Profile images
- Dog photos
- Community post images

**Future Services:**
- Cloud Messaging (Push notifications)
- Cloud Functions (Backend logic)
- Analytics (Usage tracking)

---

### 5.2 Firestore Data Structure

**Collections:**
```
/users/{userId}
  - name, email, phone, location
  - profileImageUrl, isVerified
  - stats: { totalDogs, completedMatches, averageRating }
  - createdAt

/dogs/{dogId}
  - ownerId, name, breed, age, sex, size, color
  - temperament[], healthInfo
  - imageUrls[], isAvailable
  - createdAt, updatedAt

/match_requests/{requestId}
  - requesterId, receiverId
  - requesterDogId, receiverDogId
  - status, message
  - createdAt, updatedAt, completedAt

/reviews/{reviewId}
  - reviewerId, reviewedUserId
  - matchRequestId, rating, comment
  - createdAt

/community_posts/{postId}
  - authorId, title, content, category
  - imageUrls[], likes[], commentCount
  - createdAt
  
  /community_posts/{postId}/comments/{commentId}
    - authorId, content
    - createdAt

/notifications/{notificationId}
  - userId, type, title, message
  - isRead, createdAt
  - relatedId, relatedData
```

---

### 5.3 Firestore Operations

**CRUD Operations:**
```dart
// Create
Future<void> addDog(Dog dog) async {
  await _firestore.collection('dogs').add(dog.toMap());
}

// Read (single)
Future<Dog> getDog(String dogId) async {
  DocumentSnapshot doc = await _firestore
      .collection('dogs')
      .doc(dogId)
      .get();
  return Dog.fromFirestore(doc);
}

// Read (stream)
Stream<List<Dog>> getUserDogsStream(String userId) {
  return _firestore
      .collection('dogs')
      .where('ownerId', isEqualTo: userId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Dog.fromFirestore(doc))
          .toList());
}

// Update
Future<void> updateDog(String dogId, Map<String, dynamic> data) async {
  await _firestore.collection('dogs').doc(dogId).update(data);
}

// Delete
Future<void> deleteDog(String dogId) async {
  await _firestore.collection('dogs').doc(dogId).delete();
}
```

**Complex Queries:**
```dart
// Get available dogs excluding user's own
Stream<List<Dog>> getAvailableDogsExcludingUser(String userId) {
  return _firestore
      .collection('dogs')
      .where('isAvailable', isEqualTo: true)
      .where('ownerId', isNotEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Dog.fromFirestore(doc))
          .toList());
}

// Get user reviews
Stream<List<Review>> getUserReviewsStream(String userId) {
  return _firestore
      .collection('reviews')
      .where('reviewedUserId', isEqualTo: userId)
      .orderBy('createdAt', descending: true)
      .limit(10)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Review.fromFirestore(doc))
          .toList());
}
```

---

### 5.4 Storage Operations

**Upload Flow:**
```dart
Future<String> uploadDogImage(String userId, String dogId, File image) async {
  // 1. Create unique filename
  String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
  
  // 2. Create reference
  Reference ref = _storage
      .ref()
      .child('dog_images')
      .child(userId)
      .child(dogId)
      .child(fileName);
  
  // 3. Upload file
  UploadTask uploadTask = ref.putFile(image);
  
  // 4. Get download URL
  TaskSnapshot snapshot = await uploadTask;
  String downloadUrl = await snapshot.ref.getDownloadURL();
  
  return downloadUrl;
}
```

**Delete Flow:**
```dart
Future<void> deleteDogImages(List<String> imageUrls) async {
  for (String url in imageUrls) {
    try {
      Reference ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
    }
  }
}
```

---

## 6. Data Models

### 6.1 Model Structure

**Base Model Pattern:**
```dart
class Dog {
  final String id;
  final String ownerId;
  final String name;
  final String breed;
  // ... other fields
  
  Dog({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.breed,
    // ... other fields
  });
  
  // Factory constructors for deserialization
  factory Dog.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Dog(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      name: data['name'] ?? '',
      breed: data['breed'] ?? '',
      // ... other fields with null safety
    );
  }
  
  factory Dog.fromJson(Map<String, dynamic> json) {
    return Dog(
      id: json['id'],
      ownerId: json['ownerId'],
      name: json['name'],
      breed: json['breed'],
      // ... other fields
    );
  }
  
  // Serialization methods
  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'name': name,
      'breed': breed,
      // ... other fields
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ownerId': ownerId,
      'name': name,
      'breed': breed,
      // ... other fields
    };
  }
  
  // CopyWith for immutability
  Dog copyWith({
    String? id,
    String? name,
    String? breed,
    // ... other fields
  }) {
    return Dog(
      id: id ?? this.id,
      name: name ?? this.name,
      breed: breed ?? this.breed,
      // ... other fields
    );
  }
}
```

---

### 6.2 Model Relationships

**User → Dogs (One-to-Many)**
```dart
class User {
  final String id;
  // ... fields
  
  Future<List<Dog>> getDogs() async {
    return await FirestoreService().getUserDogs(id);
  }
}
```

**MatchRequest → Users + Dogs (Many-to-One)**
```dart
class MatchRequest {
  final String requesterId;
  final String receiverId;
  final String requesterDogId;
  final String receiverDogId;
  
  Future<User> getRequester() async {
    return await FirestoreService().getUser(requesterId);
  }
  
  Future<Dog> getRequesterDog() async {
    return await FirestoreService().getDog(requesterDogId);
  }
}
```

---

## 7. Services Layer

### 7.1 AuthService

**Responsibilities:**
- User authentication
- User profile management
- Session handling

**Key Methods:**
```dart
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestore = FirestoreService();
  
  // Get current user
  User? get currentUser => _auth.currentUser;
  
  // Authentication stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  // Sign in
  Future<User?> signIn(String email, String password) async {
    UserCredential result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }
  
  // Register
  Future<User?> register(String name, String email, String password) async {
    UserCredential result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (result.user != null) {
      await _firestore.createUserProfile(result.user!.uid, name, email);
    }
    
    return result.user;
  }
  
  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
```

---

### 7.2 FirestoreService

**Responsibilities:**
- All Firestore database operations
- CRUD for all collections
- Complex queries
- Compatibility calculations

**Organization:**
```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // User operations
  Future<void> createUserProfile(/*...*/);
  Future<UserModel> getUserProfile(String userId);
  Future<void> updateUserProfile(/*...*/);
  
  // Dog operations
  Future<void> addDog(Dog dog);
  Future<Dog> getDog(String dogId);
  Stream<List<Dog>> getUserDogsStream(String userId);
  Future<void> updateDog(/*...*/);
  Future<void> deleteDog(String dogId);
  
  // Match request operations
  Future<void> sendMatchRequest(/*...*/);
  Stream<List<MatchRequest>> getReceivedRequestsStream(String userId);
  Stream<List<MatchRequest>> getSentRequestsStream(String userId);
  Future<void> updateRequestStatus(/*...*/);
  
  // Review operations
  Future<void> submitReview(/*...*/);
  Stream<List<Review>> getUserReviewsStream(String userId);
  
  // Community operations
  Future<void> createPost(/*...*/);
  Stream<List<CommunityPost>> getPostsStream();
  Future<void> likePost(/*...*/);
  Future<void> addComment(/*...*/);
  
  // Utility operations
  double calculateCompatibility(Dog dog1, Dog dog2);
  Future<void> updateUserStats(String userId);
}
```

---

### 7.3 StorageService

**Responsibilities:**
- File uploads
- File deletion
- URL generation

**Key Methods:**
```dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Upload profile image
  Future<String> uploadProfileImage(String userId, File image);
  
  // Upload dog images
  Future<List<String>> uploadDogImages(
    String userId,
    String dogId,
    List<File> images,
  );
  
  // Upload community image
  Future<String> uploadCommunityImage(
    String userId,
    String postId,
    File image,
  );
  
  // Delete image
  Future<void> deleteImage(String imageUrl);
  
  // Delete multiple images
  Future<void> deleteImages(List<String> imageUrls);
}
```

---

## 8. UI Components

### 8.1 Screen Structure

**Standard Screen Layout:**
```dart
class ExampleScreen extends StatefulWidget {
  @override
  _ExampleScreenState createState() => _ExampleScreenState();
}

class _ExampleScreenState extends State<ExampleScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Example')),
      body: Consumer<ExampleProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (provider.error != null) {
            return Center(child: Text('Error: ${provider.error}'));
          }
          
          return _buildContent(provider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () { /* action */ },
        child: Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildContent(ExampleProvider provider) {
    return ListView.builder(
      itemCount: provider.items.length,
      itemBuilder: (context, index) {
        return ItemCard(item: provider.items[index]);
      },
    );
  }
}
```

---

### 8.2 Reusable Widgets

**Widget Organization:**
```
widgets/
├── cards/
│   ├── dog_card.dart
│   ├── match_request_card.dart
│   ├── community_post_card.dart
│   └── review_card.dart
│
├── inputs/
│   ├── custom_text_field.dart
│   ├── image_picker_widget.dart
│   └── dropdown_selector.dart
│
├── buttons/
│   ├── primary_button.dart
│   ├── secondary_button.dart
│   └── icon_button_widget.dart
│
└── common/
    ├── loading_indicator.dart
    ├── empty_state.dart
    └── error_message.dart
```

**Example Reusable Widget:**
```dart
class DogCard extends StatelessWidget {
  final Dog dog;
  final VoidCallback? onTap;
  final bool showCompatibility;
  final double? compatibilityScore;
  
  const DogCard({
    required this.dog,
    this.onTap,
    this.showCompatibility = false,
    this.compatibilityScore,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            _buildImage(),
            _buildInfo(),
            if (showCompatibility) _buildCompatibility(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildImage() { /* ... */ }
  Widget _buildInfo() { /* ... */ }
  Widget _buildCompatibility() { /* ... */ }
}
```

---

## 9. Navigation

### 9.1 Navigation Structure

**Main Navigation (Bottom Nav):**
```
Home Tab
  ├─ Dashboard
  └─ Browse Matches
  
My Dogs Tab
  ├─ Dogs List
  ├─ Add Dog
  └─ Dog Detail
  
Match Tab
  ├─ Match Requests
  └─ Request Detail
  
Community Tab
  ├─ Community Feed
  ├─ Create Post
  └─ Post Detail
  
Profile Tab
  ├─ Profile View
  ├─ Edit Profile
  ├─ Completed Matches
  └─ Submit Review
```

### 9.2 Navigation Implementation

**Named Routes (Future Enhancement):**
```dart
MaterialApp(
  routes: {
    '/': (context) => HomeScreen(),
    '/dog-detail': (context) => DogDetailScreen(),
    '/add-dog': (context) => AddEditDogScreen(),
    '/profile': (context) => ProfileScreen(),
    // ... other routes
  },
)
```

**Current Navigation (Direct):**
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => DogDetailScreen(dog: dog),
  ),
);
```

---

## 10. Error Handling

### 10.1 Error Handling Strategy

**Levels:**
1. **UI Level:** Display user-friendly messages
2. **Provider Level:** Catch and store errors
3. **Service Level:** Throw specific exceptions
4. **Firebase Level:** Handle network/auth errors

**Example:**
```dart
// Service Level
Future<Dog> getDog(String dogId) async {
  try {
    DocumentSnapshot doc = await _firestore
        .collection('dogs')
        .doc(dogId)
        .get();
    
    if (!doc.exists) {
      throw Exception('Dog not found');
    }
    
    return Dog.fromFirestore(doc);
  } on FirebaseException catch (e) {
    throw Exception('Firebase error: ${e.message}');
  } catch (e) {
    throw Exception('Unknown error: $e');
  }
}

// Provider Level
Future<void> fetchDog(String dogId) async {
  try {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    _currentDog = await FirestoreService().getDog(dogId);
    
    _isLoading = false;
    notifyListeners();
  } catch (e) {
    _error = e.toString();
    _isLoading = false;
    notifyListeners();
  }
}

// UI Level
Consumer<DogProvider>(
  builder: (context, provider, child) {
    if (provider.isLoading) {
      return CircularProgressIndicator();
    }
    
    if (provider.error != null) {
      return ErrorMessage(
        message: provider.error!,
        onRetry: () => provider.fetchDog(dogId),
      );
    }
    
    return DogDetails(dog: provider.currentDog);
  },
)
```

---

## Performance Considerations

### Optimization Strategies

**1. Image Optimization:**
- Compress images before upload
- Use cached network images
- Implement lazy loading

**2. Data Pagination:**
- Limit query results
- Load more on scroll
- Implement infinite scroll

**3. Stream Management:**
- Cancel streams when not needed
- Use StreamBuilder efficiently
- Avoid unnecessary rebuilds

**4. Provider Optimization:**
- Use `Consumer` with builder pattern
- Implement `select` for specific fields
- Avoid provider in build method

**5. Firebase Optimization:**
- Implement offline persistence
- Use batch writes when possible
- Optimize security rules

---

## Testing Strategy

### Test Pyramid

```
         /\
        /E2E\           <- End-to-End (Few)
       /------\
      /Widget \         <- Widget Tests (More)
     /--------\
    /  Unit    \       <- Unit Tests (Most)
   /------------\
```

**Unit Tests:**
- Model serialization
- Utility functions
- Compatibility algorithm
- Validators

**Widget Tests:**
- Screen rendering
- User interactions
- Provider integration
- Navigation

**Integration Tests:**
- Firebase operations
- Full user flows
- Cross-feature interactions

---

## Security Considerations

### Data Protection

**Authentication:**
- Firebase Auth handles tokens
- Automatic session refresh
- Secure password storage

**Authorization:**
- Firestore Security Rules
- User-owned data access
- Document-level permissions

**Data Validation:**
- Client-side validation
- Server-side rules
- Input sanitization

**Image Upload:**
- File type validation
- File size limits
- User-specific paths

---

## Scalability

### Future Scaling Strategies

**Horizontal Scaling:**
- Firebase auto-scales
- No server management
- Pay-as-you-grow

**Code Scalability:**
- Modular architecture
- Easy feature addition
- Clean separation of concerns

**Database Scalability:**
- Firestore handles large datasets
- Automatic indexing
- Distributed architecture

**Storage Scalability:**
- Firebase Storage auto-scales
- CDN for image delivery
- Optimized bandwidth usage

---

## Deployment Architecture

### Development Environment
```
Local Machine
  ├─ Flutter SDK
  ├─ Firebase Emulators (optional)
  └─ VS Code / Android Studio
```

### Production Environment
```
Firebase Cloud
  ├─ Authentication
  ├─ Cloud Firestore
  ├─ Cloud Storage
  ├─ Cloud Functions (future)
  └─ Cloud Messaging (future)
```

### CI/CD Pipeline (Future)
```
GitHub → Actions → Build → Test → Deploy
```

---

## Documentation Standards

**Code Documentation:**
- Inline comments for complex logic
- Class and method documentation
- README for each major feature

**API Documentation:**
- Service method descriptions
- Parameter explanations
- Return value documentation
- Example usage

**Architecture Documentation:**
- This file (ARCHITECTURE.md)
- Diagram updates as needed
- Decision records

---

**Architecture Version:** 1.0  
**Last Updated:** January 2025  
**Maintainers:** Development Team
