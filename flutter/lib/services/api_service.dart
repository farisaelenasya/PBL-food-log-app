import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/artikel_model.dart';

class ApiService {
  static String get baseUrl {
  if (kIsWeb) {
    return 'http://localhost:8000/api'; // web chrome
  } else {
    return 'http://10.0.2.2:8000/api'; // android emulator
  }
}

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
  // FOOD
  static Future<List<Map<String, dynamic>>> searchFoods(
      String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/foods/search?q=$query'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      return [];
    } catch (e) {
      debugPrint('Search Food Error: $e');
      return [];
    }
  }

 static Future<bool> saveFoodLog(
    Map<String, dynamic> jurnal) async {
  try {
    print("=== DATA DIKIRIM ===");
    print(jsonEncode(jurnal));

    final response = await http.post(
      Uri.parse('$baseUrl/food-logs'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(jurnal),
    );

    print("=== STATUS ===");
    print(response.statusCode);

    print("=== RESPONSE ===");
    print(response.body);

    return response.statusCode == 200 ||
        response.statusCode == 201;
  } catch (e) {
    print("=== ERROR ===");
    print(e);
    return false;
  }
}
// Di api_service.dart
static List<Map<String, dynamic>> normalizeFoodData(List<dynamic> data) {
  return data.map((item) {
    return {
      'id': (item['id'] ?? '').toString(),  // ← pastikan string
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

    print(response.body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final List data = json['data'];

      return data
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

    return [];
  } catch (e) {
    debugPrint('Get Food Logs Error: $e');
    return [];
  }
}
// points
  static Future<Map<String, dynamic>> getPoints() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/points'),
    );

    print("=== POINTS RESPONSE ===");
    print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {
      "success": false,
      "data": {
        "total_poin": 0,
        "level_user": 1
      }
    };
  } catch (e) {
    debugPrint('Get Points Error: $e');

    return {
      "success": false,
      "data": {
        "total_poin": 0,
        "level_user": 1
      }
    };
  } 
}
static Future<Map<String, dynamic>> getDailySugar() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/daily-sugar'),
    );

    print("=== DAILY SUGAR ===");
    print(response.body);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    return {
      "success": false,
      "data": {
        "total_gula": 0,
        "limit": 25,
        "warning": false
      }
    };
  } catch (e) {
    debugPrint('Get Daily Sugar Error: $e');

    return {
      "success": false,
      "data": {
        "total_gula": 0,
        "limit": 25,
        "warning": false
      }
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
      Uri.parse('$baseUrl/artikels'),
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

    print(response.body);

    return response.statusCode == 200 ||
        response.statusCode == 201;
  } catch (e) {
    print('Tambah Artikel Error: $e');
    return false;
  }
}
static Future<List<ArtikelModel>> getArtikel() async {
  try {
    final response = await http.get(
      Uri.parse('$baseUrl/artikel'),
      headers: {'Accept': 'application/json'},
    );

    print("=== GET ARTIKEL ===");
    print(response.body);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);

      final data = json['data'];

      // 🔥 FIX: kalau single object
      if (data is Map<String, dynamic>) {
        return [ArtikelModel.fromJson(data)];
      }

      // 🔥 FIX: kalau list
      if (data is List) {
        return data.map((e) => ArtikelModel.fromJson(e)).toList();
      }
    }

    return [];
  } catch (e) {
    print("GET ARTIKEL ERROR: $e");
    return [];
  }
}
}