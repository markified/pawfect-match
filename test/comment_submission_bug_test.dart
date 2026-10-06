import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pawfect/screens/community/post_detail_screen.dart';
import 'package:pawfect/models/community_post.dart';
import 'package:pawfect/models/user_model.dart';
import 'package:pawfect/providers/auth_provider.dart';
import 'package:pawfect/providers/community_provider.dart';

void main() {
  group('Bug Condition Exploration - Comment Submission', () {
    late MockAuthProvider mockAuthProvider;
    late MockCommunityProvider mockCommunityProvider;
    late CommunityPost testPost;

    setUp(() {
      mockAuthProvider = MockAuthProvider();
      mockCommunityProvider = MockCommunityProvider();
      
      testPost = CommunityPost(
        id: 'test_post_123',
        authorId: 'author_456',
        authorName: 'Test Author',
        title: 'Test Post',
        content: 'This is a test post',
        category: PostCategory.general,
        createdAt: DateTime.now(),
      );
    });

    testWidgets(
      'Property 1.1: Comment submission with error should display SnackBar with error message',
      (WidgetTester tester) async {
        
        mockAuthProvider.setMockUser(UserModel(
          uid: 'user_789',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now(),
        ));
        
        
        mockCommunityProvider.shouldThrowError = true;
        mockCommunityProvider.errorMessage = 'Network error: Unable to reach Firestore';

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ChangeNotifierProvider<CommunityProvider>.value(value: mockCommunityProvider),
            ],
            child: MaterialApp(
              home: PostDetailScreen(post: testPost),
            ),
          ),
        );
        await tester.pumpAndSettle();

        
        final commentTextField = find.byType(TextField);
        await tester.enterText(commentTextField, 'Great post!');
        await tester.pumpAndSettle();

        
        final sendButton = find.byIcon(Icons.send);
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        
        
        expect(
          find.text('Failed to post comment: Network error: Unable to reach Firestore'),
          findsOneWidget,
          reason: 'COUNTEREXAMPLE: No error SnackBar displayed - missing try-catch and user feedback',
        );
        
        
        
        expect(
          find.text('Great post!'),
          findsOneWidget,
          reason: 'COUNTEREXAMPLE: TextField incorrectly cleared on error',
        );
      },
    );

    testWidgets(
      'Property 1.2: Comment submission should show loading state and disable button',
      (WidgetTester tester) async {
        
        mockAuthProvider.setMockUser(UserModel(
          uid: 'user_789',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now(),
        ));
        
        
        mockCommunityProvider.simulateDelay = const Duration(seconds: 3);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ChangeNotifierProvider<CommunityProvider>.value(value: mockCommunityProvider),
            ],
            child: MaterialApp(
              home: PostDetailScreen(post: testPost),
            ),
          ),
        );
        await tester.pumpAndSettle();

        
        final commentTextField = find.byType(TextField);
        await tester.enterText(commentTextField, 'Great post!');
        await tester.pumpAndSettle();

        
        final sendButton = find.byIcon(Icons.send);
        await tester.tap(sendButton);
        await tester.pump(); 

        
        
        expect(
          find.byType(CircularProgressIndicator),
          findsOneWidget,
          reason: 'COUNTEREXAMPLE: No loading indicator - missing _isSubmitting state',
        );

        
        
        final iconButton = tester.widget<IconButton>(find.ancestor(
          of: find.byIcon(Icons.send),
          matching: find.byType(IconButton),
        ));
        expect(
          iconButton.onPressed,
          isNull,
          reason: 'COUNTEREXAMPLE: Button not disabled during submission - allows duplicates',
        );

        
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Property 1.3: Comment submission without authentication should display auth error',
      (WidgetTester tester) async {
        
        mockAuthProvider.setMockUser(null);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ChangeNotifierProvider<CommunityProvider>.value(value: mockCommunityProvider),
            ],
            child: MaterialApp(
              home: PostDetailScreen(post: testPost),
            ),
          ),
        );
        await tester.pumpAndSettle();

        
        final commentTextField = find.byType(TextField);
        await tester.enterText(commentTextField, 'Great post!');
        await tester.pumpAndSettle();

        
        final sendButton = find.byIcon(Icons.send);
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        
        
        expect(
          find.text('Please log in to comment'),
          findsOneWidget,
          reason: 'COUNTEREXAMPLE: No auth error message - missing user feedback for null user',
        );
      },
    );

    testWidgets(
      'Property 1.4: Rapid button taps should not create duplicate submissions',
      (WidgetTester tester) async {
        
        mockAuthProvider.setMockUser(UserModel(
          uid: 'user_789',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now(),
        ));
        
        
        mockCommunityProvider.submissionCount = 0;
        mockCommunityProvider.simulateDelay = const Duration(milliseconds: 500);

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ChangeNotifierProvider<CommunityProvider>.value(value: mockCommunityProvider),
            ],
            child: MaterialApp(
              home: PostDetailScreen(post: testPost),
            ),
          ),
        );
        await tester.pumpAndSettle();

        
        final commentTextField = find.byType(TextField);
        await tester.enterText(commentTextField, 'Great post!');
        await tester.pumpAndSettle();

        
        final sendButton = find.byIcon(Icons.send);
        await tester.tap(sendButton);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(sendButton);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(sendButton);
        await tester.pump(const Duration(milliseconds: 50));

        
        await tester.pumpAndSettle();

        
        
        expect(
          mockCommunityProvider.submissionCount,
          equals(1),
          reason: 'COUNTEREXAMPLE: Multiple submissions (${mockCommunityProvider.submissionCount}) - missing button disable logic',
        );
      },
    );

    testWidgets(
      'Property 1.5: Successful comment submission should clear TextField and dismiss keyboard',
      (WidgetTester tester) async {
        
        mockAuthProvider.setMockUser(UserModel(
          uid: 'user_789',
          email: 'test@example.com',
          name: 'Test User',
          createdAt: DateTime.now(),
        ));
        
        mockCommunityProvider.shouldThrowError = false;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              ChangeNotifierProvider<AuthProvider>.value(value: mockAuthProvider),
              ChangeNotifierProvider<CommunityProvider>.value(value: mockCommunityProvider),
            ],
            child: MaterialApp(
              home: PostDetailScreen(post: testPost),
            ),
          ),
        );
        await tester.pumpAndSettle();

        
        final commentTextField = find.byType(TextField);
        await tester.enterText(commentTextField, 'Great post!');
        await tester.pumpAndSettle();

        
        await tester.tap(commentTextField);
        await tester.pumpAndSettle();

        
        final sendButton = find.byIcon(Icons.send);
        await tester.tap(sendButton);
        await tester.pumpAndSettle();

        
        final textField = tester.widget<TextField>(commentTextField);
        expect(
          textField.controller?.text ?? '',
          isEmpty,
          reason: 'TextField should be cleared after successful submission',
        );

        
        expect(
          FocusManager.instance.primaryFocus?.hasFocus ?? false,
          isFalse,
          reason: 'Keyboard should be dismissed after successful submission',
        );
      },
    );
  });
}


class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  UserModel? _currentUser;
  final bool _isLoading = false;
  String? _errorMessage;
  
  @override
  UserModel? get currentUser => _currentUser;
  
  @override
  bool get isLoading => _isLoading;
  
  @override
  String? get errorMessage => _errorMessage;
  
  @override
  bool get isAuthenticated => _currentUser != null;
  
  void setMockUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }
  
  @override
  Future<bool> signIn({required String email, required String password}) async => false;
  
  @override
  Future<bool> signUp({
    required String email,
    required String password,
    required String name,
    String? phoneNumber,
    String? location,
  }) async => false;
  
  @override
  Future<void> signOut() async {}
  
  @override
  Future<void> updateUserProfile(UserModel user) async {}
  
  @override
  Future<void> loadUserData(String uid) async {}
  
  @override
  Future<bool> resetPassword(String email) async => false;
  
  @override
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}


class MockCommunityProvider extends ChangeNotifier implements CommunityProvider {
  bool shouldThrowError = false;
  String _errorMessage = 'Mock error';
  Duration? simulateDelay;
  int submissionCount = 0;
  
  set errorMessage(String message) {
    _errorMessage = message;
  }
  
  @override
  Future<bool> createComment(dynamic comment) async {
    submissionCount++;
    
    if (simulateDelay != null) {
      await Future.delayed(simulateDelay!);
    }
    
    if (shouldThrowError) {
      throw Exception(_errorMessage);
    }
    
    return true;
  }
  
  
  @override
  List<CommunityPost> get posts => [];
  
  @override
  PostCategory? get selectedCategory => null;
  
  @override
  bool get isLoading => false;
  
  @override
  String? get errorMessage => shouldThrowError ? _errorMessage : null;
  
  @override
  void listenToCommunityPosts() {}
  
  @override
  void filterByCategory(PostCategory? category) {}
  
  @override
  Future<bool> createPost(CommunityPost post) async => false;
  
  @override
  Future<bool> updatePost(CommunityPost post) async => false;
  
  @override
  Future<bool> deletePost(String postId) async => false;
  
  @override
  Future<void> toggleLike(String postId, String userId) async {}
  
  @override
  void clearError() {}
}
