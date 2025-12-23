# CreditXAI Flutter Frontend - Demo App

## 🚀 Quick Start

### Demo Login Credentials

```
Email:    test@example.com
Password: password123
```

### Installation & Run

```bash
cd frontend
flutter clean
flutter pub get
flutter run -d chrome
```

Or for Android/iOS:
```bash
flutter run  # Automatically selects connected device
```

## 📱 Available Screens (All Offline - No API Required)

### 1. **Onboarding** (`/onboarding`)
- 3-page introduction to ethical AI credit scoring
- Glassmorphism design with animations
- "Skip" button or "Get Started" button to proceed

### 2. **Login/Signup** (`/login`)
- **Demo Login:** Use credentials above
- Signup available (creates new account locally)
- Navigates to Home Dashboard on successful login
- Navigates to Personal Info form on successful signup

### 3. **Multi-Step Application Form**

#### Step 1: Personal Information (`/personal-info`)
- Full Name
- Date of Birth
- Social Security Number (masked)
- Email Address
- Phone Number

#### Step 2: Financial Details (`/financials`)
- Employment Status (dropdown)
- Primary Income
- Additional Income
- Savings
- Investments
- Rent/Housing Costs
- Loan Payments

#### Step 3: Application Summary (`/summary`)
- Review all entered information
- Edit capabilities (buttons to modify each section)
- Agree to terms checkbox
- Submit button (enabled when terms accepted)

### 4. **Home Dashboard** (`/user/home`)
- User greeting with name
- **Credit Score Gauge** - Shows animated score (mock: 785)
- **Quick Actions** - Buttons for common tasks
- **Activity List** - Recent applications with status badges

### 5. **Profile Screen** (`/user/profile`)
- User avatar with edit button
- Personal information display
- Settings toggles:
  - Dark Mode toggle
  - Notifications toggle
  - Email Preferences toggle
  - Privacy Settings toggle

### 6. **AI Score Results** (`/score-results`)
- Large credit score display (mock: 820)
- Approval badge
- **SHAP Explainability Chart** - Shows which factors influenced the score:
  - Income (positive/negative impact)
  - Debt Ratio (positive/negative impact)
  - Age (positive/negative impact)
  - Loan Amount (positive/negative impact)
- **Next Steps** - Recommendation cards

## 🎨 Design System

### Colors
- **Primary Background:** `#0A1515` (Dark Teal)
- **Secondary Background:** `#0F1A1A`, `#1A2A2A`
- **Accent Color:** `#00D9CC` (Cyan)
- **Text Primary:** White
- **Text Secondary:** `#A0A8B0` (Gray)
- **Status Colors:**
  - Success: `#10B981` (Green)
  - Warning: `#F59E0B` (Orange)
  - Error: `#EF4444` (Red)

### Typography
- **Font Family:** Inter (via Google Fonts)
- **Dark Mode Default:** Enabled

### UI Elements
- **Glassmorphism:** BackdropFilter with 0.8 opacity
- **Border Radius:** 12-24px
- **Shadows:** Soft shadows for depth
- **Icons:** Material Design Icons

## 🔄 Navigation Flow

```
Onboarding (3 pages)
    ↓
Login/Signup
    ↓
Home Dashboard ← ← ← Main Hub
    ↓
Forms (Personal → Financial → Summary)
    ↓
Score Results
    ↓
Profile (accessible from home)
```

## 📊 Mock Data

All data is **locally generated** with no backend calls:

### Score Calculation
```dart
base = 400 + 
       (income/10000) × 200 + 
       (1 - debt_ratio) × 200 + 
       age_factor + 
       loan_factor + 
       random_noise
```

### SHAP Values
Factors are ranked by impact on the score. Positive values support approval, negative oppose it.

## ⚙️ Technical Stack

- **Framework:** Flutter 3.9.2+
- **State Management:** Riverpod 2.6.1
- **Navigation:** GoRouter 6.5.9
- **Animations:** Lottie 3.3.2
- **Charts:** FL Chart 1.1.1
- **UI:** Material 3 with custom theming

## 📝 Features Implemented

✅ Onboarding with Lottie animations
✅ Dark mode by default
✅ Glassmorphism UI components
✅ Multi-step form with validation
✅ Score gauge with custom painter
✅ SHAP visualization chart
✅ Tab navigation
✅ Smooth page transitions
✅ Snackbar notifications
✅ Profile management UI
✅ Status badges for applications

## ⚠️ Limitations (Demo Mode)

- ❌ No backend API integration yet
- ❌ No persistent data storage
- ❌ No real authentication
- ❌ No actual score calculation (mock values only)
- ❌ No image upload (profile avatar is placeholder)
- ❌ No push notifications

## 🔧 Troubleshooting

### Build Issues
```bash
flutter clean
flutter pub get
flutter pub cache clean
flutter pub get
```

### Chrome Debugger Issues
Try running on a physical device or web server:
```bash
flutter run -d web-server
```

### Missing Pubspec Dependencies
```bash
flutter pub get
flutter packages get
```

## 📦 Project Structure

```
frontend/
├── lib/
│   ├── main.dart                          # App entry
│   ├── src/
│   │   ├── app_router.dart               # GoRouter configuration
│   │   ├── providers.dart                # Riverpod providers
│   │   ├── theme/
│   │   │   └── app_theme.dart            # Theme & colors
│   │   ├── screens/                      # All screen widgets
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── login_screen_new.dart
│   │   │   ├── personal_info_form_screen.dart
│   │   │   ├── financial_details_form_screen.dart
│   │   │   ├── application_summary_screen_new.dart
│   │   │   ├── user_home_dashboard_screen.dart
│   │   │   ├── profile_screen_new.dart
│   │   │   ├── ai_score_results_screen.dart
│   │   │   └── [other screens]
│   │   └── widgets/                      # Reusable components
│   │       ├── custom_text_field.dart
│   │       ├── shap_bar_chart.dart
│   │       └── [other widgets]
│   └── assets/
│       ├── images/
│       └── lottie/                       # Animation JSON files
│           ├── onboarding1.json
│           ├── onboarding2.json
│           └── onboarding3.json
├── android/
├── ios/
├── web/
├── pubspec.yaml
└── README.md
```

## 🎯 Next Steps

1. **Backend Integration:** Connect to actual API endpoints
2. **Database:** Implement local storage with Hive or SQLite
3. **Authentication:** Integrate Firebase or custom auth
4. **Real Scores:** Connect to actual ML model for credit scoring
5. **Notifications:** Implement Firebase Cloud Messaging
6. **Image Upload:** Implement image picker and upload

## 📧 Support

For issues or questions about the frontend implementation, check the `DEMO_CREDENTIALS.md` file or review the code comments throughout the project.

---

**Last Updated:** December 2025
**Status:** Demo/Development Version
