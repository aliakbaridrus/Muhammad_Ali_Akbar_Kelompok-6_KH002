import 'dart:convert';
import 'dart:io' as io;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class ApiService {
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  static const String fileName = 'users_praktikum08.json';
  static const String webStorageKey = 'users_praktikum08_json';

  // Ketentuan NIM: 20240801218
  // 3 digit terakhir = 218 -> angka tengah (1) digeser ke belakang -> N = 281
  static const String nim = '20240801218';
  static const int nilaiN = 281;
  static const int nimUserId = 1499 + nilaiN; // 1499 + 281 = 1780

  static Future<String> getJsonFilePath() async {
    if (kIsWeb) {
      return 'Browser LocalStorage (Key: "$webStorageKey")';
    }
    final directory = await getApplicationDocumentsDirectory();
    return '${directory.path}/$fileName';
  }

  static Future<io.File?> _getLocalFile() async {
    if (kIsWeb) return null;
    final directory = await getApplicationDocumentsDirectory();
    return io.File('${directory.path}/$fileName');
  }

  static Future<List<dynamic>> _fetchInitialData() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users'))
          .timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded.take(5).toList();
        }
      }
    } catch (_) {
      // Gunakan fallback lokal jika offline atau terkendala jaringan
    }
    return _defaultUsers.map((u) => Map<String, dynamic>.from(u)).toList();
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
      final initialUsers = await _fetchInitialData();
      await prefs.setString(webStorageKey, jsonEncode(initialUsers));
      return initialUsers;
    }

    try {
      final file = await _getLocalFile();
      if (file != null && await file.exists()) {
        final contents = await file.readAsString();
        if (contents.trim().isNotEmpty) {
          return jsonDecode(contents) as List<dynamic>;
        }
      }

      final initialUsers = await _fetchInitialData();
      if (file != null) {
        await file.writeAsString(
          const JsonEncoder.withIndent('  ').convert(initialUsers),
        );
      }
      await prefs.setString(webStorageKey, jsonEncode(initialUsers));
      return initialUsers;
    } catch (_) {
      final cachedJson = prefs.getString(webStorageKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return jsonDecode(cachedJson) as List<dynamic>;
      }
      return _defaultUsers.map((u) => Map<String, dynamic>.from(u)).toList();
    }
  }

  static Future<void> _writeJsonData(List<dynamic> users) async {
    final jsonString = const JsonEncoder.withIndent('  ').convert(users);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(webStorageKey, jsonString);

    if (!kIsWeb) {
      try {
        final file = await _getLocalFile();
        if (file != null) {
          await file.writeAsString(jsonString);
        }
      } catch (e) {
        debugPrint('Gagal menulis file lokal: $e');
      }
    }
  }

  // GET: Mengambil seluruh data User
  static Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 200));
    final rawList = await _readJsonData();
    return rawList
        .map((item) => User.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  // GET: Mengambil detail satu User berdasarkan ID
  static Future<User> getUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final users = await _readJsonData();

    final found = users.firstWhere(
      (element) =>
          (element['id'] is int
              ? element['id']
              : int.tryParse(element['id'].toString())) ==
          id,
      orElse: () => null,
    );

    if (found != null) {
      return User.fromJson(Map<String, dynamic>.from(found));
    }

    throw Exception('Data User dengan ID $id tidak ditemukan');
  }

  // POST: Menambahkan User baru berdasarkan ID dari NIM (1499 + N = 1780)
  static Future<User> createUser(
    String name,
    String email, {
    String city = 'Jakarta',
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final users = await _readJsonData();

    int newId = nimUserId; // Default rumus NIM: 1499 + 281 = 1780
    final existingIds = users
        .map<int>(
          (u) => u['id'] is int
              ? u['id'] as int
              : int.tryParse(u['id'].toString()) ?? 0,
        )
        .toSet();

    while (existingIds.contains(newId)) {
      newId++;
    }

    final newUserMap = {
      'id': newId,
      'name': name,
      'email': email,
      'address': {'city': city},
    };

    users.insert(0, newUserMap);
    await _writeJsonData(users);

    return User.fromJson(newUserMap);
  }

  // PUT: Memperbarui nama dan email User
  static Future<User> updateUser(
    int id,
    String name,
    String email, {
    String? city,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final users = await _readJsonData();

    final index = users.indexWhere(
      (element) =>
          (element['id'] is int
              ? element['id']
              : int.tryParse(element['id'].toString())) ==
          id,
    );

    if (index == -1) {
      throw Exception('Gagal PUT User: ID $id tidak ditemukan');
    }

    final existing = Map<String, dynamic>.from(users[index]);
    existing['name'] = name;
    existing['email'] = email;
    if (city != null && city.trim().isNotEmpty) {
      existing['address'] = {'city': city.trim()};
    }

    users[index] = existing;
    await _writeJsonData(users);

    return User.fromJson(existing);
  }

  // PATCH: Memperbarui nama User dengan menambahkan teks " - Flutter Developer"
  static Future<User> patchUser(int id, [String? customBaseName]) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final users = await _readJsonData();

    final index = users.indexWhere(
      (element) =>
          (element['id'] is int
              ? element['id']
              : int.tryParse(element['id'].toString())) ==
          id,
    );

    if (index == -1) {
      throw Exception('Gagal PATCH User: ID $id tidak ditemukan');
    }

    final existing = Map<String, dynamic>.from(users[index]);
    final currentName = (customBaseName ?? existing['name']?.toString() ?? '')
        .replaceAll(' - Flutter Developer', '')
        .trim();
    existing['name'] = '$currentName - Flutter Developer';

    users[index] = existing;
    await _writeJsonData(users);

    return User.fromJson(existing);
  }

  // DELETE: Menghapus User berdasarkan ID
  static Future<bool> deleteUser(int id) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final users = await _readJsonData();

    final index = users.indexWhere(
      (element) =>
          (element['id'] is int
              ? element['id']
              : int.tryParse(element['id'].toString())) ==
          id,
    );

    if (index == -1) {
      return false;
    }

    users.removeAt(index);
    await _writeJsonData(users);
    return true;
  }

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

    await _writeJsonData(_defaultUsers);
  }

  static final List<Map<String, dynamic>> _defaultUsers = [
    {
      'id': 1,
      'name': 'Leanne Graham',
      'email': 'Sincere@april.biz',
      'address': {'city': 'Gwenborough'},
    },
    {
      'id': 2,
      'name': 'Ervin Howell',
      'email': 'Shanna@melissa.tv',
      'address': {'city': 'Wisokyburgh'},
    },
    {
      'id': 3,
      'name': 'Clementine Bauch',
      'email': 'Nathan@yesenia.net',
      'address': {'city': 'McKenziehaven'},
    },
    {
      'id': 4,
      'name': 'Patricia Lebsack',
      'email': 'Julianne.OConner@kory.org',
      'address': {'city': 'South Elvis'},
    },
    {
      'id': 5,
      'name': 'Chelsey Dietrich',
      'email': 'Lucio_Hettinger@annie.ca',
      'address': {'city': 'Roscoeview'},
    },
  ];
}
