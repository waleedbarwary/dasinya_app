# 🔐 Admin Panel Setup Guide

## 📱 Features Implemented:

✅ **Secret Admin Access:** Long-press on "DASINYA TV" logo to access admin login
✅ **Secure Login:** Hardcoded credentials (no Firebase Auth needed)
✅ **Live Stream Upload:** Add live TV channels with thumbnails
✅ **Archive Video Upload:** Upload full videos with progress indicator
✅ **Real-time Sync:** Uploads instantly appear in the app

---

## 🚀 How to Use:

### 1️⃣ **Access Admin Panel:**
- Open the app
- **Long-press** on "DASINYA TV" logo at the top
- You'll be taken to the login screen

### 2️⃣ **Login Credentials:**
```
Username: dasinyatv
Password: Dasinya$12
```

### 3️⃣ **Upload Live Stream:**
1. Go to "LIVE STREAM" tab
2. Fill in:
   - Title (required)
   - Stream URL (required) - e.g., `https://example.com/stream.m3u8`
   - Category (optional)
   - Description (optional)
3. Select Thumbnail Image
4. Tap "Upload Live Stream"
5. Done! ✅

### 4️⃣ **Upload Archive Video:**
1. Go to "ARCHIVE VIDEO" tab
2. Fill in:
   - Title (required)
   - Category (optional)
   - Duration (optional) - e.g., "1h 30m"
   - Description (optional)
3. Select Thumbnail Image
4. **Select Video File** from gallery
5. Tap "Upload Archive Video"
6. **Wait for upload** (progress bar shows %)
7. Done! ✅

---

## 🔧 Setup Requirements:

### 1️⃣ **Install Dependencies:**

Run in terminal:
```bash
flutter pub get
```

This installs:
- `image_picker` - Pick images and videos
- `firebase_storage` - Upload files to Firebase

### 2️⃣ **Update Firebase Storage Rules:**

Go to: **Firebase Console → Storage → Rules**

Replace with:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /uploads/{allPaths=**} {
      // Allow anyone to read uploaded files
      allow read: if true;
      
      // Allow authenticated users to write
      // For now, allow all writes (change this in production!)
      allow write: if true;
    }
  }
}
```

**⚠️ IMPORTANT:** In production, you should add proper authentication!

For now, since we're using hardcoded admin login (not Firebase Auth), we allow all writes. 

**Better production rule:**
```javascript
// Only allow writes from specific IPs or with valid token
allow write: if request.auth != null;
```

### 3️⃣ **Android Permissions:**

Already added in `AndroidManifest.xml`:
- `INTERNET`
- `READ_EXTERNAL_STORAGE`
- `WRITE_EXTERNAL_STORAGE`

If you get permission errors, make sure your `AndroidManifest.xml` has:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.CAMERA"/>
```

---

## 📁 Storage Structure:

Files are uploaded to Firebase Storage:

```
uploads/
├── thumbnails/
│   ├── thumbnail_1706280000000.jpg
│   ├── thumbnail_1706280000001.jpg
│   └── ...
└── videos/
    ├── video_1706280000000.mp4
    ├── video_1706280000001.mp4
    └── ...
```

---

## 🎯 Testing:

### Test Live Stream:
```
Title: Test Live Channel
Stream URL: https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8
Category: Test
```

### Test Archive Video:
1. Pick any video from your gallery
2. Upload with title "Test Video"
3. Check Archive tab in main app

---

## 🔒 Security Notes:

### ⚠️ Current Setup (Development):
- Hardcoded credentials in code
- No Firebase Authentication
- Storage rules allow all writes

### ✅ Production Recommendations:
1. **Use Firebase Authentication:**
   - Implement proper user authentication
   - Add admin role/claims
   - Check `request.auth.token.admin == true` in rules

2. **Secure Storage Rules:**
   ```javascript
   allow write: if request.auth != null && 
                   request.auth.token.admin == true;
   ```

3. **Move Credentials to Backend:**
   - Don't hardcode passwords in the app
   - Use Firebase Functions for admin verification
   - Implement rate limiting

4. **Add Input Validation:**
   - Validate URLs
   - Check file sizes
   - Restrict file types

---

## 🐛 Troubleshooting:

### "Permission denied" error:
- Check Firebase Storage rules (see step 2️⃣ above)
- Make sure `firebase_storage` is in `pubspec.yaml`
- Run `flutter pub get`

### "Image picker not working":
- Check AndroidManifest.xml permissions
- For iOS, add to `ios/Runner/Info.plist`:
  ```xml
  <key>NSPhotoLibraryUsageDescription</key>
  <string>We need access to your photos to upload videos</string>
  <key>NSCameraUsageDescription</key>
  <string>We need access to your camera</string>
  ```

### Upload stuck at 0%:
- Check internet connection
- Check Firebase Storage rules
- Look at debug console for errors

### Video not showing in app:
- Check that `isLive` field is set correctly (true for live, false for archive)
- Verify `uploadDate` field exists (should be auto-set)
- Check Firestore rules allow read access

---

## 📊 Firestore Data Structure:

### Live Stream Document:
```json
{
  "title": "Channel Name",
  "description": "Description",
  "url": "https://stream-url.com/live.m3u8",
  "thumbnailUrl": "https://storage.googleapis.com/.../thumbnail.jpg",
  "logoUrl": "https://storage.googleapis.com/.../thumbnail.jpg",
  "category": "News",
  "duration": "LIVE",
  "uploadDate": Timestamp,
  "isLive": true,
  "featured": false,
  "viewers": 0
}
```

### Archive Video Document:
```json
{
  "title": "Video Title",
  "description": "Description",
  "url": "https://storage.googleapis.com/.../video.mp4",
  "thumbnailUrl": "https://storage.googleapis.com/.../thumbnail.jpg",
  "category": "Drama",
  "duration": "1h 30m",
  "uploadDate": Timestamp,
  "isLive": false,
  "featured": false,
  "viewers": 0
}
```

---

## 🎉 Success!

You now have a fully functional admin panel to manage your content!

**No need to manually add documents in Firebase Console anymore!** 🚀
