import 'package:flutter/material.dart';
import 'admin_add_artikel_page.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/artikel_model.dart';

// ── Model artikel ─────────────────────────────────────────────
class DataArtikel {
  String judul;
  String kategori;
  String tanggal;
  bool diterbitkan;
  String isiSingkat;
  String? linkArtikel;

  DataArtikel({
    required this.judul,
    required this.kategori,
    required this.tanggal,
    required this.diterbitkan,
    required this.isiSingkat,
    this.linkArtikel,
  });
}

class AdminArtikelPage extends StatefulWidget {
  const AdminArtikelPage({super.key});

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  final _cariCtrl = TextEditingController();
  String _filterKategori = 'Semua';

  List<DataArtikel> _artikel = [];
 bool _isLoading = true;

@override
void initState() {
  super.initState();
  _loadArtikel();
}

Future<void> _loadArtikel() async {
  try {
    final data = await ApiService.getArtikel();
   
   for (var e in data) {
  print("JUDUL: ${e.judul}");
  print("LINK: ${e.linkArtikel}");
}
    setState(() {
  _artikel = data.map((e) {
    return DataArtikel(
  judul: e.judul,
  kategori: e.kategori,
  tanggal: DateFormat(
    'dd MMM yyyy',
  ).format(
    DateTime.parse(e.createdAt),
  ),
  diterbitkan: true,
  isiSingkat: e.isi,
  linkArtikel: e.linkArtikel,
);
  }).toList();

  _isLoading = false;
});
  }catch (e) {
    print("ERROR ARTIKEL: $e");

    setState(() {
      _isLoading = false;
    });
  }
}

  final List<String> _kategoriList = [
    'Semua', 'KESEHATAN JANTUNG', 'NUTRISI', 'GAYA HIDUP', 'MEDIS',
  ];

  List<DataArtikel> get _filtered {
    return _artikel.where((a) {
      final cocokKategori =
          _filterKategori == 'Semua' || a.kategori == _filterKategori;
      final cocokCari = _cariCtrl.text.isEmpty ||
          a.judul.toLowerCase().contains(_cariCtrl.text.toLowerCase());
      return cocokKategori && cocokCari;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final totalDiterbitkan = _artikel.where((a) => a.diterbitkan).length;
    final totalArtikel = _artikel.length;

    final totalDraft =_artikel.where((a) => !a.diterbitkan).length;

    final totalKategori =_artikel.map((e) => e.kategori).toSet().length;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ───────────────────────────────────────
            _buildAppBar(),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ── Judul & deskripsi ───────────────────
                    const Text(
                      'Manajemen Artikel',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A2340),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Kelola konten edukasi medis untuk pasien\ndan tenaga kesehatan dalam satu tempat.',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF78909C),
                          height: 1.5),
                    ),
                    const SizedBox(height: 16),

                    // ── Tombol buat artikel ─────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AdminBuatArtikelPage(
                              onSimpan: (artikel) =>
                                  setState(() => _artikel.insert(0, artikel)),
                            ),
                          ),
                        ),
                      icon: const Icon(
                      Icons.add_circle_outline_rounded,size: 20,),
                       label: const Text(
                       'Buat Artikel Baru',
                        style: TextStyle(
                        fontWeight: FontWeight.w700,
                         fontSize: 15,  ),
                       ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1A73E8),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Statistik ───────────────────────────
                  GridView.count(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  crossAxisCount: 2,
  childAspectRatio: 1.6,
  crossAxisSpacing: 12,
  mainAxisSpacing: 12,
  children: [

    _kartuStatArtikel(
      'Total Artikel',
      '$totalArtikel',
      null,
    ),

    _kartuStatArtikel(
      'Publish',
      '$totalDiterbitkan',
      null,
    ),

    _kartuStatArtikel(
      'Draft',
      '$totalDraft',
      null,
    ),

    _kartuStatArtikel(
      'Kategori',
      '$totalKategori',
      null,
    ),
  ],
),
                    const SizedBox(height: 16),

                    // ── Search ──────────────────────────────
                    TextField(
                      controller: _cariCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Cari judul artikel atau kata kunci...',
                        hintStyle: const TextStyle(
                            color: Color(0xFFB0BEC5), fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: Color(0xFFB0BEC5), size: 20),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              BorderSide(color: Colors.grey.shade200),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // ── Tombol Filter ───────────────────────
                    _buildFilterChips(),
                    const SizedBox(height: 16),

                    // ── Daftar artikel ──────────────────────
                    ..._filtered.map((a) => _buildKartuArtikel(a)),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
    Widget _buildAppBar() {
  return Container(
    padding: const EdgeInsets.symmetric(
      horizontal: 20,
      vertical: 16,
    ),
    color: Colors.white,
    child: Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1A73E8),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        const Text(
          'AdminFoodLog',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A2340),
          ),
        ),
      ],
    ),
  );
}
 Widget _kartuStatArtikel( String label, String nilai, String? sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF90A4AE))),
          const SizedBox(height: 4),
          Text(
            nilai,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1A2340),
              height: 1,
            ),
          ),
          if (sub != null) ...[
            const SizedBox(height: 4),
            Text(sub,
                style: const TextStyle(
                    fontSize: 11, color: Color(0xFF26A69A))),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 34,
      child: Row(
        children: [
          const Icon(Icons.filter_list_rounded,
              size: 18, color: Color(0xFF78909C)),
          const SizedBox(width: 8),
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _kategoriList.map((k) {
                final aktif = _filterKategori == k;
                return GestureDetector(
                  onTap: () => setState(() => _filterKategori = k),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: aktif
                          ? const Color(0xFF1A73E8)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: aktif
                            ? const Color(0xFF1A73E8)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      k,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: aktif
                            ? Colors.white
                            : const Color(0xFF78909C),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKartuArtikel(DataArtikel a) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar placeholder
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Icon(
              a.kategori == 'NUTRISI'
              ? Icons.restaurant_menu_rounded
               : a.kategori == 'GAYA HIDUP'
              ? Icons.health_and_safety_rounded
               : a.kategori == 'MEDIS'
              ? Icons.medical_services_rounded
               : Icons.favorite_rounded,
               size: 48,
               color: Colors.white.withOpacity(0.6),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge kategori + tanggal
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: a.diterbitkan
                            ? const Color(0xFFE3F2FD)
                            : const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        a.kategori,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: a.diterbitkan
                              ? const Color(0xFF1A73E8)
                              : const Color(0xFFE65100),
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        a.tanggal,
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF90A4AE)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Judul
                Text(
                  a.judul,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A2340),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),

                // Isi singkat
                Text(
                  a.isiSingkat,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF78909C),
                      height: 1.4),
                ),
                const SizedBox(height: 10),

                // Stats + tombol edit/hapus
                Row(
                  children: [
                   Container(
  padding: const EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 5,
  ),
  decoration: BoxDecoration(
    color: a.diterbitkan
        ? Colors.green.shade50
        : Colors.orange.shade50,
    borderRadius: BorderRadius.circular(8),
  ),
  child: Text(
    a.diterbitkan
        ? 'Dipublikasikan'
        : 'Draft',
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      color: a.diterbitkan
          ? Colors.green
          : Colors.orange,
    ),
  ),
),

const Spacer(),

                    // Tombol Edit
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdminBuatArtikelPage(
                            artikelEdit: a,
                            onSimpan: (updated) => setState(() {
                              final i = _artikel.indexOf(a);
                              if (i != -1) _artikel[i] = updated;
                            }),
                          ),
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.edit_rounded,
                                size: 12, color: Color(0xFF1A73E8)),
                            SizedBox(width: 4),
                            Text('Edit',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1A73E8))),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Tombol Hapus
                    GestureDetector(
                      onTap: () => _konfirmasiHapus(a),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.delete_rounded,
                                size: 12, color: Color(0xFFE53935)),
                            SizedBox(width: 4),
                            Text('Hapus',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFE53935))),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(DataArtikel a) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Artikel?'),
        content: Text('Artikel "${a.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              setState(() => _artikel.remove(a));
              Navigator.pop(context);
            },
            child: const Text('Hapus',
                style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}