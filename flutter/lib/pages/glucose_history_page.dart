import 'package:flutter/material.dart';
import 'add_glucose_page.dart';
import '../services/api_service.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class GlucoseHistoryPage extends StatefulWidget {
  const GlucoseHistoryPage({super.key});

  @override
  State<GlucoseHistoryPage> createState() => _GlucoseHistoryPageState();
}

class _GlucoseHistoryPageState extends State<GlucoseHistoryPage> {
  List<Map<String, dynamic>> apiData = [];
  int _tabAktif = 1;
final List<String> _daftarTab = ['Hari', 'Minggu', 'Bulan'];

List<Map<String, dynamic>> get _dataFiltered {
  final now = DateTime.now();
  return apiData.where((e) {
    final waktu = DateTime.parse(e['created_at']);
    if (_tabAktif == 0) {
      return waktu.year == now.year &&
          waktu.month == now.month &&
          waktu.day == now.day;
    } else if (_tabAktif == 1) {
      return now.difference(waktu).inDays <= 7;
    } else {
      return now.difference(waktu).inDays <= 30;
    }
  }).toList();
}


  Future<void> loadGlucose() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiService.baseUrl}/glucoses'),
        headers: {'Accept': 'application/json'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        setState(() {
          apiData = List<Map<String, dynamic>>.from(json['data']);
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    loadGlucose();
  }

Widget _buildTabPeriode() {
  return Container(
    decoration: BoxDecoration(
      color: const Color(0xFFE2E5EA),
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.all(4),
    child: Row(
      children: List.generate(_daftarTab.length, (i) {
        final aktif = _tabAktif == i;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _tabAktif = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: aktif ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: aktif
                    ? [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))]
                    : [],
              ),
              child: Text(
                _daftarTab[i],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
                  color: aktif ? const Color(0xFF2979FF) : Colors.grey[500],
                ),
              ),
            ),
          ),
        );
      }),
    ),
  );
}

  String _statusGlukosa(double nilai) {
  if (nilai < 70) return 'Hipoglikemia';
  if (nilai <= 99) return 'Normal';
  if (nilai <= 125) return 'Pra-Diabetes';
  if (nilai <= 199) return 'Diabetes';
  return 'Diabetes Kritis';
}

Color _warnaStatus(double nilai) {
  if (nilai < 70) return const Color(0xFFFF6B35);
  if (nilai <= 99) return const Color(0xFF4CAF50);
  if (nilai <= 125) return const Color(0xFFFFA726);
  if (nilai <= 199) return const Color(0xFFF44336);
  return const Color(0xFFB71C1C);
}

  String _formatWaktuSingkat(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24)
      return 'Hari ini, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (diff.inDays == 1)
      return 'Kemarin, ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final entri = _dataFiltered;
     final data7 = entri.isEmpty ? <double>[]
        : (List<Map<String, dynamic>>.from(entri)
            ..sort((a, b) => DateTime.parse(a['created_at'])
                .compareTo(DateTime.parse(b['created_at']))))
            .map((e) => (e['glucose_level'] as num).toDouble())
            .toList();
    final rata = entri.isEmpty ? 0.0
        : entri.fold<double>(0, (s, e) => s + (e['glucose_level'] as num).toDouble()) / entri.length;

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
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline,
                color: Color(0xFF2979FF), size: 26),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const AddGlucosePage()));
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),
      
        _buildTabPeriode(),
          const SizedBox(height: 16),

          // Kartu Ringkasan
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.blue.withValues(alpha: 0.07),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rata-rata Minggu Ini',
                        style:
                            TextStyle(fontSize: 13, color: Colors.grey[500])),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        _statusGlukosa(rata),
                        style: TextStyle(
                            fontSize: 11,
                            color: _warnaStatus(rata),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(rata.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('mg/dL',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Grafik Garis Live
                SizedBox(
                  height: 100,
                  child: _GrafikGarisLive(data: data7),
                ),
                const SizedBox(height: 8),
                // Label hari
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _labelHari(data7.length)
                      .map((h) => Text(h,
                          style: TextStyle(
                              fontSize: 9,
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600)))
                      .toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Header Riwayat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Semua Entri',
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF2979FF),
        foregroundColor: Colors.white,
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => const AddGlucosePage()));
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label:
            const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  List<String> _labelHari(int jumlah) {
    final hari = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    final sekarang = DateTime.now().weekday - 1;
    return List.generate(jumlah, (i) {
      final idx = (sekarang - (jumlah - 1 - i)) % 7;
      return hari[idx < 0 ? idx + 7 : idx];
    });
  }

  Widget _buildItemEntri(Map<String, dynamic> e) {
    final double nilai = (e['glucose_level'] as int).toDouble();
    final warna = _warnaStatus(nilai);
    final status = _statusGlukosa(nilai);
    final waktu = DateTime.parse(e['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: Text(
                  nilai.toStringAsFixed(0),
                  style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold, color: warna),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(e['patient_name'] ?? '-',
                          style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                            color: warna.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8)),
                        child: Text(status,
                            style: TextStyle(
                                fontSize: 10,
                                color: warna,
                                fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_formatWaktuSingkat(waktu),
                      style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ],
              ),
            ),
            Text('${nilai.toStringAsFixed(0)}\nmg/dL',
                textAlign: TextAlign.right,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: warna,
                    height: 1.3)),
          ],
        ),
      ),
    );
  }
}

class _GrafikGarisLive extends StatelessWidget {
  final List<double> data;
  const _GrafikGarisLive({required this.data});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PainterGrafik(data: data),
      child: const SizedBox.expand(),
    );
  }
}

class _PainterGrafik extends CustomPainter {
  final List<double> data;
  _PainterGrafik({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final nilaiMin = 60.0;
    final nilaiMax = 200.0;
    final rentang = nilaiMax - nilaiMin;
    final padTop = 10.0;
    final padBottom = 10.0;
    final tinggi = size.height - padTop - padBottom;

    double toY(double v) => padTop + tinggi * (1 - (v - nilaiMin) / rentang);
    double toX(int i) => i * size.width / (data.length - 1);

    // Garis normal
    final paintRef = Paint()
      ..color = Colors.grey.withValues(alpha: 0.2)
      ..strokeWidth = 1;
    canvas.drawLine(
        Offset(0, toY(140)), Offset(size.width, toY(140)), paintRef);
    canvas.drawLine(Offset(0, toY(70)), Offset(size.width, toY(70)), paintRef);

    // Path kurva
    final path = Path();
    final pathIsi = Path();
    for (int i = 0; i < data.length; i++) {
      final x = toX(i);
      final y = toY(data[i]);
      if (i == 0) {
        path.moveTo(x, y);
        pathIsi.moveTo(x, y);
      } else {
        final px = toX(i - 1);
        final py = toY(data[i - 1]);
        final cpx = (px + x) / 2;
        path.cubicTo(cpx, py, cpx, y, x, y);
        pathIsi.cubicTo(cpx, py, cpx, y, x, y);
      }
    }

    pathIsi.lineTo(toX(data.length - 1), size.height);
    pathIsi.lineTo(0, size.height);
    pathIsi.close();

    canvas.drawPath(
        pathIsi,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF2979FF).withValues(alpha: 0.2),
              const Color(0xFF2979FF).withValues(alpha: 0.01)
            ],
          ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFF2979FF)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Titik terbaru
    final xLast = toX(data.length - 1);
    final yLast = toY(data.last);
    canvas.drawCircle(Offset(xLast, yLast), 6, Paint()..color = Colors.white);
    canvas.drawCircle(
        Offset(xLast, yLast), 4, Paint()..color = const Color(0xFF2979FF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
