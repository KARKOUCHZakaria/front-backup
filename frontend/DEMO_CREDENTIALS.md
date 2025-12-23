# Demo Credentials

## Login Screen

Use the following credentials to test the application:

**Email:** `test@example.com`
**Password:** `password123`

## Features Available (No API Required)

✅ **Onboarding Screens** - 3-page ethical AI credit scoring introduction
✅ **Login/Signup** - Works with demo credentials above
✅ **Personal Information Form** - Step 1 of 4 (mock data, no validation)
✅ **Financial Details Form** - Step 2 of 4 (mock data, no validation)
✅ **Application Summary** - Step 3/4 review screen
✅ **Home Dashboard** - Shows user greeting, mock score gauge (785), quick actions
✅ **Profile Screen** - User profile with settings
✅ **AI Score Results** - Shows credit score with SHAP explanations

## Navigation Flow

1. **Onboarding** → Click "Get Started"
2. **Login Screen** → Enter demo credentials → Go to Home
3. **Home Dashboard** → View profile, score, activity
4. **Forms Flow** (from home): Personal Info → Financial Details → Summary → Score Results

## Theme

- **Default:** Dark Mode (dark teal with cyan accents)
- **Color Scheme:** 
  - Background: #0A1515 (dark teal)
  - Accent: #00D9CC (cyan)
  - Text: White/Light gray

## Building & Running

```bash
cd frontend
flutter clean
flutter pub get
flutter run -d chrome  # Or your target device
```

## Notes

- All forms submit with mock data (no backend validation)
- Score results are randomly generated based on form inputs
- SHAP values are calculated locally with mock algorithms
- Navigation is fully functional between screens
- All UI matches Figma design specifications
