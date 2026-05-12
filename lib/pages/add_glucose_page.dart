import 'package:flutter/material.dart';
import '../models/glucose_entry.dart';
import '../models/glucose_store.dart';
import 'glucose_history_page.dart';

class AddGlucosePage extends StatefulWidget {
  const AddGlucosePage({super.key});

  @override
  State<AddGlucosePage> createState() => _AddGlucosePageState();
}

class _AddGlucosePageState extends State<AddGlucosePage> {
  final _nilaiController = TextEditingController(text: '0');
  final _catatanController = TextEditingController();
  DateTime _tanggalDipilih = DateTime.now();
  TimeOfDay _waktuDipilih = TimeOfDay.now();
  int _indeksKonteks = 0;
  bool _sedangMenyimpan = false;

  final List<String> _daftarKonteks = [
    'Sebelum Sarapan',
    'Setelah Sarapan',
    'Sebelum Makan Siang',
    'Setelah Makan Siang',
    'Sebelum Makan Malam',
    'Setelah Makan Malam',
    'Puasa',
    'Sebelum Tidur',
  ];

  @override
  void dispose() {
    _nilaiController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tanggalDipilih,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2979FF)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _tanggalDipilih = picked);
  }

  Future<void> _pilihWaktu() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _waktuDipilih,
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2979FF)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _waktuDipilih = picked);
  }

  void _simpan() async {
    final nilai = double.tryParse(_nilaiController.text);
    if (nilai == null || nilai <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nilai gula darah yang valid'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _sedangMenyimpan = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final waktuLengkap = DateTime(
      _tanggalDipilih.year, _tanggalDipilih.month, _tanggalDipilih.day,
      _waktuDipilih.hour, _waktuDipilih.minute,
    );

    GlucoseStore().tambah(GlucoseEntry(
      nilai: nilai,
      waktu: waktuLengkap,
      konteksMakan: _daftarKonteks[_indeksKonteks],
      catatan: _catatanController.text.trim(),
    ));

    setState(() => _sedangMenyimpan = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data gula darah berhasil disimpan!'), backgroundColor: Color(0xFF2979FF)),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const GlucoseHistoryPage()),
    );
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatWaktu(TimeOfDay t) {
    final jam = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final menit = t.minute.toString().padLeft(2, '0');
    final period = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$jam:$menit $period';
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
        title: const Text(
          'Tambah Bacaan Glukosa',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF1A1A2E)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Input Nilai Gula Darah
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 12, offset: const Offset(0, 3))],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                children: [
                  Text(
                    'Kadar Gula Darah',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nilaiController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[300],
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (v) => setState(() {}),
                        ),
                      ),
                      const Text(
                        'mg/dL',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2979FF)),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFF2979FF), thickness: 2),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Tanggal & Waktu
            _buildSectionHeader(Icons.calendar_month_outlined, 'Tanggal & Waktu'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tanggal', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pilihTanggal,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatTanggal(_tanggalDipilih),
                                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E))),
                              const Icon(Icons.calendar_today_outlined, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Waktu', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _pilihWaktu,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatWaktu(_waktuDipilih),
                                style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E))),
                              const Icon(Icons.access_time_outlined, size: 18, color: Colors.grey),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Konteks Makan
            _buildSectionHeader(Icons.restaurant_outlined, 'Konteks Makan'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_daftarKonteks.length, (i) {
                final dipilih = _indeksKonteks == i;
                return GestureDetector(
                  onTap: () => setState(() => _indeksKonteks = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: dipilih ? const Color(0xFF2979FF) : Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: dipilih ? const Color(0xFF2979FF) : Colors.grey[300]!,
                      ),
                      boxShadow: dipilih
                          ? [const BoxShadow(color: Color(0x332979FF), blurRadius: 8, offset: Offset(0, 3))]
                          : [],
                    ),
                    child: Text(
                      _daftarKonteks[i],
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                        color: dipilih ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                );
              }),
            ),

            const SizedBox(height: 20),

            // Catatan & Gejala
            _buildSectionHeader(Icons.edit_note_outlined, 'Catatan & Gejala'),
            const SizedBox(height: 10),
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
                  hintText: 'Contoh: Merasa sedikit pusing, makan semangkuk besar buah...',
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

            const SizedBox(height: 28),

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
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  _sedangMenyimpan ? 'Menyimpan...' : 'Simpan Bacaan',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData ikon, String judul) {
    return Row(
      children: [
        Icon(ikon, size: 20, color: const Color(0xFF2979FF)),
        const SizedBox(width: 8),
        Text(judul, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
      ],
    );
  }
}