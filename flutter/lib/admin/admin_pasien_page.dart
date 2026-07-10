import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminPasienPage extends StatefulWidget {
  const AdminPasienPage({super.key});

  @override
  State<AdminPasienPage> createState() => _AdminPasienPageState();
}

class _AdminPasienPageState extends State<AdminPasienPage> {
  final _cariCtrl = TextEditingController();

  List<Map<String, dynamic>> _semuaPasien = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPasien();
  }

  @override
  void dispose() {
    _cariCtrl.dispose();
    super.dispose();
  }

  // ── Ambil data pasien dari API — otomatis terisi begitu ──
  // ── pasien baru mendaftar lewat halaman register mereka ─
  Future<void> _loadPasien() async {
    try {
      final data = await ApiService.getPasien();
      setState(() {
        _semuaPasien = data;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('ERROR LOAD PASIEN: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await _loadPasien();
  }

  // ── Helper ambil field dengan aman (nama key bisa beda) ──
  String _ambilNama(Map<String, dynamic> p) =>
      (p['nama'] ?? p['name'] ?? p['nama_pasien'] ?? 'Tanpa Nama').toString();

  String _ambilEmail(Map<String, dynamic> p) =>
      (p['email'] ?? '-').toString();

  String _ambilTipe(Map<String, dynamic> p) =>
      (p['tipe_diabetes'] ?? p['tipe'] ?? '-').toString();

  String _ambilTanggalDaftar(Map<String, dynamic> p) {
    final raw = p['created_at'] ?? p['dibuat_pada'] ?? p['tanggal_daftar'];
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      const bulan = [
        '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      return '${dt.day} ${bulan[dt.month]} ${dt.year}';
    } catch (_) {
      return '';
    }
  }

  String _inisialDari(String nama) {
    final bagian = nama.trim().split(' ').where((s) => s.isNotEmpty).toList();
    if (bagian.isEmpty) return '?';
    if (bagian.length == 1) return bagian[0][0].toUpperCase();
    return (bagian[0][0] + bagian[1][0]).toUpperCase();
  }

  List<Map<String, dynamic>> get _filtered {
    if (_cariCtrl.text.isEmpty) return _semuaPasien;
    final q = _cariCtrl.text.toLowerCase();
    return _semuaPasien.where((p) {
      return _ambilNama(p).toLowerCase().contains(q) ||
          _ambilEmail(p).toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),

            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFF1A73E8)),
                    )
                  : RefreshIndicator(
                      onRefresh: _refresh,
                      child: SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),

                            // Banner
                            _buildBannerKelola(),
                            const SizedBox(height: 16),

                            // Search bar
                            _buildSearchBar(),
                            const SizedBox(height: 16),

                            // Ringkasan populasi (total pasien terdaftar otomatis)
                            _buildRingkasanPopulasi(),
                            const SizedBox(height: 16),

                            // Label daftar
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'DAFTAR PASIEN TERDAFTAR (${_filtered.length})',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF90A4AE),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Daftar pasien atau kosong
                            if (_filtered.isEmpty)
                              _buildKosong()
                            else
                              ..._filtered.map((p) => _buildKartuPasien(p)),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildAppBar(BuildContext context) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    color: Colors.white,
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Daftar Pasien',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A2340),
              ),
            ),
            SizedBox(height: 3),
            Text(
              'Kelola data pasien terdaftar',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF78909C),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: _refresh,
          icon: const Icon(
            Icons.refresh_rounded,
            color: Color(0xFF78909C),
            size: 22,
          ),
        ),
      ],
    ),
  );
}

  Widget _buildBannerKelola() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF1E88E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Daftar Pasien',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Pasien akan muncul otomatis di sini setelah mereka mendaftar akun melalui aplikasi.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _cariCtrl,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Cari nama atau email pasien...',
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded,
            color: Color(0xFFB0BEC5), size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1A73E8), width: 1.5),
        ),
      ),
    );
  }

  // ── Ringkasan: total pasien otomatis dari panjang list API ──
  Widget _buildRingkasanPopulasi() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.people_alt_rounded,
                color: Color(0xFF1A73E8), size: 24),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_semuaPasien.length}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2340),
                  height: 1,
                ),
              ),
              const Text(
                'TOTAL PASIEN TERDAFTAR',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF90A4AE),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKosong() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          Icon(Icons.people_outline_rounded, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 10),
          Text(
            _cariCtrl.text.isEmpty
                ? 'Belum ada pasien yang mendaftar'
                : 'Pasien tidak ditemukan',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ── Kartu pasien: hanya info, tanpa toggle aktif/nonaktif ──
  Widget _buildKartuPasien(Map<String, dynamic> p) {
    final nama  = _ambilNama(p);
    final email = _ambilEmail(p);
    final tipe  = _ambilTipe(p);
    final tgl   = _ambilTanggalDaftar(p);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          // Avatar inisial
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                _inisialDari(nama),
                style: const TextStyle(
                  color: Color(0xFF1A73E8),
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Info pasien
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A2340),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$email • $tipe',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF90A4AE),
                  ),
                ),
                if (tgl.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 4),
                      Text(
                        'Bergabung $tgl',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF90A4AE)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Badge "Terdaftar" — statis, tanpa interaksi
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Terdaftar',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF43A047),
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}