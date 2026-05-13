import 'package:flutter/material.dart';
import 'meal_history_page.dart';

class CatatanMakananManualPage extends StatefulWidget {
  const CatatanMakananManualPage({super.key});

  @override
  State<CatatanMakananManualPage> createState() => _CatatanMakananManualPageState();
}

class _CatatanMakananManualPageState extends State<CatatanMakananManualPage> {
  final _namaController = TextEditingController();
  final _sendokController = TextEditingController(text: '0');
  final _beratController = TextEditingController(text: '0');
  final _catatanController = TextEditingController();

  double _porsiDipilih = 1.0;
  String _satuanDipilih = 'Porsi';
  int _waktuMakanDipilih = 0; // 0=Sarapan,1=Siang,2=Malam,3=Cemilan
  bool _sedangMenyimpan = false;

  final List<double> _daftarPorsi = [0.5, 1.0, 2.0];
  final List<String> _daftarSatuan = ['Piring', 'Porsi', 'Mangkok'];
  final List<Map<String, dynamic>> _daftarWaktu = [
    {'label': 'Sarapan', 'ikon': Icons.wb_sunny_outlined},
    {'label': 'Siang', 'ikon': Icons.wb_twilight_outlined},
    {'label': 'Malam', 'ikon': Icons.nights_stay_outlined},
    {'label': 'Cemilan', 'ikon': Icons.cookie_outlined},
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _sendokController.dispose();
    _beratController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() async {
    if (_namaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nama makanan tidak boleh kosong'), backgroundColor: Colors.redAccent),
      );
      return;
    }
    setState(() => _sedangMenyimpan = true);
    await Future.delayed(const Duration(milliseconds: 600));
    setState(() => _sedangMenyimpan = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Makanan berhasil disimpan!'), backgroundColor: Color(0xFF2979FF)),
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MealHistoryPage()),
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
        title: const Text('Catat Makanan Manual',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // Nama Makanan
            _label('Nama Makanan'),
            const SizedBox(height: 8),
            _inputField(_namaController, 'Contoh: Nasi Goreng'),
            const SizedBox(height: 20),

            // Porsi - angka
            _label('Porsi'),
            const SizedBox(height: 10),
            Row(
              children: _daftarPorsi.map((p) {
                final dipilih = _porsiDipilih == p;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _porsiDipilih = p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: EdgeInsets.only(right: p != 2.0 ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: dipilih ? const Color(0xFFE8F0FE) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dipilih ? const Color(0xFF2979FF) : Colors.grey[300]!,
                          width: dipilih ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        p == 0.5 ? '0.5' : p.toInt().toString(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                          color: dipilih ? const Color(0xFF2979FF) : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),

            // Satuan porsi
            Row(
              children: _daftarSatuan.map((s) {
                final dipilih = _satuanDipilih == s;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _satuanDipilih = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      margin: EdgeInsets.only(right: s != 'Mangkok' ? 10 : 0),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: dipilih ? const Color(0xFFE8F0FE) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: dipilih ? const Color(0xFF2979FF) : Colors.grey[300]!,
                          width: dipilih ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        s,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                          color: dipilih ? const Color(0xFF2979FF) : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Waktu Makan
            _label('Waktu Makan'),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 3.0,
              children: List.generate(_daftarWaktu.length, (i) {
                final dipilih = _waktuMakanDipilih == i;
                return GestureDetector(
                  onTap: () => setState(() => _waktuMakanDipilih = i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      color: dipilih ? const Color(0xFFE8F0FE) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: dipilih ? const Color(0xFF2979FF) : Colors.grey[300]!,
                        width: dipilih ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_daftarWaktu[i]['ikon'] as IconData,
                          size: 18,
                          color: dipilih ? const Color(0xFF2979FF) : Colors.grey[500]),
                        const SizedBox(width: 8),
                        Text(
                          _daftarWaktu[i]['label'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: dipilih ? FontWeight.bold : FontWeight.normal,
                            color: dipilih ? const Color(0xFF2979FF) : Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Takaran Porsi
            _label('Takaran Porsi'),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Jumlah Sendok', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 6),
                      _inputFieldNum(_sendokController),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Berat (Gram)', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                      const SizedBox(height: 6),
                      _inputFieldNum(_beratController),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Catatan
            _label('Catatan'),
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
                  hintText: 'Tambahkan detail tambahan...',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  filled: true, fillColor: Colors.white,
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
                    ? const SizedBox(width: 20, height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Icon(Icons.save_outlined, size: 20),
                label: Text(
                  _sedangMenyimpan ? 'Menyimpan...' : 'Simpan Makanan',
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

  Widget _label(String teks) => Text(teks,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)));

  Widget _inputField(TextEditingController ctrl, String hint) => Container(
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

  Widget _inputFieldNum(TextEditingController ctrl) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6)],
    ),
    child: TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        filled: true, fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}