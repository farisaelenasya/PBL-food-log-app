import 'dart:convert';
import 'dart:typed_data';

import 'package:glucoguide/database/database_helper.dart';
import 'package:http/http.dart' as http;

class FoodRecognitionService {

  // 🔥 Ganti dengan API Key Anda dari Google Cloud Vision
  static const String _visionApiKey =
      'AIzaSyC81R0ZxUMIzMvNohbJA0VeUuAottxo2oU';

  static const String _visionUrl =
      'https://vision.googleapis.com/v1/images:annotate';
    
  

  // 🔥 Ganti dengan API Key dari CalorieNinjas
  static const String _calorieApiKey =
      'NczatTkwvalcEGfbUhHwysvaBDXLhi4Fomx5JyIS';

  static const String _calorieUrl =
      'https://api.calorieninjas.com/v1/nutrition';

  /// Step 1: Deteksi makanan dari foto menggunakan Google Cloud Vision
  Future<String?> detectFoodFromImage(
    Uint8List imageBytes,
  ) async {

    try {

      // ✅ WEB SAFE
      String base64Image = base64Encode(imageBytes);

      // Panggil Google Cloud Vision API
      final response = await http.post(
        Uri.parse(
          '$_visionUrl?key=$_visionApiKey',
        ),

        headers: {
          'Content-Type': 'application/json',
        },

        body: jsonEncode({
          'requests': [
            {
              'image': {
                'content': base64Image,
              },

              'features': [
                {
                  'type': 'LABEL_DETECTION',
                  'maxResults': 10,
                },

                {
                  'type': 'OBJECT_LOCALIZATION',
                  'maxResults': 5,
                }
              ],

              'imageContext': {
                'languageHints': ['id', 'en']
              }
            }
          ]
        }),
      );

      if (response.statusCode == 200) {

        final data = jsonDecode(response.body);

        final labels =
            data['responses'][0]['labelAnnotations']
                as List?;

        if (labels != null &&
            labels.isNotEmpty) {

          // Cari label makanan
          for (var label in labels) {

            String description =
                label['description']
                        as String? ??
                    '';

            double score =
                (label['score'] as num?)
                        ?.toDouble() ??
                    0;

            if (_isFoodRelated(description) &&
                score > 0.4) {

              String foodName =
                  _mapToIndonesianFood(
                description,
              );

              print(
                'Detected: $description '
                '(Score: $score) '
                '-> $foodName',
              );

              return foodName;
            }
          }
        }

      } else {

       print('Vision API Error: ${response.statusCode}');
      print('Body: ${response.body}');
      }

   } catch (e, stack) {
  print('Error detecting food: $e');
  print(stack);
}

    return null;
  }

  /// Cek apakah label berhubungan makanan
  bool _isFoodRelated(String label) {

    List<String> foodKeywords = [

      // English
      'food',
      'dish',
      'meal',
      'cuisine',
      'rice',
      'noodle',
      'chicken',
      'meat',
      'fish',
      'egg',
      'tofu',

      // Indonesia
      'makanan',
      'nasi',
      'mie',
      'ayam',
      'ikan',
      'telur',
      'tahu',
      'tempe',
      'sayur',
      'buah',
      'goreng',
      'bakar',
      'soto',
      'bakso',
    ];

    return foodKeywords.any(
      (keyword) =>
          label.toLowerCase().contains(
                keyword.toLowerCase(),
              ),
    );
  }

  /// Mapping label
  String _mapToIndonesianFood(
    String label,
  ) {

    final Map<String, String> mapping = {

      // Nasi
      'fried rice': 'Nasi Goreng',
      'rice': 'Nasi Putih',

      // Ayam
      'fried chicken': 'Ayam Goreng',
      'grilled chicken': 'Ayam Bakar',
      'chicken': 'Ayam',

      // Mie
      'noodle': 'Mie',
      'fried noodle': 'Mie Goreng',

      // Lainnya
      'tofu': 'Tahu',
      'tempeh': 'Tempe',
      'egg': 'Telur',
      'fish': 'Ikan',
      'vegetable': 'Sayur',
      'fruit': 'Buah',
    };

    for (var entry in mapping.entries) {

      if (label.toLowerCase().contains(
            entry.key,
          )) {

        return entry.value;
      }
    }

    return label
        .split(' ')
        .map(
          (word) =>
              word[0].toUpperCase() +
              word.substring(1)
                  .toLowerCase(),
        )
        .join(' ');
  }

  /// Step 2: Ambil nutrisi
  Future<Map<String, dynamic>?>
      getNutritionFromName(
    String foodName,
  ) async {

    try {

      final response = await http.get(

        Uri.parse(
          '$_calorieUrl?query='
          '${Uri.encodeComponent(foodName)}',
        ),

        headers: {
          'X-Api-Key': _calorieApiKey,
        },
      );

      if (response.statusCode == 200) {

        final data =
            jsonDecode(response.body);

        final items =
            data['items'] as List?;

        if (items != null &&
            items.isNotEmpty) {

          final item = items[0];

          return {
            'nama': foodName,
            'kalori':
                (item['calories'] ?? 0)
                    .toDouble(),

            'karbo':
                (item[
                            'carbohydrates_total_g'] ??
                        0)
                    .toDouble(),

            'protein':
                (item['protein_g'] ?? 0)
                    .toDouble(),

            'lemak':
                (item['fat_total_g'] ?? 0)
                    .toDouble(),

            'serat':
                (item['fiber_g'] ?? 0)
                    .toDouble(),

            'gula':
                (item['sugar_g'] ?? 0)
                    .toDouble(),
          };
        }
      }

    } catch (e) {

      print(
        'Error getting nutrition: $e',
      );
    }

    return null;
  }

  /// 🔥 MAIN METHOD
  Future<Map<String, dynamic>?>
      analyzeFoodFromBytes(
    Uint8List imageBytes,
  ) async {

    // Step 1
    String? foodName =
        await detectFoodFromImage(
      imageBytes,
    );

    if (foodName == null) {

      print(
        'Tidak dapat mendeteksi makanan',
      );

      return null;
    }

    // Step 2
    Map<String, dynamic>? nutrition =
        await getNutritionFromName(
      foodName,
    );

    if (nutrition != null) {
      return nutrition;
    }

    // fallback database lokal
    return await _searchLocalDatabase(
      foodName,
    );
  }

  /// fallback db lokal
  Future<Map<String, dynamic>?>
      _searchLocalDatabase(
    String foodName,
  ) async {

    final dbHelper =
        DatabaseHelper.instance;

    final foods =
        await dbHelper.searchFoods(
      foodName,
    );

    if (foods.isNotEmpty) {

      return {
        'nama': foods[0]['nama'],
        'kalori':
            foods[0]['kalori_100g'],

        'karbo':
            foods[0]['karbo_100g'],

        'protein':
            foods[0]['protein_100g'],

        'lemak':
            foods[0]['lemak_100g'],

        'serat':
            foods[0]['serat_100g'],

        'gula':
            foods[0]['gula_100g'],
      };
    }

    return null;
  }

  bool isConfigured() {

    return _visionApiKey !=
                'YOUR_GOOGLE_VISION_API_KEY' &&
            _calorieApiKey !=
                'YOUR_CALORIE_NINJAS_API_KEY';
  }
}