import 'package:flutter/material.dart';

bool isKonteksSetelahMakan(String? konteks) {
  if (konteks == null) return false;
  return konteks.toLowerCase().startsWith('setelah');
}

bool isKonteksSebelumTidur(String? konteks) {
  if (konteks == null) return false;
  return konteks.toLowerCase() == 'sebelum tidur';
}

String hitungStatusGula(double nilai, String? konteks) {
  if (nilai == 0) return 'Belum Ada Data';
  if (nilai < 70) return 'Rendah';

  if (isKonteksSebelumTidur(konteks)) {
    if (nilai <= 140) return 'Normal';
    if (nilai <= 180) return 'Perlu Perhatian';
    return 'Tinggi';
  }

  final setelahMakan = isKonteksSetelahMakan(konteks);

  if (setelahMakan) {
    if (nilai < 140) return 'Normal';
    if (nilai <= 199) return 'Pra-Diabetes';
    return 'Diabetes';
  } else {
    if (nilai < 100) return 'Normal';
    if (nilai <= 125) return 'Pra-Diabetes';
    return 'Diabetes';
  }
}

Color warnaStatusGula(String status) {
  switch (status) {
    case 'Rendah':
      return Colors.orange;
    case 'Normal':
      return Colors.green;
    case 'Pra-Diabetes':
      return const Color(0xFFFF8C00);
    case 'Diabetes':
      return Colors.red;
    case 'Perlu Perhatian':
      return const Color(0xFFFF8C00);
    case 'Tinggi':
      return Colors.red;
    default:
      return Colors.grey;
  }
}