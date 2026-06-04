import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _namaController        = TextEditingController();
  final _ringkasanController   = TextEditingController();
  final _tinggiBadanController = TextEditingController();
  final _beratBadanController  = TextEditingController();
  final _noTeleponController   = TextEditingController();
  String _jenisDiabetes        = 'Diabetes Tipe 2';
  bool _sedangMemuat           = true;
  bool _sedangSimpan           = false;
  File? _fotoTerpilih;
  String? _fotoProfilUrl;
  Uint8List? _fotoBytes;
  String? _fotoNamaFile;
  final _imagePicker           = ImagePicker();

  static const String _baseUrl = 'http://localhost:8000/api';

  final List<String> _daftarDiabetes = [
    'Diabetes Tipe 1',
    'Diabetes Tipe 2',
    'Diabetes Gestasional',
    'Pra-Diabetes',
  ];

  static const Map<String, String> _labelKeApi = {
    'Diabetes Tipe 1'     : 'Tipe 1',
    'Diabetes Tipe 2'     : 'Tipe 2',
    'Diabetes Gestasional': 'Gestasional',
    'Pra-Diabetes'        : 'Pra-Diabetes',
  };
  static const Map<String, String> _apiKeLabel = {
    'Tipe 1'      : 'Diabetes Tipe 1',
    'Tipe 2'      : 'Diabetes Tipe 2',
    'Gestasional' : 'Diabetes Gestasional',
    'Pra-Diabetes': 'Pra-Diabetes',
  };

  @override
  void initState() {
    super.initState();
    _muatProfil();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _ringkasanController.dispose();
    _tinggiBadanController.dispose();
    _beratBadanController.dispose();
    _noTeleponController.dispose();
    super.dispose();
  }

  Future<void> _muatProfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final res = await http.get(
        Uri.parse('$_baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final user = jsonDecode(res.body)['user'];
        setState(() {
          _namaController.text        = user['name'] ?? '';
          _tinggiBadanController.text = (user['tinggi_badan'] ?? '').toString();
          _beratBadanController.text  = (user['berat_badan'] ?? '').toString();
          _noTeleponController.text   = user['no_telepon'] ?? '';
          _fotoProfilUrl              = user['foto_profil'];
          final apiVal = user['tipe_diabetes'] ?? 'Tipe 2';
          _jenisDiabetes = _apiKeLabel[apiVal] ?? 'Diabetes Tipe 2';
        });
      } else {
        _snackbar('Gagal memuat profil', Colors.red);
      }
    } catch (_) {
      _snackbar('Gagal terhubung ke server', Colors.red);
    } finally {
      setState(() => _sedangMemuat = false);
    }
  }

  Future<void> _pilihFoto(ImageSource sumber) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: sumber,
        imageQuality: 80,
        maxWidth: 512,
      );
      if (picked != null) {
        if (kIsWeb) {
          final bytes = await picked.readAsBytes();
          setState(() {
            _fotoBytes    = bytes;
            _fotoNamaFile = picked.name;
            _fotoTerpilih = null;
          });
        } else {
          setState(() {
            _fotoTerpilih = File(picked.path);
            _fotoBytes    = null;
            _fotoNamaFile = null;
          });
        }
      }
    } catch (_) {
      _snackbar('Gagal memilih foto', Colors.red);
    }
  }

  void _tampilPilihFoto() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Pilih Foto Profil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.camera_alt, color: Color(0xFF2979FF)),
              ),
              title: const Text('Ambil dari Kamera'),
              onTap: () {
                Navigator.pop(context);
                _pilihFoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.photo_library, color: Color(0xFF2979FF)),
              ),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                _pilihFoto(ImageSource.gallery);
              },
            ),
            if (_fotoProfilUrl != null || _fotoTerpilih != null || _fotoBytes != null)
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFEBEE),
                  child: Icon(Icons.delete_outline, color: Colors.red),
                ),
                title: const Text('Hapus Foto',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _fotoTerpilih  = null;
                    _fotoProfilUrl = null;
                    _fotoBytes     = null;
                    _fotoNamaFile  = null;
                  });
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _simpanProfil() async {
    if (_namaController.text.trim().isEmpty) {
      _snackbar('Nama tidak boleh kosong', Colors.red);
      return;
    }

    setState(() => _sedangSimpan = true);

    print('=== DEBUG SIMPAN ===');
    print('FOTO TERPILIH: $_fotoTerpilih');
    print('FOTO BYTES: $_fotoBytes');
    print('FOTO URL: $_fotoProfilUrl');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      http.Response res;

      if (_fotoTerpilih != null || _fotoBytes != null) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$_baseUrl/profile'),
        );
        request.headers['Authorization'] = 'Bearer $token';
        request.headers['Accept']        = 'application/json';
        request.fields['_method']        = 'PUT';
        request.fields['name']           = _namaController.text.trim();
        request.fields['tinggi_badan']   = _tinggiBadanController.text.trim();
        request.fields['berat_badan']    = _beratBadanController.text.trim();
        request.fields['no_telepon']     = _noTeleponController.text.trim();
        request.fields['tipe_diabetes']  = _labelKeApi[_jenisDiabetes] ?? 'Tipe 2';

        if (kIsWeb && _fotoBytes != null) {
          request.files.add(http.MultipartFile.fromBytes(
            'foto_profil',
            _fotoBytes!,
            filename: _fotoNamaFile ?? 'foto.jpg',
          ));
        } else if (_fotoTerpilih != null) {
          request.files.add(await http.MultipartFile.fromPath(
            'foto_profil',
            _fotoTerpilih!.path,
          ));
        }

        final streamed = await request.send();
        res = await http.Response.fromStream(streamed);

        print('STATUS MULTIPART: ${res.statusCode}');
        print('BODY MULTIPART: ${res.body}');

      } else {
        res = await http.put(
          Uri.parse('$_baseUrl/profile'),
          headers: {
            'Content-Type' : 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'name'         : _namaController.text.trim(),
            'tinggi_badan' : int.tryParse(_tinggiBadanController.text.trim()),
            'berat_badan'  : int.tryParse(_beratBadanController.text.trim()),
            'no_telepon'   : _noTeleponController.text.trim(),
            'tipe_diabetes': _labelKeApi[_jenisDiabetes] ?? 'Tipe 2',
          }),
        );

        print('STATUS PUT: ${res.statusCode}');
        print('BODY PUT: ${res.body}');
      }

      final data = jsonDecode(res.body);

      if (res.statusCode == 200 && data['status'] == true) {
        await prefs.setString('user_name', data['user']['name']);
        if (data['user']['foto_profil'] != null) {
          await prefs.setString('foto_profil', data['user']['foto_profil']);
        }

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil disimpan'),
            backgroundColor: Color(0xFF2979FF),
          ),
        );
        Navigator.pop(context, true);
      } else {
        _snackbar(data['message'] ?? 'Gagal menyimpan profil', Colors.red);
      }
    } catch (e) {
      print('ERROR: $e');
      _snackbar('Gagal terhubung ke server', Colors.red);
    } finally {
      setState(() => _sedangSimpan = false);
    }
  }

  void _snackbar(String pesan, Color warna) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(pesan),
      backgroundColor: warna,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              size: 18, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ubah Profil',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E))),
      ),
      body: _sedangMemuat
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF2979FF)))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // ── Foto Profil ──────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: _tampilPilihFoto,
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 52,
                            backgroundColor: Colors.blue[100],
                            backgroundImage: _fotoBytes != null
                                ? MemoryImage(_fotoBytes!) as ImageProvider
                                : _fotoTerpilih != null
                                    ? FileImage(_fotoTerpilih!) as ImageProvider
                                    : (_fotoProfilUrl != null &&
                                            _fotoProfilUrl!.isNotEmpty)
                                        ? NetworkImage(_fotoProfilUrl!)
                                            as ImageProvider
                                        : null,
                            child: (_fotoBytes == null &&
                                    _fotoTerpilih == null &&
                                    (_fotoProfilUrl == null ||
                                        _fotoProfilUrl!.isEmpty))
                                ? const Icon(Icons.person,
                                    size: 56, color: Color(0xFF2979FF))
                                : null,
                          ),
                          Positioned(
                            bottom: 0, right: 0,
                            child: Container(
                              width: 32, height: 32,
                              decoration: const BoxDecoration(
                                  color: Color(0xFF2979FF),
                                  shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt,
                                  size: 17, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: _tampilPilihFoto,
                      child: const Text('Ganti Foto',
                          style: TextStyle(
                              color: Color(0xFF2979FF),
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                  ),
                  // ─────────────────────────────────────────
                  const SizedBox(height: 28),

                  _buildLabel('Nama Lengkap'),
                  const SizedBox(height: 8),
                  _buildTextField(
                      controller: _namaController, hint: 'Nama lengkap'),
                  const SizedBox(height: 20),

                  _buildLabel('Ringkasan Kesehatan'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ringkasanController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 15),
                    decoration:
                        _inputDecoration('Catatan kesehatan singkat...'),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Tinggi Badan (cm)'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _tinggiBadanController,
                              hint: '170',
                              jenisKeyboard: TextInputType.number,
                              prefiks: const Icon(Icons.height,
                                  size: 18, color: Color(0xFF2979FF)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('Berat Badan (kg)'),
                            const SizedBox(height: 8),
                            _buildTextField(
                              controller: _beratBadanController,
                              hint: '65',
                              jenisKeyboard: TextInputType.number,
                              prefiks: const Icon(
                                  Icons.monitor_weight_outlined,
                                  size: 18,
                                  color: Color(0xFF2979FF)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Nomor HP'),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _noTeleponController,
                    hint: 'Contoh: 08123456789',
                    jenisKeyboard: TextInputType.phone,
                    prefiks: const Icon(Icons.phone_outlined,
                        size: 18, color: Color(0xFF2979FF)),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Jenis Diabetes'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _jenisDiabetes,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down,
                            color: Color(0xFF2979FF)),
                        items: _daftarDiabetes
                            .map((jenis) => DropdownMenuItem(
                                value: jenis,
                                child: Text(jenis,
                                    style: const TextStyle(fontSize: 15))))
                            .toList(),
                        onChanged: (val) =>
                            setState(() => _jenisDiabetes = val!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline,
                            color: Color(0xFF2979FF), size: 18),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Informasi ini membantu menyesuaikan pelacakan kesehatan dan rekomendasi makan Anda.',
                            style:
                                TextStyle(fontSize: 15, color: Colors.blue[700]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2979FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      onPressed: _sedangSimpan ? null : _simpanProfil,
                      icon: _sedangSimpan
                          ? const SizedBox(
                              width: 20, height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.save_outlined, size: 20),
                      label: Text(
                        _sedangSimpan ? 'Menyimpan...' : 'Simpan Perubahan',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 15)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildLabel(String teks) => Text(teks,
      style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1A1A2E)));

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType jenisKeyboard = TextInputType.text,
    Widget? prefiks,
  }) {
    return TextField(
      controller: controller,
      keyboardType: jenisKeyboard,
      style: const TextStyle(fontSize: 15),
      decoration: _inputDecoration(hint, prefiks: prefiks),
    );
  }

  InputDecoration _inputDecoration(String hint, {Widget? prefiks}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
      prefixIcon: prefiks,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF2979FF))),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }
}