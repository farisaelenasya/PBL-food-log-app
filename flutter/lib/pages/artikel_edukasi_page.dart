import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/artikel_model.dart';
import '../services/api_service.dart';

class ArtikelEdukasiPage extends StatefulWidget {
  const ArtikelEdukasiPage({super.key});

  @override
  State<ArtikelEdukasiPage> createState() => _ArtikelEdukasiPageState();
}

class _ArtikelEdukasiPageState extends State<ArtikelEdukasiPage> {
  List<ArtikelModel> artikelList = [];
  bool isLoading = true;

  final List<String> _kategoriList = [
    'SEMUA',
    'KESEHATAN JANTUNG',
    'NUTRISI',
    'GAYA HIDUP',
    'MEDIS',
    'MENTAL HEALTH',
  ];

  String selectedKategori = 'SEMUA';
  String search = "";

  @override
  void initState() {
    super.initState();
    loadArtikel();
  }

  Future<void> loadArtikel() async {
    try {
      final data = await ApiService.getArtikel();
      setState(() {
        artikelList = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  List<ArtikelModel> get filtered {
    return artikelList.where((a) {
      final matchKategori = selectedKategori == 'SEMUA'
          ? true
          : a.kategori.toUpperCase() ==
              selectedKategori.toUpperCase();

      final matchSearch =
          a.judul.toLowerCase().contains(search.toLowerCase());

      return matchKategori && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FC),

      // ================= APP BAR =================
      appBar: AppBar(
        elevation: 0,
        toolbarHeight: 85,
        centerTitle: true,
        backgroundColor: Colors.blue,
        title: const Text(
          "Edukasi Kesehatan",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Column(
        children: [

          // ================= SEARCH =================
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              decoration: InputDecoration(
                hintText: "Cari artikel kesehatan...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ================= CATEGORY =================
          SizedBox(
            height: 45,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: _kategoriList.length,
              itemBuilder: (context, i) {
                final k = _kategoriList[i];
                final active = selectedKategori == k;

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(k),
                    selected: active,
                    onSelected: (_) {
                      setState(() => selectedKategori = k);
                    },
                    selectedColor: Colors.blue,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: active ? Colors.white : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // ================= LIST =================
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text("Tidak ada artikel"),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      return _card(filtered[i]);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ================= CARD STYLE MODERN =================
  Widget _card(ArtikelModel item) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailArtikelPage(artikel: item),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blueGrey.withOpacity(.12),
              blurRadius: 18,
              spreadRadius: 2,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Row(
          children: [

            // ICON BOX
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.local_hospital,
                color: Colors.blue,
              ),
            ),

            const SizedBox(width: 12),

            // TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // kategori
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 13,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        item.kategori,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // judul
                  Text(
                    item.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // isi
                  Text(
                    item.isi,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_circle_right_rounded,
              color: Colors.blue,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}

// ================= DETAIL PAGE =================
class DetailArtikelPage extends StatelessWidget {
  final ArtikelModel artikel;

  const DetailArtikelPage({super.key, required this.artikel});

  Future<void> _open(String? link) async {
    if (link == null || link.isEmpty) return;
    final uri = Uri.tryParse(link);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),

      body: CustomScrollView(
        slivers: [

          // ================= HEADER ESTETIK =================
          SliverAppBar(
            expandedHeight: 68,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A90E2), Color(0xFF6FB1FC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      artikel.kategori,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ================= CONTENT =================
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // TITLE
                    Text(
                      artikel.judul,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // DIVIDER SOFT
                    Container(
                      height: 1,
                      color: Colors.grey.shade200,
                    ),

                    const SizedBox(height: 16),

                    // CONTENT
                    Text(
                      artikel.isi,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 30),

                    // BUTTON ESTETIK
                    if (artikel.linkArtikel != null &&
                        artikel.linkArtikel!.isNotEmpty)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4A90E2), Color(0xFF6FB1FC)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: () => _open(artikel.linkArtikel),
                          icon: const Icon(Icons.open_in_new),
                          label: const Text("Baca Sumber Lengkap"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            padding: const EdgeInsets.all(14),
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}