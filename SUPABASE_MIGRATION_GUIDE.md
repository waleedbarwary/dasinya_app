# 🚀 Complete Supabase Migration Guide

## ✅ What's Been Done:

### 1. Dependencies Updated ✓
- Removed: `firebase_core`, `cloud_firestore`, `firebase_storage`  
- Added: `supabase_flutter: ^2.0.0`

### 2. main.dart Updated ✓
- Replaced Firebase initialization with Supabase
- **You need to add your credentials:**

```dart
await Supabase.initialize(
  url: 'YOUR_SUPABASE_URL',        // ← Add this
  anonKey: 'YOUR_SUPABASE_ANON_KEY', // ← Add this
);
```

### 3. VideoModel Migrated ✓
- Changed `fromFirestore()` → `fromMap()`
- Changed `toFirestore()` → `toMap()`
- Now works with Supabase JSON

### 4. SupabaseService Created ✓
- Complete replacement for FirebaseService
- Methods: `getLiveChannels()`, `getArchiveVideos()`, `uploadFile()`, `addVideo()`

### 5. home_screen.dart Updated ✓
- Using `SupabaseService` instead of `FirebaseService`

---

## 🔧 What YOU Need to Do:

### Step 1: Get Supabase Credentials

1. Go to [supabase.com](https://supabase.com)
2. Create a new project (or use existing)
3. Go to **Settings → API**
4. Copy:
   - **Project URL** (e.g., `https://abcdefgh.supabase.co`)
   - **anon/public key** (starts with `eyJ...`)

### Step 2: Update main.dart

```dart
await Supabase.initialize(
  url: 'https://YOUR-PROJECT.supabase.co',
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
);
```

### Step 3: Create Database Table

Run this SQL in **Supabase → SQL Editor:**

```sql
-- Create videos table
CREATE TABLE public.videos (
  id BIGSERIAL PRIMARY KEY,
  title TEXT NOT NULL,
  description TEXT DEFAULT '',
  url TEXT NOT NULL,
  thumbnail_url TEXT,
  logo_url TEXT,
  category TEXT DEFAULT 'General',
  duration TEXT DEFAULT '00:00',
  upload_date TIMESTAMPTZ DEFAULT NOW(),
  is_live BOOLEAN DEFAULT FALSE,
  featured BOOLEAN DEFAULT FALSE,
  viewers INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Allow public read access"
  ON public.videos
  FOR SELECT
  USING (true);

-- Allow authenticated uploads (for admin)
CREATE POLICY "Allow authenticated insert"
  ON public.videos
  FOR INSERT
  WITH CHECK (auth.role() = 'authenticated' OR true);

CREATE POLICY "Allow authenticated update"
  ON public.videos
  FOR UPDATE
  USING (auth.role() = 'authenticated' OR true);
```

### Step 4: Create Storage Bucket

In **Supabase → Storage:**

1. Create bucket named: `media`
2. **Make it public**
3. Set policies:

```sql
-- Allow public read
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
USING (bucket_id = 'media');

-- Allow authenticated write
CREATE POLICY "Authenticated write access"
ON storage.objects FOR INSERT
WITH CHECK (bucket_id = 'media');
```

### Step 5: Update Admin Dashboard

The admin dashboard needs complete rewrite for Supabase.  
Create new file: `lib/screens/admin/admin_dashboard_screen_supabase.dart`

**Key changes:**
- Replace `FirebaseStorage` with `Supabase.instance.client.storage`
- Replace `FirebaseFirestore` with `Supabase.instance.client.from('videos')`
- Use `SupabaseService().uploadThumbnail()` and `uploadVideo()`
- Use `SupabaseService().addVideo()` to insert data

**Example upload:**

```dart
// OLD (Firebase):
final ref = FirebaseStorage.instance.ref().child('path');
await ref.putFile(file);
final url = await ref.getDownloadURL();

// NEW (Supabase):
final url = await _supabaseService.uploadThumbnail(file);
// or
final url = await _supabaseService.uploadVideo(file);
```

**Example insert:**

```dart
// OLD (Firebase):
await FirebaseFirestore.instance.collection('videos').add({...});

// NEW (Supabase):
await _supabaseService.addVideo(
  title: title,
  url: url,
  thumbnailUrl: thumbnailUrl,
  category: category,
  duration: duration,
  isLive: true,
);
```

### Step 6: Run Commands

```bash
# Stop app
# Then clean
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run
```

---

## 📊 Database Schema:

```
videos table:
├── id (bigserial, primary key)
├── title (text, required)
├── description (text)
├── url (text, required)
├── thumbnail_url (text)
├── logo_url (text)
├── category (text)
├── duration (text)
├── upload_date (timestamptz)
├── is_live (boolean)
├── featured (boolean)
├── viewers (integer)
└── created_at (timestamptz)
```

## 🗄️ Storage Structure:

```
media/ (bucket)
├── thumbnails/
│   ├── 1706280000000_image.jpg
│   └── ...
└── videos/
    ├── 1706280000000_video.mp4
    └── ...
```

---

## 🔒 Security (RLS Policies):

### For Testing (Open Access):
```sql
-- Allow anyone to read
CREATE POLICY "Public read" ON videos
  FOR SELECT USING (true);

-- Allow anyone to write (TEMPORARY!)
CREATE POLICY "Public write" ON videos
  FOR INSERT WITH CHECK (true);
```

### For Production (Secure):
```sql
-- Only allow authenticated users to write
CREATE POLICY "Authenticated write" ON videos
  FOR INSERT 
  WITH CHECK (auth.role() = 'authenticated');
```

---

## 🐛 Troubleshooting:

### "Invalid API key" Error:
- Check your `anon` key is correct
- Check `url` doesn't have trailing slash

### "relation videos does not exist":
- Run the SQL table creation script
- Check table is in `public` schema

### "new row violates row-level security policy":
- Disable RLS temporarily for testing:
  ```sql
  ALTER TABLE videos DISABLE ROW LEVEL SECURITY;
  ```

### Storage upload fails:
- Check bucket is public
- Check RLS policies on `storage.objects`
- Check bucket name is exactly `media`

---

## 📝 Migration Checklist:

- [x] 1. Update pubspec.yaml
- [x] 2. Update main.dart
- [x] 3. Update VideoModel
- [x] 4. Create SupabaseService
- [x] 5. Update home_screen.dart
- [ ] 6. Get Supabase credentials
- [ ] 7. Create videos table
- [ ] 8. Create storage bucket
- [ ] 9. Update admin dashboard
- [ ] 10. Migrate existing data (if any)
- [ ] 11. Test live streams
- [ ] 12. Test archive uploads
- [ ] 13. Test admin panel

---

## 🎉 After Migration:

Your app will:
- ✅ Use Supabase instead of Firebase
- ✅ Have real-time updates
- ✅ Support file uploads
- ✅ Work with admin panel
- ✅ No Firebase billing restrictions!

---

## 💰 Cost Comparison:

**Firebase:** Regional restrictions, complex pricing  
**Supabase:** 500MB database + 1GB storage FREE forever!

Upgrade to Pro ($25/month) for:
- 8GB database
- 100GB storage
- 50GB bandwidth

---

Need help? Check:
- [Supabase Docs](https://supabase.com/docs)
- [Flutter Supabase](https://supabase.com/docs/guides/getting-started/quickstarts/flutter)
