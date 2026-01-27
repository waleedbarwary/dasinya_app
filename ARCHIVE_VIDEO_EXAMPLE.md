# 📺 نموونەی زیادکردنی Video لە Firestore

## 🔴 Live TV Channel:

```json
{
  "title": "Dasinya News",
  "description": "24/7 Kurdish News Channel",
  "url": "https://your-stream-url.com/live.m3u8",
  "thumbnailUrl": "https://i.ibb.co/xyz/logo.png",
  "logoUrl": "https://i.ibb.co/xyz/logo.png",
  "category": "News",
  "duration": "LIVE",
  "uploadDate": "2024-01-26T00:00:00Z",
  "isLive": true,
  "featured": true,
  "viewers": 0
}
```

---

## 📚 Archive Video:

```json
{
  "title": "Kurdish Movie - Love Story",
  "description": "A romantic Kurdish drama about...",
  "url": "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8",
  "thumbnailUrl": "https://i.ibb.co/xyz/movie-poster.jpg",
  "category": "Drama",
  "duration": "2h 15m",
  "uploadDate": "2024-01-20T10:30:00Z",
  "isLive": false,
  "featured": false,
  "viewers": 0
}
```

---

## 📚 More Archive Videos:

### Documentary:
```json
{
  "title": "Kurdistan History",
  "description": "Documentary about Kurdish culture",
  "url": "https://your-video-url.com/documentary.m3u8",
  "thumbnailUrl": "https://i.ibb.co/xyz/doc-poster.jpg",
  "category": "Documentary",
  "duration": "45m",
  "uploadDate": "2024-01-15T14:00:00Z",
  "isLive": false,
  "featured": false,
  "viewers": 0
}
```

### Action Movie:
```json
{
  "title": "Kurdish Action - Hero",
  "description": "Action-packed Kurdish film",
  "url": "https://your-video-url.com/action.m3u8",
  "thumbnailUrl": "https://i.ibb.co/xyz/action-poster.jpg",
  "category": "Action",
  "duration": "1h 50m",
  "uploadDate": "2024-01-10T18:00:00Z",
  "isLive": false,
  "featured": false,
  "viewers": 0
}
```

### Comedy Show:
```json
{
  "title": "Kurdish Comedy Night",
  "description": "Funny Kurdish comedy show",
  "url": "https://your-video-url.com/comedy.m3u8",
  "thumbnailUrl": "https://i.ibb.co/xyz/comedy-poster.jpg",
  "category": "Comedy",
  "duration": "1h 20m",
  "uploadDate": "2024-01-05T20:00:00Z",
  "isLive": false,
  "featured": false,
  "viewers": 0
}
```

---

## 🎯 چۆن لە Firebase Console زیاد بکەیت:

### **هەنگاوەکان:**

1. **بڕۆ بۆ:** https://console.firebase.google.com/project/dasinya-tv/firestore
2. **کلیک لەسەر:** `videos` collection
3. **کلیک لەسەر:** "Add document"
4. **Document ID:** "Auto-ID" بهێڵەوە
5. **فیلدەکان زیاد بکە:**

   **Field 1:**
   - Field name: `title`
   - Field type: `string`
   - Value: `Kurdish Movie - Love Story`

   **Field 2:**
   - Field name: `description`
   - Field type: `string`
   - Value: `A romantic Kurdish drama...`

   **Field 3:**
   - Field name: `url`
   - Field type: `string`
   - Value: `https://your-video-url.com/movie.m3u8`

   **Field 4:**
   - Field name: `thumbnailUrl`
   - Field type: `string`
   - Value: `https://i.ibb.co/xyz/poster.jpg`

   **Field 5:**
   - Field name: `category`
   - Field type: `string`
   - Value: `Drama`

   **Field 6:**
   - Field name: `duration`
   - Field type: `string`
   - Value: `2h 15m`

   **Field 7:**
   - Field name: `uploadDate`
   - Field type: `timestamp`
   - Value: [Click calendar icon, select date]

   **Field 8:** ⚠️ **زۆر گرنگ!**
   - Field name: `isLive`
   - Field type: `boolean` (نەک string!)
   - Value: `false` ✓

   **Field 9:**
   - Field name: `featured`
   - Field type: `boolean`
   - Value: `false` ✓

   **Field 10:**
   - Field name: `viewers`
   - Field type: `number`
   - Value: `0`

6. **کلیک لەسەر:** "Save"

---

## 🔗 لینکە بەکارهاتووەکان بۆ تاقیکردنەوە:

### Sample Video URLs (بۆ تاقیکردنەوە):
```
https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8

https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8

https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8
```

### Sample Image URLs (بۆ Poster/Thumbnail):
```
https://i.ibb.co/MkmXyttP/5278332249655342554-removebg-preview.png

https://picsum.photos/400/600
```

---

## ✅ پاش زیادکردن:

- **ئەپەکە خۆکار دەتوانێتەوە** (real-time)
- **بڕۆ بۆ Archive tab** لە ئەپەکە
- **ویدیۆکانت دەبینیت!** 🎉

---

## 🎨 Tips:

### **بۆ Poster باش:**
- **Aspect Ratio:** 2:3 (وەک Netflix)
- **Resolution:** 400x600px یان 800x1200px
- **Format:** JPG یان PNG

### **بۆ Video URL:**
- **Format:** .m3u8 (HLS)
- **پێویستە:** HTTPS بێت
- **تاقی بکەوە** پێش زیادکردن

---

## 📊 Firestore Security Rules:

ئەگەر پێویستت بە write access بوو بۆ ئەپەکە (بۆ ئایندە):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /videos/{video} {
      // پێشتر: read ڕێگەدراو بوو، write نا
      allow read: if true;
      
      // ئەگەر بتەوێت لە ئەپەکەوە زیاد بکەیت:
      // allow write: if request.auth != null; // تەنها لاگین کراوەکان
    }
  }
}
```

---

## 🚀 دواتر:

ئەگەر زۆر ویدیۆ هەبێت و بتەوێت بە bulk زیاد بکەیت، دەتوانم کۆدێکت بۆ بنووسم!
