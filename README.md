# Expenz - Personal Expense & Financial Management App

A comprehensive, cross-platform mobile expense and budget tracker built with **Flutter**, **Dart**, and **Firebase Cloud Firestore**. The app provides intuitive expense/income logging, real-time keyword search, interactive charts, category budgeting, dark mode theming, and offline-first cloud synchronization.

---

## 📌 Project Overview
**Expenz** is designed to help users track their daily financial activity, manage expenses across customizable categories, view real-time monthly spending totals, and visualize budget allocation using dynamic interactive charts.

---

## 🚀 Features Implemented

### 🌟 Core Requirements (100% Complete)
| Requirement | Status | Implementation Details |
| :--- | :---: | :--- |
| **Add New Expenses** | ✅ Complete | Dynamic form with live amount preview, category selection, date & time pickers, and optional notes/description. |
| **Edit Existing Expenses** | ✅ Complete | Dedicated `EditExpenseScreen` with prefilled values, full form validation, and real-time state updating. |
| **Delete Expenses** | ✅ Complete | Swipe-to-delete gesture (`Dismissible`) with red background warning and persistent storage removal. |
| **Select Expense Category** | ✅ Complete | Preconfigured categories: *Food*, *Transport*, *Health*, *Shopping*, *Subscription* with dedicated icons & color palettes. |
| **Store Expenses Using Firebase** | ✅ Complete | **Firebase Cloud Firestore** integration with fallback to local `SharedPreferences` cache for offline resilience. |
| **Monthly Total Expenses** | ✅ Complete | Dynamic calculation for the current/selected month with a month switcher (previous/next/today). |
| **Expense History / List** | ✅ Complete | Scrollable transactions feed displaying title, category avatar, date/time, amount, and notes. |
| **Filter by Category & Date** | ✅ Complete | Horizontal category `ChoiceChips` and a `DatePicker` dialog filter with an instant "Reset" button. |
| **Form Validation** | ✅ Complete | Validation for required fields, positive numeric amounts (`> 0`), and email format checks. |
| **Loading, Empty & Error States** | ✅ Complete | Animated loading indicators, custom empty state illustrations/prompts, and error banners with "Retry" action. |

---

### 🎨 Additional Features (Optional & Enhancements)
| Feature | Status | Implementation Details |
| :--- | :---: | :--- |
| **Keyword Search Functionality** | ✅ Complete | Real-time text search filtering expenses and incomes across title, category, and optional notes with clear button and match counters. |
| **Dark Mode Theming** | ✅ Complete | Complete light & dark theme palette (`ThemeService`) with reactive `ValueNotifier`, toggleable via Profile switch or Home screen icon, and persisted across app restarts. |
| **Interactive Charts** | ✅ Complete | Category distribution pie chart and spending trend line chart powered by `fl_chart`. |
| **Income Tracking & Category Budgeting** | ✅ Complete | Dual expense & income logging, financial report breakdown, and category percentage indicators. |
| **Automated Test Suite** | ✅ Complete | Unit and widget tests (`test/search_and_theme_test.dart` & `test/widget_test.dart`) covering business logic, search filtering, and theme switching. |

---

## 🛠️ Technologies & Packages Used

| Technology / Package | Version | Purpose |
| :--- | :---: | :--- |
| **Flutter SDK** | `>= 3.12.2` | Cross-platform UI framework |
| **Dart** | `>= 3.0.0` | Client-optimized programming language |
| **firebase_core** | `^4.15.0` | Firebase app initialization |
| **cloud_firestore** | `^6.10.0` | Cloud database for persistent expense storage & sync |
| **shared_preferences** | `^2.5.5` | Local key-value store for user sessions, theme mode, and offline cache |
| **fl_chart** | `^1.2.0` | High-performance interactive charts (Pie & Line charts) |
| **intl** | `^0.20.3` | Date, time, and currency formatting |
| **smooth_page_indicator** | `^3.0.0` | Interactive onboarding page dots indicator |
| **cupertino_icons** | `^1.0.8` | iOS-styled icons support |
| **flutter_lints** | `^6.0.0` | Recommended Dart and Flutter lint rules for clean code |

---

## 🤖 AI Tools Used

During the development and enhancement of this project, the following AI tools and workflows were utilized:
- **Antigravity (Google DeepMind):**
  - **Architecture & Refactoring:** Modularized services for `ThemeService`, `ExpenceService`, and `UserService`.
  - **Feature Implementation:** Implemented real-time keyword search filtering algorithms and multi-attribute search across title, category, and notes.
  - **Firebase Firestore Integration:** Architected dual storage with cloud sync and graceful offline cache fallback.
  - **Theming & Responsiveness:** Built reactive light/dark theme system using `ValueNotifier<ThemeMode>`.
  - **Automated Test Generation:** Authored widget and unit tests ensuring high code reliability and regression safety.

---

## 📂 Project Structure

```
lib/
├── data/
│   └── onboarding_data.dart        # Onboarding slider content
├── models/
│   ├── expence_model.dart          # Expense model & category mappings
│   ├── income_model.dart           # Income model & category mappings
│   └── onboarding_model.dart       # Onboarding data model
├── screens/
│   ├── onboarding/                 # Onboarding screens
│   ├── add_new.dart                # Add Expense & Income form with live validation
│   ├── budget_screen.dart          # Financial report, charts & category cards
│   ├── edit_expense_screen.dart    # Edit expense screen with prefilled values
│   ├── home_screen.dart            # Dashboard, month switcher, monthly totals, recent list
│   ├── main_screen.dart            # Bottom navigation bar shell
│   ├── profile_screen.dart         # User profile, wallet, dark mode toggle & logout
│   ├── transactions_screen.dart    # Transaction history, search & category/date filters
│   └── user_data_screen.dart       # User registration screen with validation
├── services/
│   ├── expence_services.dart       # Firestore cloud sync & offline cache operations
│   ├── income_services.dart        # Income storage service
│   ├── theme_service.dart          # Light/Dark Theme management & persistence
│   └── user_details_service.dart   # User profile persistence service
├── utils/
│   ├── colors.dart                 # Color constants
│   └── constants.dart              # Layout & styling constants
├── widgets/
│   ├── category_card.dart          # Category breakdown card with progress bar
│   ├── custum_button.dart          # Reusable styled button
│   ├── expence_card.dart           # Interactive expense item card with edit trigger
│   ├── income_card.dart            # Income transaction card
│   ├── line_chart.dart             # Spending trend line chart
│   ├── pie_chart.dart              # Category distribution pie chart
│   ├── profile_card.dart           # Settings & profile action card
│   └── wrapper.dart                # Auth state router
└── main.dart                       # App entry point & theme initialization
```

---

## ⚙️ Project Setup & Installation

### Prerequisites
1. **Flutter SDK** (v3.12.2 or higher): [Install Flutter](https://docs.flutter.dev/get-started/install)
2. **Dart SDK** (v3.0.0 or higher)
3. **Android Studio** / **VS Code** with Flutter extensions installed
4. An Android Emulator or physical device with USB debugging enabled

### Step-by-Step Instructions

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/Navanga12/Expenz_app-.git
   cd Expenz_app-
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run Automated Tests:**
   Verify that all unit and widget tests pass:
   ```bash
   flutter test
   ```

4. **Run the Application:**
   ```bash
   flutter run
   ```

5. **Build Release APK (Optional):**
   To generate a release APK for distribution:
   ```bash
   flutter build apk --release
   ```
   The generated APK will be located at:
   `build/app/outputs/flutter-apk/app-release.apk`

---

## 🧪 Testing Verification
All core functions, filtering mechanisms, and theme switching are covered by automated tests in `test/`:
- `test/search_and_theme_test.dart`: Validates ThemeService initialization, persistence, dark mode toggling, keyword search across titles and notes, empty search states, and filter resets.
- `test/widget_test.dart`: Validates app launch and root Material structure.

Run tests anytime using:
```bash
flutter test
```
