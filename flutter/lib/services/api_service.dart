import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  /// Kirim data gula darah ke Laravel
  static Future<bool> simpanGlukosa({
    required String patientName,
    required int glucoseLevel,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/glucoses'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'patient_name': patientName,
          'glucose_level': glucoseLevel,
        }),
      );
      return response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  /// Ambil 7 data gula darah terbaru
  static Future<List<double>> ambilData7Hari() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/glucoses'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List list = json['data'];
        final reversed = list.reversed.toList();
        return reversed
            .map<double>((e) => (e['glucose_level'] as int).toDouble())
            .toList();
      }
    } catch (e) {
      print('ApiService error: $e');
    }
    return [88, 102, 97, 142, 118, 125, 131];
  }

  /// Ambil semua data dengan created_at untuk keperluan mingguan/bulanan
  static Future<List<Map<String, dynamic>>> ambilSemuaData() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/glucoses'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List list = json['data'];
        return List<Map<String, dynamic>>.from(list);
      }
    } catch (e) {
      print('ApiService error: $e');
    }
    return [];
  }
}
