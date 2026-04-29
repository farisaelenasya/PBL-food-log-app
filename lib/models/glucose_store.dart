import 'glucose_entry.dart';

class GlucoseStore {
  static final GlucoseStore _instance = GlucoseStore._internal();
  factory GlucoseStore() => _instance;
  GlucoseStore._internal();

  final List<GlucoseEntry> _daftarEntri = [
    GlucoseEntry(nilai: 110, waktu: DateTime.now().subtract(const Duration(hours: 2)), konteksMakan: 'Sebelum Sarapan'),
    GlucoseEntry(nilai: 125, waktu: DateTime.now().subtract(const Duration(days: 1, hours: 5)), konteksMakan: 'Setelah Makan Siang'),
    GlucoseEntry(nilai: 98,  waktu: DateTime.now().subtract(const Duration(days: 2)), konteksMakan: 'Puasa'),
    GlucoseEntry(nilai: 142, waktu: DateTime.now().subtract(const Duration(days: 3)), konteksMakan: 'Setelah Makan Malam'),
    GlucoseEntry(nilai: 105, waktu: DateTime.now().subtract(const Duration(days: 4)), konteksMakan: 'Sebelum Makan Siang'),
    GlucoseEntry(nilai: 118, waktu: DateTime.now().subtract(const Duration(days: 5)), konteksMakan: 'Setelah Sarapan'),
    GlucoseEntry(nilai: 90,  waktu: DateTime.now().subtract(const Duration(days: 6)), konteksMakan: 'Puasa'),
  ];

  List<GlucoseEntry> get semuaEntri => List.unmodifiable(_daftarEntri);

  void tambah(GlucoseEntry entri) {
    _daftarEntri.insert(0, entri);
  }

  // Ambil 7 data terbaru untuk grafik
  List<double> get data7Hari {
    final sorted = [..._daftarEntri]..sort((a, b) => a.waktu.compareTo(b.waktu));
    final recent = sorted.length >= 7 ? sorted.sublist(sorted.length - 7) : sorted;
    return recent.map((e) => e.nilai).toList();
  }

  double get rataRata {
    if (_daftarEntri.isEmpty) return 0;
    return _daftarEntri.map((e) => e.nilai).reduce((a, b) => a + b) / _daftarEntri.length;
  }
}