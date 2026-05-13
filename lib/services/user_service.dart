import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  static const _keyUserId    = 'user_id';
  static const _keyUserNama  = 'user_nama';
  static const _keyUserEmail = 'user_email';

  // ── Daftar akun baru ──────────────────────────────────────────────────────
  Future<String?> daftar({
    required String nama,
    required String email,
    required String password,
  }) async {
    final existing = await DatabaseHelper().getUserByEmail(email);
    if (existing != null) return 'Email sudah terdaftar';

    final id = await DatabaseHelper().insertUser({
      'nama': nama,
      'email': email,
      'password': password,
      'dibuat_pada': DateTime.now().toIso8601String(),
    });

    if (id <= 0) return 'Gagal membuat akun';
    await _simpanSesi(id: id, nama: nama, email: email);
    return null;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final user = await DatabaseHelper().getUserByEmail(email);
    if (user == null) return 'Email tidak terdaftar';
    if (user['password'] != password) return 'Kata sandi salah';

    await _simpanSesi(
      id: user['id'] as int,
      nama: user['nama'] as String,
      email: user['email'] as String,
    );
    return null;
  }

  Future<void> _simpanSesi({
    required int id,
    required String nama,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
    await prefs.setString(_keyUserNama, nama);
    await prefs.setString(_keyUserEmail, email);
  }

  Future<bool> sudahLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  Future<Map<String, String>> getUserAktif() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'nama': prefs.getString(_keyUserNama) ?? 'Pengguna',
      'email': prefs.getString(_keyUserEmail) ?? '',
    };
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserNama);
    await prefs.remove(_keyUserEmail);
  }
}