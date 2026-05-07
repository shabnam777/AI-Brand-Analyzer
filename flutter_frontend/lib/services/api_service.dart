import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/analysis_result.dart';

class ApiService {
  // Local: http://localhost:5000
  // Android emulator: http://10.0.2.2:5000
  // Production: https://your-app.onrender.com
  static const String baseUrl = 'https://ai-brand-analyzer.onrender.com';
  // static const String baseUrl = 'http://localhost:5000';

  static Future<AnalysisResult> analyze({required String query, required String brand}) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/analyze'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'query': query, 'userBrand': brand}),
        )
        .timeout(const Duration(seconds: 60));

    if (response.statusCode == 200) {
      return AnalysisResult.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Analysis failed: ${response.statusCode} — ${response.body}');
    }
  }
}
