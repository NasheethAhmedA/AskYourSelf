# 🧠 AskYourSelf

A Flutter app to ask yourself meaningful questions daily, weekly, or monthly — and reflect over time with a built-in answer calendar. Fully open source and built with clean architecture, Provider state management, and a local SQLite database.

---

## ✨ Features

- 📝 Add custom questions
- ❓ Answer them with various types:
  - Multiple Choice (MCQ)
  - Multiple Select (MSQ)
  - Paragraph / Long text
  - Rating
  - Slider
- ⏰ Set when to be asked again (daily, weekly, monthly)
- 📆 Calendar view to see your answer history
- 🔁 Automatically hides answered questions until the next cycle
- 💾 Offline-first with `sqflite` support
- 🖥️ Compatible with Flutter Web via `sqflite_common_ffi_web`

---

## 📦 Tech Stack

- Flutter 3.x (Material Design)
- Provider (state management)
- SQFLite + sqflite_common_ffi_web (local persistence)
- Modular architecture & clean code practices

---

## 🚀 Getting Started

### 1. Clone the Repo
```bash
git clone https://github.com/NasheethAhmedA/AskYourSelf.git
````

### 2. Navigate to project directory
```bash
cd AskYourSelf
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Run It

```bash
flutter run
```

---

## 📁 Project Structure

```
lib/
├── core/               # Theming & core utilities
├── db/                 # SQLite database helper
├── models/             # Data models
├── providers/          # State management (Provider)
├── screens/            # UI screens
├── widgets/            # Reusable widgets
└── main.dart           # App entry point
```

---

## 🤝 Contributing

Contributions are welcome! Feel free to fork, submit pull requests, report issues, or suggest features.

---

## 📃 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
