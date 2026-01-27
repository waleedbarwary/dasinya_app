# 🔥 Firebase Integration Guide for Dasinya TV

## ✅ Step 1: Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project or select existing one named **"Dasinya TV"**
3. Enable **Cloud Firestore Database**
   - Go to **Build** → **Firestore Database**
   - Click **Create Database**
   - Start in **Test Mode** (for development)
   - Choose your preferred location

## 📱 Step 2: Add Android App to Firebase

1. In Firebase Console, click **Project Settings** (gear icon)
2. Under **Your apps**, click **Add app** → **Android**
3. Register your app with these details:
   - **Android package name**: `com.dasinya.tv`
   - **App nickname**: `Dasinya TV`
   - **Debug signing certificate SHA-1**: (Optional for now)
4. Click **Register app**

## 📥 Step 3: Download google-services.json

1. After registration, Firebase will provide `google-services.json`
2. Download this file
3. Place it in the following directory:
   ```
   android/app/google-services.json
   ```
   **IMPORTANT**: It must be in `android/app/` folder, NOT in `android/` root!

## 🗂️ Step 4: Create Firestore Database Structure

In Firebase Console → Firestore Database → Start collection:

### Collection: `videos`

Create documents with this structure:

#### Example 1: Live TV Channel
```json
{
  "title": "Dasinya News",
  "description": "24/7 News Coverage",
  "thumbnailUrl": "https://i.ibb.co/MkmXyttP/5278332249655342554-removebg-preview.png",
  "logoUrl": "https://i.ibb.co/MkmXyttP/5278332249655342554-removebg-preview.png",
  "videoUrl": "https://your-stream-url.com/news.m3u8",
  "category": "News",
  "duration": "LIVE",
  "uploadDate": "2026-01-26T00:00:00Z",
  "isLive": true,
  "featured": true,
  "viewers": 2500
}
```

#### Example 2: Archive Video
```json
{
  "title": "Breaking News Special",
  "description": "Latest breaking news coverage from today",
  "thumbnailUrl": "https://via.placeholder.com/300x450?text=News",
  "videoUrl": "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
  "category": "News",
  "duration": "45:30",
  "uploadDate": "2026-01-25T12:00:00Z",
  "isLive": false,
  "featured": false,
  "viewers": 1200
}
```

### Required Fields Explanation:

| Field | Type | Description |
|-------|------|-------------|
| `title` | String | Video/Channel name |
| `description` | String | Brief description |
| `thumbnailUrl` | String | Full URL to thumbnail image |
| `logoUrl` | String | (Optional) Channel logo URL for live streams |
| `videoUrl` | String | HLS stream URL (.m3u8) |
| `category` | String | Category (News, Sports, Movies, etc.) |
| `duration` | String | Format: "HH:MM:SS" or "LIVE" |
| `uploadDate` | Timestamp | Firestore timestamp |
| `isLive` | Boolean | true = Live Stream, false = Archive |
| `featured` | Boolean | true = Show in hero section |
| `viewers` | Number | Current viewer count |

## 🛡️ Step 5: Firestore Security Rules (Development)

In Firebase Console → Firestore Database → Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to all users
    match /videos/{videoId} {
      allow read: if true;
      allow write: if false; // Only admin can write
    }
  }
}
```

**For Production**, you'll want to add authentication.

## 🔐 Step 6: Firestore Indexes (Optional but Recommended)

If you get index errors, Firebase will provide a direct link to create them. Or manually create:

### Index 1: Live Channels
- **Collection**: `videos`
- **Fields**:
  - `isLive` (Ascending)
  - `uploadDate` (Descending)

### Index 2: Archive by Category
- **Collection**: `videos`
- **Fields**:
  - `isLive` (Ascending)
  - `category` (Ascending)
  - `uploadDate` (Descending)

## 🚀 Step 7: Run Your App

```bash
# Clean and rebuild
flutter clean
flutter pub get

# Run on Android
flutter run
```

## 📊 Step 8: Add Sample Data (Quick Start)

Use Firebase Console to add these documents quickly:

### 4 Live Channels:
1. **Dasinya News** (isLive: true, featured: true)
2. **Dasinya Sports** (isLive: true)
3. **Dasinya Kids** (isLive: true)
4. **Dasinya Music** (isLive: true)

### 6 Archive Videos:
1. **Breaking News** (isLive: false, category: "News")
2. **Sports Highlights** (isLive: false, category: "Sports")
3. **Movie Night** (isLive: false, category: "Movies")
4. **Music Festival** (isLive: false, category: "Music")
5. **Documentary** (isLive: false, category: "Documentary")
6. **Kids Show** (isLive: false, category: "Kids")

## 🎯 Expected Results

✅ **Home Screen**:
- Hero section shows the featured live stream
- "Live TV Channels" section displays all videos where `isLive = true`
- "Video Archive" preview shows recent videos where `isLive = false`

✅ **Archive Tab**:
- Grid view of all archive videos
- Real-time updates when videos are added/removed

✅ **Loading States**:
- Beautiful shimmer effect while data loads
- Error messages if no internet or Firestore issues

## 🐛 Troubleshooting

### Error: "No Firebase App"
- Ensure `google-services.json` is in `android/app/`
- Run `flutter clean` and rebuild

### Error: "Permission Denied"
- Check Firestore Security Rules
- Ensure rules allow read access

### Error: "Missing Index"
- Click the link in the error message
- Firebase will create the index automatically

### Error: "No videos showing"
- Check Firestore data exists
- Verify field names match exactly (case-sensitive)
- Check `uploadDate` is Firestore Timestamp type

## 🔄 How to Update Data

### Add New Live Channel:
```javascript
{
  "isLive": true,
  "featured": false,
  // ... other fields
}
```

### Add New Archive Video:
```javascript
{
  "isLive": false,
  "featured": false,
  // ... other fields
}
```

### Make a Channel Featured:
```javascript
{
  "featured": true,
  // This will show in the hero section
}
```

## 📝 Notes

- **Test Mode**: Firestore rules allow all reads for 30 days
- **Production**: Implement Firebase Authentication
- **Performance**: Enable offline persistence (already configured)
- **Monitoring**: Check Firebase Console → Usage tab

## 🎨 Customization

All Firebase calls are in:
- `lib/services/firebase_service.dart` - Main service
- `lib/screens/home_screen.dart` - UI implementation

Modify queries in `firebase_service.dart` to customize data fetching.

---

## ✨ You're All Set!

Your Dasinya TV app is now powered by Firebase Firestore with real-time updates! 🎉
