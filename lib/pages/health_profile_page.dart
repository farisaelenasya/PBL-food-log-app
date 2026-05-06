import 'package:flutter/material.dart';
import 'edit_profile_page.dart';

class HealthProfilePage extends StatelessWidget {
  const HealthProfilePage({super.key});

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
        title: const Text('Profil Kesehatan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
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
                    child: const Icon(Icons.person, size: 55, color: Color(0xFF2979FF)),
                  ),
                  const SizedBox(height: 12),
                  const Text('Alex Thompson', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 4),
                  Text('ID Pasien: #98210-HT', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                ],
              ),
            ),
            const SizedBox(height: 12),

            _buildSeksi('Data Dasar', [
              _bariInfo(Icons.person_outline, 'Nama Lengkap', 'Alex Thompson'),
              _bariInfo(Icons.cake_outlined, 'Tanggal Lahir', '14 Oktober 1991\n32 tahun'),
              _bariInfo(Icons.wc, 'Jenis Kelamin', 'Laki-laki\nBiologis'),
            ]),
            const SizedBox(height: 12),

            _buildSeksi('Informasi Medis', [
              _bariMedis(Icons.bloodtype_outlined, Colors.red, 'Golongan Darah', 'O Positif (O+)', 'Penting untuk keadaan darurat'),
              _bariInfo(Icons.monitor_heart_outlined, 'Tanda Vital', '182 cm    78 kg\nDiperbarui 2 hari lalu'),
            ]),
            const SizedBox(height: 12),

            _buildSeksi('Informasi Kontak', [
              _bariInfo(Icons.email_outlined, 'Alamat Email', 'alex.t@example.com\nKontak utama'),
              _bariInfo(Icons.phone_outlined, 'Nomor Telepon', '+62 812-3456-7890\nHandphone'),
              _bariKontakDarurat(),
            ]),
            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2979FF), foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                  ),
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditProfilePage())),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Ubah Informasi Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
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
          Text(judul, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
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
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                Text(nilai, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _bariMedis(IconData ikon, Color warnaIkon, String label, String nilai, String sub) {
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
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(nilai, style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E), fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: const Color(0xFFFFEBEE), borderRadius: BorderRadius.circular(6)),
                      child: Text(sub, style: const TextStyle(fontSize: 10, color: Colors.red)),
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

  static Widget _bariKontakDarurat() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.emergency_outlined, size: 20, color: Color(0xFF2979FF)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kontak Darurat', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const SizedBox(height: 2),
                const Text('Sarah Thompson (Istri)', style: TextStyle(fontSize: 14, color: Color(0xFF1A1A2E))),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF2979FF)),
            child: const Text('Hubungi', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}