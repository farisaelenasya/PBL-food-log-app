import 'package:flutter/material.dart';

class ReminderSettingsPage extends StatefulWidget {
  const ReminderSettingsPage({super.key});

  @override
  State<ReminderSettingsPage> createState() => _ReminderSettingsPageState();
}

class _ReminderSettingsPageState extends State<ReminderSettingsPage> {
  bool _pengingatMakanAktif = true;
  bool _pengingatObatAktif = true;
  bool _cekGulaDarahAktif = false;
  bool _ringkasanMingguanAktif = true;
  String _hariPengiriman = 'Minggu';

  final List<String> _daftarHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Pengaturan Pengingat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline, color: Color(0xFF2979FF)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildJudulSeksi('NOTIFIKASI HARIAN'),
            const SizedBox(height: 10),

            _buildKartuPengingat(
              ikon: Icons.restaurant_outlined,
              ikonBg: const Color(0xFFE3F2FD),
              ikonWarna: const Color(0xFF2979FF),
              judul: 'Pengingat Catatan Makan',
              subjudul: 'Tetap pada jalur dengan pencatatan makan Anda',
              aktif: _pengingatMakanAktif,
              onToggle: (v) => setState(() => _pengingatMakanAktif = v),
              konten: _pengingatMakanAktif ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    _chipWaktu('08.00\nPagi'),
                    const SizedBox(width: 8),
                    _chipWaktu('13.00\nSiang'),
                    const SizedBox(width: 8),
                    _chipWaktu('19.30\nMalam'),
                    const SizedBox(width: 8),
                    _chipTambah(),
                  ],
                ),
              ) : null,
            ),
            const SizedBox(height: 12),

            _buildKartuPengingat(
              ikon: Icons.medication_outlined,
              ikonBg: const Color(0xFFE8F5E9),
              ikonWarna: Colors.green,
              judul: 'Pengingat Obat',
              subjudul: 'Jangan sampai melewatkan dosis terjadwal',
              aktif: _pengingatObatAktif,
              onToggle: (v) => setState(() => _pengingatObatAktif = v),
              konten: _pengingatObatAktif ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    _chipWaktu('10.03\nPagi'),
                    const SizedBox(width: 8),
                    _chipTambah(),
                  ],
                ),
              ) : null,
            ),
            const SizedBox(height: 12),

            _buildKartuPengingat(
              ikon: Icons.water_drop_outlined,
              ikonBg: const Color(0xFFFCE4EC),
              ikonWarna: Colors.pinkAccent,
              judul: 'Cek Gula Darah',
              subjudul: 'Pantau kadar gula darah secara rutin',
              aktif: _cekGulaDarahAktif,
              onToggle: (v) => setState(() => _cekGulaDarahAktif = v),
              teksTidakAktif: 'Notifikasi saat ini dinonaktifkan',
            ),
            const SizedBox(height: 20),

            _buildJudulSeksi('LAPORAN'),
            const SizedBox(height: 10),

            _buildKartuPengingat(
              ikon: Icons.bar_chart_rounded,
              ikonBg: const Color(0xFFEDE7F6),
              ikonWarna: Colors.deepPurple,
              judul: 'Ringkasan Mingguan',
              subjudul: 'Tinjau tren kesehatan Anda setiap minggu',
              aktif: _ringkasanMingguanAktif,
              onToggle: (v) => setState(() => _ringkasanMingguanAktif = v),
              konten: _ringkasanMingguanAktif ? Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Hari Pengiriman', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                    DropdownButton<String>(
                      value: _hariPengiriman,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.keyboard_arrow_down, size: 16),
                      style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600),
                      items: _daftarHari.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
                      onChanged: (v) => setState(() => _hariPengiriman = v!),
                    ),
                  ],
                ),
              ) : null,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildJudulSeksi(String judul) {
    return Text(judul, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[500], letterSpacing: 1));
  }

  Widget _buildKartuPengingat({
    required IconData ikon,
    required Color ikonBg,
    required Color ikonWarna,
    required String judul,
    required String subjudul,
    required bool aktif,
    required ValueChanged<bool> onToggle,
    Widget? konten,
    String? teksTidakAktif,
  }) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))]),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: ikonBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(ikon, color: ikonWarna, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(judul, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                    const SizedBox(height: 2),
                    Text(subjudul, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  ],
                ),
              ),
              Switch(value: aktif, onChanged: onToggle, activeColor: const Color(0xFF2979FF)),
            ],
          ),
          if (!aktif && teksTidakAktif != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(teksTidakAktif, style: TextStyle(fontSize: 11, color: Colors.grey[400], fontStyle: FontStyle.italic)),
            ),
          if (konten != null) konten,
        ],
      ),
    );
  }

  Widget _chipWaktu(String waktu) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(8)),
      child: Text(waktu, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF2979FF), fontWeight: FontWeight.w600)),
    );
  }

  Widget _chipTambah() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFF2979FF)), borderRadius: BorderRadius.circular(8)),
      child: const Text('+ Tambah', style: TextStyle(fontSize: 11, color: Color(0xFF2979FF), fontWeight: FontWeight.w600)),
    );
  }
}