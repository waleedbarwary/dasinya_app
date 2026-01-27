# 🚀 گۆڕینی Backend بۆ Supabase - ڕێنمای کوردی

## ✅ چی دروستکرا:

هەموو کۆدەکە گۆڕا لە Firebase بۆ Supabase!

- ❌ Firebase لابرا
- ✅ Supabase زیادکرا
- ✅ هەموو شتێک کار دەکات (Live TV + Archive + Admin)
- ✅ UI هەر وەک خۆی مایەوە (هیچ گۆڕانکاری لە دیزاین نییە)

---

## 🎯 ئێستا تۆ چی بکەیت؟

### 1️⃣ **Supabase Account دروست بکە** (5 خولەک)

1. بڕۆ بۆ: https://supabase.com
2. **"Start your project"** بکە
3. Account دروست بکە (بە Gmail)
4. **"New Project"** بکە
5. **Name:** بنووسە "Dasinya TV"
6. **Database Password:** پاسوۆردێک دانە و **بیپارێزە!**
7. **Region:** هەڵبژێرە (باشترین: Europe)
8. **"Create"** بکە
9. چاوەڕوانی 2 خولەک

---

### 2️⃣ **دووکەی تایبەت وەربگرە** (1 خولەک)

1. لە Supabase، بڕۆ بۆ: **Settings** (⚙️) → **API**
2. **ئەم دووانە کۆپی بکە:**

```
Project URL:  https://XXXX.supabase.co
anon key:     eyJhbGciOiJIUzI1NiIsInR5...
```

3. **بکەرەوە:** `lib/main.dart`
4. **بیلکێنە ئێرە:**

```dart
await Supabase.initialize(
  url: 'https://XXXX.supabase.co',           // ← لێرە
  anonKey: 'eyJhbGciOiJIUzI1NiIsInR5...',  // ← لێرە
);
```

**Save بکە!** (Ctrl+S)

---

### 3️⃣ **Database Table دروست بکە** (2 خولەک)

1. لە Supabase، بڕۆ بۆ: **SQL Editor** (لە لای چەپ)
2. **"New Query"** بکە
3. **ئەم کۆدە کۆپی بکە و بیلکێنە:**

```sql
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

ALTER TABLE public.videos ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read access" ON public.videos
  FOR SELECT USING (true);

CREATE POLICY "Public write access" ON public.videos
  FOR ALL USING (true) WITH CHECK (true);

CREATE INDEX idx_videos_is_live ON public.videos(is_live);
CREATE INDEX idx_videos_upload_date ON public.videos(upload_date DESC);
```

4. **Run** بکە (یان Ctrl+Enter)
5. دەبینیت: "Success"

---

### 4️⃣ **Storage Bucket دروست بکە** (2 خولەک)

1. لە Supabase، بڕۆ بۆ: **Storage**
2. **"New bucket"** بکە
3. **Name:** بنووسە **media** (وردبە!)
4. **Public bucket:** تیک بکە ✓
5. **Create** بکە

6. کلیک لەسەر **media** bucket
7. بڕۆ بۆ **Policies**
8. **"New policy"** بکە
9. هەڵبژێرە: **"Allow public read"**
10. **Save** بکە

11. دوبارە **"New policy"** بکە
12. هەڵبژێرە: **"Allow all operations"**
13. **Save** بکە

---

### 5️⃣ **ئەپەکە بکەرەوە!** (3 خولەک)

لە **Android Studio Terminal**، بنووسە:

```bash
flutter clean
```

چاوەڕوانی...

```bash
flutter pub get
```

چاوەڕوانی...

```bash
flutter run
```

**ئێستا ئەپەکە دەکەوێتەوە!** 🎉

---

## ✅ تاقیکردنەوە:

### تاقی 1: Admin Panel
1. **Long-press** لەسەر "DASINYA TV" logo
2. **Login:**
   - Username: `dasinyatv`
   - Password: `Dasinya$12`
3. دەبێت بچێتە ژوورەوە ✓

### تاقی 2: Live Stream زیاد بکە
1. بڕۆ بۆ **LIVE STREAM** tab
2. **Title:** بنووسە "Test Channel"
3. **Stream URL:** بلکێنە:
   ```
   https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8
   ```
4. **Category:** بنووسە "Test"
5. **Thumbnail** هەڵبژێرە
6. **Upload Live Stream** بکە
7. دەبینیت: "Live stream added successfully! 🎉"
8. بگەڕێوە بۆ Home → Channel ەکەت دەبینیت! ✓

### تاقی 3: Archive Video زیاد بکە
1. بڕۆ بۆ **ARCHIVE VIDEO** tab
2. **Title:** بنووسە "Test Video"
3. **Category:** بنووسە "Test"
4. **Duration:** بنووسە "45m"
5. **Thumbnail** هەڵبژێرە
6. **Video** هەڵبژێرە لە gallery
7. **Upload Archive Video** بکە
8. **سەیری Progress Bar بکە** (0% → 100%) ⏳
9. دەبینیت: "Archive video uploaded successfully! 🎉"
10. بڕۆ بۆ Archive tab → ویدیۆکەت دەبینیت! ✓

---

## 🐛 ئەگەر هەڵە هەبوو:

### "Invalid API key"
**چارەسەر:** پشتڕاست بکەرەوە URL و anonKey لە `main.dart`

### "relation videos does not exist"
**چارەسەر:** SQL کۆدەکە دوبارە Run بکە

### "Row Level Security policy violation"
**چارەسەر:** پشتڕاست بکەرەوە هەموو SQL کە Run کراوە

### "Storage bucket not found"
**چارەسەر:** Bucket ەکە دڵنیابە ناوی **media** یە (بچووک)

### Upload کار ناکات
**چارەسەر:**
1. Bucket **public** بێت
2. Storage policies دروست بن
3. ئینتەرنێت کار بکات

---

## 📊 داتاکانت لە Supabase پشکنین:

### Database:
1. **Table Editor** بکەرەوە
2. **videos** table هەڵبژێرە
3. داتاکانت دەبینیت

### Storage:
1. **Storage** → **media** بکەرەوە
2. دەبینیت:
   - `thumbnails/` folder
   - `videos/` folder
3. فایلەکانت لە ناویانەوە

---

## 💰 نرخەکان:

**بەخۆڕایی:**
- 500MB database
- 1GB storage
- Realtime updates
- بۆ هەمیشە بەخۆڕایی! 🎉

**Pro ($25/مانگ):**
- 8GB database
- 100GB storage

---

## 🎉 تەواو بوو!

ئێستا ئەپەکەت **بەبێ Firebase** کار دەکات!

**سوودەکانی:**
- ✅ لە هەموو دونیادا کار دەکات (بێ سنووردار)
- ✅ هەرزانتر
- ✅ Real-time updates
- ✅ Open-source

---

## 📝 یارمەتی زیاتر:

- سەیری **MIGRATION_COMPLETE.md** بکە (بە ئینگلیزی)
- سەیری **SUPABASE_MIGRATION_GUIDE.md** بکە (وردەکاری زیاتر)

---

**هەر پرسیارێک هەبوو، پێم بڵێ!** 😊

**بە خێر هاتیت بۆ Supabase!** 🚀
