# Firebase Setup Guide for Pawfect Match

This guide will help you configure Firebase for the Pawfect Match application.

## Prerequisites

- Flutter SDK installed
- Firebase CLI installed
- A Google account
- FlutterFire CLI installed

## Step 1: Install FlutterFire CLI

If you haven't installed the FlutterFire CLI yet, run:

```bash
dart pub global activate flutterfire_cli
```

Make sure the pub cache bin directory is in your PATH.

## Step 2: Create a Firebase Project

1. Go to the [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or select an existing project
3. Follow the setup wizard:
   - Enter project name: `pawfect-match` (or your preferred name)
   - Disable Google Analytics (optional for development)
   - Click "Create project"

## Step 3: Configure Firebase for Flutter

Run the following command in your project root directory:

```bash
flutterfire configure
```

This will:

- Prompt you to select your Firebase project
- Ask which platforms to support (select Android, iOS, Web)
- Generate `firebase_options.dart` file automatically
- Configure your Android and iOS projects

### Expected Output

The command will create:

- `lib/firebase_options.dart` - Contains all Firebase configuration
- Update `android/app/google-services.json` (for Android)
- Update `ios/Runner/GoogleService-Info.plist` (for iOS)

## Step 4: Enable Firebase Services

### 4.1 Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click **Get Started**
3. Enable **Email/Password** sign-in method
4. Click **Save**

### 4.2 Enable Cloud Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click **Create database**
3. Select **Start in test mode** (for development)
4. Choose your Cloud Firestore location
5. Click **Enable**

### 4.3 Update Firestore Security Rules

Replace the default rules with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  
    // Dog profiles
    match /dogs/{dogId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.ownerId;
    }
  
    // Match requests
    match /matchRequests/{requestId} {
      allow read: if request.auth != null && 
        (request.auth.uid == resource.data.requesterId || 
         request.auth.uid == resource.data.targetOwnerId);
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.requesterId;
      allow update: if request.auth != null && 
        (request.auth.uid == resource.data.requesterId || 
         request.auth.uid == resource.data.targetOwnerId);
    }
  
    // Reviews
    match /reviews/{reviewId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && 
        request.auth.uid == request.resource.data.reviewerId;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.reviewerId;
    }
  
    // Community posts
    match /communityPosts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.authorId;
    }
  }
}
```

### 4.4 Enable Firebase Storage

1. In Firebase Console, go to **Storage**
2. Click **Get Started**
3. Accept the default security rules (we'll update them)
4. Click **Done**

### 4.5 Update Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /dog_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  
    match /user_images/{userId}/{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## Step 5: Update main.dart

Update your `lib/main.dart` to import the generated configuration:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}
```

## Step 6: Verify Dependencies

Ensure your `pubspec.yaml` has all required Firebase packages:

```yaml
dependencies:
  firebase_core: ^3.8.1
  firebase_auth: ^5.3.3
  cloud_firestore: ^5.5.2
  firebase_storage: ^12.3.6
```

Run:

```bash
flutter pub get
```

## Step 7: Test the Setup

Run the app to verify Firebase is properly configured:

```bash
flutter run
```

If you see any errors, check:

1. `firebase_options.dart` exists in `lib/`
2. All Firebase services are enabled in console
3. Dependencies are properly installed

## Firestore Data Structure

The app uses the following collections:

### users

```
{
  uid: string
  email: string
  name: string
  phoneNumber: string (optional)
  location: string (optional)
  profileImageUrl: string (optional)
  createdAt: timestamp
}
```

### dogs

```
{
  id: string
  ownerId: string
  name: string
  breed: string
  ageInMonths: number
  sex: "male" | "female"
  size: string
  color: string
  temperaments: array<string>
  imageUrls: array<string>
  healthInfo: string (optional)
  rating: number
  ratingCount: number
  isAvailableForBreeding: boolean
  createdAt: timestamp
  lastUpdated: timestamp (optional)
}
```

### matchRequests

```
{
  id: string
  requesterId: string
  requesterDogId: string
  targetOwnerId: string
  targetDogId: string
  status: "pending" | "accepted" | "rejected" | "completed"
  compatibilityScore: number
  message: string (optional)
  createdAt: timestamp
  respondedAt: timestamp (optional)
  completedAt: timestamp (optional)
}
```

### reviews

```
{
  id: string
  reviewerId: string
  reviewerName: string
  targetOwnerId: string
  targetDogId: string
  rating: number
  comment: string
  matchRequestId: string
  createdAt: timestamp
}
```

### communityPosts

```
{
  id: string
  authorId: string
  authorName: string
  title: string
  content: string
  category: string
  imageUrls: array<string>
  likes: number
  commentCount: number
  createdAt: timestamp
}
```

## Common Issues

### Issue: "No Firebase App '[DEFAULT]' has been created"

**Solution**: Make sure `Firebase.initializeApp()` is called before `runApp()`

### Issue: "google-services.json not found"

**Solution**: Run `flutterfire configure` again and select Android platform

### Issue: Permission denied errors

**Solution**: Check Firestore and Storage security rules are properly configured

### Issue: Dependencies conflict

**Solution**: Run `flutter pub upgrade` to resolve version conflicts

## Next Steps

After Firebase is configured:

1. Run the app and test user registration
2. Create a dog profile to test image uploads
3. Test the matching system
4. Review the Firebase Console to see data being stored

## Support

For more information:

- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Console](https://console.firebase.google.com/)
- [Firebase Support](https://firebase.google.com/support)
