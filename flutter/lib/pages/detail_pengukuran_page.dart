import 'package:flutter/material.dart';

class DetailPengukuranPage extends StatefulWidget {
  final Map<String, dynamic> data;
  const DetailPengukuranPage({super.key, required this.data});

  @override
  State<DetailPengukuranPage> createState() => _DetailPengukuranPageState();
}

enum KondisiGula { rendah, normal, tinggi, sangatTinggi }

class _DetailPengukuranPageState extends State<DetailPengukuranPage> {
  int _indeksTips = 0;
  final PageController _tipsController = PageController();

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

  String _namaHari(int weekday) {
    const hari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    return hari[weekday - 1];
  }

  String _namaBulan(int bulan) {
    const daftar = ['', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return daftar[bulan];
  }

  KondisiGula _kondisiGula(double nilai) {
    if (nilai < 70) return KondisiGula.rendah;
    if (nilai <= 140) return KondisiGula.normal;
    if (nilai <= 180) return KondisiGula.tinggi;
    return KondisiGula.sangatTinggi;
  }

  List<Map<String, dynamic>> _daftarTips(double nilai, KondisiGula kondisi) {
    switch (kondisi) {
      case KondisiGula.rendah:
        return [
          {
            'kategori': '⚠️ Gula Darah Rendah',
            'ikon': Icons.warning_amber_rounded,
            'warna': [const Color(0xFFF57F17), const Color(0xFFFFA000)],
            'isi': 'Gula darah Anda rendah (${nilai.toStringAsFixed(0)} mg/dL). Segera konsumsi makanan/minuman manis dan istirahat.',
          },
          {
            'kategori': '🍽️ Makanan yang Dianjurkan',
            'ikon': Icons.restaurant_menu,
            'warna': [const Color(0xFF43A047), const Color(0xFF66BB6A)],
            'isi': null,
            'daftarMakanan': [
              {'nama': 'Jus buah murni / madu', 'alasan': 'Naikkan gula darah dengan cepat'},
              {'nama': 'Pisang atau kurma', 'alasan': 'Gula alami yang mudah diserap'},
              {'nama': 'Roti gandum dengan selai', 'alasan': 'Energi cepat + tahan lama'},
              {'nama': 'Susu full cream', 'alasan': 'Karbohidrat + protein seimbang'},
              {'nama': 'Biskuit asin', 'alasan': 'Karbohidrat simpel untuk darurat'},
            ],
            'mode': 'anjuran',
          },
          {
            'kategori': '🏃 Olahraga Hari Ini',
            'ikon': Icons.self_improvement,
            'warna': [const Color(0xFF7B1FA2), const Color(0xFFAB47BC)],
            'isi': null,
            'daftarOlahraga': [
              {'nama': 'Hindari olahraga berat', 'durasi': 'Sementara waktu', 'ikon': Icons.block},
              {'nama': 'Stretching ringan', 'durasi': '5–10 menit', 'ikon': Icons.accessibility_new},
              {'nama': 'Istirahat cukup', 'durasi': 'Prioritas utama', 'ikon': Icons.hotel},
              {'nama': 'Jalan santai', 'durasi': 'Setelah makan', 'ikon': Icons.directions_walk},
            ],
          },
        ];

      case KondisiGula.normal:
        return [
          {
            'kategori': '✅ Gula Darah Normal',
            'ikon': Icons.check_circle_outline,
            'warna': [const Color(0xFF2979FF), const Color(0xFF448AFF)],
            'isi': 'Gula darah Anda normal (${nilai.toStringAsFixed(0)} mg/dL). Pertahankan pola makan dan gaya hidup sehat Anda!',
          },
          {
            'kategori': '🚫 Makanan yang Dihindari',
            'ikon': Icons.no_food_outlined,
            'warna': [const Color(0xFFE53935), const Color(0xFFEF5350)],
            'isi': null,
            'daftarMakanan': [
              {'nama': 'Minuman bersoda & jus kemasan', 'alasan': 'Tinggi gula tambahan'},
              {'nama': 'Kue manis & permen', 'alasan': 'Gula sederhana berlebih'},
              {'nama': 'Gorengan berminyak', 'alasan': 'Meningkatkan resistensi insulin'},
              {'nama': 'Nasi putih porsi besar', 'alasan': 'Indeks glikemik tinggi'},
              {'nama': 'Makanan olahan/cepat saji', 'alasan': 'Tinggi gula & sodium tersembunyi'},
            ],
          },
          {
            'kategori': '🏃 Rekomendasi Olahraga',
            'ikon': Icons.directions_run_rounded,
            'warna': [const Color(0xFF00897B), const Color(0xFF26A69A)],
            'isi': null,
            'daftarOlahraga': [
              {'nama': 'Jalan kaki', 'durasi': '30 menit/hari', 'ikon': Icons.directions_walk},
              {'nama': 'Senam ringan', 'durasi': '20 menit pagi', 'ikon': Icons.self_improvement},
              {'nama': 'Bersepeda santai', 'durasi': '30 menit, 3×/minggu', 'ikon': Icons.pedal_bike_outlined},
              {'nama': 'Renang', 'durasi': '30 menit, 2×/minggu', 'ikon': Icons.pool_outlined},
              {'nama': 'Yoga & stretching', 'durasi': '15–20 menit/hari', 'ikon': Icons.accessibility_new},
            ],
          },
        ];

      case KondisiGula.tinggi:
        return [
          {
            'kategori': '⚠️ Gula Darah Tinggi',
            'ikon': Icons.trending_up_rounded,
            'warna': [const Color(0xFFF4511E), const Color(0xFFFF7043)],
            'isi': 'Gula darah Anda tinggi (${nilai.toStringAsFixed(0)} mg/dL). Kurangi karbohidrat hari ini dan perbanyak gerak.',
          },
          {
            'kategori': '🚫 Hindari Sekarang',
            'ikon': Icons.no_food_outlined,
            'warna': [const Color(0xFFE53935), const Color(0xFFEF5350)],
            'isi': null,
            'daftarMakanan': [
              {'nama': 'Nasi, roti, mie putih', 'alasan': 'Langsung naikkan gula darah'},
              {'nama': 'Minuman manis & boba', 'alasan': 'Gula cair terserap sangat cepat'},
              {'nama': 'Buah manis (mangga, durian)', 'alasan': 'Fruktosa tinggi'},
              {'nama': 'Gorengan & fast food', 'alasan': 'Lemak trans memperparah kondisi'},
              {'nama': 'Kecap & saus manis', 'alasan': 'Gula tersembunyi tinggi'},
            ],
          },
          {
            'kategori': '🏃 Olahraga Turunkan Gula',
            'ikon': Icons.directions_run_rounded,
            'warna': [const Color(0xFF00897B), const Color(0xFF26A69A)],
            'isi': null,
            'daftarOlahraga': [
              {'nama': 'Jalan kaki cepat', 'durasi': '30–45 menit', 'ikon': Icons.directions_walk},
              {'nama': 'Senam aerobik', 'durasi': '30 menit', 'ikon': Icons.self_improvement},
              {'nama': 'Bersepeda', 'durasi': '30 menit', 'ikon': Icons.pedal_bike_outlined},
              {'nama': 'Naik turun tangga', 'durasi': '10–15 menit', 'ikon': Icons.stairs},
              {'nama': 'Yoga aktif', 'durasi': '20 menit', 'ikon': Icons.accessibility_new},
            ],
          },
        ];

      case KondisiGula.sangatTinggi:
        return [
          {
            'kategori': '🚨 Gula Darah Sangat Tinggi',
            'ikon': Icons.emergency_rounded,
            'warna': [const Color(0xFFB71C1C), const Color(0xFFD32F2F)],
            'isi': 'Gula darah Anda ${nilai.toStringAsFixed(0)} mg/dL — sangat tinggi! Segera konsultasikan ke dokter dan minum air putih yang banyak.',
          },
          {
            'kategori': '🚫 HINDARI Semua Ini',
            'ikon': Icons.no_food_outlined,
            'warna': [const Color(0xFFE53935), const Color(0xFFEF5350)],
            'isi': null,
            'daftarMakanan': [
              {'nama': 'Semua makanan manis', 'alasan': 'Berbahaya untuk kondisi ini'},
              {'nama': 'Karbohidrat sederhana', 'alasan': 'Nasi, roti, mie — batasi ketat'},
              {'nama': 'Minuman bergula', 'alasan': 'Termasuk jus & susu kental manis'},
              {'nama': 'Alkohol', 'alasan': 'Sangat berbahaya saat gula tinggi'},
              {'nama': 'Makanan tinggi garam', 'alasan': 'Memperburuk tekanan darah'},
            ],
          },
          {
            'kategori': '🏃 Olahraga Ringan Saja',
            'ikon': Icons.directions_walk,
            'warna': [const Color(0xFF7B1FA2), const Color(0xFFAB47BC)],
            'isi': null,
            'daftarOlahraga': [
              {'nama': 'Jalan kaki santai', 'durasi': '15–20 menit', 'ikon': Icons.directions_walk},
              {'nama': 'Stretching pelan', 'durasi': '10 menit', 'ikon': Icons.accessibility_new},
              {'nama': 'Hindari olahraga berat', 'durasi': 'Berbahaya saat ini', 'ikon': Icons.block},
              {'nama': 'Perbanyak minum air', 'durasi': '8+ gelas/hari', 'ikon': Icons.water_drop_outlined},
            ],
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final double nilai = (data['glucose_level'] as num).toDouble();
    final waktu = DateTime.parse(data['created_at']);
    final warna = _warnaStatus(nilai);
    final status = _statusGlukosa(nilai);
    final konteksMakan = data['konteks_makan'];
    final catatan = data['catatan'];
    final kondisi = _kondisiGula(nilai);
    final tips = _daftarTips(nilai, kondisi);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Detail Pengukuran',
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu Kadar Gula Darah
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Text('Kadar Gula Darah',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500])),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(nilai.toStringAsFixed(0),
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E))),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text('mg/dL',
                          style: TextStyle(fontSize: 14, color: Colors.grey[400])),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: warna.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        nilai <= 99 ? Icons.check_circle : Icons.warning_amber_rounded,
                        size: 14,
                        color: warna,
                      ),
                      const SizedBox(width: 4),
                      Text(status,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: warna)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Kartu Tanggal & Waktu
          Row(
            children: [
              Expanded(child: _buildKartuInfo(
                icon: Icons.calendar_today_outlined,
                label: 'Tanggal',
                value: '${_namaHari(waktu.weekday)}, ${waktu.day} ${_namaBulan(waktu.month)} ${waktu.year}',
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildKartuInfo(
                icon: Icons.access_time,
                label: 'Waktu',
                value: '${waktu.hour.toString().padLeft(2, '0')}:${waktu.minute.toString().padLeft(2, '0')}',
              )),
            ],
          ),
          const SizedBox(height: 12),

          // Kartu Kategori (konteks makan)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE3F2FD),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.restaurant, color: Color(0xFF2979FF), size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kategori', style: TextStyle(fontSize: 11, color: Colors.grey[500])),
                    const SizedBox(height: 2),
                    Text(
                      (konteksMakan != null && konteksMakan.toString().isNotEmpty)
                          ? konteksMakan.toString()
                          : 'Tidak ada kategori',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ===== Panduan Hari Ini (gaya Dashboard) =====
          Text('Panduan Hari Ini',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
          const SizedBox(height: 10),

          // Tab pill horizontal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(tips.length, (i) {
                final aktif = _indeksTips == i;
                final warnaTab = (tips[i]['warna'] as List<Color>)[0];
                return GestureDetector(
                  onTap: () {
                    setState(() => _indeksTips = i);
                    _tipsController.animateToPage(i,
                        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: aktif ? warnaTab : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      tips[i]['kategori'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: aktif ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 12),

          // Kartu konten (carousel gaya Dashboard)
          SizedBox(
            height: _indeksTips == 0 ? 110 : 220,
            child: PageView.builder(
              controller: _tipsController,
              itemCount: tips.length,
              onPageChanged: (i) => setState(() => _indeksTips = i),
              itemBuilder: (context, i) {
                final tip = tips[i];
                final gradienWarna = tip['warna'] as List<Color>;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: gradienWarna,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: i == 0
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(12)),
                              child: Icon(tip['ikon'] as IconData, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(tip['kategori'] as String,
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 3),
                                  Text(tip['isi'] as String,
                                      style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.4)),
                                ],
                              ),
                            ),
                          ],
                        )
                      : (tip['daftarMakanan'] != null)
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: Icon(
                                        (tip['mode'] == 'anjuran') ? Icons.restaurant_menu : Icons.no_food_outlined,
                                        color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                      (tip['mode'] == 'anjuran') ? 'Makanan yang Dianjurkan' : 'Makanan yang Perlu Dihindari',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ]),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: (tip['daftarMakanan'] as List).length,
                                    itemBuilder: (_, j) {
                                      final item = (tip['daftarMakanan'] as List)[j] as Map<String, String>;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 18,
                                              height: 18,
                                              decoration: BoxDecoration(
                                                  color: Colors.white.withValues(alpha: 0.25),
                                                  shape: BoxShape.circle),
                                              child: Icon(
                                                  (tip['mode'] == 'anjuran') ? Icons.check : Icons.close,
                                                  color: Colors.white, size: 11),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: RichText(
                                                  text: TextSpan(children: [
                                                TextSpan(
                                                    text: item['nama']! + '  ',
                                                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                                TextSpan(
                                                    text: item['alasan'],
                                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.78), fontSize: 10.5)),
                                              ])),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(10)),
                                    child: const Icon(Icons.directions_run_rounded, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Rekomendasi Olahraga',
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                ]),
                                const SizedBox(height: 10),
                                Expanded(
                                  child: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: (tip['daftarOlahraga'] as List).length,
                                    itemBuilder: (_, j) {
                                      final item = (tip['daftarOlahraga'] as List)[j] as Map<String, dynamic>;
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 6),
                                        child: Row(
                                          children: [
                                            Icon(item['ikon'] as IconData,
                                                color: Colors.white.withValues(alpha: 0.9), size: 16),
                                            const SizedBox(width: 8),
                                            Text(item['nama'] as String,
                                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.2),
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              child: Text(item['durasi'] as String,
                                                  style: const TextStyle(color: Colors.white, fontSize: 10)),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // Dot indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              tips.length,
              (i) => AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: _indeksTips == i ? 20 : 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: _indeksTips == i ? (tips[i]['warna'] as List<Color>)[0] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Catatan
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: const [
                  Icon(Icons.note_outlined, size: 20),
                  SizedBox(width: 8),
                  Text('Catatan', style: TextStyle(fontWeight: FontWeight.bold)),
                ]),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    (catatan != null && catatan.toString().isNotEmpty)
                        ? '"${catatan.toString()}"'
                        : 'Belum ada catatan untuk pengukuran ini.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuInfo({required IconData icon, required String label, required String value}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Icon(icon, color: Colors.grey[400]),
          const SizedBox(height: 6),
          Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}