/// API Configuration for the Backend
class ApiConfig {
  /// Base URL for the Backend API (Java Spring Boot)
  /// For Web: use localhost
  /// For Android emulator: use 10.0.2.2 instead of localhost
  /// For physical device: use your computer's local IP (e.g., 192.168.1.x)
  static const String backendUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'http://localhost:8081',
  );

  /// Base URL for the ML API (Python FastAPI)
  static const String mlUrl = String.fromEnvironment(
    'ML_URL',
    defaultValue: 'http://localhost:8000',
  );

  /// Base URL - defaults to backend
  static String get baseUrl => backendUrl;

  /// Timeout durations
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);

  /// Auth Endpoints (Backend Java)
  static String get authRegister => '$backendUrl/auth/register';
  static String get authLogin => '$backendUrl/auth/login';
  static String get authVerifyCin => '$backendUrl/auth/verify-cin';

  /// User Endpoints (Backend Java)
  static String get currentUser => '$backendUrl/api/users/me';

  /// Application Endpoints (Backend Java)
  static String get submitApplication => '$backendUrl/api/applications';
  static String getUserApplications(int userId) =>
      '$backendUrl/api/applications/user/$userId';
  static String getApplication(int applicationId) =>
      '$backendUrl/api/applications/$applicationId';

  /// Document Endpoints (Backend Java)
  static String get uploadDocument => '$backendUrl/api/documents/upload';
  static String getUserDocuments(int userId) =>
      '$backendUrl/api/documents/user/$userId';

  /// ML API Endpoints (Python FastAPI)
  static String get predict => '$mlUrl/predict';
  static String get score => '$mlUrl/score';
  static String get explainShap => '$mlUrl/explain';
  static String get fairnessMetrics => '$mlUrl/fairness';
  static String get modelHealth => '$mlUrl/health';
  static String get modelInfo => '$mlUrl/info';

  /// Feature importance endpoints
  static String get featureImportance => '$mlUrl/feature-importance';

  /// Batch prediction endpoint
  static String get batchPredict => '$mlUrl/batch-predict';

  /// API Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  /// Headers with auth token
  static Map<String, String> authHeaders(String token) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  /// Check if running in production
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  /// Enable logging in debug mode
  static bool get enableLogging => !isProduction;
}
