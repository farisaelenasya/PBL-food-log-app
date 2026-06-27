import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../pages/login_page.dart';

class AdminDashboardPage extends StatefulWidget {   // ← ubah dari AdminBerandaPage
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isActive = true;
  late final Stream<Map<String, dynamic>> _stream;

  @override
  void initState() {
    super.initState();
    _stream = _dashboardStream();
  }

  @override
  void dispose() {
    _isActive = false;
    super.dispose();
  }

  Stream<Map<String, dynamic>> _dashboardStream() async* {
    while (_isActive) {
      // Fetch terpisah — satu gagal tidak pengaruhi yang lain
      int totalArtikel = 0;
      int totalPasien  = 0;
      List<Map<String, dynamic>> aktivitas = [];

      try {
        final data = await ApiService.getArtikel();
        totalArtikel = data.length;
      } catch (_) {}

      try {
        final data = await ApiService.getPasien();
        totalPasien = data.length;
      } catch (_) {}

      try {
        final glukosa  = await ApiService.ambilSemuaData();
        final foodLogs = await ApiService.getFoodLogs();

        final List<Map<String, dynamic>> temp = [];

        for (final g in glukosa.take(5)) {
          temp.add({
            'nama' : g['patient_name'] ?? 'Pasien',
            'info' : 'Catat gula darah: ${g['glucose_level']} mg/dL',
            'waktu': g['created_at'] ?? '',
            'warna': const Color(0xFF1A73E8),
            'ikon' : Icons.water_drop_outlined,
          });
        }

        for (final f in foodLogs.take(5)) {
          temp.add({
            'nama' : 'Pasien',
            'info' : 'Catat makanan: ${f['nama_makanan']} (${(f['kalori'] as num?)?.toStringAsFixed(0) ?? '0'} kkal)',
            'waktu': f['dicatat_pada'] ?? '',
            'warna': const Color(0xFF26A69A),
            'ikon' : Icons.restaurant_outlined,
          });
        }

        temp.sort((a, b) =>
            (b['waktu'] as String).compareTo(a['waktu'] as String));

        aktivitas = temp.take(6).toList();
      } catch (_) {}

      if (_isActive) {
        yield {
          'totalArtikel': totalArtikel,
          'totalPasien' : totalPasien,
          'aktivitas'   : aktivitas,
        };
      }

      await Future.delayed(const Duration(seconds: 10));
    }
  }

  String _formatWaktu(String raw) {
    try {
      final dt   = DateTime.parse(raw).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1)  return 'Baru saja';
      if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
      if (diff.inHours < 24)   return '${diff.inHours} jam lalu';
      return '${diff.inDays} hari lalu';
    } catch (_) {
      return '';
    }
  }

Future<void> _logout() async {
  final konfirm = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Logout'),
      content: const Text('Yakin ingin keluar dari Admin Panel?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Logout',
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
      body: SafeArea(
        child: StreamBuilder<Map<String, dynamic>>(
          stream: _stream,
          builder: (context, snapshot) {
            final data      = snapshot.data;
            final isLoading = !snapshot.hasData;

            return RefreshIndicator(
              onRefresh: () async => setState(() {}),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildGridStatistik(data, isLoading),
                    const SizedBox(height: 20),
                    _buildAktivitasTerbaru(data, isLoading),
                    const SizedBox(height: 16),
                    _buildTipAdmin(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── HEADER (tanpa Live badge) ────────────────────────────
  Widget _buildHeader() {
    final jam    = DateTime.now().hour;
    final sapaan = jam < 11
        ? 'Selamat Pagi'
        : jam < 15
            ? 'Selamat Siang'
            : jam < 19
                ? 'Selamat Sore'
                : 'Selamat Malam';

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF1A73E8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text('AD',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 13)),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(sapaan,
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFF90A4AE))),
            const Text('Admin Panel',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A2340))),
          ],
        ),
        const Spacer(),
        IconButton(
          onPressed: _logout,
        icon: const Icon(Icons.logout_rounded),
        color: const Color(0xFFE53935),
        tooltip: 'Logout',
        ),
      ],
    );
  }

  // ── 2 KARTU: Artikel + Total Pasien ─────────────────────
  Widget _buildGridStatistik(Map<String, dynamic>? data, bool isLoading) {
    final items = [
      {
        'nilai': isLoading ? '...' : '${data!['totalArtikel']}',
        'label': 'Artikel Aktif',
        'sub'  : 'Konten edukasi pasien',
        'warna': const Color(0xFF1A73E8),
        'ikon' : Icons.article_outlined,
      },
      {
        'nilai': isLoading ? '...' : '${data!['totalPasien']}',
        'label': 'Total Pasien',
        'sub'  : 'Pengguna terdaftar',
        'warna': const Color(0xFF26A69A),
        'ikon' : Icons.people_outline_rounded,
      },
    ];

    return Row(
      children: List.generate(items.length, (idx) {
        final item = items[idx];
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(
              right: idx == 0 ? 8 : 0,
              left : idx == 1 ? 8 : 0,
            ),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: (item['warna'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['ikon'] as IconData,
                      color: item['warna'] as Color, size: 20),
                ),
                const SizedBox(height: 14),
                isLoading
                    ? Container(
                        width: 48,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Text(
                        item['nilai'] as String,
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: item['warna'] as Color,
                            height: 1),
                      ),
                const SizedBox(height: 4),
                Text(item['label'] as String,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2340))),
                const SizedBox(height: 2),
                Text(item['sub'] as String,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF90A4AE))),
              ],
            ),
          ),
        );
      }),
    );
  }

  // ── AKTIVITAS TERBARU ────────────────────────────────────
bool _expandAktivitas = false;

Widget _buildAktivitasTerbaru(
    Map<String, dynamic>? data, bool isLoading) {
  final semuaList =
      (data?['aktivitas'] as List<Map<String, dynamic>>?) ?? [];

  // Default tampil 3, kalau expand tampil semua (max 6)
  final list = _expandAktivitas
      ? semuaList
      : semuaList.take(3).toList();

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
            color: Colors.black.withOpacity(0.05), blurRadius: 8)
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('AKTIVITAS TERBARU',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF90A4AE),
                    letterSpacing: 0.5)),
            if (!isLoading && semuaList.length > 3)
              GestureDetector(
                onTap: () =>
                    setState(() => _expandAktivitas = !_expandAktivitas),
                child: Text(
                  _expandAktivitas ? 'Sembunyikan' : 'Lihat Semua',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A73E8)),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
        if (isLoading)
          ...List.generate(
            3,
            (_) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10))),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          width: 120,
                          height: 10,
                          color: Colors.grey[200]),
                      const SizedBox(height: 4),
                      Container(
                          width: 180,
                          height: 10,
                          color: Colors.grey[100]),
                    ],
                  ),
                ],
              ),
            ),
          )
        else if (semuaList.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: Text('Belum ada aktivitas',
                  style: TextStyle(
                      fontSize: 13, color: Color(0xFF90A4AE))),
            ),
          )
        else
          ...list.map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (a['warna'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(a['ikon'] as IconData,
                          color: a['warna'] as Color, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a['nama'] as String,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: Color(0xFF1A2340))),
                          Text(a['info'] as String,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF78909C)),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Text(
                      _formatWaktu(a['waktu'] as String),
                      style: const TextStyle(
                          fontSize: 10, color: Color(0xFF90A4AE)),
                    ),
                  ],
                ),
              )),
      ],
    ),
  );
}
  Widget _buildTipAdmin() {
    final tips = [
      '📊 Pantau pasien dengan rata-rata gula >180 mg/dL setiap hari.',
      '📝 Artikel baru meningkatkan keterlibatan pasien hingga 40%.',
      '🥗 Pasien yang catat makanan rutin cenderung lebih terkontrol.',
      '💧 Ingatkan pasien minum air 8 gelas/hari lewat notifikasi.',
    ];
    final tip = tips[DateTime.now().day % tips.length];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1A73E8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.lightbulb_outline_rounded,
                color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Tips Admin Hari Ini',
                    style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(tip,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}