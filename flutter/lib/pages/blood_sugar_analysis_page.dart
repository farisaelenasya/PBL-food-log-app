import 'package:flutter/material.dart';
import 'dart:math';
import '../services/api_service.dart';
import 'dashboard_page.dart';
import 'meal_history_page.dart';
import 'health_profile_page.dart';
import 'food_photo_input_page.dart';

class BloodSugarAnalysisPage extends StatefulWidget {
  const BloodSugarAnalysisPage({super.key});

  @override
  State<BloodSugarAnalysisPage> createState() => _BloodSugarAnalysisPageState();
}

class _BloodSugarAnalysisPageState extends State<BloodSugarAnalysisPage> {
  int _tabAktif = 1;
  int _indeksNavbar = 1; 
  final List<String> _daftarTab = ['Hari', 'Minggu', 'Bulan'];

  // Data gula darah per hari (SEN-MIN)
  List<Map<String, dynamic>> _semuaData = [];
bool _isLoading = true;

List<double> get _dataMingguan {
  final now = DateTime.now();
  return List.generate(4, (i) {
    final mingguKe = i + 1;
    final entries = _semuaData.where((r) {
      final tgl = DateTime.parse(r['created_at']).toLocal();
      if (tgl.year != now.year || tgl.month != now.month) return false;
      final hariKe = tgl.day;
      if (mingguKe == 1) return hariKe <= 7;
      if (mingguKe == 2) return hariKe >= 8 && hariKe <= 14;
      if (mingguKe == 3) return hariKe >= 15 && hariKe <= 21;
      return hariKe >= 22;
    }).toList();
    if (entries.isEmpty) return -1.0;
    final total = entries.fold<double>(0, (sum, r) => sum + (r['glucose_level'] as num).toDouble());
    return total / entries.length;
  });
}

// === DATA BULANAN: rata-rata per bulan tahun ini ===
List<double> get _dataBulanan {
  final now = DateTime.now();
  return List.generate(12, (i) {
    final bulan = i + 1;
    final entries = _semuaData.where((r) {
      final tgl = DateTime.parse(r['created_at']);
      return tgl.year == now.year && tgl.month == bulan;
    }).toList();
    if (entries.isEmpty) return -1.0;
    final total = entries.fold<double>(0, (sum, r) => sum + (r['glucose_level'] as num).toDouble());
    return total / entries.length;
  });
}


List<String> get _labelHari {
  if (_tabAktif == 1) return ['Mgu 1', 'Mgu 2', 'Mgu 3', 'Mgu 4'];
  if (_tabAktif == 2) return ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Ags', 'Sep', 'Okt', 'Nov', 'Des'];
  final now = DateTime.now();
 final entries = _semuaData.where((r) {
  final tgl = DateTime.parse(r['created_at']); 
  final tglLokal = tgl.toLocal();
  return tglLokal.year == now.year && tglLokal.month == now.month && tglLokal.day == now.day;
}).toList();
  return entries.map((r) {
  final tgl = DateTime.parse(r['created_at']).toLocal();
  return '${tgl.hour.toString().padLeft(2, '0')}:${tgl.minute.toString().padLeft(2, '0')}';
}).toList();
}

List<double> get _dataHarian {
  final now = DateTime.now();
  final entries = _semuaData.where((r) {
  final tgl = DateTime.parse(r['created_at']); // ← tambah ini
  final tglLokal = tgl.toLocal();
  return tglLokal.year == now.year && tglLokal.month == now.month && tglLokal.day == now.day;
}).toList();
  return entries.map((r) => (r['glucose_level'] as num).toDouble()).toList();
}

List<double> get _dataAktif {
  if (_tabAktif == 0) return _dataHarian;
  if (_tabAktif == 1) return _dataMingguan;
  if (_tabAktif == 2) return _dataBulanan;
  return [];
}

  List<double> get _dataValid => _dataAktif.where((v) => v > 0).toList();
double get _rataRata => _dataValid.isEmpty ? 0 : _dataValid.reduce((a, b) => a + b) / _dataValid.length;
double get _tertinggi => _dataValid.isEmpty ? 0 : _dataValid.reduce(max);
double get _terendah => _dataValid.isEmpty ? 0 : _dataValid.reduce(min);
int get _indeksTertinggi => _dataValid.isEmpty ? 0 : _dataAktif.indexOf(_tertinggi).clamp(0, _dataAktif.length - 1);
int get _indeksTerendah => _dataValid.isEmpty ? 0 : _dataAktif.indexOf(_terendah).clamp(0, _dataAktif.length - 1);// Persentase data dalam rentang normal (70-140 mg/dL)
double get _persenDalamRentang {
  if (_dataValid.isEmpty) return 0;
  final dalamRentang = _dataValid.where((v) => v >= 70 && v <= 180).length;
  return (dalamRentang / _dataValid.length) * 100;
}

// Standar deviasi sebagai ukuran variasi
double get _variasiGlukosa {
  if (_dataValid.length < 2) return 0;
  final mean = _rataRata;
  final variance = _dataValid.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / _dataValid.length;
  return sqrt(variance);
}

String get _statusRataRata {
  if (_rataRata == 0) return 'TIDAK ADA DATA';
  if (_rataRata < 70) return 'RENDAH';
  if (_rataRata <= 140) return 'NORMAL';
  if (_rataRata <= 180) return 'TINGGI';
  return 'SANGAT TINGGI';
}

Color get _warnaStatusRataRata {
  if (_rataRata == 0) return Colors.grey;
  if (_rataRata < 70) return Colors.orange;
  if (_rataRata <= 140) return Colors.green;
  if (_rataRata <= 180) return const Color(0xFFFF8C00);
  return Colors.red;
}

Color get _warnaLatarStatusRataRata {
  if (_rataRata == 0) return Colors.grey.shade100;
  if (_rataRata < 70) return const Color(0xFFFFF3E0);
  if (_rataRata <= 140) return const Color(0xFFE8F5E9);
  if (_rataRata <= 180) return const Color(0xFFFFF8E1);
  return const Color(0xFFFFEBEE);
}

@override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await ApiService.ambilSemuaData();
    setState(() {
      _semuaData = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Analisis Gula Darah',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF1A1A2E)),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
      children: [
      SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildTabPeriode(),
            const SizedBox(height: 16),
            _buildKartuGrafik(),
            const SizedBox(height: 16),
            _buildGridStatistik(),
            const SizedBox(height: 100),
          ],
        ),
      ),

    Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: _buildNavBawah(),
    ),
  ],
),
);
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

  Widget _buildKartuGrafik() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Flexible(
            child: Text(
              _tabAktif == 0 ? 'Rata-rata Hari Ini'
              : _tabAktif == 1 ? 'Rata-rata Minggu Ini'
              : 'Rata-rata Bulan Ini',
            style: TextStyle(fontSize: 13, color: Colors.grey[500], fontWeight: FontWeight.w500),
      ),
    ),

            Container(
               padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
               decoration: BoxDecoration(
               color: _warnaLatarStatusRataRata,
               borderRadius: BorderRadius.circular(8),
            ),
               child: Text(
               _statusRataRata,
               style: TextStyle(
                fontSize: 11,
               color: _warnaStatusRataRata,
               fontWeight: FontWeight.bold,
               letterSpacing: 0.5,
            ),
          ),
         ),
       ],
     ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _rataRata.toStringAsFixed(0),
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(width: 6),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('mg/dL', style: TextStyle(fontSize: 14, color: Colors.grey[400])),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: _isLoading
             ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
             : _dataValid.isEmpty
              ? const Center(child: Text('Belum ada data', style: TextStyle(color: Colors.grey)))
             : _GrafikGaris(
            data: _dataAktif.map((v) => v < 0 ? 0.0 : v).toList(),
            labelHari: _labelHari,
            indeksAktif: (_dataAktif.length - 1).clamp(0, _dataAktif.length - 1),
          ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _labelHari.asMap().entries.map((e) {
            final aktif = e.key == _dataAktif.lastIndexWhere((v) => v > 0);
            return Expanded(
              child: Text(
                  e.value,
                 textAlign: TextAlign.center,
                 style: TextStyle(
            fontSize: _tabAktif == 2 ? 9 : 11,
            fontWeight: aktif ? FontWeight.bold : FontWeight.normal,
            color: aktif ? const Color(0xFF2979FF) : Colors.grey[400],
        ),
      ),
    );
  }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGridStatistik() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      children: [
        _buildKartuStat(
          ikon: Icons.trending_up,
          warnaIkon: const Color(0xFF2979FF),
          label: 'TERTINGGI',
          nilai: _dataValid.isEmpty ? '-' : '${_tertinggi.toInt()} mg/dL',
          subjudul: _labelHari.isEmpty || _indeksTertinggi < 0 || _indeksTertinggi >= _labelHari.length ? '-' : '${_labelHari[_indeksTertinggi].toLowerCase().capitalize()}',
        ),
        _buildKartuStat(
          ikon: Icons.trending_down,
          warnaIkon: const Color(0xFFFF8C00),
          label: 'TERENDAH',
          nilai: _dataValid.isEmpty ? '-' : '${_terendah.toInt()} mg/dL',
          subjudul: _labelHari.isEmpty || _indeksTerendah < 0 || _indeksTerendah >= _labelHari.length ? '-' : '${_labelHari[_indeksTerendah].toLowerCase().capitalize()}',
        ),
        _buildKartuStat(
          ikon: Icons.check_circle,
          warnaIkon: Colors.green,
          label: 'DALAM RENTANG',
          nilai: '${_persenDalamRentang.toStringAsFixed(0)}%',
          subjudul: _persenDalamRentang >= 70 ? 'Stabil' : 'Perlu Perhatian',
          warnaLatar: const Color(0xFFF0FFF4),
        ),
        _buildKartuStat(
          ikon: Icons.history,
          warnaIkon: Colors.teal,
          label: 'VARIASI',
          nilai: '+/- ${_variasiGlukosa.toStringAsFixed(0)}',
          subjudul: _variasiGlukosa < 15 ? 'Rendah' : _variasiGlukosa < 30 ? 'Sedang' : 'Tinggi',
        ),
      ],
    );
  }

  Widget _buildKartuStat({
    required IconData ikon,
    required Color warnaIkon,
    required String label,
    required String nilai,
    required String subjudul,
    Color? warnaLatar,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: warnaLatar ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(ikon, size: 14, color: warnaIkon),
              const SizedBox(width: 5),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.grey[500], letterSpacing: 0.5)),
            ],
          ),
          Text(nilai, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          Text(subjudul, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
        ],
      ),
    );
  }

  Widget _buildNavBawah() {
    final daftarMenu = [
      {'ikon': Icons.home_rounded, 'label': 'Beranda'},
      {'ikon': Icons.bar_chart_rounded, 'label': 'Laporan'},
      {'ikon': null, 'label': 'Tambah'},
      {'ikon': Icons.history_rounded, 'label': 'Riwayat'},
      {'ikon': Icons.person_outline_rounded, 'label': 'Profil'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 20,
              offset: const Offset(0, -4))
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(daftarMenu.length, (i) {
          if (i == 2) {
            return GestureDetector(
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const FoodPhotoInputPage())),
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFF2979FF),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Color(0x442979FF),
                        blurRadius: 12,
                        offset: Offset(0, 4))
                  ],
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            );
          }

          final aktif = _indeksNavbar == i;

          final List<Widget?> halamanTujuan = [
            const DashboardPage(),
            const BloodSugarAnalysisPage(),
            null,
            const MealHistoryPage(),
            const HealthProfilePage()
          ];

          return GestureDetector(
            onTap: () {
              setState(() => _indeksNavbar = i);

              if (halamanTujuan[i] != null) {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => halamanTujuan[i]!));
              }
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(daftarMenu[i]['ikon'] as IconData,
                    color: aktif ? const Color(0xFF2979FF) : Colors.grey[400],
                    size: 24),
                const SizedBox(height: 3),
                Text(daftarMenu[i]['label'] as String,
                    style: TextStyle(
                        fontSize: 10,
                        color:
                            aktif ? const Color(0xFF2979FF) : Colors.grey[400],
                        fontWeight:
                            aktif ? FontWeight.w600 : FontWeight.normal)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// Extension untuk capitalize string
extension StringExtension on String {
  String capitalize() => isEmpty ? this : '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}

// Widget custom grafik garis
class _GrafikGaris extends StatelessWidget {
  final List<double> data;
  final List<String> labelHari;
  final int indeksAktif;

  const _GrafikGaris({required this.data, required this.labelHari, required this.indeksAktif});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GrafisPainter(data: data, indeksAktif: indeksAktif),
      child: const SizedBox.expand(),
    );
  }
}

class _GrafisPainter extends CustomPainter {
  final List<double> data;
  final int indeksAktif;

  _GrafisPainter({required this.data, required this.indeksAktif});

  @override
  void paint(Canvas canvas, Size size) {
    final double nilaiMin = 60;
    final double nilaiMax = max(220, data.where((v) => v > 0).fold(0.0, (a, b) => a > b ? a : b) + 20);
    final double rentang = nilaiMax - nilaiMin;
    final double padTop = 20;
    final double padBottom = 10;
    final double tinggiGrafik = size.height - padTop - padBottom;

    double toY(double val) {
      return padTop + tinggiGrafik * (1 - (val - nilaiMin) / rentang);
    }

    double toX(int i) {
  if (data.length <= 1) return size.width / 2;
  return i * size.width / (data.length - 1);
}
    // Garis referensi
    final paintRef = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Garis Tinggi (180+)
    paintRef.color = Colors.red.withValues(alpha: 0.3);
    canvas.drawLine(Offset(0, toY(160)), Offset(size.width, toY(160)), paintRef);
    // Garis Normal (70-140)
    paintRef.color = Colors.grey.withValues(alpha: 0.25);
    canvas.drawLine(Offset(0, toY(180)), Offset(size.width, toY(180)), paintRef);
    // Garis Rendah
    paintRef.color = Colors.orange.withValues(alpha: 0.3);
    canvas.drawLine(Offset(0, toY(70)), Offset(size.width, toY(70)), paintRef);

    // Label garis referensi
    void drawLabel(String teks, double y, Color warna) {
      final tp = TextPainter(
        text: TextSpan(text: teks, style: TextStyle(fontSize: 9, color: warna)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(size.width - tp.width - 2, y - 10));
    }
    drawLabel('Tinggi (180+)', toY(160), Colors.red.withValues(alpha: 0.5));
    drawLabel('Normal (70-180)', toY(180), Colors.grey.withValues(alpha: 0.5));
    drawLabel('Rendah (70-)', toY(70), Colors.orange.withValues(alpha: 0.5));

    // Buat path kurva halus
    final path = Path();
    final pathIsi = Path();

    bool pathDimulai = false;
    for (int i = 0; i < data.length; i++) {
      if (data[i] <= 0) continue; // skip hari/bulan kosong
      final x = toX(i);
      final y = toY(data[i]);
      if (!pathDimulai) {
        path.moveTo(x, y);
        pathIsi.moveTo(x, y);
        pathDimulai = true;
      } else {
        final prevIdx = data.sublist(0, i).lastIndexWhere((v) => v > 0);
        final prevX = toX(prevIdx);
        final prevY = toY(data[prevIdx]);
        final cp1x = prevX + (x - prevX) / 2;
        final cp2x = prevX + (x - prevX) / 2;
        path.cubicTo(cp1x, prevY, cp2x, y, x, y);
        pathIsi.cubicTo(cp1x, prevY, cp2x, y, x, y);
      }
    }

    if (!pathDimulai) return; // tidak ada data sama sekali

    // Isi gradien di bawah kurva
    final lastValidIdx = data.lastIndexWhere((v) => v > 0);
    final firstValidIdx = data.indexWhere((v) => v > 0);
    if (lastValidIdx >= 0) {
      pathIsi.lineTo(toX(lastValidIdx), size.height);
      pathIsi.lineTo(toX(firstValidIdx), size.height);
      pathIsi.close();
    }

    final gradienIsi = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [const Color(0xFF2979FF).withValues(alpha: 0.18), const Color(0xFF2979FF).withValues(alpha: 0.02)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(pathIsi, gradienIsi);

    // Garis kurva biru
    final paintGaris = Paint()
      ..color = const Color(0xFF2979FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(path, paintGaris);

    // Titik aktif (KAM)
    if (indeksAktif >= 0 && indeksAktif < data.length && data[indeksAktif] > 0) {
      final xAktif = toX(indeksAktif);
      final yAktif = toY(data[indeksAktif]);
      final paintTitikLuar = Paint()..color = Colors.white;
      final paintTitikDalam = Paint()..color = const Color(0xFF2979FF);
      canvas.drawCircle(Offset(xAktif, yAktif), 7, paintTitikLuar);
      canvas.drawCircle(Offset(xAktif, yAktif), 4.5, paintTitikDalam);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}