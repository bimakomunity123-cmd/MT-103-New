import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // PENTING: Ganti baseUrl sesuai platform kamu
  // Windows/Web: http://localhost:5000/api
  // Android Emulator: http://10.0.2.2:5000/api
  // iOS Simulator: http://localhost:5000/api
  // Device Fisik: http://[IP-LAPTOP]:5000/api
  static const String baseUrl = 'http://localhost:5000/api';

  // ========== HEALTH CHECK ==========
  static Future<bool> checkConnection() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      return res.statusCode == 200;
    } catch (e) {
      print('Backend offline: $e');
      return false;
    }
  }

  // ========== AUTH ==========
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Backend offline', 'error': e.toString()};
    }
  }

  static Future<Map<String, dynamic>> validateAuth(
    String loginId,
    String password,
    String otp,
  ) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/auth/validate'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'login_id': loginId,
              'password': password,
              'otp': otp,
            }),
          )
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'message': 'Backend offline'};
    }
  }

  // ========== ACCOUNT ==========
  static Future<Map<String, dynamic>> getAccountInfo(String username) async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/account/info?username=$username'))
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'data': {}};
    }
  }

  static Future<Map<String, dynamic>> getBalance() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/account/balance'))
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false};
    }
  }

  // ========== COMPLIANCE ==========
  static Future<Map<String, dynamic>> getComplianceStatus() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/compliance/status'))
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'data': {}};
    }
  }

  // ========== TRANSACTIONS ==========
  static Future<Map<String, dynamic>> getTransactions() async {
    try {
      final res = await http
          .get(Uri.parse('$baseUrl/transactions'))
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false, 'data': []};
    }
  }

  // ========== UPLOAD ==========
  static Future<Map<String, dynamic>> startUpload() async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/upload/start'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false};
    }
  }

  static Future<Map<String, dynamic>> completeUpload(String code) async {
    try {
      final res = await http
          .post(
            Uri.parse('$baseUrl/upload/complete'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'code': code}),
          )
          .timeout(const Duration(seconds: 5));
      return jsonDecode(res.body);
    } catch (e) {
      return {'success': false};
    }
  }
}
