import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class MedicationLogService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> catatDiminum(int medicationId) async {
    return _kirimLog(medicationId: medicationId, status: 'diminum');
  }

  Future<bool> catatTunda(int medicationId, {int menit = 30}) async {
    return _kirimLog(
        medicationId: medicationId, status: 'ditunda', tundaMenit: menit);
  }

  Future<bool> _kirimLog({
    required int medicationId,
    required String status,
    int? tundaMenit,
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/medication-logs'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'medication_id': medicationId,
        'status': status,
        if (tundaMenit != null) 'tunda_menit': tundaMenit,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    }
    print('DEBUG medication-logs status: ${response.statusCode}');
    print('DEBUG medication-logs body: ${response.body}');
    throw Exception('Gagal mengirim log obat (${response.statusCode})');
  }
}
