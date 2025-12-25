import 'dart:async';
import 'dart:convert';

import '../providers.dart';
import '../models/application.dart';
import '../config/api_config.dart';
import 'http_service.dart';

class ApplicationService {
  final HttpService _httpService;

  ApplicationService({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  // Simulate sending application to backend and returning success
  Future<bool> submitApplication(CreditApplication app) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return true; // assume accepted by backend
  }

  /// Submit application and compute a demo score based on form values.
  /// Returns a [ScoreResult] computed from the provided [form] map.
  Future<ScoreResult> submitApplicationWithScore(
    CreditApplication app,
    Map<String, dynamic> form,
  ) async {
    // simulate network latency
    await Future.delayed(const Duration(milliseconds: 700));
    // Use the local compute function for demo purposes
    final result = computeScoreFromForm(form);
    return result;
  }

  /// Fetch user applications from the backend
  Future<List<Application>> fetchUserApplications(int userId) async {
    try {
      final url = ApiConfig.getUserApplications(userId);
      print('🔵 Fetching applications from: $url');

      final response = await _httpService.get(url);

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // Backend returns: {"success": true, "data": [...], "message": null, "errorCode": null}
        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final List<dynamic> data = jsonResponse['data'];
          print('✅ Found ${data.length} applications');

          return data.map((json) => Application.fromJson(json)).toList();
        } else {
          print('⚠️ API returned success=false');
          return [];
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching applications: $e');
      return [];
    }
  }

  /// Get the latest credit score from user's applications
  Future<int?> getUserCreditScore(int userId) async {
    try {
      final applications = await fetchUserApplications(userId);

      if (applications.isEmpty) {
        print('📊 No applications found for user $userId');
        return null;
      }

      // Sort by creation date (newest first)
      applications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // Get the most recent application's credit score (from ML analysis)
      final latestApp = applications.first;
      if (latestApp.creditScore != null) {
        print(
          '✅ Using ML credit score: ${latestApp.creditScore} from application ${latestApp.id}',
        );
        return latestApp.creditScore;
      }

      print('⚠️ Latest application has no credit score');
      return null;
    } catch (e) {
      print('❌ Error fetching credit score: $e');
      return null;
    }
  }
}
