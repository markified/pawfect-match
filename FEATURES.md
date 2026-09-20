# 🎯 Pawfect Match - Feature Documentation

Complete guide to all features and functionality in the Pawfect Match app.

---

## Table of Contents
1. [Authentication & User Management](#authentication--user-management)
2. [Dog Profile Management](#dog-profile-management)
3. [Smart Matching System](#smart-matching-system)
4. [Match Request Management](#match-request-management)
5. [Community Features](#community-features)
6. [Reviews & Ratings](#reviews--ratings)
7. [Notifications](#notifications)
8. [Profile Management](#profile-management)

---

## 1. Authentication & User Management

### 1.1 User Registration
**Screen:** `LoginScreen` (Registration Tab)

**Features:**
- Email and password registration
- Form validation:
  - Valid email format
  - Password minimum 6 characters
  - Name required
- Automatic Firestore user document creation
- Initial user statistics (0 dogs, 0 matches, 5.0 rating)

**User Document Structure:**
```dart
{
  'userId': String,
  'name': String,
  'email': String,
  'phone': String?,
  'location': String?,
  'profileImageUrl': String?,
  'isVerified': false,
  'createdAt': Timestamp,
  'stats': {
    'totalDogs': 0,
    'completedMatches': 0,
    'averageRating': 5.0
  }
}
```

**Flow:**
1. User enters name, email, password
2. Firebase Auth creates account
3. Firestore user document created
4. User automatically logged in
5. Redirected to Home screen

---

### 1.2 User Login
**Screen:** `LoginScreen` (Login Tab)

**Features:**
- Email/password authentication
- Remember me functionality (handled by Firebase)
- Error handling for invalid credentials
- Automatic session management

**Flow:**
1. User enters email and password
2. Firebase Auth validates credentials
3. AuthProvider updates state
4. Redirected to Home screen

---

### 1.3 User Logout
**Location:** Profile Screen → Logout button

**Features:**
- Clear authentication state
- Return to login screen
- Clean provider state reset

---

## 2. Dog Profile Management

### 2.1 Add Dog
**Screen:** `AddEditDogScreen`
**Access:** My Dogs Tab → Floating Action Button (+)

**Features:**
- **Image Selection:**
  - Multiple photo upload (up to 5 photos)
  - Gallery picker integration
  - Image preview with remove option
  - Automatic Firebase Storage upload
  - Path: `dog_images/{userId}/{dogId}/{timestamp}.jpg`

- **Dog Information Fields:**
  - **Name** (Text input, required)
  - **Breed** (Dropdown selector with 50+ breeds)
  - **Age** (Number input, months)
  - **Sex** (Radio buttons: Male/Female)
  - **Size** (Chips: Small/Medium/Large/Giant)
  - **Color** (Text input)
  - **Temperament** (Multi-select chips):
    - Friendly, Playful, Calm, Energetic
    - Protective, Gentle, Social, Independent
  - **Health Information** (Multi-line text)
  - **Availability** (Toggle switch)

- **Form Validation:**
  - Name, breed, age, sex, size required
  - At least one photo required
  - Health info recommended but optional

**Dog Document Structure:**
```dart
{
  'id': String,
  'ownerId': String,
  'name': String,
  'breed': String,
  'age': int,
  'sex': String,
  'size': String,
  'color': String,
  'temperament': List<String>,
  'healthInfo': String,
  'imageUrls': List<String>,
  'isAvailable': bool,
  'createdAt': Timestamp,
  'updatedAt': Timestamp
}
```

**Flow:**
1. User fills form and uploads photos
2. Photos uploaded to Firebase Storage
3. Dog document created in Firestore
4. User's `totalDogs` stat incremented
5. Return to My Dogs screen

---

### 2.2 Edit Dog
**Screen:** `AddEditDogScreen` (Edit Mode)
**Access:** Dog Detail Screen → Edit button (owner only)

**Features:**
- Pre-populated form with existing data
- Update any field
- Add/remove photos
- Save changes to Firestore
- Delete old images if removed

**Flow:**
1. Load existing dog data
2. User modifies fields
3. Upload new photos if added
4. Update Firestore document
5. Return to Dog Detail screen

---

### 2.3 Delete Dog
**Access:** Dog Detail Screen → Delete button (owner only)

**Features:**
- Confirmation dialog
- Delete all associated images from Storage
- Delete Firestore document
- Decrement user's `totalDogs` stat

**Flow:**
1. User taps delete button
2. Confirmation dialog shown
3. Delete images from Storage
4. Delete Firestore document
5. Return to My Dogs screen

---

### 2.4 View Dog Details
**Screen:** `DogDetailScreen`
**Access:** Tap any dog card

**Features:**

**Image Gallery:**
- Swipeable image carousel
- Page indicators
- Full-width images in expandable app bar
- Zoom support (future enhancement)

**Dog Information Sections:**
- **Basic Info Card:**
  - Breed, Age, Size, Color
  - Owner name (clickable to view profile)
  - Owner location and verification badge
  
- **Temperament Section:**
  - Colorful chips displaying personality traits
  - Visual separation for easy scanning

- **Health Information:**
  - Expandable section
  - Full health details and notes

- **Owner Profile Card:**
  - Profile photo
  - Name and verification status
  - Location
  - Tap to view full profile/reputation

- **Reviews Section:**
  - Real-time stream of recent reviews
  - Star ratings
  - Review comments
  - Reviewer information

**Owner Actions (if viewing own dog):**
- Edit button → Edit dog information
- Delete button → Remove dog profile

**Flow:**
1. User taps dog card
2. Dog details loaded from Firestore
3. Reviews streamed in real-time
4. Swipe through photos
5. Tap owner card to view reputation

---

## 3. Smart Matching System

### 3.1 Browse Matches
**Screen:** `DashboardTab` and `BrowseMatchesScreen`
**Access:** Home Tab

**Features:**

**Compatibility Algorithm:**
```dart
Compatibility Score = 
  (35% × Breed Match) +
  (25% × Age Compatibility) +
  (15% × Sex Compatibility) +
  (25% × Temperament Overlap)
```

**Breed Match:**
- Same breed = 100%
- Different breed = 0%
- (Future: Similar breed groups)

**Age Compatibility:**
- Ideal age difference: 0-24 months
- Perfect match (0-12 months): 100%
- Good match (13-24 months): 75%
- Fair match (25-36 months): 50%
- Poor match (37+ months): 25%

**Sex Compatibility:**
- Opposite sex = 100%
- Same sex = 0%

**Temperament Overlap:**
- Shared traits / Total unique traits × 100%
- Example: 3 shared traits out of 6 unique = 50%

**Display Features:**
- Dog cards with photos
- Compatibility percentage badge
- Breed, age, location
- Owner verification badge
- Tap card to view details
- Tap "Send Request" to match

**Filtering (Future Enhancement):**
- By breed
- By age range
- By location
- By compatibility threshold

---

### 3.2 Compatibility Calculation
**Service:** `FirestoreService.calculateCompatibility()`

**Algorithm Details:**

```dart
double calculateCompatibility(Dog dog1, Dog dog2) {
  double breedScore = (dog1.breed == dog2.breed) ? 1.0 : 0.0;
  
  int ageDiff = (dog1.age - dog2.age).abs();
  double ageScore = ageDiff <= 12 ? 1.0 :
                    ageDiff <= 24 ? 0.75 :
                    ageDiff <= 36 ? 0.5 : 0.25;
  
  double sexScore = (dog1.sex != dog2.sex) ? 1.0 : 0.0;
  
  Set<String> temp1 = dog1.temperament.toSet();
  Set<String> temp2 = dog2.temperament.toSet();
  int sharedTraits = temp1.intersection(temp2).length;
  int totalTraits = temp1.union(temp2).length;
  double tempScore = totalTraits > 0 ? sharedTraits / totalTraits : 0.0;
  
  return (breedScore * 0.35) + 
         (ageScore * 0.25) + 
         (sexScore * 0.15) + 
         (tempScore * 0.25);
}
```

**Why These Weights?**
- **Breed (35%):** Most critical for successful breeding genetics
- **Age (25%):** Important for health and fertility
- **Sex (15%):** Binary requirement but less weighted
- **Temperament (25%):** Important for compatibility and offspring traits

---

## 4. Match Request Management

### 4.1 Send Match Request
**Screen:** `DogDetailScreen` → "Send Request" button
**Access:** View any available dog (not your own)

**Features:**
- Personal message to owner
- Select which of your dogs to match
- Send request notification
- Request document created in Firestore

**Match Request Structure:**
```dart
{
  'id': String,
  'requesterId': String,
  'receiverId': String,
  'requesterDogId': String,
  'receiverDogId': String,
  'status': 'pending', // pending, accepted, declined, completed
  'message': String,
  'createdAt': Timestamp,
  'updatedAt': Timestamp,
  'completedAt': Timestamp?
}
```

**Flow:**
1. User views dog they're interested in
2. Taps "Send Request" button
3. Selects their dog from dropdown
4. Writes optional message
5. Request created in Firestore
6. Notification sent to receiver
7. Confirmation shown

---

### 4.2 View Match Requests
**Screen:** `MatchRequestsScreen`
**Access:** Match Tab or Home Dashboard

**Features:**

**Two Tabs:**
1. **Received Requests:**
   - Requests sent to you
   - Pending status highlighted
   - Accept/Decline buttons
   - View requester's dog and profile

2. **Sent Requests:**
   - Requests you've sent
   - Status badges (Pending/Accepted/Declined)
   - Cancel pending requests option
   - View receiver's response

**Request Card Information:**
- Requester/Receiver name and photo
- Both dogs' names and photos
- Compatibility percentage
- Request message
- Status and timestamp
- Action buttons based on role and status

**Real-time Updates:**
- Stream from Firestore
- Instant status changes
- New request notifications

---

### 4.3 Accept/Decline Requests
**Screen:** `RequestDetailScreen`
**Access:** Tap received request

**Features:**

**Accept Request:**
- Updates status to 'accepted'
- Sends notification to requester
- Increments potential match count
- Enables messaging (future feature)

**Decline Request:**
- Updates status to 'declined'
- Sends notification to requester
- Option to provide reason (future)

**View Request Details:**
- Full dog profiles for both parties
- Compatibility breakdown
- Request message
- Chat history (future)

**Flow:**
1. User views received request
2. Reviews both dog profiles
3. Checks compatibility score
4. Reads requester's message
5. Accepts or declines
6. Status updated in real-time
7. Notification sent to requester

---

### 4.4 Complete Match
**Screen:** `RequestDetailScreen` (Accepted requests)
**Access:** Both parties can mark as completed

**Features:**
- "Mark as Completed" button
- Confirmation dialog
- Updates status to 'completed'
- Records completion timestamp
- Increments both users' `completedMatches` stat
- Enables review submission

**Flow:**
1. User completes breeding arrangement
2. Taps "Mark as Completed"
3. Confirms action
4. Request status updated
5. Both users notified
6. Review prompts enabled

---

## 5. Community Features

### 5.1 View Community Posts
**Screen:** `CommunityScreen`
**Access:** Community Tab

**Features:**

**Post Display:**
- Card-based feed layout
- Author name and profile photo
- Post category badge
- Title and content preview
- Images (if attached)
- Like count and comment count
- Timestamp (relative, e.g., "2 hours ago")

**Category Filter:**
- All Posts
- Breeding Tips
- Success Stories
- Questions
- Events
- General Discussion

**Interactions:**
- Like/Unlike posts
- Tap post to view details
- Pull-to-refresh

**Real-time Updates:**
- New posts appear automatically
- Like counts update live
- Comment counts update live

**Post Structure:**
```dart
{
  'id': String,
  'authorId': String,
  'authorName': String,
  'authorPhotoUrl': String?,
  'title': String,
  'content': String,
  'category': String,
  'imageUrls': List<String>,
  'likes': List<String>, // userIds who liked
  'commentCount': int,
  'createdAt': Timestamp
}
```

---

### 5.2 Create Post
**Screen:** `CreatePostScreen`
**Access:** Community Tab → Floating Action Button (+)

**Features:**

**Post Creation Form:**
- Title (required)
- Content (required, multi-line)
- Category selection (required):
  - Breeding Tips
  - Success Story
  - Question
  - Event
  - General
- Image upload (up to 3 images)
- Preview before posting

**Image Upload:**
- Pick from gallery
- Multiple image support
- Upload to Firebase Storage
- Path: `community_images/{userId}/{postId}/{timestamp}.jpg`
- Preview with remove option

**Form Validation:**
- Title minimum 3 characters
- Content minimum 10 characters
- Category required
- Images optional

**Flow:**
1. User taps create post button
2. Fills title, content, selects category
3. Optionally adds images
4. Taps "Post" button
5. Images uploaded to Storage
6. Post document created in Firestore
7. Return to Community feed
8. New post appears at top

---

### 5.3 View Post Details
**Screen:** `PostDetailScreen`
**Access:** Tap any post card

**Features:**

**Post Content:**
- Full title and content
- All images in gallery
- Author profile (clickable)
- Category badge
- Timestamp

**Like System:**
- Heart icon (filled if liked by user)
- Like count
- Tap to like/unlike
- Real-time count updates

**Comments Section:**
- Real-time comment stream
- Newest comments first
- Comment author photo and name
- Comment content
- Timestamp
- Delete option for comment author

**Comment Form:**
- Text input at bottom
- Character limit (500)
- Submit button
- Real-time submission

**Comment Structure:**
```dart
{
  'id': String,
  'authorId': String,
  'authorName': String,
  'authorPhotoUrl': String?,
  'content': String,
  'createdAt': Timestamp
}
```

---

### 5.4 Like Posts
**Location:** Any post card or Post Detail screen

**Features:**
- Heart icon toggle
- Optimistic UI update
- Firestore transaction for consistency
- User ID added/removed from `likes` array
- Like count incremented/decremented

**Flow:**
1. User taps heart icon
2. UI updates immediately
3. Firestore document updated
4. Like count refreshed
5. Other users see updated count

---

### 5.5 Comment on Posts
**Screen:** `PostDetailScreen`
**Location:** Comment input at bottom

**Features:**
- Text input field
- Submit button
- Character limit validation
- Real-time comment addition
- Comment count auto-increments
- Notification sent to post author

**Flow:**
1. User types comment
2. Taps submit button
3. Comment validated
4. Comment document created in subcollection
5. Post's `commentCount` incremented
6. Comment appears immediately
7. Notification sent to post author

---

## 6. Reviews & Ratings

### 6.1 View Completed Matches
**Screen:** `CompletedMatchesScreen`
**Access:** Profile Tab → "Completed Matches"

**Features:**
- List of all completed match requests
- Both your completed and partner's completed
- Partner information
- Dogs involved
- Completion date
- "Leave Review" button (if not already reviewed)

**Flow:**
1. User navigates to completed matches
2. Views list of successful matches
3. Selects match to review
4. Redirected to Submit Review screen

---

### 6.2 Submit Review
**Screen:** `SubmitReviewScreen`
**Access:** Completed Matches → "Leave Review"

**Features:**

**Rating System:**
- 5-star rating interface
- Interactive star icons
- Required to submit

**Review Form:**
- Text area for detailed review
- Placeholder text with guidelines
- Character minimum: 20 characters
- Character maximum: 500 characters

**Review Guidelines:**
- Be honest and constructive
- Focus on breeding experience
- Mention communication quality
- Note dog health and genetics
- Describe overall satisfaction

**Validation:**
- Rating required (1-5 stars)
- Comment minimum length
- Cannot review same match twice

**Review Structure:**
```dart
{
  'id': String,
  'reviewerId': String,
  'reviewerName': String,
  'reviewedUserId': String,
  'matchRequestId': String,
  'rating': int, // 1-5
  'comment': String,
  'createdAt': Timestamp
}
```

**Flow:**
1. User selects completed match
2. Taps "Leave Review"
3. Selects star rating
4. Writes detailed comment
5. Taps "Submit Review"
6. Review saved to Firestore
7. Reviewed user's `averageRating` recalculated
8. Notification sent to reviewed user
9. Return to completed matches

---

### 6.3 View Reviews
**Locations:**
- Dog Detail Screen (Reviews section)
- User Profile (future enhancement)

**Features:**
- Real-time stream of reviews
- Reviewer name and photo
- Star rating display
- Review comment
- Timestamp
- "Verified Match" badge

**Average Rating Calculation:**
```dart
double newAverage = (
  (currentAverage * totalReviews) + newRating
) / (totalReviews + 1)
```

**Display:**
- Recent reviews (last 10)
- Star rating visualization
- Reviewer profile link
- Timestamp

---

## 7. Notifications

### 7.1 Notification Types

**Match Request Notifications:**
- "New match request from [User]"
- "Your match request was accepted by [User]"
- "Your match request was declined by [User]"
- "Match with [User] marked as completed"

**Community Notifications:**
- "[User] liked your post"
- "[User] commented on your post"
- "[User] mentioned you in a comment" (future)

**Review Notifications:**
- "[User] left you a review"
- "You have a new 5-star rating!"

**Profile Notifications:**
- "[User] viewed your profile" (future)
- "[User] viewed your dog's profile" (future)

**Notification Structure:**
```dart
{
  'id': String,
  'userId': String,
  'type': String, // match_request, community, review, profile
  'title': String,
  'message': String,
  'isRead': bool,
  'createdAt': Timestamp,
  'relatedId': String?, // dogId, requestId, postId, etc.
  'relatedData': Map<String, dynamic>? // Additional context
}
```

---

### 7.2 Notification Display
**Location:** Profile Screen → Notifications card (unread count)

**Features:**
- Unread count badge
- Tap to view notification list
- Mark as read
- Group by date
- Tap to navigate to related content

**Flow:**
1. Notification created in Firestore
2. Badge appears on Profile tab
3. User taps to view notifications
4. Taps notification to view details
5. Navigates to related screen
6. Notification marked as read

---

## 8. Profile Management

### 8.1 View Profile
**Screen:** `ProfileScreen`
**Access:** Profile Tab

**Features:**

**Profile Header:**
- Profile photo (tap to update)
- User name
- Verification badge (if verified)
- Location
- Member since date

**Statistics Card:**
- Total Dogs registered
- Completed Matches count
- Average Rating (with stars)

**Menu Options:**
- Edit Profile
- Completed Matches
- My Reviews
- Notifications
- Settings (future)
- Help & Support (future)
- Logout

---

### 8.2 Edit Profile
**Screen:** `EditProfileScreen`
**Access:** Profile → Edit Profile

**Features:**

**Editable Fields:**
- Profile photo upload
- Name (required)
- Phone number
- Location
- Bio (future enhancement)

**Profile Photo Upload:**
- Pick from gallery
- Crop/resize (future)
- Upload to Firebase Storage
- Path: `profile_images/{userId}/profile.jpg`
- Update user document

**Form Validation:**
- Name required
- Phone format validation
- Location optional

**Flow:**
1. User taps Edit Profile
2. Form pre-populated with current data
3. User updates fields
4. Optionally uploads new photo
5. Taps Save
6. Photo uploaded (if changed)
7. Firestore user document updated
8. Return to Profile screen
9. Changes reflected immediately

---

### 8.3 User Statistics

**Tracked Statistics:**

**Total Dogs:**
- Incremented when dog added
- Decremented when dog deleted
- Displayed on profile

**Completed Matches:**
- Incremented when match marked completed
- Used for reputation
- Displayed on profile

**Average Rating:**
- Calculated from all received reviews
- Updated after each new review
- Displayed with stars
- Used for verification eligibility

**Profile Views (Future):**
- Increment on profile view
- Daily unique visitors
- Total all-time views

---

### 8.4 Verification Badge

**Criteria for Verification:**
- 5+ completed matches
- 4.0+ average rating
- Active for 3+ months
- Profile 100% complete

**Benefits:**
- Trust indicator
- Higher visibility in search
- Priority match suggestions
- Exclusive features (future)

**Display:**
- Blue checkmark badge
- "Verified Breeder" label
- Shown on all user interactions

---

## 9. Additional Features

### 9.1 Search & Filters
**Status:** Planned for next version

**Dog Search:**
- By breed
- By location
- By age range
- By size
- By availability

**User Search:**
- By name
- By location
- By verification status

---

### 9.2 In-App Messaging
**Status:** Planned for next version

**Features:**
- Real-time chat with matched users
- Send text messages
- Send photos
- Message notifications
- Chat history
- Typing indicators

---

### 9.3 Push Notifications
**Status:** Planned for next version

**Features:**
- Firebase Cloud Messaging integration
- Notification preferences
- Custom notification sounds
- Badge counts
- Deep linking to content

---

### 9.4 Advanced Analytics
**Status:** Planned for next version

**User Analytics:**
- Profile views over time
- Match success rate
- Response time
- Popular dogs

**System Analytics:**
- User engagement metrics
- Feature usage statistics
- Popular breeds
- Geographic distribution

---

## Feature Checklist

✅ **Completed Features:**
- [x] User authentication
- [x] Profile management
- [x] Dog profile CRUD
- [x] Smart matching algorithm
- [x] Match request system
- [x] Community posts and comments
- [x] Reviews and ratings
- [x] Notifications system
- [x] Image uploads
- [x] Real-time updates

🚧 **Planned Features:**
- [ ] In-app messaging
- [ ] Push notifications
- [ ] Advanced search/filters
- [ ] Payment integration
- [ ] Breeding calendar
- [ ] Health record integration
- [ ] Map view
- [ ] Dark mode

---

**Total Feature Count: 40+ implemented features across 8 major modules**
