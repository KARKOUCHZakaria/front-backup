import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'http_service.dart';

class DocumentService {
  final HttpService _httpService;

  DocumentService({HttpService? httpService})
    : _httpService = httpService ?? HttpService();

  /// Upload documents and create application with ML analysis
  Future<ApplicationResult> uploadDocumentsAndAnalyze({
    required Uint8List payslip1Bytes,
    required String payslip1Name,
    required Uint8List payslip2Bytes,
    required String payslip2Name,
    required Uint8List payslip3Bytes,
    required String payslip3Name,
    required Uint8List taxBytes,
    required String taxName,
    required Uint8List bankBytes,
    required String bankName,
  }) async {
    try {
      print('🔵 [DocumentService] Starting document upload and analysis');

      // Create multipart request
      final url = '${ApiConfig.backendUrl}/api/applications/upload-and-analyze';
      final request = http.MultipartRequest('POST', Uri.parse(url));

      // Add auth token
      final authHeader = await _httpService.getAuthHeader();
      if (authHeader != null) {
        request.headers['Authorization'] = authHeader;
      }

      // Add payslips
      request.files.add(
        http.MultipartFile.fromBytes(
          'payslip1',
          payslip1Bytes,
          filename: payslip1Name,
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'payslip2',
          payslip2Bytes,
          filename: payslip2Name,
        ),
      );
      request.files.add(
        http.MultipartFile.fromBytes(
          'payslip3',
          payslip3Bytes,
          filename: payslip3Name,
        ),
      );

      // Add tax declaration
      request.files.add(
        http.MultipartFile.fromBytes(
          'taxDeclaration',
          taxBytes,
          filename: taxName,
        ),
      );

      // Add bank statement
      request.files.add(
        http.MultipartFile.fromBytes(
          'bankStatement',
          bankBytes,
          filename: bankName,
        ),
      );

      print(
        '🔵 [DocumentService] Sending ${request.files.length} files to backend',
      );

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📡 [DocumentService] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          print('✅ [DocumentService] Application created successfully');
          print('   Application ID: ${data['applicationId']}');
          print('   Credit Score: ${data['creditScore']}');
          print('   Decision: ${data['decision']}');

          return ApplicationResult(
            success: true,
            applicationId: data['applicationId']?.toString(),
            creditScore: data['creditScore']?.toInt(),
            decision: data['decision']?.toString() ?? 'PENDING',
            message: data['message']?.toString(),
            documentScores: DocumentScores(
              cinScore: data['documentScores']?['cinScore']?.toDouble(),
              payslipScore: data['documentScores']?['payslipScore']?.toDouble(),
              taxScore: data['documentScores']?['taxScore']?.toDouble(),
              bankScore: data['documentScores']?['bankScore']?.toDouble(),
            ),
          );
        } else {
          final error = jsonResponse['message'] ?? 'Unknown error';
          print('❌ [DocumentService] API error: $error');
          return ApplicationResult(success: false, message: error);
        }
      } else {
        final error = 'HTTP ${response.statusCode}: ${response.body}';
        print('❌ [DocumentService] HTTP error: $error');
        return ApplicationResult(success: false, message: error);
      }
    } catch (e) {
      print('❌ [DocumentService] Exception: $e');
      return ApplicationResult(success: false, message: 'Upload failed: $e');
    }
  }
}

class ApplicationResult {
  final bool success;
  final String? applicationId;
  final int? creditScore;
  final String? decision;
  final String? message;
  final DocumentScores? documentScores;

  ApplicationResult({
    required this.success,
    this.applicationId,
    this.creditScore,
    this.decision,
    this.message,
    this.documentScores,
  });
}

class DocumentScores {
  final double? cinScore;
  final double? payslipScore;
  final double? taxScore;
  final double? bankScore;

  DocumentScores({
    this.cinScore,
    this.payslipScore,
    this.taxScore,
    this.bankScore,
  });

  double? get averageScore {
    final scores = [
      cinScore,
      payslipScore,
      taxScore,
      bankScore,
    ].where((s) => s != null).cast<double>().toList();
    if (scores.isEmpty) return null;
    final sum = scores.reduce((a, b) => a + b);
    return sum / scores.length;
  }
}
