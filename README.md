# 🎵 Wavr

Wavr is a modern offline-first music player designed to import, manage, download, and listen to playlists from multiple online sources while maintaining a clean and fast user experience.

---

## ✨ Features

### 📥 Playlist Import
- Import playlists from TXT files
- Import playlists from supported music platforms
- Automatic playlist parsing and validation

### 🎵 Music Library
- Local music management
- Album and playlist organization
- Favorites system
- Recently played tracking

### ⬇️ Offline Downloads
- Download tracks for offline listening
- Download progress tracking
- Download queue management
- Automatic file organization

### 🔎 Search
- Fast local search
- Playlist search
- Track filtering

### ⚡ Performance
- Offline-first architecture
- Local caching
- Optimized database queries
- Background processing

### 🎨 User Experience
- Modern Material Design interface
- Responsive layouts
- Dark mode support
- Smooth animations

---

## 🏗 Architecture

The project follows a clean and scalable architecture:

```
lib/
├── core/
├── data/
│   ├── models/
│   ├── repositories/
│   └── services/
├── features/
│   ├── import/
│   ├── library/
│   ├── player/
│   ├── search/
│   └── settings/
├── shared/
└── main.dart
```

---

## 🛠 Tech Stack

### Frontend
- Flutter
- Dart
- Material 3

### State Management
- Riverpod

### Local Storage
- SQLite
- SharedPreferences

### Audio
- just_audio
- audio_service
- audio_session

### Utilities
- file_picker
- permission_handler
- connectivity_plus
- workmanager

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Android SDK

### Installation

```bash
git clone https://github.com/CodeWrittter/wavr.git

cd wavr

flutter pub get
```

### Run

```bash
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

---

## 📱 Supported Platforms

- Android
- iOS (planned)
- Windows (planned)
- Linux (planned)
- macOS (planned)

---

## 📸 Screenshots

Coming soon.

---

## 🗺 Roadmap

- [ ] Playlist synchronization
- [ ] Multi-source support
- [ ] Smart recommendations
- [ ] Cloud backup
- [ ] Lyrics support
- [ ] Equalizer
- [ ] Android Auto support
- [ ] Wear OS support

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome.

---

## 📄 License

This project is licensed under the MIT License.

---

## 👨‍💻 Author

Borel (CodeWrittter)

Building the future of playlist management and offline music listening.
