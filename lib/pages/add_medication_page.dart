import 'package:flutter/material.dart';
import '../models/medication_entry.dart';
import '../models/medication_store.dart';
import 'notifikasi_page.dart';

class AddMedicationPage extends StatefulWidget {
  const AddMedicationPage({super.key});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _namaController = TextEditingController();
  final _dosisController = TextEditingController();
  final _catatanController = TextEditingController();

  int _indeksFrekuensi = 0;
  int _indeksWaktu = 0; // 0=Jam Spesifik, 1=Waktu Makan
  bool _sedangMenyimpan = false;

  final List<Map<String, dynamic>> _daftarFrekuensi = [
    {'label': 'Setiap Hari', 'ikon': Icons.calendar_today_outlined},
    {'label': 'Interval Jam', 'ikon': Icons.history_outlined},
    {'label': 'Sesuai Kebutuhan', 'ikon': Icons.emergency_outlined},
  ];

  // Chips waktu yang sudah ditambahkan
  final List<String> _chipWaktu = ['Sebelum Sarapan', '08:00'];

  final List<String> _pilihanWaktuMakan = [
    'Sebelum Sarapan',
    'Setelah Sarapan',
    'Sebelum Makan Siang',
    'Setelah Makan Siang',
    'Sebelum Makan Malam',
    'Setelah Makan Malam',
    'Sebelum Tidur',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _dosisController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _tambahWaktu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pilih Waktu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._pilihanWaktuMakan.map((w) => ListTile(
              title: Text(w),
              onTap: () {
                setState(() => _chipWaktu.add(w));
                Navigator.pop(ctx);
              },
            )),
          ],
        ),
      ),
    );
  }

  void _hapusChip(int i) {
    setState(() => _chipWaktu.removeAt(i));
  }

  void _simpan() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama obat tidak boleh kosong'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _sedangMenyimpan = true);
    await Future.delayed(const Duration(milliseconds: 600));

    MedicationStore().tambah(MedicationEntry(
      namaObat: _namaController.text.trim(),
      dosis: _dosisController.text.trim().isEmpty ? '-' : _dosisController.text.trim(),
      frekuensi: _daftarFrekuensi[_indeksFrekuensi]['label'] as String,
      waktuKonsumsi: _chipWaktu.join(', '),
      tipe: _indeksWaktu == 0 ? 'jam' : 'makan',
      catatan: _catatanController.text.trim(),
      dibuatPada: DateTime.now(),
    ));

    setState(() => _sedangMenyimpan = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Obat berhasil disimpan!'), backgroundColor: Color(0xFF2979FF)),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const NotifikasiPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F2F5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Tambah Obat Baru',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Nama Obat
            _buildLabel('Nama Obat'),
            const SizedBox(height: 8),
            _buildTextField(_namaController, 'Misal: Metformin, Insulin'),
            const SizedBox(height: 16),

            // Dosis
            _buildLabel('Dosis'),
            const SizedBox(height: 8),
            _buildTextField(_dosisController, 'Misal: 500mg, 10 unit'),
            const SizedBox(height: 20),

            // Frekuensi
            _buildLabel('Frekuensi'),
            const SizedBox(height: 10),
            Row(
              children: List.generate(_daftarFrekuensi.length, (i) {
                final dipilih = _indeksFrekuensi == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _indeksFrekuensi = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      margin: EdgeInsets.only(right: i < 2 ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: dipilih ? const Color(0xFFE8F0FE) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: dipilih ? const Color(0xFF2979FF) : Colors.grey[300]!,
                          width: dipilih ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(_daftarFrekuensi[i]['ikon'] as IconData,
                            size: 20,
                            color: dipilih ? const Color(0xFF2979FF) : Colors.grey[500]),
                          const SizedBox(height: 6),
                          Text(_daftarFrekuensi[i]['label'] as String,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                              color: dipilih ? const Color(0xFF2979FF) : Colors.grey[600],
                            )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Waktu Konsumsi
            _buildLabel('Waktu Konsumsi'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _indeksWaktu = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: _indeksWaktu == 0 ? const Color(0xFFE8F0FE) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _indeksWaktu == 0 ? const Color(0xFF2979FF) : Colors.grey[300]!,
                          width: _indeksWaktu == 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time_outlined, size: 18,
                            color: _indeksWaktu == 0 ? const Color(0xFF2979FF) : Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text('Jam Spesifik',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: _indeksWaktu == 0 ? const Color(0xFF2979FF) : Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _indeksWaktu = 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: _indeksWaktu == 1 ? const Color(0xFFE8F0FE) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _indeksWaktu == 1 ? const Color(0xFF2979FF) : Colors.grey[300]!,
                          width: _indeksWaktu == 1 ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_outlined, size: 18,
                            color: _indeksWaktu == 1 ? const Color(0xFF2979FF) : Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text('Waktu Makan',
                            style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: _indeksWaktu == 1 ? const Color(0xFF2979FF) : Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Chips waktu
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._chipWaktu.asMap().entries.map((e) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(e.value, style: const TextStyle(fontSize: 13, color: Color(0xFF1A1A2E))),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => _hapusChip(e.key),
                        child: Icon(Icons.close, size: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )),
                GestureDetector(
                  onTap: _tambahWaktu,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text('Tambah Waktu', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Catatan Tambahan
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Catatan Tambahan'),
                Text('(Opsional)', style: TextStyle(fontSize: 12, color: Colors.grey[400], fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
              ),
              child: TextField(
                controller: _catatanController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Contoh: Diminum dengan air putih hangat',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFE8F0FE),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Patuhi Jadwal Obat',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 4),
                        Text('Kami akan mengingatkan Anda\ntepat waktu setiap harinya.',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4)),
                      ],
                    ),
                  ),
                  const Icon(Icons.medication_rounded, size: 48, color: Color(0xFF2979FF)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2979FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: const Color(0x442979FF),
                ),
                onPressed: _sedangMenyimpan ? null : _simpan,
                icon: _sedangMenyimpan
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  _sedangMenyimpan ? 'Menyimpan...' : 'Simpan Obat',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String teks) {
    return Text(teks, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)));
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          filled: true, fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}