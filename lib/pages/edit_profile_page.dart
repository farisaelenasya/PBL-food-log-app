import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _namaController = TextEditingController(text: 'Alex Thompson');
  final _ringkasanController = TextEditingController();
  final _tinggiBadanController = TextEditingController(text: '182');
  final _beratBadanController = TextEditingController(text: '78');
  String _jenisDiabetes = 'Diabetes Tipe 2';

  final List<String> _daftarDiabetes = [
    'Diabetes Tipe 1',
    'Diabetes Tipe 2',
    'Diabetes Gestasional',
    'Pra-Diabetes',
  ];

  @override
  void dispose() {
    _namaController.dispose();
    _ringkasanController.dispose();
    _tinggiBadanController.dispose();
    _beratBadanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ubah Profil', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto Profil
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.blue[100],
                    child: const Icon(Icons.person, size: 52, color: Color(0xFF2979FF)),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 28, height: 28,
                      decoration: const BoxDecoration(color: Color(0xFF2979FF), shape: BoxShape.circle),
                      child: const Icon(Icons.camera_alt, size: 15, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Center(child: Text('Ganti Foto', style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.w600, fontSize: 13))),
            const SizedBox(height: 24),

            _buildLabel('Nama Lengkap'),
            const SizedBox(height: 6),
            _buildTextField(controller: _namaController, hint: 'Alex Thompson'),
            const SizedBox(height: 16),

            _buildLabel('Ringkasan Kesehatan'),
            const SizedBox(height: 6),
            TextField(
              controller: _ringkasanController,
              maxLines: 3,
              decoration: _inputDecoration('Catatan kesehatan singkat...'),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Tinggi Badan (cm)'),
                      const SizedBox(height: 6),
                      _buildTextField(controller: _tinggiBadanController, hint: '182', jenisKeyboard: TextInputType.number,
                        prefiks: const Icon(Icons.height, size: 16, color: Color(0xFF2979FF))),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Berat Badan (kg)'),
                      const SizedBox(height: 6),
                      _buildTextField(controller: _beratBadanController, hint: '78', jenisKeyboard: TextInputType.number,
                        prefiks: const Icon(Icons.monitor_weight_outlined, size: 16, color: Color(0xFF2979FF))),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _buildLabel('Jenis Diabetes'),
            const SizedBox(height: 6),
            Container(
              decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _jenisDiabetes,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF2979FF)),
                  items: _daftarDiabetes.map((jenis) => DropdownMenuItem(value: jenis, child: Text(jenis, style: const TextStyle(fontSize: 14)))).toList(),
                  onChanged: (val) => setState(() => _jenisDiabetes = val!),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE3F2FD), borderRadius: BorderRadius.circular(10)),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF2979FF), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text('Informasi ini membantu menyesuaikan pelacakan kesehatan dan rekomendasi makan Anda.',
                      style: TextStyle(fontSize: 12, color: Colors.blue[700])),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2979FF), foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profil berhasil disimpan'), backgroundColor: Color(0xFF2979FF)),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.save_outlined, size: 18),
                label: const Text('Simpan Perubahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal', style: TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String teks) => Text(teks, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF1A1A2E)));

  Widget _buildTextField({required TextEditingController controller, required String hint, TextInputType jenisKeyboard = TextInputType.text, Widget? prefiks}) {
    return TextField(controller: controller, keyboardType: jenisKeyboard, decoration: _inputDecoration(hint, prefiks: prefiks));
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefiks}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
      prefixIcon: prefiks,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF2979FF))),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}