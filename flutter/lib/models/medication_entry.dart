class MedicationEntry {
  final int? id;
  final String namaObat;
  final String dosis;
  final String frekuensi;
  final String waktuKonsumsi;
  final String tipe; // 'jam' atau 'makan'
  final String catatan;
  final DateTime dibuatPada;

  MedicationEntry({
    this.id,
    required this.namaObat,
    required this.dosis,
    required this.frekuensi,
    required this.waktuKonsumsi,
    required this.tipe,
    this.catatan = '',
    required this.dibuatPada,
  });

  factory MedicationEntry.fromJson(Map<String, dynamic> json) {
    return MedicationEntry(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      namaObat: json['nama_obat'] ?? '-',
      dosis: json['dosis'] ?? '-',
      frekuensi: json['frekuensi'] ?? '-',
      waktuKonsumsi: json['waktu_konsumsi'] ?? '-',
      tipe: json['tipe'] ?? 'jam',
      catatan: json['catatan'] ?? '',
      dibuatPada: json['dibuat_pada'] != null
    ? DateTime.tryParse(json['dibuat_pada']) ?? DateTime.now()
    : DateTime.now(),
    );
  }
}