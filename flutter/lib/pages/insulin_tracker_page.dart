import 'package:flutter/material.dart';
import '../services/medication_service.dart';
import '../models/medication_entry.dart';
import 'add_medication_page.dart';
import 'notifikasi_page.dart';

class InsulinTrackerPage extends StatefulWidget {
  const InsulinTrackerPage({super.key});

  @override
  State<InsulinTrackerPage> createState() => _InsulinTrackerPageState();
}

class _InsulinTrackerPageState extends State<InsulinTrackerPage> {
  final _service = MedicationService();
  List<MedicationEntry> _daftarObat = [];
  bool _loading = true;
  String? _error;

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
    final daftarObat = _daftarObat;

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
            icon: const Icon(Icons.add, color: Color(0xFF2979FF)),
            tooltip: 'Tambah Obat',
            onPressed: () async {
              final berhasil = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddMedicationPage()),
              );
              if (berhasil == true) _muatData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Color(0xFF2979FF)),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotifikasiPage())),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text('Gagal memuat: $_error'))
              : daftarObat.isEmpty
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
    );
  }

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _service.getMedications();
      setState(() {
        _daftarObat = data
            .map((e) => MedicationEntry.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
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
    return Dismissible(
      key: Key('obat-${obat.id}'),
      direction: DismissDirection.horizontal,
      confirmDismiss: (arah) => _konfirmasiHapus(obat),
      onDismissed: (_) => _hapusObat(obat),
      background: _backgroundHapus(Alignment.centerLeft),
      secondaryBackground: _backgroundHapus(Alignment.centerRight),
      child: GestureDetector(
        onTap: () async {
          final berhasil = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddMedicationPage(medication: obat)),
          );
          if (berhasil == true) _muatData();
        },
        child: Container(
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
        ),
      ),
    );
  }

  Widget _backgroundHapus(Alignment align) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      alignment: align,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.red[400],
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
    );
  }

  Future<bool> _konfirmasiHapus(MedicationEntry obat) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Obat?'),
        content: Text('Yakin ingin menghapus "${obat.namaObat}" dari daftar obat?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    return hasil ?? false;
  }

  Future<void> _hapusObat(MedicationEntry obat) async {
    setState(() => _daftarObat.removeWhere((o) => o.id == obat.id));

    try {
      if (obat.id != null) {
        await _service.deleteMedication(obat.id!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${obat.namaObat} berhasil dihapus'), backgroundColor: const Color(0xFF2979FF)),
      );
    } catch (e) {
      if (!mounted) return;
      // Gagal hapus di server → muat ulang data biar list balik sinkron
      _muatData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghapus: ${e.toString().replaceFirst('Exception: ', '')}'), backgroundColor: Colors.redAccent),
      );
    }
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
              _muatData();
            },
            icon: const Icon(Icons.add),
            label: const Text('Tambah Obat'),
          ),
        ],
      ),
    );
  }
}