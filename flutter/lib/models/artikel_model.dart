class ArtikelModel {
  final int id;
  final String judul;
  final String kategori;
  final String isi;
  final String? linkArtikel;
  final String createdAt;

  ArtikelModel({
    required this.id,
    required this.judul,
    required this.kategori,
    required this.isi,
    this.linkArtikel,
    required this.createdAt,
  });

  factory ArtikelModel.fromJson(Map<String, dynamic> json) {
    return ArtikelModel(
      id: json['id'],
      judul: json['judul'],
      kategori: json['kategori'],
      isi: json['isi'],
      linkArtikel: json['link_artikel'],
      createdAt: json['created_at'] ?? '',
    );
  }
}