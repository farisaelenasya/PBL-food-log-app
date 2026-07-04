import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

class MedicationService {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<dynamic>> getMedications() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/medications'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['data'];
    }

    throw Exception('Gagal mengambil data obat');
  }

  Future<bool> addMedication({
    required String namaObat,
    required String dosis,
    required String frekuensi,
    required String waktuKonsumsi,
    required String tipe,
    String catatan = '',
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/medications'),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nama_obat': namaObat,
        'dosis': dosis,
        'frekuensi': frekuensi,
        'waktu_konsumsi': waktuKonsumsi,
        'tipe': tipe,
        'catatan': catatan,
      }),
    );

    return response.statusCode == 200 || response.statusCode == 201;
  }

  Future<bool> deleteMedication(int id) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/medications/$id'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }
}