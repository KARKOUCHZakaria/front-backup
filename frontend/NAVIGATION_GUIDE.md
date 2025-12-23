# Navigation Routes Documentation

## Complete Application Routes

### 🚀 Application Flow

#### 1. **Splash & Onboarding Flow**
- `/splash` - Splash screen (initial screen)
  - → Auto-navigates to `/onboarding` after 3 seconds
- `/onboarding` - Main onboarding screen
  - → Back: not available (first screen)
  - → Next: `/onboarding/explainable` or Skip to `/login`
- `/onboarding/explainable` - Explainable AI onboarding
  - → Back: `/onboarding`
  - → Next: `/onboarding/ethics`
- `/onboarding/ethics` - Ethics onboarding
  - → Back: `/onboarding/explainable`
  - → Next: `/onboarding/privacy`
- `/onboarding/privacy` - Privacy onboarding
  - → Back: `/onboarding/ethics`
  - → Next: `/onboarding/consent`
- `/onboarding/consent` - Consent screen
  - → Back: `/onboarding/privacy`
  - → Next: `/login` or `/auth/register`

#### 2. **Authentication Flow**
- `/login` - Login screen
  - → Back: `/onboarding`
  - → Demo credentials: test@example.com / password123
  - → Success: `/user/home`
  - → Register: `/auth/register`
- `/auth/register` - Registration/credentials screen
  - → Back: `/login`
  - → Success: `/user/home`

#### 3. **User Dashboard & Home**
- `/user/home` - User home dashboard (main screen after login)
  - → Back: not available (logged in home)
  - → Actions:
    - New Application: `/user/new-application`
    - View Score: `/user/score-gauge`
    - Notifications: `/notifications`
    - Settings: `/settings`
    - Profile: `/user/profile`

#### 4. **Application Process Flow**
- `/user/new-application` - New credit application form
  - → Back: `/user/home`
  - → Next: `/personal-info`
- `/personal-info` - Personal information form
  - → Back: `/user/new-application`
  - → Next: `/financials`
- `/financials` - Financial details form
  - → Back: `/personal-info`
  - → Next: `/user/financials`
- `/user/financials` - Financials step screen
  - → Back: `/financials`
  - → Next: `/user/verification`
- `/user/verification` - Verification screen
  - → Back: `/user/financials`
  - → Next: `/user/score-gauge`

#### 5. **Score & Results Flow**
- `/user/score-gauge` - Score gauge visualization
  - → Back: `/user/home`
  - → Next: `/user/score-summary`
- `/user/score-summary` - Summary score screen
  - → Back: `/user/score-gauge`
  - → Next: `/user/results-detailed`
- `/user/results-detailed` - Detailed results
  - → Back: `/user/score-summary`
  - → Home: `/user/home`
- `/score-results` - AI score results screen
  - → Back: previous screen
- `/user/score-result` - Score result screen
  - → Back: `/user/home`

#### 6. **User Profile & Settings**
- `/user/profile` - User profile screen
  - → Back: `/user/home`
  - → Actions:
    - Notifications: `/notifications`
    - Settings: `/settings`
    - Help: `/help-support`
    - About: `/about`
- `/settings` - Settings screen
  - → Back: previous screen
  - → Actions:
    - Privacy Policy: `/privacy-policy`
    - Help: `/help-support`
    - About: `/about`
    - Logout: `/login`
- `/notifications` - Notifications screen
  - → Back: previous screen
- `/help-support` - Help and support screen
  - → Back: previous screen
- `/about` - About screen
  - → Back: previous screen
  - → Privacy Policy: `/privacy-policy`
  - → Terms: `/terms`

#### 7. **Legal & Information**
- `/privacy-policy` - Privacy policy screen
  - → Back: previous screen (settings/about)
- `/terms` - Terms of service screen
  - → Back: previous screen

#### 8. **Application Summaries**
- `/user/application-summary` - Application summary
  - → Back: previous screen
- `/summary` - Application summary (alternative)
  - → Back: previous screen

#### 9. **Admin Flow**
- `/admin/login` - Admin login screen
  - → Back: `/login`
  - → Success: `/admin/dashboard`
- `/admin/dashboard` - Admin dashboard
  - → Back: not available (admin home)
  - → Actions:
    - Applications: `/admin/applications`
- `/admin/applications` - Admin applications list
  - → Back: `/admin/dashboard`
  - → Detail: `/admin/applications/:id`
- `/admin/applications/:id` - Admin application detail
  - → Back: `/admin/applications`

## 🎯 Key Features

### Navigation
- **GoRouter** for declarative routing
- **Back navigation** supported on all screens (except splash and home screens)
- **Deep linking** ready
- **Parameter passing** for dynamic routes

### User Experience
- Smooth transitions between screens
- Consistent back button behavior
- Intuitive flow from onboarding to application completion
- Quick access to settings, notifications, and help from multiple entry points

### Demo Credentials
- **User Login**: test@example.com / password123
- All demo users can access full application flow

## 📱 Screen Categories

1. **Onboarding (5 screens)**: Splash → Onboarding → Explainable → Ethics → Privacy → Consent
2. **Authentication (2 screens)**: Login, Register
3. **User Dashboard (1 screen)**: Home with quick actions
4. **Application Process (6 screens)**: Complete credit application flow
5. **Score & Results (4 screens)**: Score visualization and detailed results
6. **Profile & Settings (6 screens)**: User preferences and account management
7. **Legal (2 screens)**: Privacy policy and terms
8. **Admin (3 screens + detail)**: Admin dashboard and application management

**Total: 29+ unique screens with full navigation support!**
