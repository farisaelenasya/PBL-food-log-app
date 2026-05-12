import 'package:flutter/material.dart';
import '../models/glucose_store.dart';
import '../models/glucose_entry.dart';
import '../models/medication_store.dart';
import '../models/medication_entry.dart';

// ─── Model Notifikasi ────────────────────────────────────────────────────────

enum TipeNotif { gulaRendah, gulaTinggi, obat, info }

class ItemNotif {
  final String id;
  final TipeNotif tipe;
  final String judul;
  final String isi;
  final DateTime waktu;
  bool sudahDibaca;

  ItemNotif({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.isi,
    required this.waktu,
    this.sudahDibaca = false,
  });
}

// ─── Service: Generate notif dari data gula darah ───────────────────────────

class NotifService {
  static const double batasRendah = 70;  // mg/dL
  static const double batasTinggi = 180; // mg/dL

  static List<ItemNotif> buatNotifGula(List<GlucoseEntry> entri) {
    final List<ItemNotif> hasil = [];

    for (int i = 0; i < entri.length; i++) {
      final e = entri[i];
      if (e.nilai < batasRendah) {
        hasil.add(ItemNotif(
          id: 'gula_rendah_$i',
          tipe: TipeNotif.gulaRendah,
          judul: '⚠️ Gula Darah Terlalu Rendah',
          isi:
              'Kadar gula Anda ${e.nilai.toStringAsFixed(0)} mg/dL saat ${e.konteksMakan}. '
              'Segera konsumsi makanan/minuman manis.',
          waktu: e.waktu,
          sudahDibaca: i > 0, // hanya yg terbaru yg unread
        ));
      } else if (e.nilai > batasTinggi) {
        hasil.add(ItemNotif(
          id: 'gula_tinggi_$i',
          tipe: TipeNotif.gulaTinggi,
          judul: '🔴 Gula Darah Terlalu Tinggi',
          isi:
              'Kadar gula Anda ${e.nilai.toStringAsFixed(0)} mg/dL saat ${e.konteksMakan}. '
              'Batasi asupan karbohidrat dan tetap aktif bergerak.',
          waktu: e.waktu,
          sudahDibaca: i > 0,
        ));
      }
    }
    return hasil;
  }

  static List<ItemNotif> buatNotifObat(List<MedicationEntry> obat) {
    return obat.asMap().entries.map((entry) {
      final o = entry.value;
      return ItemNotif(
        id: 'obat_${entry.key}',
        tipe: TipeNotif.obat,
        judul: '💊 Pengingat Obat',
        isi: 'Waktunya minum ${o.namaObat} — ${o.dosis} (${o.frekuensi}).',
        waktu: o.dibuatPada,
        sudahDibaca: entry.key > 0,
      );
    }).toList();
  }

  static List<ItemNotif> notifInfo() => [
        ItemNotif(
          id: 'tips_1',
          tipe: TipeNotif.info,
          judul: '💡 Tips Hari Ini',
          isi:
              'Jalan kaki 15 menit setelah makan dapat membantu menstabilkan gula darah Anda.',
          waktu: DateTime.now().subtract(const Duration(hours: 1)),
          sudahDibaca: true,
        ),
        ItemNotif(
          id: 'cek_1',
          tipe: TipeNotif.info,
          judul: '🩸 Pengingat Cek Gula',
          isi: 'Sudah waktunya mengecek kadar gula darah Anda hari ini.',
          waktu: DateTime.now().subtract(const Duration(hours: 3)),
          sudahDibaca: true,
        ),
      ];
}

// ─── Page ────────────────────────────────────────────────────────────────────

class NotifikasiPage extends StatefulWidget {
  const NotifikasiPage({super.key});

  @override
  State<NotifikasiPage> createState() => _NotifikasiPageState();
}

class _NotifikasiPageState extends State<NotifikasiPage> {
  final _glucoseStore = GlucoseStore();
  final _medStore = MedicationStore();

  late List<ItemNotif> _semuaNotif;

  @override
  void initState() {
    super.initState();
    _buildNotif();
  }

  void _buildNotif() {
    final gulaNotif = NotifService.buatNotifGula(_glucoseStore.semuaEntri);
    final obatNotif = NotifService.buatNotifObat(_medStore.semuaObat);
    final infoNotif = NotifService.notifInfo();

    _semuaNotif = [...gulaNotif, ...obatNotif, ...infoNotif];
    // Sort terbaru di atas
    _semuaNotif.sort((a, b) => b.waktu.compareTo(a.waktu));
  }

  int get _jumlahBelumDibaca =>
      _semuaNotif.where((n) => !n.sudahDibaca).length;

  void _tandaiSemua() {
    setState(() {
      for (final n in _semuaNotif) {
        n.sudahDibaca = true;
      }
    });
  }

  void _tandaiSatu(String id) {
    setState(() {
      final idx = _semuaNotif.indexWhere((n) => n.id == id);
      if (idx != -1) _semuaNotif[idx].sudahDibaca = true;
    });
  }

  void _hapus(String id) {
    setState(() {
      _semuaNotif.removeWhere((n) => n.id == id);
    });
  }

  String _formatWaktu(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mnt lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin';
    return '${diff.inDays} hari lalu';
  }

  // ── Konfigurasi visual per tipe ──

  _NotifStyle _styleFor(TipeNotif tipe) {
    switch (tipe) {
      case TipeNotif.gulaRendah:
        return _NotifStyle(
          bg: const Color(0xFFFFF3E0),
          iconBg: const Color(0xFFFFE0B2),
          iconColor: const Color(0xFFE65100),
          icon: Icons.warning_amber_rounded,
          badgeColor: const Color(0xFFE65100),
          badgeText: 'RENDAH',
        );
      case TipeNotif.gulaTinggi:
        return _NotifStyle(
          bg: const Color(0xFFFFEBEE),
          iconBg: const Color(0xFFFFCDD2),
          iconColor: const Color(0xFFC62828),
          icon: Icons.trending_up_rounded,
          badgeColor: const Color(0xFFC62828),
          badgeText: 'TINGGI',
        );
      case TipeNotif.obat:
        return _NotifStyle(
          bg: const Color(0xFFE8F5E9),
          iconBg: const Color(0xFFC8E6C9),
          iconColor: const Color(0xFF2E7D32),
          icon: Icons.medication_rounded,
          badgeColor: const Color(0xFF2E7D32),
          badgeText: 'OBAT',
        );
      case TipeNotif.info:
        return _NotifStyle(
          bg: const Color(0xFFE3F2FD),
          iconBg: const Color(0xFFBBDEFB),
          iconColor: const Color(0xFF1565C0),
          icon: Icons.info_outline_rounded,
          badgeColor: const Color(0xFF1565C0),
          badgeText: 'INFO',
        );
    }
  }

  // ── BUILD ──

  @override
  Widget build(BuildContext context) {
    // Pisahkan: hari ini vs lebih lama
    final hariIni = _semuaNotif
        .where((n) => DateTime.now().difference(n.waktu).inHours < 24)
        .toList();
    final lebihLama = _semuaNotif
        .where((n) => DateTime.now().difference(n.waktu).inHours >= 24)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: _buildAppBar(),
      body: _semuaNotif.isEmpty
          ? _buildKosong()
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 12),

                // ── Ringkasan alert gula ──
                _buildRingkasanAlert(),

                const SizedBox(height: 16),

                // ── Hari ini ──
                if (hariIni.isNotEmpty) ...[
                  _buildSectionLabel('Hari ini'),
                  const SizedBox(height: 8),
                  ...hariIni.map((n) => _buildKartu(n)),
                  const SizedBox(height: 16),
                ],

                // ── Lebih lama ──
                if (lebihLama.isNotEmpty) ...[
                  _buildSectionLabel('Sebelumnya'),
                  const SizedBox(height: 8),
                  ...lebihLama.map((n) => _buildKartu(n)),
                ],

                const SizedBox(height: 80),
              ],
            ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF0F2F5),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Notifikasi',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E)),
          ),
          if (_jumlahBelumDibaca > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF2979FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$_jumlahBelumDibaca',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ],
      ),
      centerTitle: true,
      actions: [
        if (_jumlahBelumDibaca > 0)
          TextButton(
            onPressed: _tandaiSemua,
            child: const Text(
              'Baca Semua',
              style: TextStyle(color: Color(0xFF2979FF), fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ── Ringkasan alert gula darah ──

  Widget _buildRingkasanAlert() {
    final gulaNotif = _semuaNotif
        .where((n) =>
            n.tipe == TipeNotif.gulaRendah || n.tipe == TipeNotif.gulaTinggi)
        .toList();

    if (gulaNotif.isEmpty) return const SizedBox.shrink();

    final jumlahRendah =
        gulaNotif.where((n) => n.tipe == TipeNotif.gulaRendah).length;
    final jumlahTinggi =
        gulaNotif.where((n) => n.tipe == TipeNotif.gulaTinggi).length;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF2979FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF2979FF).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔔 Ringkasan Alert Gula Darah',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _chipRingkasan(
                  '${jumlahRendah}x Rendah',
                  Icons.arrow_downward_rounded,
                  const Color(0xFFFFB300),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _chipRingkasan(
                  '${jumlahTinggi}x Tinggi',
                  Icons.arrow_upward_rounded,
                  const Color(0xFFEF5350),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Target normal: 70 – 180 mg/dL',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _chipRingkasan(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12)),
        ],
      ),
    );
  }

  // ── Label section ──

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Color(0xFF9E9E9E),
          letterSpacing: 0.5),
    );
  }

  // ── Kartu notifikasi (swipe to dismiss) ──

  Widget _buildKartu(ItemNotif notif) {
    final style = _styleFor(notif.tipe);

    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(18),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_outline, color: Colors.white, size: 24),
            SizedBox(height: 4),
            Text('Hapus',
                style: TextStyle(color: Colors.white, fontSize: 11)),
          ],
        ),
      ),
      onDismissed: (_) => _hapus(notif.id),
      child: GestureDetector(
        onTap: () => _tandaiSatu(notif.id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: notif.sudahDibaca ? Colors.white : style.bg,
            borderRadius: BorderRadius.circular(18),
            border: notif.sudahDibaca
                ? null
                : Border.all(
                    color: style.iconColor.withValues(alpha: 0.25),
                    width: 1.2),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ikon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: style.iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(style.icon, color: style.iconColor, size: 24),
                ),
                const SizedBox(width: 12),

                // Konten
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris atas: judul + waktu
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notif.judul,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: notif.sudahDibaca
                                    ? FontWeight.w600
                                    : FontWeight.bold,
                                color: const Color(0xFF1A1A2E),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _formatWaktu(notif.waktu),
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Isi
                      Text(
                        notif.isi,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Baris bawah: badge + dot belum dibaca
                      Row(
                        children: [
                          // Badge tipe
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: style.badgeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              style.badgeText,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: style.badgeColor,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),

                          const Spacer(),

                          // Dot unread (seperti WA/IG)
                          if (!notif.sudahDibaca)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: style.iconColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),

                      // Tombol aksi untuk obat
                      if (notif.tipe == TipeNotif.obat) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            _tombolAksi('✓ Sudah Diminum',
                                const Color(0xFF2E7D32),
                                const Color(0xFFC8E6C9)),
                            const SizedBox(width: 8),
                            _tombolAksi(
                                'Tunda', Colors.grey[600]!, Colors.grey[100]!),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tombolAksi(String label, Color warnaTeks, Color warnaBg) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
            color: warnaBg, borderRadius: BorderRadius.circular(20)),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                color: warnaTeks,
                fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _buildKosong() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none_outlined,
              size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Tidak ada notifikasi',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[400])),
          const SizedBox(height: 8),
          Text(
            'Semua dalam batas normal.\nTetap pantau gula darahmu ya! 💪',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: Colors.grey[400], height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── Helper style ────────────────────────────────────────────────────────────

class _NotifStyle {
  final Color bg;
  final Color iconBg;
  final Color iconColor;
  final IconData icon;
  final Color badgeColor;
  final String badgeText;

  const _NotifStyle({
    required this.bg,
    required this.iconBg,
    required this.iconColor,
    required this.icon,
    required this.badgeColor,
    required this.badgeText,
  });
}