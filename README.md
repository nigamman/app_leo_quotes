# Leo Quotes 🌟  
A beautifully designed motivational quotes app built with Flutter.

[![Play Store](https://img.shields.io/badge/Download-Play%20Store-blue?logo=google-play)](https://play.google.com/store/apps/details?id=com.nigamman.leoquotes)

Leo Quotes provides a curated collection of inspirational and motivational quotes to uplift your day. With a sleek interface, it's the perfect companion for daily positivity.

---

## ✨ Features

- 📝 **Curated Quotes**: Motivational, success, life, and wisdom quotes.
- 🔔 **Daily Quote Notifications**: Get inspired with daily reminders.
- 📱 **Home Screen Widget** *(Android)*: Displays quotes right on the user's home screen — updates regularly.
- ⚙️ **Background Tasks**: Powered by `workmanager` to refresh quotes in the widget.
- 📥 **Offline Access**: Works even without an internet connection.
- 🎨 **Polished UI/UX**: Smooth transitions, dark mode, and clean typography.
- 🔍 **Category Browsing**: Easily explore quotes by category.

---

## 🛠️ Tech Stack

- **Flutter** & **Dart**
- **State Management**: [Provider, Riverpod]
- **Local Storage**: [Shared Preferences, Firebase Realtime Database]
- **Push Notifications**: Onesignal
- **Animations**: Android UI toolkit, flutter widgets

---

## 📦 Packages Used

- `provider` – State management  
- `shared_preferences` – Local storage  
- `home_widget` – Android home screen widget integration  
- `workmanager` – Background task scheduling for widget updates  
- `flutter_local_notifications` – Daily quote notifications  
- `google_fonts` – Typography  
- `url_launcher` – External link handling  
- `animations` – UI transitions

---

## ⚙️ Technical Highlights

- Integrated a native **Android home widget** using the `home_widget` package.
- Quotes are refreshed on the home screen using **background workers** via the `workmanager` package.
- Built with **modular code structure**, clean architecture, and separation of concerns.

--- 

## 🚀 Getting Started

### Prerequisites:
- Flutter SDK (>=3.)5.3
- Android Studio / VS Code

### Setup:

```bash
git clone https://github.com/nigamman/app_leo_quotes.git
cd app_leo_quotes
flutter pub get
flutter run
