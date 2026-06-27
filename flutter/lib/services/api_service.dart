import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/artikel_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.1.3:8000/api';
  
  static Future<Map<String, String>> _authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Kirim data gula darah ke Laravel
  static Future<bool> simpanGlukosa({
    required String patientName,
    required int glucoseLevel,
  }) async {
    try {
      final headers = await _authHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl/glucoses'),
        headers: headers,
        body: jsonEncode({
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
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/glucoses'),
        headers: headers,
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
      debugPrint('ApiService error: $e');
    }
    return [88, 102, 97, 142, 118, 125, 131];
  }

 /// Ambil semua data dengan created_at untuk keperluan mingguan/bulanan
  static Future<List<Map<String, dynamic>>> ambilSemuaData() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/glucoses'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List list = json['data'];
        return List<Map<String, dynamic>>.from(list);
      }
    } catch (e) {
      debugPrint('ApiService error: $e');
    }
    return [];
  }

  /// Ambil data pasien untuk dashboard admin.
  /// Backend: GET /api/users → UserController@index
  /// Pasien baru yang sudah register otomatis ikut muncul di sini
  /// karena query langsung ke tabel users, tidak ada cache/list statis.
  static Future<List<Map<String, dynamic>>> getPasien() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: await _authHeaders(),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        // Laravel apiResource/index biasanya bungkus dengan {"data": [...]}
        // tapi beberapa controller custom langsung return array.
        final List list = json is Map && json.containsKey('data')
            ? json['data']
            : json as List;
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('ApiService getPasien error: $e');
    }
    return [];
  }

/// ADMIN: Ambil daftar pasien (role = 'user') untuk monitoring
  /// Backend: GET /api/admin/patients → AdminController@patients
  static Future<List<Map<String, dynamic>>> getAdminPatients() async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/patients'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List list = json['data'];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('getAdminPatients error: $e');
    }
    return [];
  }

  /// ADMIN: Ambil data gula darah milik 1 pasien tertentu
  /// Backend: GET /api/admin/patients/{id}/glucose → AdminController@patientGlucose
  static Future<List<Map<String, dynamic>>> getAdminPatientGlucose(
      int patientId) async {
    try {
      final headers = await _authHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl/admin/patients/$patientId/glucose'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List list = json['data'];
        return list.map((e) => Map<String, dynamic>.from(e)).toList();
      }
    } catch (e) {
      debugPrint('getAdminPatientGlucose error: $e');
    }
    return [];
  }

  // FOOD
  static Future<List<Map<String, dynamic>>> searchFoods(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Search Food Error: $e');
      return [];
    }
  }

  static Future<bool> saveFoodLog(Map<String, dynamic> jurnal) async {
    try {
      debugPrint('=== DATA DIKIRIM ===');
      debugPrint(jsonEncode(jurnal));

      final response = await http.post(
        Uri.parse('$baseUrl/food-logs'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jurnal),
      );

      debugPrint('=== STATUS ===');
      debugPrint('${response.statusCode}');

      debugPrint('=== RESPONSE ===');
      debugPrint(response.body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('=== ERROR ===');
      debugPrint('$e');
      return false;
    }
  }

  // Normalisasi data makanan dari backend agar tipe data konsisten
  static List<Map<String, dynamic>> normalizeFoodData(List<dynamic> data) {
    return data.map((item) {
      return {
        'id': (item['id'] ?? '').toString(),
        'nama': (item['nama'] ?? '').toString(),
        'emoji': (item['emoji'] ?? '🍽️').toString(),
        'kalori_100g': _toDouble(item['kalori_100g']),
        'karbo_100g': _toDouble(item['karbo_100g']),
        'protein_100g': _toDouble(item['protein_100g']),
        'lemak_100g': _toDouble(item['lemak_100g']),
        'serat_100g': _toDouble(item['serat_100g'] ?? 0),
        'gula_100g': _toDouble(item['gula_100g'] ?? 0),
        'kategori': (item['kategori'] ?? 'umum').toString(),
        'indeks_glikemik': _toInt(item['indeks_glikemik'] ?? 50),
      };
    }).toList();
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static Future<List<Map<String, dynamic>>> getFoodLogs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/food-logs'),
      );

      debugPrint(response.body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final List data = json['data'];
        return data.map((e) => Map<String, dynamic>.from(e)).toList();
      }

      return [];
    } catch (e) {
      debugPrint('Get Food Logs Error: $e');
      return [];
    }
  }

  // POINTS
  static Future<Map<String, dynamic>> getPoints() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/points'),
        headers: await _authHeaders(),
      );

      debugPrint('=== POINTS RESPONSE ===');
      debugPrint(response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'data': {'total_poin': 0, 'level_user': 1}
      };
    } catch (e) {
      debugPrint('Get Points Error: $e');
      return {
        'success': false,
        'data': {'total_poin': 0, 'level_user': 1}
      };
    }
  }

  static Future<Map<String, dynamic>> getDailySugar() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/daily-sugar'),
      );

      debugPrint('=== DAILY SUGAR ===');
      debugPrint(response.body);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      return {
        'success': false,
        'data': {'total_gula': 0, 'limit': 25, 'warning': false}
      };
    } catch (e) {
      debugPrint('Get Daily Sugar Error: $e');
      return {
        'success': false,
        'data': {'total_gula': 0, 'limit': 25, 'warning': false}
      };
    }
  }

  static Future<bool> tambahArtikel({
    required String judul,
    required String kategori,
    required String isi,
    required String link,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/artikel'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'judul': judul,
          'kategori': kategori,
          'isi': isi,
          'link_artikel': link,
        }),
      );

      debugPrint('=== TAMBAH ARTIKEL STATUS: ${response.statusCode} ===');
      debugPrint(response.body);

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      debugPrint('Tambah Artikel Error: $e');
      return false;
    }
  }

  /// Hapus artikel berdasarkan id.
  static Future<bool> hapusArtikel(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/artikel/$id'),
        headers: {'Accept': 'application/json'},
      );
      debugPrint('=== HAPUS ARTIKEL STATUS: ${response.statusCode} ===');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Hapus Artikel Error: $e');
      return false;
    }
  }

  //lihat catatan di ArtikelController.
  static Future<List<ArtikelModel>> getArtikel() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/artikel'),
        headers: {'Accept': 'application/json'},
      );

      debugPrint('=== GET ARTIKEL ===');
      debugPrint(response.body);

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];

        if (data is Map<String, dynamic>) {
          return [ArtikelModel.fromJson(data)];
        }

        if (data is List) {
          return data.map((e) => ArtikelModel.fromJson(e)).toList();
        }
      }

      return [];
    } catch (e) {
      debugPrint('GET ARTIKEL ERROR: $e');
      return [];
    }
  }
}
