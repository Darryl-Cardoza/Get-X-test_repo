# GetX Flutter Boilerplate

> **A robust Flutter starter template** leveraging GetX and Clean Architecture for scalable, maintainable, and testable mobile applications.

---

## 📦 Project Structure

Organized by feature and layer, promoting separation of concerns:

```
lib/
├── core/                  # Shared utilities, services, constants
│   ├── bindings/          # Initial & global bindings
│   ├── constants/         # App-wide constants (URLs, keys)
│   ├── language/          # Localization service & JSON assets
│   ├── services/          # ApiService, StorageService, Config
│   ├── theme/             # Light & Dark ThemeData
│   └── utils/             # Validators, helpers
├── features/
│   └── auth/              # Authentication feature
│       ├── data/
│       │   ├── datasources/  # Remote & local data sources
│       │   └── repositories/ # Repo implementations
│       ├── domain/
│       │   ├── entities/     # Core business entities
│       │   ├── repositories/ # Abstractions
│       │   └── usecases/     # Business logic
│       └── presentation/
│           ├── bindings/     # Feature-specific bindings
│           ├── controllers/  # GetX controllers
│           ├── views/        # Pages & widgets
│           └── widgets/      # Reusable UI components
├── global_widgets/        # Shared widgets (e.g., FormInputField)
├── routes/                # AppRoutes & AppPages
└── main.dart              # App entry, GetMaterialApp
```

---

## 🚀 Features

- **GetX** for state management, routing, and dependency injection
- **Clean Architecture** layers: data, domain, presentation
- **Secure Storage** using `flutter_secure_storage` + encryption
- **HTTP Service** with retry, timeout, connectivity check, token injection
- **Localization** via JSON assets (`en_US.json`, `hr_HR.json`, etc.)
- **Theming**: Light & Dark modes, custom `AppTheme` configuration
- **Validators**: Email, password, URLs, numbers, dates, and more
- **Reusable Widgets**: e.g., `FormInputField`, `AppDialog`
- **Logging & Crash Reporting**: Masked logs + Firebase Crashlytics
- **Automations**: Scheduled tasks and reminders (optional)

---

## 🔧 Getting Started

1. **Clone the repo**

   ```bash
   git clone https://github.com/<your-org>/getx-flutter-boilerplate.git
   cd getx-flutter-boilerplate
   ```

2. **Install dependencies**

   ```bash
   flutter pub get
   ```

3. **Configure environment**

    - Add `.env` at project root with your API keys
    - Example `.env`:
      ```env
      API_BASE_URL=https://api.yourdomain.com
      GOOGLE_MAPS_API_KEY=YOUR_KEY
      ```

4. **Generate code (optional)**

   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

5. **Run on device/simulator**

   ```bash
   flutter run
   ```

---

## 🌐 Internationalization

- JSON translation files in `assets/lang/` (e.g., `en_US.json`, `hr_HR.json`)
- Loaded at startup via `LocalizationService.init()` in `main.dart`
- Usage: `Text('login'.tr)` displays translated string.

---

## 🔐 Security Best Practices

- **Secure Storage** for tokens & keys
- **TLS enforcement** & **certificate pinning** (Android/iOS configs)
- **Obfuscation** & **minification** on release builds
- **Mask logs** and **report errors** without PII

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/XYZ`)
3. Commit your changes (`git commit -m 'Add XYZ feature'`)
4. Push to the branch (`git push origin feature/XYZ`)
5. Create a Pull Request

Please follow the existing code style and write tests for new features.

---

## 📄 License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

Built with ❤️ by Rite Technologies

