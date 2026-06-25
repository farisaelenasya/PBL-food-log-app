import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import 'package:intl/date_symbol_data_local.dart';

class MealHistoryPage extends StatefulWidget {
  const MealHistoryPage({super.key});

  @override
  State<MealHistoryPage> createState() => _MealHistoryPageState();
}

class _MealHistoryPageState extends State<MealHistoryPage> {
  List<Map<String, dynamic>> _riwayat = [];
  bool _isLoading = true;
  int _selectedTab = 0;
  double _totalKalori = 0;
  double _totalKarbo = 0;
  double _totalGula = 0;

  bool _peringatanSudahMuncul = false;
  String _tanggalPeringatan = '';

  static const double _batasGulaHarian = 25.0;

  @override
  void initState() {
    super.initState();
    _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (_tanggalPeringatan != today) {
      _tanggalPeringatan = today;
      _peringatanSudahMuncul = false;
    }

    setState(() => _isLoading = true);

    try {
      final rawList = await ApiService.getFoodLogs();
      final List<Map<String, dynamic>> fixedList =
          List<Map<String, dynamic>>.from(rawList);

      double totalKal = 0;
      double totalKarbo = 0;
      double totalGula = 0;

      for (final r in fixedList) {
        final kalori = double.tryParse((r['kalori'] ?? 0).toString()) ?? 0;
        final karbo  = double.tryParse((r['karbo'] ?? 0).toString()) ?? 0;
        final gula   = double.tryParse((r['gula'] ?? 0).toString()) ?? 0;
        final tanggal = r['dicatat_pada']?.toString().substring(0, 10) ?? '';

        if (tanggal == today) {
          totalKal   += kalori;
          totalKarbo += karbo;
          totalGula  += gula;
        }
      }

      setState(() {
        _riwayat      = fixedList;
        _totalKalori  = totalKal;
        _totalKarbo   = totalKarbo;
        _totalGula    = totalGula;
        _isLoading    = false;
      });

      if (totalGula > _batasGulaHarian && !_peringatanSudahMuncul) {
        _peringatanSudahMuncul = true;
        Future.delayed(Duration.zero, () {
          _showPeringatanGula(totalGula);
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat riwayat: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPeringatanGula(double totalGula) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Text('⚠️', style: TextStyle(fontSize: 24)),
            SizedBox(width: 8),
            Text('Peringatan Gula',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE53935))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total gula hari ini ${totalGula.toStringAsFixed(1)}g melebihi batas harian untuk penderita diabetes.',
              style: const TextStyle(fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Batas gula harian (Kemenkes/WHO):',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFE65100))),
                  const SizedBox(height: 6),
                  _barisInfo('Penderita diabetes', '≤ 25g/hari',
                      const Color(0xFFE53935)),
                  _barisInfo('Orang normal', '≤ 50g/hari', Colors.orange),
                  const SizedBox(height: 6),
                  Text(
                    'Total kamu hari ini: ${totalGula.toStringAsFixed(1)}g',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE53935)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tips: Kurangi makanan manis, minuman bergula, dan buah tinggi gula untuk sisa hari ini.',
              style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Mengerti',
                style: TextStyle(
                    color: Color(0xFF2979FF), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _barisInfo(String label, String nilai, Color warna) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Text('• $label: ',
              style: TextStyle(fontSize: 11, color: Colors.grey[700])),
          Text(nilai,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.bold, color: warna)),
        ],
      ),
    );
  }

  String _formatWaktu(String? dicatatPada, String? waktuMakan) {
    if (dicatatPada == null) return waktuMakan ?? '-';
    try {
      final dt        = DateTime.parse(dicatatPada);
      final now       = DateTime.now();
      final today     = DateFormat('yyyy-MM-dd').format(now);
      final yesterday = DateFormat('yyyy-MM-dd')
          .format(now.subtract(const Duration(days: 1)));
      final logDate   = DateFormat('yyyy-MM-dd').format(dt);
      final jam       = DateFormat('HH:mm').format(dt);
      String hari;
      if (logDate == today) hari = 'Hari ini';
      else if (logDate == yesterday) hari = 'Kemarin';
      else hari = DateFormat('EEEE', 'id_ID').format(dt);
      return '$hari, $jam • ${waktuMakan ?? ''}';
    } catch (_) {
      return waktuMakan ?? '-';
    }
  }

  List<Map<String, dynamic>> get _filteredRiwayat {
    final now = DateTime.now();
    if (_selectedTab == 0) {
      return _riwayat.where((item) {
        final tanggal = DateTime.tryParse(item['dicatat_pada']?.toString() ?? '');
        if (tanggal == null) return false;
        return tanggal.year == now.year &&
            tanggal.month == now.month &&
            tanggal.day == now.day;
      }).toList();
    }
    if (_selectedTab == 1) {
      final mingguLalu = now.subtract(const Duration(days: 7));
      return _riwayat.where((item) {
        final tanggal = DateTime.tryParse(item['dicatat_pada']?.toString() ?? '');
        if (tanggal == null) return false;
        return tanggal.isAfter(mingguLalu);
      }).toList();
    }
    return _riwayat.where((item) {
      final tanggal = DateTime.tryParse(item['dicatat_pada']?.toString() ?? '');
      if (tanggal == null) return false;
      return tanggal.month == now.month && tanggal.year == now.year;
    }).toList();
  }

  Map<String, List<Map<String, dynamic>>> get _groupedRiwayat {
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (final item in _filteredRiwayat) {
      final dicatatPada = item['dicatat_pada']?.toString() ?? '';
      final tanggal = dicatatPada.length >= 10
          ? dicatatPada.substring(0, 10)
          : 'Tidak diketahui';
      grouped.putIfAbsent(tanggal, () => []);
      grouped[tanggal]!.add(item);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final entriHariIni = _riwayat.where((r) {
      final tanggal = r['dicatat_pada']?.toString() ?? '';
      if (tanggal.length < 10) return false;
      return tanggal.substring(0, 10) == today;
    }).length;

    final persenGula = (_totalGula / _batasGulaHarian).clamp(0.0, 1.0);
    final gulaLewat  = _totalGula > _batasGulaHarian;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Riwayat Makan',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
        centerTitle: true,
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF2979FF)),
              onPressed: _loadRiwayat),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2979FF)))
          : _riwayat.isEmpty
              ? _buildKosong()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2979FF), Color(0xFF448AFF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildRingkasan(
                                _totalKalori.toStringAsFixed(0), 'Total Kalori'),
                            _buildPemisah(),
                            _buildRingkasan(
                                '${_totalKarbo.toStringAsFixed(0)}g', 'Total Karbo'),
                            _buildPemisah(),
                            _buildRingkasan('$entriHariIni', 'Entri Hari Ini'),
                          ],
                        ),
                      ),
                    ),

                    // Indikator Gula Harian
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 8)
                          ],
                        ),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('🍬', style: TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                const Text('Total Gula Hari Ini',
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1A1A2E))),
                                const Spacer(),
                                Text(
                                  '${_totalGula.toStringAsFixed(1)}g / ${_batasGulaHarian.toStringAsFixed(0)}g',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: gulaLewat
                                        ? const Color(0xFFE53935)
                                        : const Color(0xFF43A047),
                                  ),
                                ),
                                if (gulaLewat) ...[
                                  const SizedBox(width: 6),
                                  GestureDetector(
                                    onTap: () => _showPeringatanGula(_totalGula),
                                    child: const Text('⚠️',
                                        style: TextStyle(fontSize: 16)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: persenGula,
                                minHeight: 10,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  gulaLewat
                                      ? const Color(0xFFE53935)
                                      : const Color(0xFF43A047),
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              gulaLewat
                                  ? '⚠ Batas gula harian terlampaui! Kurangi makanan manis.'
                                  : 'Batas gula harian: ${_batasGulaHarian.toStringAsFixed(0)}g (standar Kemenkes untuk diabetes)',
                              style: TextStyle(
                                fontSize: 11,
                                color: gulaLewat
                                    ? const Color(0xFFE53935)
                                    : Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 2),
                      child: Row(
                        children: [
                          Text('SEMUA RIWAYAT',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.grey[500],
                                  letterSpacing: 1)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    _buildTabFilter(),
                    const SizedBox(height: 10),

                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadRiwayat,
                        child: ListView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          children: _groupedRiwayat.entries.map((entry) {
                            final tanggal = entry.key;
                            final makanan = entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              child: ExpansionTile(
                                title: Text(
                                  '$tanggal (${makanan.length} makanan)',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                children: makanan
                                    .map((item) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: _buildItemRiwayat(
                                              context, item),
                                        ))
                                    .toList(),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildTabFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tabItem('Hari', 0),
          _tabItem('Minggu', 1),
          _tabItem('Bulan', 2),
        ],
      ),
    );
  }

  Widget _tabItem(String title, int index) {
    final aktif = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: aktif ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: aktif ? const Color(0xFF2979FF) : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_food_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Belum ada riwayat makan',
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text('Tambahkan makanan pertamamu!',
              style: TextStyle(fontSize: 13, color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildRingkasan(String nilai, String label) {
    return Column(
      children: [
        Text(nilai,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 2),
        Text(label,
            style:
                TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.8))),
      ],
    );
  }

  Widget _buildPemisah() =>
      Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3));

  Widget _buildItemRiwayat(BuildContext context, Map<String, dynamic> item) {
    final double karbo  = double.tryParse(item['karbo']?.toString() ?? '0') ?? 0;
    final double kalori = double.tryParse(item['kalori']?.toString() ?? '0') ?? 0;
    final double gula   = double.tryParse(item['gula']?.toString() ?? '0') ?? 0;

    final bool gulaTinggi = gula > 10;

    final String nama = (item['nama_makanan'] ??
            item['nama'] ??
            item['name'] ??
            'Makanan')
        .toString();
    final String emoji    = item['emoji']?.toString() ?? '🍽';
    final String waktuStr = _formatWaktu(
      item['dicatat_pada']?.toString(),
      item['waktu_makan']?.toString(),
    );
    final Color warna = _warnaWaktu(item['waktu_makan']?.toString());

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                  color: warna.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12)),
              child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(nama,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E))),
                      ),
                      if (gulaTinggi)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE8E8),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('🍬 Gula Tinggi',
                              style: TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFFE53935),
                                  fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(waktuStr,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      _chipNutrisi('${kalori.toStringAsFixed(0)} kkal',
                          const Color(0xFF2979FF)),
                      _chipNutrisi('${karbo.toStringAsFixed(0)}g karbo',
                          Colors.green),
                      if (gula > 0)
                        _chipNutrisi('${gula.toStringAsFixed(1)}g gula',
                            gulaTinggi
                                ? const Color(0xFFE53935)
                                : Colors.orange),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _warnaWaktu(String? waktu) {
    switch (waktu) {
      case 'Sarapan': return const Color(0xFFFF8C00);
      case 'Siang':   return const Color(0xFF2979FF);
      case 'Malam':   return Colors.indigo;
      case 'Cemilan': return Colors.green;
      default:        return const Color(0xFF2979FF);
    }
  }

  Widget _chipNutrisi(String teks, Color warna) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: warna.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(teks,
          style: TextStyle(
              fontSize: 10, color: warna, fontWeight: FontWeight.w600)),
    );
  }
}