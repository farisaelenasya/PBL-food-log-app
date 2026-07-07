import 'package:flutter/material.dart';
import '../services/medication_service.dart';
import '../services/notification_service.dart';
import '../models/medication_entry.dart';

class AddMedicationPage extends StatefulWidget {
  final MedicationEntry? medication;

  const AddMedicationPage({super.key, this.medication});

  @override
  State<AddMedicationPage> createState() => _AddMedicationPageState();
}

class _AddMedicationPageState extends State<AddMedicationPage> {
  final _namaController = TextEditingController();
  final _dosisController = TextEditingController();
  final _catatanController = TextEditingController();

  int _indeksFrekuensi = 0;
  int _indeksWaktu = 0;
  bool _sedangMenyimpan = false;

  final _service = MedicationService(); // ← pakai service
  bool get _modeEdit => widget.medication != null;

  @override
  void initState() {
    super.initState();
    if (_modeEdit) {
      final obat = widget.medication!;
      _namaController.text = obat.namaObat;
      _dosisController.text = obat.dosis == '-' ? '' : obat.dosis;
      _catatanController.text = obat.catatan;

      _indeksFrekuensi = _daftarFrekuensi.indexWhere((f) => f['label'] == obat.frekuensi);
      if (_indeksFrekuensi == -1) _indeksFrekuensi = 0;

      _indeksWaktu = obat.tipe == 'makan' ? 1 : 0;

      _chipWaktu.addAll(
        obat.waktuKonsumsi.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty),
      );
      _hariTerpilih.addAll(obat.hariTerpilih);   
    }
  }

  final List<Map<String, dynamic>> _daftarFrekuensi = [
    {'label': 'Setiap Hari', 'ikon': Icons.calendar_today_outlined},
    {'label': 'Sekali Saja', 'ikon': Icons.looks_one_outlined},
    {'label': 'Hari Tertentu', 'ikon': Icons.event_repeat_outlined},
  ];

  final List<String> _chipWaktu = [];

  final List<String> _hariTerpilih = [];
  final List<String> _daftarHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu'
  ];

  final Map<String, int> _mapHariKeWeekday = {
    'Senin': DateTime.monday,
    'Selasa': DateTime.tuesday,
    'Rabu': DateTime.wednesday,
    'Kamis': DateTime.thursday,
    'Jumat': DateTime.friday,
    'Sabtu': DateTime.saturday,
    'Minggu': DateTime.sunday,
  };

  void _toggleHari(String hari) {
    setState(() {
      if (_hariTerpilih.contains(hari)) {
        _hariTerpilih.remove(hari);
      } else {
        _hariTerpilih.add(hari);
      }
    });
  }

  final List<String> _pilihanWaktuMakan = [
    'Sebelum Sarapan',
    'Setelah Sarapan',
    'Sebelum Makan Siang',
    'Setelah Makan Siang',
    'Sebelum Makan Malam',
    'Setelah Makan Malam',
    'Sebelum Tidur',
  ];

  final Map<String, String> _defaultJamMakan = {
    'Sebelum Sarapan': '06:00',
    'Setelah Sarapan': '07:00',
    'Sebelum Makan Siang': '11:30',
    'Setelah Makan Siang': '12:30',
    'Sebelum Makan Malam': '17:30',
    'Setelah Makan Malam': '18:30',
    'Sebelum Tidur': '21:00',
  };

  @override
  void dispose() {
    _namaController.dispose();
    _dosisController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  // ── Pilih jam spesifik (mode "Jam Spesifik") ────────────────
  Future<void> _pilihJamSpesifik() async {
    final waktu = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF2979FF)),
        ),
        child: child!,
      ),
    );
    if (waktu != null) {
      final jam = waktu.hour.toString().padLeft(2, '0');
      final menit = waktu.minute.toString().padLeft(2, '0');
      final waktuBaru = '$jam:$menit';

      if (_chipWaktu.contains(waktuBaru)) {
        _showSnackbar('Jam $waktuBaru sudah ditambahkan', Colors.orange);
        return;
      }
      setState(() => _chipWaktu.add(waktuBaru));
    }
  }

  // ── Toggle pilih/batal waktu makan (mode "Waktu Makan") ─────
  void _toggleWaktuMakan(String label) {
    setState(() {
      if (_chipWaktu.contains(label)) {
        _chipWaktu.remove(label);
      } else {
        _chipWaktu.add(label);
      }
    });
  }

  void _hapusChip(String chip) => setState(() => _chipWaktu.remove(chip));

  ({int hour, int minute}) _parseJamDariChip(String chip) {
    if (chip.contains(':')) {
      final parts = chip.split(':');
      return (hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    final default_ = _defaultJamMakan[chip] ?? '08:00';
    final parts = default_.split(':');
    return (hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  FrekuensiObat _toFrekuensiObat(String label) {
    switch (label) {
      case 'Sekali Saja':
        return FrekuensiObat.sekaliSaja;
      case 'Hari Tertentu':
        return FrekuensiObat.hariTertentu;
      case 'Setiap Hari':
      default:
        return FrekuensiObat.setiapHari;
    }
  }

 Future<void> _batalkanNotifLama(MedicationEntry obatLama) async {
    final frekuensiEnumLama = _toFrekuensiObat(obatLama.frekuensi);
    final chipsLama = obatLama.waktuKonsumsi
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);

    for (final chip in chipsLama) {
      final notifIdLama = ('${obatLama.namaObat}-$chip').hashCode & 0x7FFFFFFF;

      if (frekuensiEnumLama == FrekuensiObat.hariTertentu) {
        for (int hari = 1; hari <= 7; hari++) {
          await NotificationService().dismiss(notifIdLama * 10 + hari);
        }
      } else {
        await NotificationService().dismiss(notifIdLama);
      }
    }
  }

  // ── SIMPAN via API ──────────────────────────────────────────
  void _simpan() async {
    if (_namaController.text.trim().isEmpty) {
      _showSnackbar('Nama obat tidak boleh kosong', Colors.redAccent);
      return;
    }
    if (_chipWaktu.isEmpty) {
      _showSnackbar('Tambahkan minimal 1 waktu konsumsi', Colors.redAccent);
      return;
    }
    if (_daftarFrekuensi[_indeksFrekuensi]['label'] == 'Hari Tertentu' &&
        _hariTerpilih.isEmpty) {
      _showSnackbar('Pilih minimal 1 hari', Colors.redAccent);
      return;
    }
    setState(() => _sedangMenyimpan = true);

    try {
      final namaObat = _namaController.text.trim();
      final dosis = _dosisController.text.trim().isEmpty
          ? '-'
          : _dosisController.text.trim();
      final frekuensiLabel =
          _daftarFrekuensi[_indeksFrekuensi]['label'] as String;

      if (_modeEdit) {
       await _service.updateMedication(
          id: widget.medication!.id!,
          namaObat: namaObat,
          dosis: dosis,
          frekuensi: frekuensiLabel,
          waktuKonsumsi: _chipWaktu.join(', '),
          tipe: _indeksWaktu == 0 ? 'jam' : 'makan',
          catatan: _catatanController.text.trim(),
          hariTerpilih: _hariTerpilih,   // ← baris baru ini
        );
        await _batalkanNotifLama(widget.medication!);
      } else {
        await _service.addMedication(
          namaObat: namaObat,
          dosis: dosis,
          frekuensi: frekuensiLabel,
          waktuKonsumsi: _chipWaktu.join(', '),
          tipe: _indeksWaktu == 0 ? 'jam' : 'makan',
          catatan: _catatanController.text.trim(),
          hariTerpilih: _hariTerpilih,   // ← baris baru ini
        );
      }

      if (frekuensiLabel != 'Sesuai Kebutuhan') {
        final frekuensiEnum = _toFrekuensiObat(frekuensiLabel);
        final hariWeekday = _hariTerpilih
            .map((h) => _mapHariKeWeekday[h])
            .whereType<int>()
            .toList();

        for (int i = 0; i < _chipWaktu.length; i++) {
          final chip = _chipWaktu[i];
          final jamMenit = _parseJamDariChip(chip);
          final notifId = ('$namaObat-$chip').hashCode & 0x7FFFFFFF;

          await NotificationService().jadwalkanNotifObat(
            id: notifId,
            namaObat: namaObat,
            dosis: dosis,
            waktuLabel: chip,
            jam: jamMenit.hour,
            menit: jamMenit.minute,
            frekuensi: frekuensiEnum,
            hariTerpilih: frekuensiEnum == FrekuensiObat.hariTertentu
                ? hariWeekday
                : null,
          );
        }
      }

      if (!mounted) return;
      _showSnackbar(
        _modeEdit ? 'Obat berhasil diperbarui!' : 'Obat berhasil disimpan!',
        const Color(0xFF2979FF),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      _showSnackbar(
          e.toString().replaceFirst('Exception: ', ''), Colors.redAccent);
    } finally {
      if (mounted) setState(() => _sedangMenyimpan = false);
    }
  }

  void _showSnackbar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(pesan), backgroundColor: warna),
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
        title: Text(_modeEdit ? 'Edit Obat' : 'Tambah Obat Baru',
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            _buildLabel('Nama Obat'),
            const SizedBox(height: 8),
            _buildTextField(_namaController, 'Misal: Metformin, Insulin'),
            const SizedBox(height: 16),

            _buildLabel('Dosis'),
            const SizedBox(height: 8),
            _buildTextField(_dosisController, 'Misal: 500mg, 10 unit'),
            const SizedBox(height: 20),

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
                          color: dipilih
                              ? const Color(0xFF2979FF)
                              : Colors.grey[300]!,
                          width: dipilih ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(_daftarFrekuensi[i]['ikon'] as IconData,
                              size: 20,
                              color: dipilih
                                  ? const Color(0xFF2979FF)
                                  : Colors.grey[500]),
                          const SizedBox(height: 6),
                          Text(_daftarFrekuensi[i]['label'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: dipilih
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: dipilih
                                    ? const Color(0xFF2979FF)
                                    : Colors.grey[600],
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),

            if (_indeksFrekuensi == 2) ...[
              const SizedBox(height: 12),
              _buildLabel('Pilih Hari'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _daftarHari.map((hari) {
                  final dipilih = _hariTerpilih.contains(hari);
                  return GestureDetector(
                    onTap: () => _toggleHari(hari),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: dipilih ? const Color(0xFF2979FF) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                            color: dipilih
                                ? const Color(0xFF2979FF)
                                : Colors.grey[300]!),
                      ),
                      child: Text(
                        hari,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              dipilih ? FontWeight.bold : FontWeight.normal,
                          color: dipilih ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            const SizedBox(height: 20),

            _buildLabel('Waktu Konsumsi'),
            const SizedBox(height: 10),

            // Toggle mode: Jam Spesifik / Waktu Makan
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _indeksWaktu = 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: _indeksWaktu == 0
                            ? const Color(0xFFE8F0FE)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _indeksWaktu == 0
                              ? const Color(0xFF2979FF)
                              : Colors.grey[300]!,
                          width: _indeksWaktu == 0 ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.access_time_outlined,
                              size: 18,
                              color: _indeksWaktu == 0
                                  ? const Color(0xFF2979FF)
                                  : Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text('Jam Spesifik',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _indeksWaktu == 0
                                      ? const Color(0xFF2979FF)
                                      : Colors.grey[600])),
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
                        color: _indeksWaktu == 1
                            ? const Color(0xFFE8F0FE)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _indeksWaktu == 1
                              ? const Color(0xFF2979FF)
                              : Colors.grey[300]!,
                          width: _indeksWaktu == 1 ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.restaurant_outlined,
                              size: 18,
                              color: _indeksWaktu == 1
                                  ? const Color(0xFF2979FF)
                                  : Colors.grey[600]),
                          const SizedBox(width: 6),
                          Text('Waktu Makan',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: _indeksWaktu == 1
                                      ? const Color(0xFF2979FF)
                                      : Colors.grey[600])),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Konten sesuai mode, bergaya seperti AddGlucosePage ──
            if (_indeksWaktu == 0)
              // Mode Jam Spesifik → box tap-to-pick
              GestureDetector(
                onTap: _pilihJamSpesifik,
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 6)
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ketuk untuk pilih jam',
                          style:
                              TextStyle(fontSize: 14, color: Colors.grey[500])),
                      const Icon(Icons.access_time_outlined,
                          size: 18, color: Color(0xFF2979FF)),
                    ],
                  ),
                ),
              )
            else
              // Mode Waktu Makan → Wrap chip pilih-langsung
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _pilihanWaktuMakan.map((w) {
                  final dipilih = _chipWaktu.contains(w);
                  return GestureDetector(
                    onTap: () => _toggleWaktuMakan(w),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: dipilih ? const Color(0xFF2979FF) : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(
                          color: dipilih
                              ? const Color(0xFF2979FF)
                              : Colors.grey[300]!,
                        ),
                        boxShadow: dipilih
                            ? [
                                const BoxShadow(
                                    color: Color(0x332979FF),
                                    blurRadius: 8,
                                    offset: Offset(0, 3))
                              ]
                            : [],
                      ),
                      child: Text(
                        w,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              dipilih ? FontWeight.bold : FontWeight.normal,
                          color: dipilih ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 12),

            // Daftar jam spesifik yang sudah dipilih
            if (_indeksWaktu == 0 &&
                _chipWaktu.where((c) => c.contains(':')).isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _chipWaktu.where((c) => c.contains(':')).map((jam) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F0FE),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF2979FF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.access_time,
                            size: 14, color: Color(0xFF2979FF)),
                        const SizedBox(width: 6),
                        Text(jam,
                            style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF2979FF),
                                fontWeight: FontWeight.w600)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _hapusChip(jam),
                          child: const Icon(Icons.close,
                              size: 14, color: Color(0xFF2979FF)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('Catatan Tambahan'),
                Text('(Opsional)',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                        fontStyle: FontStyle.italic)),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6)
                ],
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
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A1A2E))),
                        const SizedBox(height: 4),
                        Text(
                            'Kami akan mengingatkan Anda\ntepat waktu setiap harinya.',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                height: 1.4)),
                      ],
                    ),
                  ),
                  const Icon(Icons.medication_rounded,
                      size: 48, color: Color(0xFF2979FF)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2979FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                  shadowColor: const Color(0x442979FF),
                ),
                onPressed: _sedangMenyimpan ? null : _simpan,
                icon: _sedangMenyimpan
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  _sedangMenyimpan
                      ? (_modeEdit ? 'Memperbarui...' : 'Menyimpan...')
                      : (_modeEdit ? 'Perbarui Obat' : 'Simpan Obat'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
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
    return Text(teks,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A1A2E)));
  }

  Widget _buildTextField(TextEditingController ctrl, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)
        ],
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}
