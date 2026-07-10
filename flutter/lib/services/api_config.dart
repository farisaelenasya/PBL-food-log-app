import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }

    return 'http://192.168.1.9:8000/api';
  }
}