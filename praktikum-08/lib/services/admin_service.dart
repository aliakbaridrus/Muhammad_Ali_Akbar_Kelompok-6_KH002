import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/admin.dart';

class AdminService {
  static const String fileName = 'admins_praktikum08.json';
  static const String webStorageKey = 'admins_praktikum08_json';

  // Ketentuan NIM: 20240801218
  // 3 digit terakhir = 218 -> angka tengah (1) digeser ke belakang -> N = 281
  // Rumus ID Admin: 792 + N = 792 + 281 = 1073
  static const String nim = '20240801218';
  static const int nilaiN = 281;
  static const int nimAdminId = 792 + nilaiN; // 1073

  static Future<io.File?> _getLocalFile() async {
    if (kIsWeb) return null;
    final directory = await getApplicationDocumentsDirectory();
    return io.File('${directory.path}/$fileName');
  }

  static Future<List<dynamic>> _readJsonData() async {
    final prefs = await SharedPreferences.getInstance();

    if (kIsWeb) {
      final cachedJson = prefs.getString(webStorageKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        try {
          return jsonDecode(cachedJson) as List<dynamic>;
        } catch (_) {}
      }
      final initialAdmins = _defaultAdmins
          .map((a) => Map<String, dynamic>.from(a))
          .toList();
      await prefs.setString(webStorageKey, jsonEncode(initialAdmins));
      return initialAdmins;
    }

    try {
      final file = await _getLocalFile();
      if (file != null && await file.exists()) {
        final contents = await file.readAsString();
        if (contents.trim().isNotEmpty) {
          return jsonDecode(contents) as List<dynamic>;
        }
      }

      final initialAdmins = _defaultAdmins
          .map((a) => Map<String, dynamic>.from(a))
          .toList();
      if (file != null) {
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(initialAdmins),
        );
      }
      await prefs.setString(webStorageKey, jsonEncode(initialAdmins));
      return initialAdmins;
    } catch (_) {
      final cachedJson = prefs.getString(webStorageKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return jsonDecode(cachedJson) as List<dynamic>;
      }
      return _defaultAdmins.map((a) => Map<String, dynamic>.from(a)).toList();
    }
  }

  static Future<void> _writeJsonData(List<dynamic> admins) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(admins);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(webStorageKey, jsonString);

    if (!kIsWeb) {
      try {
        final file = await _getLocalFile();
        if (file != null) {
          await file.writeAsString(jsonString);
        }
      } catch (e) {
        debugPrint('Gagal menulis file admin lokal: $e');
      }
    }
  }

  // GET: Mengambil seluruh data Admin menggunakan Admin.fromJson()
  static Future<List<Admin>> getAdmins() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final rawList = await _readJsonData();
    return rawList
        .map((item) => Admin.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // GET: Mengambil satu data Admin berdasarkan ID
  static Future<Admin> getAdmin(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final admins = await _readJsonData();

    final found = admins.firstWhere(
      (element) =>
          (element['id'] is int
              ? element['id']
              : int.tryParse(element['id'].toString())) ==
          id,
      orElse: () => null,
    );

    if (found != null) {
      return Admin.fromJson(Map<String, dynamic>.from(found));
    }

    throw Exception('Data Admin dengan ID $id tidak ditemukan');
  }

  // DELETE: Menghapus data Admin berdasarkan ID
  static Future<bool> deleteAdmin(int id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final admins = await _readJsonData();

    final index = admins.indexWhere(
      (element) =>
          (element['id'] is int
              ? element['id']
              : int.tryParse(element['id'].toString())) ==
          id,
    );

    if (index == -1) {
      return false;
    }

    admins.removeAt(index);
    await _writeJsonData(admins);
    return true;
  }

  // Reset data Admin ke default awal (untuk pengujian ulang)
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(webStorageKey);

    if (!kIsWeb) {
      try {
        final file = await _getLocalFile();
        if (file != null && await file.exists()) {
          await file.delete();
        }
      } catch (_) {}
    }

    await _writeJsonData(_defaultAdmins);
  }

  // Data awal Admin dengan ID menggunakan rumus 792 + N (792 + 281 = 1073)
  static final List<Map<String, dynamic>> _defaultAdmins = [
    {
      'id': nimAdminId, // 1073 (792 + 281)
      'name': 'Muhammad Ali Akbar',
      'email': 'aliidrus3142@gmail.com',
      'department': 'Mobile & Flutter Development',
    },
    {
      'id': nimAdminId + 1, // 1074
      'name': 'Rizky Pratama',
      'email': 'rizky.admin@esaunggul.ac.id',
      'department': 'IT Infrastructure & Network',
    },
    {
      'id': nimAdminId + 2, // 1075
      'name': 'Siti Nurhaliza',
      'email': 'siti.admin@esaunggul.ac.id',
      'department': 'Academic Administration',
    },
    {
      'id': nimAdminId + 3, // 1076
      'name': 'Budi Santoso',
      'email': 'budi.security@esaunggul.ac.id',
      'department': 'Cyber Security & Database',
    },
  ];
}
