# Roomie App - Complete Documentation

## 📱 App Overview
Roomie is a Flutter + Firebase chat application where users can create rooms and chat with others. The app features a minimal, modern design with Instagram-inspired navigation and comprehensive user management.

## 🔧 Recent Fixes Implemented

### 1. ✅ Dispose Issue Fixed
**Problem**: Text fields in CreateRoomPage weren't clearing after successful room creation.
**Solution**: Added automatic field clearing after successful room creation:
```dart
// Clear all text fields after successful room creation
_titleController.clear();
_descriptionController.clear();
_keywordsController.clear();
setState(() {
  _peopleCount = null;
});
```

### 2. ✅ Clickable Rooms in Settings
**Problem**: Owner rooms in Settings → My Rooms section weren't clickable.
**Solution**: Wrapped room containers with GestureDetector for navigation:
```dart
return GestureDetector(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoomDetailPage(roomId: room.id),
      ),
    );
  },
  child: Container(/* room display */),
);
```

### 3. ✅ Username Validation
**Status**: Already properly implemented in UsernameSetupPage
**Functionality**: Shows "Username is already taken" when username is unavailable during signup.

### 4. ✅ Theme Documentation
**Complete theme and UI style documented below for future reference.**

---

## 🎨 Complete Theme & UI Style Documentation

### 📱 Overall Design Philosophy
- **Minimal & Modern**: Clean, uncluttered interface with focus on content
- **Instagram-inspired**: Bottom navigation and overall layout structure
- **Professional**: Subtle shadows, consistent spacing, and refined typography
- **Accessible**: High contrast, clear hierarchy, and intuitive interactions

### 🎨 Color Palette

#### Primary Colors
- **Black**: `Colors.black` - Primary buttons, text, borders, icons
- **White**: `Colors.white` - Backgrounds, cards, app bars
- **Light Grey**: `Colors.grey[50]` - Input field backgrounds, subtle areas
- **Medium Grey**: `Colors.grey[200]` - Borders, dividers, inactive elements
- **Dark Grey**: `Colors.grey[600]` - Secondary text, descriptions
- **Accent Grey**: `Colors.grey[400]` - Icons, placeholders

#### Status Colors
- **Success**: `Colors.green` - Success messages, positive actions
- **Error**: `Colors.red` - Error messages, validation failures
- **Loading**: `Colors.white` - Loading indicators on dark backgrounds

### 📐 Layout & Spacing

#### Padding & Margins
- **Screen Padding**: `EdgeInsets.all(24.0)` - Main content areas
- **Card Padding**: `EdgeInsets.all(20)` - Room tiles and cards
- **Input Padding**: `EdgeInsets.symmetric(horizontal: 16, vertical: 16)` - Text fields
- **Button Padding**: `EdgeInsets.symmetric(horizontal: 24, vertical: 0)` - Action buttons

#### Spacing System
- **Small**: `SizedBox(height: 8)` - Between related elements
- **Medium**: `SizedBox(height: 12-16)` - Between sections
- **Large**: `SizedBox(height: 24-40)` - Between major components
- **Extra Large**: `SizedBox(height: 40+)` - Between page sections

### 🔤 Typography

#### Headings
- **Large Title**: `fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black`
- **Page Title**: `fontSize: 20, fontWeight: FontWeight.w600, color: Colors.black`
- **Section Title**: `fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87`

#### Body Text
- **Primary**: `fontSize: 16, color: Colors.black87` - Main content
- **Secondary**: `fontSize: 14, color: Colors.grey[600]` - Descriptions, metadata
- **Small**: `fontSize: 12, color: Colors.grey[500]` - Timestamps, labels

#### Interactive Text
- **Button Text**: `fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white`
- **Link Text**: `fontSize: 14, color: Colors.black, fontWeight: FontWeight.w500`

### 🎯 Component Styles

#### Text Fields
```dart
decoration: InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey[300]!),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.grey[300]!),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: Colors.black, width: 2),
  ),
  filled: true,
  fillColor: Colors.grey[50],
  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
)
```

#### Primary Buttons
```dart
style: ElevatedButton.styleFrom(
  backgroundColor: Colors.black,
  foregroundColor: Colors.white,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(12),
  ),
  elevation: 0,
)
```

#### Secondary Buttons
```dart
style: ElevatedButton.styleFrom(
  backgroundColor: Colors.white,
  foregroundColor: Colors.black,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(20),
  ),
  elevation: 0,
  side: BorderSide(color: Colors.grey[300]!),
)
```

#### Cards & Containers
```dart
decoration: BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(16),
  border: Border.all(color: Colors.grey[200]!),
  boxShadow: [
    BoxShadow(
      color: Colors.black.withOpacity(0.05),
      spreadRadius: 0,
      blurRadius: 10,
      offset: Offset(0, 2),
    ),
  ],
)
```

### 🧭 Navigation

#### Bottom Navigation Bar
- **Background**: `Colors.white`
- **Border**: `Border(top: BorderSide(color: Colors.grey[200]!, width: 1))`
- **Shadow**: Subtle shadow above the bar
- **Icons**: Outlined (inactive) vs Filled (active)
- **Labels**: `fontSize: 12, color: Colors.grey[600]` (inactive), `Colors.black` (active)

#### App Bars
- **Standard**: `backgroundColor: Colors.white, elevation: 0`
- **Custom**: `backgroundColor: Colors.black, color: Colors.white` (legacy)
- **Title**: `fontSize: 20, fontWeight: FontWeight.w600, centerTitle: true`

### 🎪 Interactive Elements

#### Floating Action Button
```dart
backgroundColor: Colors.black,
child: Icon(Icons.add, color: Colors.white),
```

#### Loading Indicators
```dart
CircularProgressIndicator(
  strokeWidth: 2,
  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
)
```

#### Icons
- **Size**: `size: 18-20` for inline icons, `size: 80-120` for illustrations
- **Color**: `Colors.grey[600]` for secondary, `Colors.black` for primary
- **Style**: Material Design outlined icons for inactive states, filled for active

### 📱 Screen Layouts

#### Authentication Screens
- **Background**: `Colors.white`
- **Content**: Centered with large illustrations
- **Form**: Stacked vertically with consistent spacing
- **Buttons**: Full-width primary buttons

#### Main App Screens
- **Background**: `Colors.grey[50]`
- **Content**: `Padding: EdgeInsets.all(16.0)`
- **Lists**: Cards with consistent spacing
- **Search**: Prominent search bar at top

#### Chat Interface
- **Messages**: Bubbles with rounded corners
- **Input**: Rounded text field with send button
- **Background**: `Colors.white` for input area

### 🎨 Visual Hierarchy

#### Z-Index Layers
1. **Background**: `Colors.grey[50]` or `Colors.white`
2. **Cards**: `Colors.white` with subtle shadows
3. **Overlays**: Semi-transparent backgrounds
4. **Modals**: Full opacity with backdrop

#### Shadow System
- **Subtle**: `color: Colors.black.withOpacity(0.05), blurRadius: 10`
- **Medium**: `color: Colors.black.withOpacity(0.1), blurRadius: 15`
- **Strong**: `color: Colors.black.withOpacity(0.2), blurRadius: 20`

### 📐 Responsive Design

#### Breakpoints
- **Mobile**: Primary design (current implementation)
- **Tablet**: Maintains same proportions with larger spacing
- **Desktop**: Not implemented (mobile-first approach)

#### Touch Targets
- **Minimum Size**: 48x48 logical pixels
- **Button Height**: 56 logical pixels
- **Input Height**: 56 logical pixels
- **Icon Size**: 24 logical pixels minimum

### 🎯 Animation & Transitions

#### Page Transitions
- **Standard**: `MaterialPageRoute` with default transitions
- **Navigation**: Smooth tab switching with `IndexedStack`
- **Loading**: `CircularProgressIndicator` for async operations

#### Micro-interactions
- **Button Press**: Subtle scale/opacity changes
- **Form Validation**: Real-time error display
- **Loading States**: Skeleton screens and spinners

### ♿ Accessibility

#### Color Contrast
- **Text on White**: Black text for maximum readability
- **Text on Black**: White text for high contrast
- **Secondary Text**: Grey tones that meet WCAG standards

#### Touch Accessibility
- **Large Touch Targets**: All interactive elements are easily tappable
- **Clear Visual Feedback**: Obvious pressed states and hover effects
- **Logical Tab Order**: Intuitive navigation flow

### 🔧 Implementation Notes

#### No ThemeData Usage
- The app deliberately avoids `ThemeData` for maximum customization control
- All styling is applied directly to individual widgets
- This allows for precise control over each component's appearance

#### Consistent Patterns
- **Border Radius**: 12px for inputs, 16px for cards, 20px+ for buttons
- **Elevation**: 0 for flat design, subtle shadows for depth
- **Spacing**: 8px grid system for consistent alignment

#### Performance Considerations
- **Minimal Rebuilds**: Efficient state management
- **Optimized Images**: Proper sizing and caching
- **Smooth Scrolling**: Optimized list performance

---

## 🏗️ App Architecture

### 📁 File Structure
```
lib/
├── auth/
│   ├── auth_gateway.dart          # Main authentication router
│   ├── auth_services.dart         # Firebase authentication services
│   ├── forgotpassword_page.dart   # Password reset page
│   ├── signin_page.dart          # User login page
│   ├── signup_page.dart          # User registration page
│   └── username_setup_page.dart  # Username setup for new users
├── home/
│   ├── chat_page.dart            # Real-time chat interface
│   ├── createroom_page.dart      # Room creation form
│   ├── home_page.dart            # Main home feed
│   └── room_detail_page.dart     # Room details and join/leave
├── models/
│   ├── message_model.dart        # Chat message data model
│   └── room_model.dart           # Room data model
├── navigation/
│   └── main_navigation.dart      # Bottom navigation with tabs
├── services/
│   └── room_service.dart         # Firestore operations for rooms
├── settings/
│   ├── profile_details_page.dart # User profile editing
│   └── settings_page.dart        # Settings and user rooms
├── widgets/
│   ├── customappbar.dart         # Custom app bar component
│   └── roomtile.dart             # Room display card
├── firebase_options.dart         # Firebase configuration
└── main.dart                     # App entry point
```

### 🔥 Firebase Integration

#### Authentication
- **Email/Password**: Standard signup and login
- **Google Sign-In**: OAuth integration with proper configuration
- **Password Reset**: Email-based password recovery
- **Account Deletion**: Comprehensive data cleanup

#### Firestore Collections
- **users**: User profiles with username, email, role
- **rooms**: Chat rooms with metadata and member lists
- **user_joins**: Track user join activity for limits
- **messages**: Subcollection under each room for chat messages

#### Data Models
```dart
// Room Model
class RoomModel {
  final String id;
  final String title;
  final String description;
  final int maxMembers;
  final List<String> keywords;
  final String createdBy;
  final List<String> members;
  final DateTime createdAt;
}

// Message Model
class MessageModel {
  final String id;
  final String text;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final String? imageUrl;
  final String? link;
}
```

### 🚀 Key Features

#### Authentication Flow
1. **Sign Up/Login** → **Username Setup** → **Main App**
2. **Persistent Sessions**: Users stay logged in across app restarts
3. **Username Validation**: Real-time availability checking
4. **Account Management**: Profile editing and account deletion

#### Room Management
1. **Create Rooms**: Title, description, max members, keywords
2. **Join/Limit System**: 2 rooms per week limit per user
3. **Owner Privileges**: Room creators are owners with special permissions
4. **Real-time Updates**: Live room member counts and availability
5, #owner can delte the room if they want in settings section -> my room section
#### Chat System
1. **Real-time Messaging**: Instant message delivery
2. **Message History**: Persistent chat history
3. **User Identification**: Sender names and avatars
4. **Link Detection**: Automatic link recognition in messages

#### Navigation
1. **Bottom Tabs**: Home, Create, Settings
2. **Consistent Flow**: Unified navigation throughout app
3. **State Preservation**: Tab state maintained during navigation

---

## 🎯 Usage Instructions for AI Development

### To Build a Similar App:

1. **Use the Color Palette**: Implement the exact color scheme documented above
2. **Follow Spacing System**: Use the 8px grid system for consistent spacing
3. **Apply Component Styles**: Use the provided code snippets for buttons, inputs, and cards
4. **Implement Navigation**: Use IndexedStack for bottom navigation
5. **Maintain Typography**: Follow the font sizes and weights specified
6. **Add Subtle Shadows**: Use the shadow system for depth
7. **Ensure Accessibility**: Follow the touch target and contrast guidelines

### Key Design Principles:
- **Minimal First**: Remove unnecessary elements
- **Consistent Spacing**: Use the documented spacing system
- **High Contrast**: Black text on white backgrounds
- **Rounded Corners**: 12px for inputs, 16px for cards
- **Subtle Shadows**: Very light shadows for depth
- **No ThemeData**: Apply styles directly to widgets

---

## 📋 Development Checklist

### ✅ Completed Features
- [x] User authentication (email/password + Google)
- [x] Username setup and validation
- [x] Room creation and management
- [x] Real-time chat system
- [x] Bottom navigation
- [x] Settings and profile management
- [x] Join limits and room ownership
- [x] Search functionality
- [x] Account deletion with data cleanup
- [x] Responsive UI design
- [x] Error handling and validation

### 🔄 Future Enhancements
- [ ] Image upload in chat
- [ ] Push notifications
- [ ] Room categories/tags
- [ ] User blocking/reporting
- [ ] Advanced search filters
- [ ] Dark mode support
- [ ] Offline message caching
- [ ] Voice messages
- [ ] Video calls integration

---

## 🐛 Known Issues & Solutions

### Fixed Issues
1. **Google Sign-In**: Fixed OAuth configuration and SHA-1 fingerprint
2. **Navigation Black Screen**: Fixed navigation stack management
3. **Text Field Clearing**: Added automatic field clearing after room creation
4. **Clickable Rooms**: Made owner rooms clickable in settings
5. **Username Validation**: Proper error messages for taken usernames
6. **Owner Member Count**: Fixed room creation so owners don't count against member limit
   - **Problem**: When owner created room with 1 member limit, owner was counted as a member, preventing others from joining
   - **Solution**: Owner is no longer added to `members` array during room creation
   - **Result**: If room is created with 1 member limit, exactly 1 other user can join (owner has special privileges)
7. **Delete Room Functionality**: Added room deletion feature for owners in Settings
   - **Feature**: Owners can delete their rooms from Settings → My Rooms section
   - **Security**: Only room owners can delete their rooms (enforced in backend)
   - **UI**: Red delete button with confirmation dialog and warning message
   - **Data Cleanup**: Deletes all messages and room data permanently

### Performance Optimizations
- Efficient Firestore queries with proper indexing
- Minimal widget rebuilds with proper state management
- Optimized list rendering with proper item builders
- Stream-based real-time updates

---

This documentation provides everything needed to understand, maintain, and extend the Roomie app. The theme documentation can be used to build similar apps with the same design language and user experience.
