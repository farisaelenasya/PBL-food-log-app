// ============================================================
// FILE: admin_monitor_page.dart
// APLIKASI: DiabеTrack - Panel Admin
// BAGIAN: Tab 4 - Monitoring Pasien
// FUNGSI: Admin memantau data gula darah pasien REAL TIME dari
//         backend (bukan dummy lagi). Menampilkan daftar pasien,
//         tabel data gula darah per pasien, tab Mingguan/Harian,
//         dan log aktivitas (di-derive dari data gula darah).
// ============================================================

import 'package:flutter/material.dart';
import '../services/api_service.dart';

// ── Model log aktivitas (tetap dipakai untuk tampilan) ────────
class LogAktivitas {
  final String judul;
  final String deskripsi;

  const LogAktivitas({required this.judul, required this.deskripsi});
}

class AdminMonitorPage extends StatefulWidget {
  const AdminMonitorPage({super.key});

  @override
  State<AdminMonitorPage> createState() => _AdminMonitorPageState();
}

class _AdminMonitorPageState extends State<AdminMonitorPage> {
  // ── State data asli dari backend ──────────────────────────
  List<Map<String, dynamic>> _pasienList = [];
  List<Map<String, dynamic>> _dataGula = [];
  int? _selectedPasienId;
  bool _loadingPasien = true;
  bool _loadingGula = false;
  String? _errorPasien;

  String _tabGula = 'Harian'; // 'Mingguan' atau 'Harian'

  @override
  void initState() {
    super.initState();
    _muatDaftarPasien();
  }

  // ── Ambil daftar pasien dari API ──────────────────────────
  Future<void> _muatDaftarPasien() async {
    setState(() {
      _loadingPasien = true;
      _errorPasien = null;
    });

    final data = await ApiService.getAdminPatients(); 

    setState(() {
      _pasienList = data;
      _loadingPasien = false;
      if (data.isEmpty) {
        _errorPasien = 'Belum ada data pasien, atau gagal memuat dari server.';
      }
    });

    if (_pasienList.isNotEmpty) {
      final idPertama = _pasienList.first['id'];
      if (idPertama != null) {
        _pilihPasien(idPertama is int ? idPertama : int.tryParse('$idPertama'));
      }
    }
  }

  // ── Pilih pasien → load data gula darahnya ────────────────
  Future<void> _pilihPasien(int? id) async {
    if (id == null) return;
    setState(() {
      _selectedPasienId = id;
      _loadingGula = true;
      _dataGula = [];
    });

    final data = await ApiService.getAdminPatientGlucose(id);

    if (!mounted) return;
    setState(() {
      _dataGula = data;
      _loadingGula = false;
    });
  }

  // ── Filter data gula darah sesuai tab Harian/Mingguan ─────
  List<Map<String, dynamic>> get _dataGulaTerfilter {
    if (_dataGula.isEmpty) return [];
    final now = DateTime.now();

    return _dataGula.where((d) {
      final created = DateTime.tryParse('${d['created_at'] ?? ''}');
      if (created == null) return true;

      if (_tabGula == 'Harian') {
        return created.year == now.year &&
            created.month == now.month &&
            created.day == now.day;
      } else {
        // Mingguan: 7 hari ke belakang
        return now.difference(created).inDays <= 7;
      }
    }).toList();
  }

  // ── Helper format waktu dari created_at (ISO string) ──────
  String _formatWaktu(String? iso, {bool tampilkanTanggal = false}) {
    if (iso == null || iso.isEmpty) return '-';
    final dt = DateTime.tryParse(iso);
    if (dt == null) return '-';

    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    final waktu = '$jam:$menit WIB';

    if (!tampilkanTanggal) return waktu;
    return '${dt.day}/${dt.month} • $waktu';
  }

  String _namaPasienAktif() {
    final p = _pasienList.firstWhere(
      (e) => e['id'] == _selectedPasienId,
      orElse: () => {},
    );
    return (p['name'] ?? 'Pasien').toString();
  }

  // ── Derive log aktivitas dari data gula darah terbaru ─────
  List<LogAktivitas> get _logAktivitasTerderivasi {
    final nama = _namaPasienAktif();
    final terbaru = _dataGulaTerfilter.take(5).toList();

    return terbaru.map((d) {
      final kadar = d['glucose_level'];
      final status = (d['status'] ?? '-').toString();
      final waktu = _formatWaktu(d['created_at']?.toString());

      return LogAktivitas(
        judul: 'Pencatatan Gula Darah',
        deskripsi:
            '$nama mencatatkan kadar gula darah $kadar mg/dL (Status: $status) pada $waktu',
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ───────────────────────────────────────
            _buildAppBar(),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _muatDaftarPasien,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      // ── Profil admin ─────────────────────────
                      _buildProfilAdmin(),

                      // ── Konten utama ─────────────────────────
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ── Daftar pasien ───────────────────
                            _buildSeksi('DATA PASIEN', null),
                            const SizedBox(height: 10),
                            _buildDaftarPasien(),
                            const SizedBox(height: 20),

                            // ── Tabel gula darah ────────────────
                            _buildSeksi('DATA GULA DARAH', _buildTabGula()),
                            const SizedBox(height: 10),
                            _buildTabelGula(),
                            const SizedBox(height: 20),

                            // ── Log aktivitas ────────────────────
                            _buildSeksi('LOG AKTIVITAS', null),
                            const SizedBox(height: 10),
                            _buildLogAktivitas(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
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

  // ── AppBar ────────────────────────────────────────────────
  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(Icons.show_chart_rounded,
                      size: 18, color: Color(0xFF1A73E8)),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Wefiname',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A2340),
                ),
              ),
            ],
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF1A73E8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Profil admin strip ────────────────────────────────────
  Widget _buildProfilAdmin() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: const [
          SizedBox(width: 44),
          SizedBox(width: 10),
          Text('', style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE))),
        ],
      ),
    );
  }

  // ── Judul seksi ───────────────────────────────────────────
  Widget _buildSeksi(String judul, Widget? trailing) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          judul,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Color(0xFF90A4AE),
            letterSpacing: 0.8,
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  // ── Tab Mingguan/Harian ───────────────────────────────────
  Widget _buildTabGula() {
    return Row(
      children: ['Mingguan', 'Harian'].map((t) {
        final aktif = _tabGula == t;
        return GestureDetector(
          onTap: () => setState(() => _tabGula = t),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(left: 6),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: aktif ? const Color(0xFF1A73E8) : const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              t,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: aktif ? Colors.white : const Color(0xFF90A4AE),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Daftar pasien untuk dipilih (DATA ASLI) ───────────────
  Widget _buildDaftarPasien() {
    if (_loadingPasien) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8))),
      );
    }

    if (_pasienList.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          _errorPasien ?? 'Belum ada data pasien.',
          style: const TextStyle(fontSize: 12, color: Color(0xFF90A4AE)),
        ),
      );
    }

    return Column(
      children: _pasienList.map((p) {
        final id = p['id'] is int ? p['id'] as int : int.tryParse('${p['id']}');
        final selected = _selectedPasienId == id;
        final nama = (p['name'] ?? '-').toString();
        final usia = p['umur'] != null ? '${p['umur']} th' : 'Usia -';
        final jk = (p['jenis_kelamin'] ?? '-').toString();
        final tipe = p['tipe_diabetes'] != null
            ? 'TIPE ${p['tipe_diabetes']}'
            : '-';

        return GestureDetector(
          onTap: () => _pilihPasien(id),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFE3F2FD) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFF1A73E8) : Colors.grey.shade100,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nama,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: selected
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFF1A2340),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$usia • $jk',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF90A4AE)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A73E8),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tipe,
                    style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Tabel data gula darah (DATA ASLI) ─────────────────────
  Widget _buildTabelGula() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('WAKTU',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF90A4AE),
                          letterSpacing: 0.8)),
                ),
                Expanded(
                  flex: 3,
                  child: Text('KADAR\n(MG/DL)',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF90A4AE),
                          letterSpacing: 0.8)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('STATUS',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF90A4AE),
                          letterSpacing: 0.8)),
                ),
                Expanded(
                  flex: 1,
                  child: Text('AKSI',
                      style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF90A4AE),
                          letterSpacing: 0.8)),
                ),
              ],
            ),
          ),

          if (_loadingGula)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF1A73E8))),
            )
          else if (_dataGulaTerfilter.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: Text(
                  'Belum ada data gula darah untuk periode ini',
                  style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE)),
                ),
              ),
            )
          else
            ..._dataGulaTerfilter.map((d) => _barisTabel(d)),
        ],
      ),
    );
  }

  Widget _barisTabel(Map<String, dynamic> d) {
    final status = (d['status'] ?? '-').toString().toUpperCase();
    final kadar = d['glucose_level'];
    final waktu = _formatWaktu(
      d['created_at']?.toString(),
      tampilkanTanggal: _tabGula == 'Mingguan',
    );

    final bool tinggi = status == 'TINGGI';
    final bool rendah = status == 'RENDAH';

    final Color warnaUtama = tinggi
        ? const Color(0xFFE53935)
        : rendah
            ? const Color(0xFFFFA726)
            : const Color(0xFF1A2340);

    final Color warnaBadgeBg = tinggi
        ? const Color(0xFFFFEBEE)
        : rendah
            ? const Color(0xFFFFF3E0)
            : const Color(0xFFE8F5E9);

    final Color warnaBadgeText = tinggi
        ? const Color(0xFFE53935)
        : rendah
            ? const Color(0xFFFFA726)
            : const Color(0xFF43A047);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              waktu,
              style: const TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A2340)),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '$kadar',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: warnaUtama),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: warnaBadgeBg,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                status,
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: warnaBadgeText,
                    letterSpacing: 0.3),
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFB0BEC5)),
          ),
        ],
      ),
    );
  }

  // ── Log aktivitas pasien (DERIVED dari data gula darah) ───
  Widget _buildLogAktivitas() {
    final logs = _logAktivitasTerderivasi;

    if (_loadingGula) {
      return const SizedBox.shrink();
    }

    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: const Text(
          'Belum ada aktivitas tercatat untuk pasien ini.',
          style: TextStyle(fontSize: 12, color: Color(0xFF90A4AE)),
        ),
      );
    }

    return Column(
      children: logs.map((log) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 10,
                height: 10,
                margin: const EdgeInsets.only(top: 3),
                decoration: const BoxDecoration(
                  color: Color(0xFF1A73E8),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      log.judul,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1A73E8)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.deskripsi,
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF78909C), height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}