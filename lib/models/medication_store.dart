import 'medication_entry.dart';

class MedicationStore {
  static final MedicationStore _instance = MedicationStore._internal();
  factory MedicationStore() => _instance;
  MedicationStore._internal();

  final List<MedicationEntry> _daftarObat = [];

  List<MedicationEntry> get semuaObat => List.unmodifiable(_daftarObat);

  void tambah(MedicationEntry obat) {
    _daftarObat.insert(0, obat);
  }
}