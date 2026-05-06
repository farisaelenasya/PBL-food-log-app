import 'package:flutter/material.dart';

class MedicalRecordsPage extends StatefulWidget {
  const MedicalRecordsPage({super.key});

  @override
  State<MedicalRecordsPage> createState() => _MedicalRecordsPageState();
}

class _MedicalRecordsPageState extends State<MedicalRecordsPage> {
  int _tabAktif = 0;
  final List<String> _daftarTab = ['Semua', 'Hasil Lab', 'Resep'];

  final List<Map<String, dynamic>> _rekamMedis = [
    {'judul': 'Laporan Lab HbA1c', 'tanggal': 'Diunggah 15 Jan 2025 • 12 MB', 'ikon': Icons.science_outlined, 'warna': Colors.blue},
    {'judul': 'Resep Insulin', 'tanggal': 'Diunggah 20 Jan 2025 • 432 KB', 'ikon': Icons.medication_outlined, 'warna': Colors.green},
    {'judul': 'Pemeriksaan Kesehatan Tahunan', 'tanggal': 'Diunggah 20 Des 2025 • 2.8 MB', 'ikon': Icons.health_and_safety_outlined, 'warna': Colors.orange},
    {'judul': 'Tes Profil Lipid', 'tanggal': 'Diunggah 05 Des 2025 • 11 MB', 'ikon': Icons.biotech_outlined, 'warna': Colors.purple},
  ];

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
        title: const Text('Rekam Medis', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Color(0xFF1A1A2E)), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // Bilah Penyimpanan
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('PENYIMPANAN TERPAKAI', style: TextStyle(fontSize: 10, color: Colors.grey[500], fontWeight: FontWeight.w700, letterSpacing: 1)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2979FF), foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                        minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () {},
                      child: const Text('Unggah', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Row(
                  children: [
                    Text('12.4 MB dari 50 MB', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: 12.4 / 50,
                    backgroundColor: Colors.grey[200],
                    color: const Color(0xFF2979FF),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Tab
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(_daftarTab.length, (i) {
                final dipilih = _tabAktif == i;
                return GestureDetector(
                  onTap: () => setState(() => _tabAktif = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: dipilih ? const Color(0xFF2979FF) : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(_daftarTab[i], style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600,
                      color: dipilih ? Colors.white : Colors.grey[600])),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),

          // Daftar Rekam Medis
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildLabelBulan('DESEMBER 2025'),
                ..._rekamMedis.map((r) => _buildKartuRekamMedis(r)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelBulan(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.grey[500], letterSpacing: 1)),
    );
  }

  Widget _buildKartuRekamMedis(Map<String, dynamic> rekam) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        leading: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
            color: (rekam['warna'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(rekam['ikon'] as IconData, color: rekam['warna'] as Color, size: 22),
        ),
        title: Text(rekam['judul'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        subtitle: Text(rekam['tanggal'], style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(icon: Icon(Icons.visibility_outlined, color: Colors.grey[400], size: 18), onPressed: () {}),
            IconButton(icon: Icon(Icons.download_outlined, color: Colors.grey[400], size: 18), onPressed: () {}),
          ],
        ),
      ),
    );
  }
}