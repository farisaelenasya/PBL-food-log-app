import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'dashboard_page.dart';
import 'blood_sugar_analysis_page.dart';
import 'meal_history_page.dart';
import 'food_photo_input_page.dart';
import '../services/api_config.dart';
import 'login_page.dart';


class HealthProfilePage extends StatefulWidget {
  const HealthProfilePage({super.key});

  @override
  State<HealthProfilePage> createState() => _HealthProfilePageState();
}

class _HealthProfilePageState extends State<HealthProfilePage> {
  Map<String, dynamic>? _user;
  bool _sedangMemuat = true;

  int _indeksAktif = 4;

  static String get baseUrl => ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  Future<void> _muatProfil() async {
    setState(() => _sedangMemuat = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final res = await http.get(
        Uri.parse('${baseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() => _user = data['user']);
      } else {
        _snackbar('Gagal memuat profil', Colors.red);
      }
    } catch (e) {
      _snackbar('Gagal terhubung ke server', Colors.red);
    } finally {
      setState(() => _sedangMemuat = false);
    }
  }

  void _snackbar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(pesan),
      backgroundColor: warna,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  String _formatTanggal(String? tgl) {
    if (tgl == null || tgl.isEmpty) return '-';
    try {
      final dt = DateTime.parse(tgl);
      const bulan = [
        '',
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return tgl;
    }
  }

Future<void> _logout() async {
  final konfirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Keluar'),
      content: const Text('Yakin ingin keluar dari akun?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Keluar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );

  if (konfirm != true) return;

  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();

  if (!mounted) return;
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const LoginPage()),
    (_) => false,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'Profil Kesehatan',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ),
      body: _sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF2979FF),
              ),
            )
          : _user == null
              ? const Center(
                  child: Text('Gagal memuat data profil'),
                )
              : _buildKonten(),
      bottomNavigationBar: _buildNavBawah(),
    );
  }

  Widget _buildKonten() {
    final u = _user!;
    final nama = u['name'] ?? '-';
    final idPasien = '#${u['id'].toString().padLeft(5, '0')}-HT';
    final tglLahir = _formatTanggal(u['tanggal_lahir']);
    final umur = u['umur'] != null ? '${u['umur']} tahun' : '-';
    final tinggi = u['tinggi_badan'] != null ? '${u['tinggi_badan']} cm' : '-';
    final berat = u['berat_badan'] != null ? '${u['berat_badan']} kg' : '-';
    final kelamin = u['jenis_kelamin'] ?? '-';
    final golDarah = u['golongan_darah'] ?? '-';
    final email = u['email'] ?? '-';
    final telepon = u['no_telepon'] ?? '-';
    final tipeDiabet =
        u['tipe_diabetes'] != null ? 'Diabetes ${u['tipe_diabetes']}' : '-';

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Container(
            color: Colors.white,
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                CircleAvatar(
                 radius: 50,
                 backgroundColor: Colors.blue[100],
                 backgroundImage: (_user!['foto_profil'] != null &&
                   (_user!['foto_profil'] as String).isNotEmpty)
                    ? NetworkImage(_user!['foto_profil'] as String)
                      : null,
                   child: (_user!['foto_profil'] == null ||
                  (_user!['foto_profil'] as String).isEmpty)
      ? const Icon(Icons.person,
          size: 50, color: Color(0xFF2979FF))
      : null,
),
                const SizedBox(height: 20),
                Text(nama,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A2E))),
                const SizedBox(height: 4),
                Text('ID Pasien: $idPasien',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(height: 12),

          _buildSeksi('Data Dasar', [
            _bariInfo(Icons.person_outline, 'Nama Lengkap', nama),
            _bariInfo(Icons.cake_outlined, 'Tanggal Lahir', '$tglLahir\n$umur'),
            _bariInfo(Icons.wc, 'Jenis Kelamin', '$kelamin\nBiologis'),
          ]),
          const SizedBox(height: 12),

          _buildSeksi('Informasi Medis', [
            _bariMedis(Icons.bloodtype_outlined, Colors.red, 'Golongan Darah',
                golDarah, 'Penting untuk keadaan darurat'),
            _bariInfo(Icons.monitor_heart_outlined, 'Tanda Vital',
                '$tinggi    $berat'),
            _bariInfo(Icons.water_drop_rounded, 'Tipe Diabetes', tipeDiabet),
          ]),
          const SizedBox(height: 12),

          _buildSeksi('Informasi Kontak', [
            _bariInfo(
                Icons.email_outlined, 'Alamat Email', '$email\nKontak utama'),
            _bariInfo(
                Icons.phone_outlined, 'Nomor Telepon', '$telepon\nHandphone'),
          ]),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2979FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                onPressed: () async {
                  final diperbarui = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(builder: (_) => const EditProfilePage()),
                  );
                  if (diperbarui == true) _muatProfil();
                },
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('Ubah Informasi Profil',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ),
           const SizedBox(height: 12), // ← tambah ini
          Padding(                    // ← tambah ini sampai bawah
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text('Keluar',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  static Widget _buildSeksi(String judul, List<Widget> baris) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(judul,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E))),
          const SizedBox(height: 12),
          ...baris,
        ],
      ),
    );
  }

  static Widget _bariInfo(IconData ikon, String label, String nilai) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 20, color: const Color(0xFF2979FF)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(nilai,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFF1A1A2E), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bariMedis(
      IconData ikon, Color warnaIkon, String label, String nilai, String sub) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ikon, size: 20, color: warnaIkon),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(nilai,
                        style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF1A1A2E),
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(sub,
                          style:
                              const TextStyle(fontSize: 10, color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBawah() {
    final daftarMenu = [
      {'ikon': Icons.home_rounded, 'label': 'Beranda'},
      {'ikon': Icons.bar_chart_rounded, 'label': 'Laporan'},
      {'ikon': null, 'label': 'Tambah'},
      {'ikon': Icons.history_rounded, 'label': 'Riwayat'},
      {'ikon': Icons.person_outline_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(daftarMenu.length, (i) {
          if (i == 2) {
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FoodPhotoInputPage())),
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF2979FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x442979FF),
                        blurRadius: 12,
                        offset: Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            );
          }

          final aktif = _indeksAktif == i;

          final List<Widget?> halamanTujuan = [
            const DashboardPage(),
            const BloodSugarAnalysisPage(),
            null,
            const MealHistoryPage(),
            const HealthProfilePage()
          ];

          return GestureDetector(
            onTap: () {
              setState(() => _indeksAktif = i);

              if (halamanTujuan[i] != null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => halamanTujuan[i]!));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(daftarMenu[i]['ikon'] as IconData,
                    color: aktif ? const Color(0xFF2979FF) : Colors.grey[400],
                    size: 24),
                const SizedBox(height: 3),
                Text(daftarMenu[i]['label'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            aktif ? const Color(0xFF2979FF) : Colors.grey[400],
                        fontWeight:
                            aktif ? FontWeight.w600 : FontWeight.normal)),
              ],
            ),
          );
        }),
      ),
    );
  }
}
