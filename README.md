# 🐾 Pawfect Match

**A comprehensive dog breeding match platform built with Flutter and Firebase**

![Flutter](https://img.shields.io/badge/Flutter-3.0+-blue.svg)
![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)
![License](https://img.shields.io/badge/License-MIT-green.svg)

---

## 📖 Overview

Pawfect Match is a mobile application designed to connect dog breeders with compatible breeding partners. The app uses an intelligent compatibility algorithm to match dogs based on breed, age, sex, and temperament, ensuring successful breeding outcomes.

### Key Highlights
- 🎯 **Smart Matching Algorithm** - 35% breed + 25% age + 15% sex + 25% temperament compatibility
- 🔥 **Firebase Backend** - Real-time data synchronization and cloud storage
- 💬 **Community Features** - Share experiences, tips, and success stories
- ⭐ **Review System** - Build trust through verified breeding partner reviews
- 📱 **Cross-Platform** - Android, iOS, and Web support

---

## ✨ Features

### 🔐 Authentication & User Management
- Email/password registration and login
- Profile management with photo upload
- Verified breeder badges
- User reputation and statistics

### 🐕 Dog Profile Management
- Register multiple dogs with detailed information
- Upload multiple photos per dog
- Track health records and temperament
- Mark availability for breeding

### 💘 Smart Matching System
- Browse available dogs with compatibility scores
- Advanced filtering (breed, age, location, size)
- Send and receive match requests
- Accept/decline breeding proposals
- In-app messaging (ready for implementation)

### 👥 Community Hub
- Create posts with categories:
  - Breeding Tips
  - Success Stories
  - Questions
  - Events
  - General Discussion
- Upload photos to posts
- Like and comment system
- Real-time updates

### ⭐ Reviews & Ratings
- Rate breeding partners (1-5 stars)
- Write detailed reviews
- View user reputation
- Verified reviews tied to completed matches

### 🔔 Notifications
- Match request alerts
- New message notifications
- Community post interactions
- Profile view notifications

---

## 🏗️ Architecture

### Tech Stack
- **Frontend:** Flutter 3.0+
- **Backend:** Firebase (Auth, Firestore, Storage)
- **State Management:** Provider pattern
- **Architecture:** Clean Architecture with separation of concerns

### Project Structure
```
lib/
├── models/          # Data models (User, Dog, MatchRequest, etc.)
├── providers/       # State management (Provider pattern)
├── screens/         # UI screens organized by feature
│   ├── auth/        # Login, Register
│   ├── dogs/        # Dog list, Add/Edit dog, Dog detail
│   ├── home/        # Dashboard, Home screen
│   ├── match/       # Browse matches, Match detail
│   ├── requests/    # Match requests, Request detail
│   ├── community/   # Community feed, Create post, Post detail
│   ├── reviews/     # Completed matches, Submit review
│   └── profile/     # Profile screen, Edit profile
├── services/        # Backend services (Firebase integration)
│   ├── auth_service.dart
│   ├── firestore_service.dart
│   └── storage_service.dart
├── utils/           # Utilities and constants
└── widgets/         # Reusable UI components
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.0 or higher
- Dart SDK 2.17 or higher
- Firebase CLI
- FlutterFire CLI
- Android Studio / VS Code
- Active Firebase project

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd pawfect
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure Firebase**

The Firebase configuration is already set up for project `pawfect-match-a4d14`. If you need to reconfigure:

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase
flutterfire configure --project=pawfect-match-a4d14
```

4. **Enable Firebase Services**

Follow the **QUICK_START.md** guide to:
- Enable Authentication (Email/Password)
- Enable Firestore Database
- Enable Storage
- Set security rules

5. **Run the app**
```bash
flutter run
```

---

## 📚 Documentation

- **[QUICK_START.md](QUICK_START.md)** - Get the app running in 5 minutes
- **[FEATURES.md](FEATURES.md)** - Detailed feature descriptions
- **[ARCHITECTURE.md](ARCHITECTURE.md)** - Code structure and design patterns
- **[USER_GUIDE.md](USER_GUIDE.md)** - End-user documentation
- **[FIREBASE_SETUP.md](FIREBASE_SETUP.md)** - Detailed Firebase configuration

---

## 🧪 Testing

### Manual Testing Checklist

**Authentication**
- [ ] Register new account
- [ ] Login with email/password
- [ ] Logout
- [ ] Profile photo upload

**Dog Management**
- [ ] Add new dog with photos
- [ ] Edit dog information
- [ ] Delete dog
- [ ] View dog details

**Matching**
- [ ] Browse available dogs
- [ ] View compatibility scores
- [ ] Send match request
- [ ] Accept/decline request
- [ ] Mark request as completed

**Community**
- [ ] Create post with photo
- [ ] Like/unlike posts
- [ ] Comment on posts
- [ ] Filter by category

**Reviews**
- [ ] View completed matches
- [ ] Submit review with rating
- [ ] View reviews on profile

---

## 🔒 Security

The app implements Firebase security rules for:
- User authentication and authorization
- Document-level access control
- Image upload validation (type and size)
- Read/write permissions based on ownership

See **FIREBASE_SETUP.md** for complete security rules.

---

## 🌐 Deployment

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

---

## 📊 Firebase Collections

### Database Structure

**users** - User profiles and statistics
```
{
  userId: {
    name, email, phone, location,
    profileImageUrl, isVerified,
    stats: { totalDogs, completedMatches, averageRating }
  }
}
```

**dogs** - Dog profiles
```
{
  dogId: {
    name, breed, age, sex, size, color,
    temperament[], healthInfo,
    imageUrls[], ownerId, isAvailable
  }
}
```

**match_requests** - Breeding match requests
```
{
  requestId: {
    requesterId, receiverId,
    requesterDogId, receiverDogId,
    status, message, createdAt
  }
}
```

**reviews** - User reviews and ratings
```
{
  reviewId: {
    reviewerId, reviewedUserId,
    matchRequestId, rating, comment
  }
}
```

**community_posts** - Community posts and comments
```
{
  postId: {
    authorId, title, content, category,
    imageUrls[], likes[], commentCount,
    comments/
  }
}
```

---

## 🎨 UI/UX

- Material Design 3
- Custom color scheme (Purple/Teal theme)
- Responsive layouts
- Image galleries with page indicators
- Pull-to-refresh functionality
- Loading states and error handling
- Empty state illustrations

---

## 🚧 Future Enhancements

- [ ] In-app messaging system
- [ ] Push notifications
- [ ] Advanced search filters
- [ ] Map view for nearby matches
- [ ] Breeding calendar and reminders
- [ ] Health record integration
- [ ] Payment gateway for premium features
- [ ] Multi-language support
- [ ] Dark mode
- [ ] Social media sharing

---

## 🐛 Known Issues

None at this time. Please report issues through the issue tracker.

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👨‍💻 Developer

Built with ❤️ using Flutter and Firebase

---

## 📞 Support

For support and questions:
- Create an issue in the repository
- Check existing documentation
- Review Firebase console logs for backend errors

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for the robust backend infrastructure
- All contributors and testers

---

**Ready to find the Pawfect Match? 🐾**

Start by reading **[QUICK_START.md](QUICK_START.md)** to get the app running in 5 minutes!
