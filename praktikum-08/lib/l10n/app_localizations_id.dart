// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Direktori Mahasiswa & Admin';

  @override
  String get detailTitle => 'Detail Pengguna';

  @override
  String get adminDetailTitle => 'Detail Admin';

  @override
  String get email => 'Email';

  @override
  String get city => 'Kota';

  @override
  String get department => 'Departemen';

  @override
  String get language => 'Bahasa';

  @override
  String get errorMessage => 'Gagal mengambil data';

  @override
  String get retry => 'Coba lagi';

  @override
  String get noData => 'Tidak ada data pengguna ditemukan';

  @override
  String get noAdminData => 'Tidak ada data admin ditemukan';

  @override
  String get usersTab => 'Daftar User';

  @override
  String get adminsTab => 'Daftar Admin';

  @override
  String get deleteAdmin => 'Hapus Admin';
}
