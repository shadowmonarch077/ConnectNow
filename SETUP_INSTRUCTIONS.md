# 🚀 ConnectNow - Flutter Zoom Clone Setup Guide

## ⚡ Why This Version Works

The old `jitsi_meet_wrapper` package was **broken** on Flutter 3.x.  
This version uses **Agora RTC Engine** — which has native Flutter support, no JVM wrapper issues, and works out of the box.

---

## 📋 Step-by-Step Setup

### Step 1: Get Free Agora App ID (5 minutes)

1. Go to **[console.agora.io](https://console.agora.io)**
2. Sign up for free (no credit card needed)
3. Click **"New Project"** → give any name → select **"Testing mode"** (no token needed)
4. Copy the **App ID**

### Step 2: Add App ID to Code

Open `lib/resources/agora_methods.dart` and replace:
```dart
static const String agoraAppId = 'YOUR_AGORA_APP_ID';
```
With your actual App ID:
```dart
static const String agoraAppId = 'abc123xyz...';
```

### Step 3: Firebase Setup (Already configured with your keys)

The `google-services.json` from your original project is included.  
If you need to set it up fresh:
1. Go to **[Firebase Console](https://console.firebase.google.com)**
2. Open your project → Project Settings → Add Android app
3. Download `google-services.json` → place in `android/app/`
4. Enable **Google Sign-In** in Authentication
5. Enable **Firestore Database**

### Step 4: Run the App

```bash
flutter clean
flutter pub get
flutter run
```

---

## 🛠 Troubleshooting

### "Manifest merger failed"
→ Run `flutter clean && flutter pub get`

### Google Sign-In fails
→ Add your SHA-1 fingerprint to Firebase:
```bash
cd android && ./gradlew signingReport
```
Copy the SHA-1 → Firebase Console → Project Settings → Add fingerprint

### Agora video not showing
→ Make sure you granted Camera + Microphone permissions on device

---

## 📱 Features

- ✅ Google Sign-In with Firebase Auth
- ✅ Instant video meetings (Agora)
- ✅ Join existing meetings by Room ID
- ✅ Mute/unmute audio & video during call
- ✅ Flip camera
- ✅ Speaker toggle
- ✅ Meeting history (Firestore)
- ✅ Copy Room ID to clipboard
- ✅ Meta-style dark UI with purple/blue gradients
- ✅ Animated login screen
- ✅ Profile settings page

---

## 🎨 UI Highlights

- Dark theme with **Meta Horizon** inspired purple→blue gradient
- Glassmorphic cards
- Animated entrance on login
- Live indicator during calls
- PiP (Picture-in-Picture) local video view

---

## 📦 Dependencies Used

| Package | Purpose |
|---------|---------|
| `agora_rtc_engine` | Video calling (replaces broken Jitsi) |
| `firebase_auth` | Authentication |
| `cloud_firestore` | Meeting history |
| `google_sign_in` | OAuth sign-in |
| `permission_handler` | Camera/mic permissions |
| `intl` | Date formatting |
| `uuid` | Room ID generation |
