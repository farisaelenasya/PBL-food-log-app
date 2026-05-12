import 'package:flutter/material.dart';
import '../models/glucose_store.dart';
import '../models/glucose_entry.dart';
import 'add_glucose_page.dart';

class GlucoseHistoryPage extends StatefulWidget {
  const GlucoseHistoryPage({super.key});

  @override
  State<GlucoseHistoryPage> createState() => _GlucoseHistoryPageState();
}

class _GlucoseHistoryPageState extends State<GlucoseHistoryPage> {
  final store = GlucoseStore();

  String _statusGlukosa(double nilai) {
    if (nilai < 70) return 'Rendah';
    if (nilai <= 140) return 'Normal';
    if (nilai <= 180) return 'Tinggi';
    return 'Sangat Tinggi';
  }

  Color _warnaStatus(double nilai) {
    if (nilai < 70) return Colors.orange;
    if (nilai <= 140) return Colors.green;
    if (nilai <= 180) return const Color(0xFFFF8C00);
    return Colors.red;
  }

  String _formatWaktuSingkat(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inHours < 24) return 'Hari ini, ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    if (diff.inDays == 1) return 'Kemarin, ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final entri = store.semuaEntri;
    final data7 = store.data7Hari;
    final rata = store.rataRata;

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
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF2979FF), size: 26),
            onPressed: () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGlucosePage()));
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          const SizedBox(height: 8),

          // Kartu Ringkasan
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.blue.withValues(alpha: 0.07), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Rata-rata Minggu Ini', style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                      child: Text(
                        _statusGlukosa(rata),
                        style: TextStyle(fontSize: 11, color: _warnaStatus(rata), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(rata.toStringAsFixed(0),
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('mg/dL', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
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
                  children: _labelHari(data7.length).map((h) =>
                    Text(h, style: TextStyle(fontSize: 9, color: Colors.grey[400], fontWeight: FontWeight.w600))
                  ).toList(),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Header Riwayat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Semua Entri', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
              Text('${entri.length} catatan', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddGlucosePage()));
          setState(() {});
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah', style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildItemEntri(GlucoseEntry e) {
    final warna = _warnaStatus(e.nilai);
    final status = _statusGlukosa(e.nilai);
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
              width: 50, height: 50,
              decoration: BoxDecoration(color: warna.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Center(
                child: Text(
                  e.nilai.toStringAsFixed(0),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: warna),
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
                      Text(e.konteksMakan,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: warna.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                        child: Text(status, style: TextStyle(fontSize: 10, color: warna, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(_formatWaktuSingkat(e.waktu),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                  if (e.catatan.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(e.catatan, style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
            Text('${e.nilai.toStringAsFixed(0)}\nmg/dL',
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: warna, height: 1.3)),
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
    final paintRef = Paint()..color = Colors.grey.withValues(alpha: 0.2)..strokeWidth = 1;
    canvas.drawLine(Offset(0, toY(140)), Offset(size.width, toY(140)), paintRef);
    canvas.drawLine(Offset(0, toY(70)), Offset(size.width, toY(70)), paintRef);

    // Path kurva
    final path = Path();
    final pathIsi = Path();
    for (int i = 0; i < data.length; i++) {
      final x = toX(i); final y = toY(data[i]);
      if (i == 0) { path.moveTo(x, y); pathIsi.moveTo(x, y); }
      else {
        final px = toX(i - 1); final py = toY(data[i - 1]);
        final cpx = (px + x) / 2;
        path.cubicTo(cpx, py, cpx, y, x, y);
        pathIsi.cubicTo(cpx, py, cpx, y, x, y);
      }
    }

    pathIsi.lineTo(toX(data.length - 1), size.height);
    pathIsi.lineTo(0, size.height);
    pathIsi.close();

    canvas.drawPath(pathIsi, Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [const Color(0xFF2979FF).withValues(alpha: 0.2), const Color(0xFF2979FF).withValues(alpha: 0.01)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    canvas.drawPath(path, Paint()
      ..color = const Color(0xFF2979FF)..strokeWidth = 2.5
      ..style = PaintingStyle.stroke..strokeCap = StrokeCap.round);

    // Titik terbaru
    final xLast = toX(data.length - 1);
    final yLast = toY(data.last);
    canvas.drawCircle(Offset(xLast, yLast), 6, Paint()..color = Colors.white);
    canvas.drawCircle(Offset(xLast, yLast), 4, Paint()..color = const Color(0xFF2979FF));
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}