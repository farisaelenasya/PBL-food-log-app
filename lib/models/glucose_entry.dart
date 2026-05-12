class GlucoseEntry {
  final double nilai;
  final DateTime waktu;
  final String konteksMakan;
  final String catatan;

  GlucoseEntry({
    required this.nilai,
    required this.waktu,
    required this.konteksMakan,
    this.catatan = '',
  });
}