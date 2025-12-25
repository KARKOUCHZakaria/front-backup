import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// HTTP Service for making API calls to backend
class HttpService {
  final http.Client _client;
  String? _authToken;

  HttpService() : _client = http.Client();

  /// Set authentication token
  void setAuthToken(String token) {
    _authToken = token;
    print('🔑 [HttpService] Auth token set');
  }

  /// Clear authentication token
  void clearAuthToken() {
    _authToken = null;
    print('🔑 [HttpService] Auth token cleared');
  }

  /// Get auth header value for manual requests
  Future<String?> getAuthHeader() async {
    return _authToken != null ? 'Bearer $_authToken' : null;
  }

  /// Get common headers
  Map<String, String> _getHeaders({bool includeAuth = true}) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && _authToken != null) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    return headers;
  }

  /// GET request
  Future<http.Response> get(String endpoint, {bool includeAuth = true}) async {
    final url = Uri.parse(endpoint);
    print('🔵 [HttpService] GET: $url');

    try {
      final response = await _client
          .get(url, headers: _getHeaders(includeAuth: includeAuth))
          .timeout(ApiConfig.receiveTimeout);

      print('✅ [HttpService] Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ [HttpService] GET failed: $e');
      rethrow;
    }
  }

  /// POST request
  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse(endpoint);
    print('🔵 [HttpService] POST: $url');
    print('📤 [HttpService] Body: ${jsonEncode(body)}');

    try {
      final response = await _client
          .post(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.sendTimeout);

      print('✅ [HttpService] Response: ${response.statusCode}');
      print('📥 [HttpService] Response body: ${response.body}');
      return response;
    } catch (e) {
      print('❌ [HttpService] POST failed: $e');
      rethrow;
    }
  }

  /// PUT request
  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse(endpoint);
    print('🔵 [HttpService] PUT: $url');

    try {
      final response = await _client
          .put(
            url,
            headers: _getHeaders(includeAuth: includeAuth),
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.sendTimeout);

      print('✅ [HttpService] Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ [HttpService] PUT failed: $e');
      rethrow;
    }
  }

  /// DELETE request
  Future<http.Response> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    final url = Uri.parse(endpoint);
    print('🔵 [HttpService] DELETE: $url');

    try {
      final response = await _client
          .delete(url, headers: _getHeaders(includeAuth: includeAuth))
          .timeout(ApiConfig.receiveTimeout);

      print('✅ [HttpService] Response: ${response.statusCode}');
      return response;
    } catch (e) {
      print('❌ [HttpService] DELETE failed: $e');
      rethrow;
    }
  }

  /// Upload file with multipart request
  Future<http.Response> uploadFile(
    String endpoint,
    File file, {
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool includeAuth = true,
  }) async {
    final url = Uri.parse(endpoint);
    print('🔵 [HttpService] UPLOAD FILE: $url');
    print(
      '📤 [HttpService] File: ${file.path}, Size: ${await file.length()} bytes',
    );

    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add headers
      final headers = _getHeaders(includeAuth: includeAuth);
      headers.remove('Content-Type'); // Let http package set this
      request.headers.addAll(headers);

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();

      // Get filename - handle case where path is empty or just "/"
      String fileName = 'upload.jpg'; // default
      try {
        final pathSegments = file.path.split('/');
        if (pathSegments.isNotEmpty && pathSegments.last.isNotEmpty) {
          fileName = pathSegments.last;
        }
      } catch (e) {
        print(
          '⚠️ [HttpService] Could not extract filename from path, using default',
        );
      }

      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: fileName,
      );
      request.files.add(multipartFile);

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
        print('📤 [HttpService] Additional fields: $additionalFields');
      }

      // Send request
      print('📤 [HttpService] Sending multipart request...');
      final streamedResponse = await request.send().timeout(
        ApiConfig.sendTimeout,
      );

      // Convert to regular response
      final response = await http.Response.fromStream(streamedResponse);

      print('✅ [HttpService] Upload response: ${response.statusCode}');
      print('📥 [HttpService] Response body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ [HttpService] Upload failed: $e');
      rethrow;
    }
  }

  /// Upload bytes (for web platform)
  Future<http.Response> uploadBytes(
    String endpoint,
    Uint8List bytes, {
    required String filename,
    String fieldName = 'file',
    Map<String, String>? additionalFields,
    bool includeAuth = true,
  }) async {
    final url = Uri.parse(endpoint);
    print('🔵 [HttpService] UPLOAD BYTES: $url');
    print('📤 [HttpService] File: $filename, Size: ${bytes.length} bytes');

    try {
      // Create multipart request
      final request = http.MultipartRequest('POST', url);

      // Add headers
      final headers = _getHeaders(includeAuth: includeAuth);
      headers.remove('Content-Type'); // Let http package set this
      request.headers.addAll(headers);

      // Add file from bytes
      final multipartFile = http.MultipartFile.fromBytes(
        fieldName,
        bytes,
        filename: filename,
      );
      request.files.add(multipartFile);

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
        print('📤 [HttpService] Additional fields: $additionalFields');
      }

      // Send request
      print('📤 [HttpService] Sending multipart request...');
      final streamedResponse = await request.send().timeout(
        ApiConfig.sendTimeout,
      );

      // Convert to regular response
      final response = await http.Response.fromStream(streamedResponse);

      print('✅ [HttpService] Upload response: ${response.statusCode}');
      print('📥 [HttpService] Response body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ [HttpService] Upload failed: $e');
      rethrow;
    }
  }

  /// Parse JSON response
  Map<String, dynamic> parseResponse(http.Response response) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (e) {
      print('❌ [HttpService] JSON parse error: $e');
      return {'error': 'Failed to parse response'};
    }
  }

  /// Check if response is successful (2xx status codes)
  bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Close the HTTP client
  void close() {
    _client.close();
  }
}
