import 'package:flutter/material.dart';
import '../models/medication_store.dart';
import '../models/medication_entry.dart';
import 'add_medication_page.dart';
import 'notifikasi_page.dart';

class InsulinTrackerPage extends StatefulWidget {
  const InsulinTrackerPage({super.key});

  @override
  State<InsulinTrackerPage> createState() => _InsulinTrackerPageState();
}

class _InsulinTrackerPageState extends State<InsulinTrackerPage> {
  final _store = MedicationStore();

  String _formatWaktu(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  @override
  Widget build(BuildContext context) {
    final daftarObat = _store.semuaObat;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Catatan Insulin & Obat',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2979FF)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage())),
          ),
        ],
      ),
      body: daftarObat.isEmpty
          ? _buildKosong()
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 8),
                _buildRingkasan(daftarObat),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Daftar Obat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    Text('${daftarObat.length} obat', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  ],
                ),
                const SizedBox(height: 10),
                ...daftarObat.map((obat) => _buildKartuObat(obat)),
                const SizedBox(height: 80),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2979FF),
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicationPage()));
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Obat', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildRingkasan(List<MedicationEntry> daftarObat) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2979FF), Color(0xFF448AFF)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          const Icon(Icons.medication_rounded, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Total Obat Aktif',
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text('${daftarObat.length} Obat Terdaftar',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('${daftarObat.where((o) => o.frekuensi == 'Setiap Hari').length} rutin harian',
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuObat(MedicationEntry obat) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: const Color(0xFFE8F0FE), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.medication_rounded, color: Color(0xFF2979FF), size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(obat.namaObat,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 3),
                  Text('${obat.dosis} • ${obat.frekuensi}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.access_time_outlined, size: 12, color: Color(0xFF2979FF)),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(obat.waktuKonsumsi,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF2979FF)),
                          overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Text(_formatWaktu(obat.dibuatPada),
                  style: TextStyle(fontSize: 10, color: Colors.grey[400])),
                const SizedBox(height: 4),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada obat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text('Tambahkan obat atau insulin Anda\nuntuk mendapatkan pengingat rutin.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey[400], height: 1.5)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2979FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddMedicationPage()));
              setState(() {});
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Obat'),
          ),
        ],
      ),
    );
  }
}