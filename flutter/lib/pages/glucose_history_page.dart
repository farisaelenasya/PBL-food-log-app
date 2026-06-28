import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'detail_pengukuran_page.dart';

class GlucoseHistoryPage extends StatefulWidget {
  const GlucoseHistoryPage({super.key});

  @override
  State<GlucoseHistoryPage> createState() => _GlucoseHistoryPageState();
}

class _GlucoseHistoryPageState extends State<GlucoseHistoryPage> {
  List<Map<String, dynamic>> apiData = [];

  Future<void> loadGlucose() async {
    try {
      final data = await ApiService.ambilSemuaData();
      setState(() {
        apiData = data;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    loadGlucose();
  }

  String statusGlukosa(double nilai) {
    if (nilai < 70) return 'Hipoglikemia';
    if (nilai <= 99) return 'Normal';
    if (nilai <= 125) return 'Pra-Diabetes';
    if (nilai <= 199) return 'Diabetes';
    return 'Diabetes Kritis';
  }

  Color warnaStatus(double nilai) {
    if (nilai < 70) return const Color(0xFFFF6B35);
    if (nilai <= 99) return const Color(0xFF4CAF50);
    if (nilai <= 125) return const Color(0xFFFFA726);
    if (nilai <= 199) return const Color(0xFFF44336);
    return const Color(0xFFB71C1C);
  }

  String _formatWaktuSingkat(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24) {
      return 'Hari ini, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) {
      return 'Kemarin, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final entri = apiData;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Gula Darah',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 16),

          // Header Riwayat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Riwayat Terakhir',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A2E))),
              Text('${entri.length} catatan',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 10),

          // Daftar entri
          ...entri.map((e) => _buildItemEntri(e)),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildItemEntri(Map<String, dynamic> e) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailPengukuranPage(data: e),
          ),
        );
      },
      child: _buildKontenEntri(e),
    );
  }

  Widget _buildKontenEntri(Map<String, dynamic> e) {
    final double nilai = (e['glucose_level'] as int).toDouble();
    final waktu = DateTime.parse(e['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF2979FF).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child:
              const Icon(Icons.water_drop, color: Color(0xFF2979FF), size: 22),
        ),
        title: Text(
          '${nilai.toInt()} mg/dL',
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E)),
        ),
        subtitle: Text(
          '${_formatWaktuSingkat(waktu)} • ${e['patient_name'] ?? '-'}',
          style: TextStyle(fontSize: 12, color: Colors.grey[500]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[300]),
      ),
    );
  }
}