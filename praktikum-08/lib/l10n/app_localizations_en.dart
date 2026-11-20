// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Student & Admin Directory';

  @override
  String get detailTitle => 'User Details';

  @override
  String get adminDetailTitle => 'Admin Details';

  @override
  String get email => 'Email';

  @override
  String get city => 'City';

  @override
  String get department => 'Department';

  @override
  String get language => 'Language';

  @override
  String get errorMessage => 'Failed to retrieve data';

  @override
  String get retry => 'Try Again';

  @override
  String get noData => 'No user data available';

  @override
  String get noAdminData => 'No admin data available';

  @override
  String get usersTab => 'User List';

  @override
  String get adminsTab => 'Admin List';

  @override
  String get deleteAdmin => 'Delete Admin';
}
