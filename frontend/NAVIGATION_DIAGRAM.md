# Application Navigation Flow

```
┌─────────────────────────────────────────────────────────────────────────┐
│                         APPLICATION START                                │
└──────────────────────────────┬──────────────────────────────────────────┘
                               │
                               ▼
                    ┌──────────────────┐
                    │  Splash Screen   │ (3 seconds)
                    │    /splash       │
                    └────────┬─────────┘
                             │
                             ▼
                    ┌──────────────────┐
                    │   Onboarding     │◄─────────┐
                    │   /onboarding    │          │
                    └────┬────────┬────┘          │
                         │        │               │
                  Next   │        │ Skip          │
                         │        │               │
                         ▼        └───────┐       │
        ┌──────────────────────┐         │       │
        │ Explainable AI       │         │       │
        │ /onboarding/         │         │       │
        │   explainable        │         │       │
        └──────┬───────────────┘         │       │
               │                         │       │
               ▼                         │       │
        ┌──────────────────────┐         │       │
        │ Ethics Onboarding    │         │       │
        │ /onboarding/ethics   │         │       │
        └──────┬───────────────┘         │       │
               │                         │       │
               ▼                         │       │
        ┌──────────────────────┐         │       │
        │ Privacy Onboarding   │         │       │
        │ /onboarding/privacy  │         │       │
        └──────┬───────────────┘         │       │
               │                         │       │
               ▼                         │       │
        ┌──────────────────────┐         │       │
        │ Consent Screen       │         │       │
        │ /onboarding/consent  │         │       │
        └──────┬───────────────┘         │       │
               │                         │       │
               └─────────────────┬───────┘       │
                                 │               │
                                 ▼               │
                    ┌──────────────────┐         │
                    │  Login Screen    │         │
                    │    /login        │─────────┘
                    └────┬────────┬────┘
                         │        │
                    Login│        │Register
                         │        │
                         │        ▼
                         │  ┌──────────────────┐
                         │  │   Register       │
                         │  │ /auth/register   │
                         │  └────────┬─────────┘
                         │           │
                         └───────────┼─────────────┐
                                     │             │
                                     ▼             │
┌────────────────────────────────────────────────────────────────────────┐ │
│                      USER DASHBOARD AREA                               │ │
│  ┌──────────────────────────────────────────────────────────────────┐  │ │
│  │                    User Home Dashboard                            │  │ │
│  │                      /user/home                                   │◄─┘ │
│  │                                                                    │  │
│  │  Actions:                                                         │  │
│  │  • New Application    • View Score      • Notifications          │  │
│  │  • Profile            • Settings        • Applications           │  │
│  └────┬───────────┬──────────┬──────────┬───────────┬──────────────┘  │
│       │           │          │          │           │                  │
└───────┼───────────┼──────────┼──────────┼───────────┼──────────────────┘
        │           │          │          │           │
        │           │          │          │           │
┌───────▼────┐  ┌───▼───────┐ │  ┌───────▼──────┐   │
│Notifications│  │ Settings  │ │  │   Profile    │   │
│/notifications│  │/settings │ │  │/user/profile │   │
└─────────────┘  └───────────┘ │  └──────────────┘   │
                                │                     │
                    New App     │  View Score         │
                                │                     │
                                ▼                     ▼
        ┌──────────────────────────────┐  ┌──────────────────────┐
        │  APPLICATION PROCESS FLOW     │  │   SCORE & RESULTS    │
        ├──────────────────────────────┤  ├──────────────────────┤
        │                               │  │                      │
        │ 1. New Application            │  │ 1. Score Gauge       │
        │    /user/new-application      │  │    /user/score-gauge │
        │         │                     │  │         │            │
        │         ▼                     │  │         ▼            │
        │ 2. Personal Info              │  │ 2. Score Summary     │
        │    /personal-info             │  │    /user/score-      │
        │         │                     │  │    summary           │
        │         ▼                     │  │         │            │
        │ 3. Financial Details          │  │         ▼            │
        │    /financials                │  │ 3. Detailed Results  │
        │         │                     │  │    /user/results-    │
        │         ▼                     │  │    detailed          │
        │ 4. Financials Step            │  │         │            │
        │    /user/financials           │  │         │            │
        │         │                     │  │         └────────────┼──┐
        │         ▼                     │  │                      │  │
        │ 5. Verification               │  │                      │  │
        │    /user/verification         │  │                      │  │
        │         │                     │  │                      │  │
        │         └─────────────────────┼──┘                      │  │
        │                               │                         │  │
        └───────────────────────────────┘                         │  │
                                                                  │  │
                                                      Back to Home│  │
                                                                  │  │
                                                                  ▼  │
                                                    ┌──────────────────┐
                                                    │  User Home       │
                                                    │  Dashboard       │
                                                    └──────────────────┘
                                                                  ▲
                                                                  │
┌─────────────────────────────────────────────────────────────────┼───┐
│                    SETTINGS & SUPPORT AREA                      │   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐         │   │
│  │  Settings    │  │Help & Support│  │    About     │         │   │
│  │  /settings   │  │/help-support │  │    /about    │         │   │
│  └──────┬───────┘  └──────────────┘  └──────┬───────┘         │   │
│         │                                    │                 │   │
│         └────────────┬───────────────────────┘                 │   │
│                      │                                         │   │
│              ┌───────┴────────┐                                │   │
│              │                │                                │   │
│              ▼                ▼                                │   │
│     ┌─────────────────┐ ┌──────────────┐                      │   │
│     │ Privacy Policy  │ │Terms of      │                      │   │
│     │ /privacy-policy │ │Service       │                      │   │
│     └─────────────────┘ │/terms        │                      │   │
│                         └──────────────┘                      │   │
│                                                               │   │
│     All screens have BACK navigation to previous screen      │   │
└───────────────────────────────────────────────────────────────┼───┘
                                                                │
                                                                │
┌───────────────────────────────────────────────────────────────▼───┐
│                        ADMIN AREA                                 │
│  ┌──────────────┐         ┌──────────────┐                       │
│  │ Admin Login  │────────►│    Admin     │                       │
│  │ /admin/login │         │  Dashboard   │                       │
│  └──────────────┘         │/admin/       │                       │
│                           │ dashboard    │                       │
│                           └──────┬───────┘                       │
│                                  │                               │
│                                  ▼                               │
│                           ┌──────────────┐                       │
│                           │Applications  │                       │
│                           │List          │                       │
│                           │/admin/       │                       │
│                           │applications  │                       │
│                           └──────┬───────┘                       │
│                                  │                               │
│                                  ▼                               │
│                           ┌──────────────┐                       │
│                           │Application   │                       │
│                           │Detail        │                       │
│                           │/admin/       │                       │
│                           │applications/ │                       │
│                           │:id           │                       │
│                           └──────────────┘                       │
└───────────────────────────────────────────────────────────────────┘

NAVIGATION FEATURES:
═══════════════════
✓ All screens support back navigation (except home screens)
✓ GoRouter provides smooth transitions
✓ Deep linking support for all routes
✓ Parameter passing for dynamic routes
✓ Consistent navigation patterns throughout the app
✓ 29+ screens with complete navigation flow
```
