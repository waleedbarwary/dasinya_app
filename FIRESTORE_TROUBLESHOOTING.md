# 🔥 Firestore Troubleshooting Guide

## Error: "Error loading channels"

### Quick Fixes:

#### 1. Check Firestore Security Rules

Go to Firebase Console → Firestore Database → Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /videos/{videoId} {
      allow read: if true;
      allow write: if false;
    }
  }
}
```

Click **Publish**!

---

#### 2. Verify Collection Name

- Must be exactly: `videos` (lowercase)
- NOT: `Videos`, `video`, `VIDEOS`

---

#### 3. Check Data Structure

Each document needs these fields:

| Field | Type | Example | Required |
|-------|------|---------|----------|
| title | string | "Dasinya News" | ✅ |
| description | string | "Live News 24/7" | ✅ |
| thumbnailUrl | string | "https://..." | ✅ |
| logoUrl | string | "https://..." | ✅ (for live) |
| videoUrl | string | "https://...m3u8" | ✅ |
| category | string | "News" | ✅ |
| duration | string | "LIVE" | ✅ |
| uploadDate | **timestamp** | (current time) | ✅ |
| isLive | **boolean** | true | ✅ |
| featured | **boolean** | false | ✅ |
| viewers | **number** | 0 | ✅ |

⚠️ **Common Mistakes:**
- ❌ `isLive: "true"` (string) → ✅ `isLive: true` (boolean)
- ❌ `viewers: "0"` (string) → ✅ `viewers: 0` (number)
- ❌ `uploadDate: "2026-01-26"` (string) → ✅ `uploadDate: Timestamp`

---

#### 4. Test Rules

In Firebase Console → Firestore Database → Rules Playground:

```
Simulator: GET
Location: /videos/testDoc
```

Should show: ✅ **Allowed**

---

#### 5. Check Network

Run in terminal:
```bash
flutter run --verbose
```

Look for errors containing:
- `FirebaseException`
- `permission-denied`
- `FIRESTORE`

---

## Sample Document (Copy & Paste)

```javascript
{
  "title": "Dasinya News",
  "description": "Live News 24/7",
  "thumbnailUrl": "https://i.ibb.co/MkmXyttP/5278332249655342554-removebg-preview.png",
  "logoUrl": "https://i.ibb.co/MkmXyttP/5278332249655342554-removebg-preview.png",
  "videoUrl": "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
  "category": "News",
  "duration": "LIVE",
  "uploadDate": "SERVER_TIMESTAMP",
  "isLive": true,
  "featured": true,
  "viewers": 0
}
```

---

## Still Not Working?

### Check Debug Console

In Android Studio → Run → Debug Console

Look for:
```
[ERROR:flutter/...] Unhandled Exception: 
FirebaseException: [permission-denied]
```

### Solution:
1. Firebase Console → Firestore → Rules
2. Change `allow read: if false;` to `allow read: if true;`
3. Publish

---

## Test Firestore Connection

Add this test code in `firebase_service.dart`:

```dart
// Test connection
Future<void> testConnection() async {
  try {
    print('Testing Firestore connection...');
    final snapshot = await _firestore.collection('videos').limit(1).get();
    print('✅ Success! Documents found: ${snapshot.docs.length}');
    if (snapshot.docs.isNotEmpty) {
      print('First document: ${snapshot.docs.first.data()}');
    }
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

Call it from home_screen.dart:
```dart
@override
void initState() {
  super.initState();
  _firebaseService.testConnection(); // Add this
  // ... rest of init
}
```

---

## Success Checklist

- [ ] Firestore Rules allow read: true
- [ ] Collection named exactly: `videos`
- [ ] At least one document with all required fields
- [ ] uploadDate is Firestore Timestamp
- [ ] isLive and featured are boolean
- [ ] viewers is number
- [ ] All URLs are valid strings
- [ ] App has internet connection
- [ ] Firebase initialized in main.dart

---

If all else fails, share the error message from Debug Console!
