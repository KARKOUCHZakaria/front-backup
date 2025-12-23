import 'dart:async';

import '../providers.dart';

class ApplicationService {
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

  Future<List<CreditApplication>> fetchApplications() async {
    await Future.delayed(const Duration(milliseconds: 400));
    // return empty - actual implementation should call API
    return [];
  }
}
