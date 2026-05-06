class MedicationEntry {
  final String namaObat;
  final String dosis;
  final String frekuensi;
  final String waktuKonsumsi;
  final String tipe; // 'jam' atau 'makan'
  final String catatan;
  final DateTime dibuatPada;

  MedicationEntry({
    required this.namaObat,
    required this.dosis,
    required this.frekuensi,
    required this.waktuKonsumsi,
    required this.tipe,
    this.catatan = '',
    required this.dibuatPada,
  });
}