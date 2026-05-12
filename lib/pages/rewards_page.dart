import 'package:flutter/material.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

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
        title: const Text('Hadiah & Poin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        actions: [
          IconButton(icon: const Icon(Icons.help_outline, color: Color(0xFF2979FF)), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Level
            Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 3))]),
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.person, size: 36, color: Color(0xFF2979FF)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Level 5: Pahlawan Kesehatan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 2),
                        Text('Kamu sudah 12 hari berturut-turut, Alex!', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: 750 / 1000,
                                  backgroundColor: Colors.grey[200],
                                  color: const Color(0xFF2979FF),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('750/1000 poin', style: TextStyle(fontSize: 11, color: Color(0xFF2979FF), fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('250 poin lagi ke Level 6', style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 12, color: Color(0xFFFFC107)),
                            const SizedBox(width: 4),
                            Expanded(child: Text('Terus catat makan untuk membuka lencana "Chef Master"', style: TextStyle(fontSize: 10, color: Colors.grey[500]))),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rincian Poin
            const Text('Rincian Poin', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),

            _buildBarisPoin(Icons.check_circle_outline, Colors.blue, 'Catatan Harian Selesai', 'Hari ini, 08.41', '+10 poin', Colors.blue),
            _buildBarisPoin(Icons.restaurant_outlined, Colors.green, 'Makan Rendah Karbo', 'Hari ini, 13.20', '+20 poin', Colors.green),
            _buildBarisPoin(Icons.directions_walk, Colors.orange, 'Pencapaian 10k Langkah', 'Kemarin', '+50 poin', Colors.orange),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {},
                child: const Text('Lihat Semua Riwayat', style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.w600, fontSize: 13)),
              ),
            ),
            const SizedBox(height: 8),

            // Tukar Hadiah
            const Text('Tukar Hadiah', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _buildKartuHadiah(Icons.local_grocery_store_outlined, 'Diskon 10% Belanja', 'Supermarket Terdekat', '100 poin')),
                const SizedBox(width: 12),
                Expanded(child: _buildKartuHadiah(Icons.self_improvement, 'Sesi Yoga Gratis', 'Studio Mindful', '200 poin')),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildBarisPoin(IconData ikon, Color warnaIkon, String judul, String subjudul, String poin, Color warnaPoin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40, height: 40,
          decoration: BoxDecoration(color: warnaIkon.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(ikon, color: warnaIkon, size: 20),
        ),
        title: Text(judul, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
        subtitle: Text(subjudul, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        trailing: Text(poin, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: warnaPoin)),
      ),
    );
  }

  Widget _buildKartuHadiah(IconData ikon, String judul, String subjudul, String poin) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
            child: Icon(ikon, color: const Color(0xFF2979FF), size: 20),
          ),
          const SizedBox(height: 10),
          Text(judul, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 2),
          Text(subjudul, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2979FF), foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0,
                minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () {},
              child: Text(poin, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}