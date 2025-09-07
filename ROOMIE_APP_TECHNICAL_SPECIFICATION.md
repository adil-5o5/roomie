# Roomie App - Complete Technical Specification

## Overview
Roomie is a Flutter + Firebase app that allows users to create chat rooms, join rooms, and communicate in real-time. The app implements Instagram-like authentication flow with username setup, room management with ownership rules, and a minimal chat system.

## Core Technologies
- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: StatefulWidget with setState
- **Real-time**: Firestore streams for live updates

## Database Structure

### Firestore Collections

#### 1. `users` Collection
```dart
// Document ID: user.uid
{
  "username": "john_doe",           // Required, unique, lowercase
  "email": "john@example.com",      // From Firebase Auth
  "github": "https://github.com/john", // Optional
  "linkedin": "https://linkedin.com/in/john", // Optional
  "createdAt": Timestamp,
  "lastLogin": Timestamp
}
```

#### 2. `rooms` Collection
```dart
// Document ID: auto-generated
{
  "title": "Flutter Developers",           // Required
  "description": "Chat for Flutter devs",  // Required
  "membersCount": 5,                       // Current member count
  "keywords": ["flutter", "dart", "mobile"], // Required array
  "createdBy": "user_uid",                 // Owner's UID
  "createdAt": Timestamp,
  "members": ["uid1", "uid2", "uid3"]      // Array of member UIDs (excludes owner)
}
```

#### 3. `rooms/{roomId}/messages` Subcollection
```dart
// Document ID: auto-generated
{
  "text": "Hello everyone!",              // Message content
  "senderId": "user_uid",                 // Sender's UID
  "senderName": "john_doe",               // Sender's username
  "timestamp": Timestamp,
  "imageUrl": "https://...",              // Optional
  "link": "https://github.com/..."        // Optional
}
```

#### 4. `join_activity` Collection (for weekly limits)
```dart
// Document ID: user.uid
{
  "joins": [
    {
      "roomId": "room_id",
      "timestamp": Timestamp,
      "action": "join" // or "leave"
    }
  ]
}
```

## Authentication Flow

### 1. Initial Authentication
- **Sign Up**: Email/password or Google Sign-In
- **Sign In**: Email/password or Google Sign-In
- **Password Reset**: Email-based password reset

### 2. Username Setup (First-time users only)
- **Trigger**: After successful authentication, check if user has username
- **Validation Rules**:
  - 3-20 characters
  - Lowercase letters, numbers, underscore only
  - Must be unique across all users
  - Cannot be changed after setting
- **Storage**: Save to `users/{uid}` document in Firestore
- **Navigation**: After username setup → Main app

### 3. Authentication Gateway
- **Purpose**: Central routing based on auth state
- **Logic**:
  1. Check if user is authenticated
  2. If not authenticated → Sign In page
  3. If authenticated but no username → Username Setup page
  4. If authenticated with username → Main Navigation

### 4. Session Management
- **Remember Me**: Firebase Auth handles session persistence
- **Auto-login**: App remembers user state on restart
- **Logout**: Clear Firebase Auth session

## User Management

### User Profile
- **Username**: Required, unique, immutable after creation
- **Email**: From Firebase Auth
- **Social Links**: GitHub, LinkedIn (optional)
- **Role**: Displayed as "Flutter Developer" (static)

### Account Management
- **Profile Updates**: Update social links only
- **Account Deletion**: 
  - Delete user's rooms and messages
  - Remove user from all joined rooms
  - Delete user document from Firestore
  - Delete Firebase Auth account

## Room Management

### Room Creation
- **Fields Required**:
  - Title (string)
  - Description (string)
  - Member count limit (number)
  - Keywords (array of strings)
- **Owner Assignment**: Creator becomes owner automatically
- **Member Count**: Owner is NOT counted in member limit
- **Storage**: Save to `rooms` collection
- **Navigation**: After creation → Home tab

### Room Ownership Rules
- **Owner Privileges**:
  - Can delete room
  - Can view room details
  - Cannot join own room (shows "You own this room")
  - Room doesn't appear in owner's Home feed
- **Member Management**:
  - Owner is not in `members` array
  - `membersCount` reflects actual members only
  - Owner has special status separate from members

### Room Discovery
- **Home Feed**: Shows all rooms except user's own rooms
- **Search**: Filter by title, description, or keywords
- **Real-time Updates**: Live member count and availability

### Room Joining
- **Join Limits**: 2 rooms per week per user
- **Validation**:
  - Check if room is full
  - Check weekly join limit
  - Check if user already in room
- **Owner Restriction**: Owners cannot join their own rooms
- **Success**: Add user to `members` array, increment `membersCount`

### Room Leaving
- **Member Removal**: Remove from `members` array
- **Count Update**: Decrement `membersCount`
- **Activity Tracking**: Record leave action for weekly limits

## Chat System

### Message Structure
- **Text Messages**: Plain text content
- **Image Messages**: Upload to Firebase Storage, store URL
- **Link Messages**: Detect and store URLs
- **Metadata**: Sender ID, username, timestamp

### Real-time Messaging
- **Stream**: Listen to `rooms/{roomId}/messages` subcollection
- **Ordering**: Messages ordered by timestamp
- **Auto-scroll**: Scroll to latest message
- **Instant Send**: No loading indicators, immediate UI update

### Message Features
- **Sender Identification**: Show username, not UID
- **Timestamp Display**: Relative time (e.g., "2m ago")
- **Link Detection**: Identify and store URLs
- **Image Support**: Upload and display images

## Navigation Structure

### Bottom Navigation (3 tabs)
1. **Home Tab**: Room discovery and search
2. **Create Tab**: Room creation form
3. **Settings Tab**: Profile and owned rooms

### Page Hierarchy
```
AuthGateway
├── SignInPage
├── SignUpPage
├── ForgotPasswordPage
├── UsernameSetupPage
└── MainNavigation
    ├── HomePage
    │   └── RoomDetailPage
    │       └── ChatPage
    ├── CreateRoomPage
    └── SettingsPage
        └── ProfileDetailsPage
```

## Business Logic

### Weekly Join Limits
- **Limit**: 2 rooms per week
- **Tracking**: Store join/leave activity in `join_activity` collection
- **Reset**: Weekly cycle (Monday to Sunday)
- **Enforcement**: Check before allowing join
- **Error Message**: "Join limit reached. Try again next week."

### Room Capacity
- **Owner Exclusion**: Owner doesn't count toward member limit
- **Example**: Room with 1 member limit = owner + 1 other member
- **Full Room**: Show "Room is full" when limit reached
- **Real-time Updates**: Live member count display

### Username Uniqueness
- **Validation**: Check against all existing usernames
- **Case Sensitivity**: Usernames are lowercase only
- **Error Handling**: "Username is already taken"
- **Confirmation**: Dialog warning about immutability

## Data Validation

### Room Creation
- **Title**: Required, non-empty
- **Description**: Required, non-empty
- **Member Count**: Required, positive integer
- **Keywords**: Required, non-empty array

### Username Setup
- **Length**: 3-20 characters
- **Characters**: Lowercase letters, numbers, underscore only
- **Uniqueness**: Must be unique across all users
- **Confirmation**: User must confirm username cannot be changed

### Message Sending
- **Content**: Non-empty text or image
- **Room Access**: User must be member or owner
- **Real-time**: Immediate UI update

## Error Handling

### Authentication Errors
- **Invalid Credentials**: Clear error messages
- **Network Issues**: Retry mechanisms
- **Google Sign-In**: Proper OAuth configuration

### Room Operations
- **Join Failures**: Specific error messages
- **Delete Failures**: Rollback and error notification
- **Permission Errors**: Clear access denied messages

### Data Validation
- **Form Validation**: Real-time field validation
- **Server Validation**: Backend data integrity checks
- **User Feedback**: Clear error messages and success confirmations

## Security Rules

### Firestore Security
- **Users**: Users can read/write their own document
- **Rooms**: Anyone can read, only owner can delete
- **Messages**: Members can read/write messages in their rooms
- **Join Activity**: Users can read/write their own activity

### Authentication Security
- **Email Verification**: Optional but recommended
- **Password Strength**: Firebase handles validation
- **Session Management**: Secure token handling
- **Account Deletion**: Complete data cleanup

## Performance Optimizations

### Firestore Queries
- **Indexing**: Proper composite indexes for complex queries
- **Pagination**: Limit results for large datasets
- **Caching**: Firestore offline persistence
- **Real-time**: Efficient stream listeners

### UI Performance
- **List Optimization**: Proper ListView.builder usage
- **Image Loading**: Efficient image caching
- **State Management**: Minimal widget rebuilds
- **Memory Management**: Proper disposal of controllers

## Key Implementation Details

### Room Service Methods
```dart
// Core room operations
createRoom(title, description, memberCount, keywords)
getRoomsStream() // Real-time room list
getRoom(roomId) // Single room details
joinRoom(roomId) // Join with weekly limit check
leaveRoom(roomId) // Leave room
deleteRoom(roomId) // Owner-only deletion
isUserInRoom(roomId) // Check membership
sendMessage(roomId, text) // Send message
```

### Authentication Service Methods
```dart
// Auth operations
signUp(email, password)
signIn(email, password)
googleSignIn()
signOut()
deleteAccount() // Complete cleanup
resetPassword(email)
isGoogleSignInAvailable()
```

### Data Models
```dart
// Room model
class RoomModel {
  String id;
  String title;
  String description;
  int membersCount;
  List<String> keywords;
  String createdBy;
  DateTime createdAt;
  List<String> members;
}

// Message model
class MessageModel {
  String id;
  String text;
  String senderId;
  String senderName;
  DateTime timestamp;
  String? imageUrl;
  String? link;
}
```

## Testing Scenarios

### Authentication Flow
1. New user signup → Username setup → Main app
2. Existing user login → Direct to main app
3. Google Sign-In → Username setup (if new) → Main app
4. Password reset → Email confirmation → New password

### Room Management
1. Create room → Owner status → Room appears in Settings
2. Join room → Member count updates → Weekly limit tracking
3. Leave room → Member count decreases → Activity recorded
4. Delete room → Complete cleanup → Room removed from all lists

### Chat System
1. Send message → Real-time delivery → UI updates
2. Multiple users → All see messages instantly
3. Image upload → Storage → URL in message
4. Link detection → URL stored → Display as text

This specification provides complete implementation details for replicating the Roomie app with all its features, business logic, and technical requirements.
