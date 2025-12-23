import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen_new.dart';
import 'screens/profile_screen_new.dart';
import 'screens/application_summary_screen.dart';
import 'screens/application_summary_screen_new.dart';
import 'screens/form_screen.dart';
import 'screens/score_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/onboarding_explainable_screen.dart';
import 'screens/onboarding_ethics_screen.dart';
import 'screens/financials_step_screen.dart';
import 'screens/financial_details_form_screen.dart';
import 'screens/personal_info_form_screen.dart';
import 'screens/summary_score_screen.dart';
import 'screens/onboarding_privacy_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/credentials_screen.dart';
import 'screens/score_gauge_screen.dart';
import 'screens/results_detailed_screen.dart';
import 'screens/consent_screen.dart';
import 'screens/user_home_dashboard_screen.dart';
import 'screens/ai_score_results_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/help_support_screen.dart';
import 'screens/about_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/terms_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/application_history_screen.dart';
import 'screens/document_upload_screen.dart';
import 'screens/supplementary_info_screen.dart';

/// Centralized router builder using GoRouter and Riverpod for navigation.

class AppRouter {
  // kept for compatibility if needed
  static GoRouter router(WidgetRef ref) => ref.watch(routerProvider);
}

final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    initialLocation: '/splash',
    routes: [
      // Splash Screen
      GoRoute(
        name: 'splash',
        path: '/splash',
        builder: (c, s) => const SplashScreen(),
      ),
      GoRoute(
        name: 'onboarding',
        path: '/onboarding',
        builder: (c, s) => const OnboardingScreen(),
      ),
      GoRoute(
        name: 'onboardingExplainable',
        path: '/onboarding/explainable',
        builder: (c, s) => const ExplainableOnboardingScreen(),
      ),
      GoRoute(
        name: 'onboardingEthics',
        path: '/onboarding/ethics',
        builder: (c, s) => const OnboardingEthicsScreen(),
      ),
      GoRoute(
        name: 'onboardingPrivacy',
        path: '/onboarding/privacy',
        builder: (c, s) => const OnboardingPrivacyScreen(),
      ),
      GoRoute(
        name: 'onboardingConsent',
        path: '/onboarding/consent',
        builder: (c, s) => const ConsentScreen(),
      ),
      GoRoute(
        name: 'financialsStep',
        path: '/user/financials',
        builder: (c, s) => const FinancialsStepScreen(),
      ),
      GoRoute(
        name: 'financials',
        path: '/financials',
        builder: (c, s) => const FinancialDetailsFormScreen(),
      ),
      GoRoute(
        name: 'personalInfo',
        path: '/personal-info',
        builder: (c, s) => const PersonalInfoFormScreen(),
      ),
      GoRoute(
        name: 'verification',
        path: '/user/verification',
        builder: (c, s) => const VerificationScreen(),
      ),
      GoRoute(
        name: 'credentials',
        path: '/auth/register',
        builder: (c, s) => const CredentialsScreen(),
      ),
      GoRoute(
        name: 'scoreGauge',
        path: '/user/score-gauge',
        builder: (c, s) => const ScoreGaugeScreen(),
      ),
      GoRoute(
        name: 'scoreSummary',
        path: '/user/score-summary',
        builder: (c, s) => const SummaryScoreScreen(),
      ),
      GoRoute(
        name: 'resultsDetailed',
        path: '/user/results-detailed',
        builder: (c, s) => const ResultsDetailedScreen(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (c, s) => const LoginScreenNew(),
      ),
      GoRoute(
        name: 'register',
        path: '/register',
        builder: (c, s) => const RegistrationScreen(),
      ),
      GoRoute(
        name: 'userHome',
        path: '/user/home',
        builder: (c, s) => const UserHomeDashboardScreen(),
      ),
      GoRoute(
        name: 'userSupplementaryInfo',
        path: '/user/supplementary-info',
        builder: (c, s) => const SupplementaryInfoScreen(),
      ),
      GoRoute(
        name: 'userDocuments',
        path: '/user/documents',
        builder: (c, s) => const DocumentUploadScreen(),
      ),
      GoRoute(
        name: 'userHistory',
        path: '/user/history',
        builder: (c, s) => const ApplicationHistoryScreen(),
      ),
      GoRoute(
        name: 'userSummary',
        path: '/user/summary',
        builder: (c, s) => const ApplicationSummaryScreen(),
      ),
      GoRoute(
        name: 'userSettings',
        path: '/user/settings',
        builder: (c, s) => const SettingsScreen(),
      ),
      GoRoute(
        name: 'userNew',
        path: '/user/new-application',
        builder: (c, s) => const CreditApplicationFormScreen(),
      ),
      GoRoute(
        name: 'userScore',
        path: '/user/score-result',
        builder: (c, s) => const ScoreResultScreen(),
      ),
      GoRoute(
        name: 'scoreResults',
        path: '/score-results',
        builder: (c, s) => const AIScoreResultsScreen(),
      ),
      GoRoute(
        name: 'userProfile',
        path: '/user/profile',
        builder: (c, s) => const ProfileScreenNew(),
      ),
      GoRoute(
        name: 'appSummary',
        path: '/user/application-summary',
        builder: (c, s) => const ApplicationSummaryScreen(),
      ),
      GoRoute(
        name: 'summary',
        path: '/summary',
        builder: (c, s) => const ApplicationSummaryScreenNew(),
      ),

      // Settings & Support
      GoRoute(
        name: 'settings',
        path: '/settings',
        builder: (c, s) => const SettingsScreen(),
      ),
      GoRoute(
        name: 'notifications',
        path: '/notifications',
        builder: (c, s) => const NotificationsScreen(),
      ),
      GoRoute(
        name: 'helpSupport',
        path: '/help-support',
        builder: (c, s) => const HelpSupportScreen(),
      ),
      GoRoute(
        name: 'about',
        path: '/about',
        builder: (c, s) => const AboutScreen(),
      ),
      GoRoute(
        name: 'privacyPolicy',
        path: '/privacy-policy',
        builder: (c, s) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        name: 'terms',
        path: '/terms',
        builder: (c, s) => const TermsScreen(),
      ),
    ],
  ),
);
