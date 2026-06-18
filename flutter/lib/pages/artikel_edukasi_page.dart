import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/artikel_model.dart';
import '../services/api_service.dart';

class ArtikelEdukasiPage extends StatefulWidget {
  const ArtikelEdukasiPage({super.key});

  @override
  State<ArtikelEdukasiPage> createState() =>
      _ArtikelEdukasiPageState();
}

class _ArtikelEdukasiPageState
    extends State<ArtikelEdukasiPage> {
  List<ArtikelModel> artikelList = [];
  bool isLoading = true;

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
      debugPrint("ERROR LOAD ARTIKEL: $e");

      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edukasi Diabetes"),
        backgroundColor: Colors.blue,
      ),
      body: artikelList.isEmpty
          ? const Center(
              child: Text(
                "Belum ada artikel",
                style: TextStyle(fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: artikelList.length,
              itemBuilder: (context, index) {
                final item = artikelList[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DetailArtikelPage(artikel: item),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.judul,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: Text(
                              item.kategori,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            item.isi,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}

/// ================= DETAIL ARTIKEL =================

class DetailArtikelPage extends StatelessWidget {
  final ArtikelModel artikel;

  const DetailArtikelPage({
    super.key,
    required this.artikel,
  });

  Future<void> _bukaLink(BuildContext context) async {
    final link = artikel.linkArtikel;
    if (link == null || link.isEmpty) return;

    final uri = Uri.tryParse(link);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak bisa membuka link artikel')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(artikel.judul),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              artikel.judul,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius:
                    BorderRadius.circular(8),
              ),
              child: Text(
                artikel.kategori,
                style: const TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              artikel.isi,
              style: const TextStyle(
                fontSize: 16,
                height: 1.6,
              ),
            ),

            const SizedBox(height: 24),

            if (artikel.linkArtikel != null &&
                artikel.linkArtikel!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _bukaLink(context),
                  icon: const Icon(
                    Icons.open_in_new,
                  ),
                  label: const Text(
                    "Buka Artikel Lengkap",
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}