import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'models/user_model.dart';
import 'models/admin.dart';
import 'services/api_service.dart';
import 'services/admin_service.dart';

void main() {
  runApp(const Praktikum08App());
}

class Praktikum08App extends StatefulWidget {
  const Praktikum08App({super.key});

  @override
  State<Praktikum08App> createState() => _Praktikum08AppState();
}

class _Praktikum08AppState extends State<Praktikum08App> {
  Locale _locale = const Locale('id');

  void _toggleLanguage() {
    setState(() {
      _locale = _locale.languageCode == 'id'
          ? const Locale('en')
          : const Locale('id');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 08 - User & Admin CRUD API',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E40AF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
      ),
      home: HomePage(
        currentLocale: _locale,
        onToggleLanguage: _toggleLanguage,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Locale currentLocale;
  final VoidCallback onToggleLanguage;

  const HomePage({
    super.key,
    required this.currentLocale,
    required this.onToggleLanguage,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<User> _users = [];
  List<Admin> _admins = [];
  bool _isLoadingUsers = true;
  bool _isLoadingAdmins = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadAllData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAllData() async {
    await Future.wait([
      _fetchUsers(),
      _fetchAdmins(),
    ]);
  }

  Future<void> _fetchUsers() async {
    setState(() => _isLoadingUsers = true);
    try {
      final data = await ApiService.getUsers();
      if (mounted) {
        setState(() {
          _users = data;
          _isLoadingUsers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingUsers = false);
        _showSnackBar('Gagal memuat User: $e', isError: true);
      }
    }
  }

  Future<void> _fetchAdmins() async {
    setState(() => _isLoadingAdmins = true);
    try {
      final data = await AdminService.getAdmins();
      if (mounted) {
        setState(() {
          _admins = data;
          _isLoadingAdmins = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingAdmins = false);
        _showSnackBar('Gagal memuat Admin: $e', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==================== OPERASI USER ====================

  // GET Detail User by ID
  Future<void> _showUserDetailById(int id) async {
    final l10n = AppLocalizations.of(context);
    try {
      final user = await ApiService.getUser(id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.person, color: Color(0xFF1E40AF)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n?.detailTitle ?? "Detail User"} (ID: ${user.id})',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('ID User', '${user.id}'),
              const Divider(),
              _detailRow('Nama / Name', user.name),
              const Divider(),
              _detailRow(l10n?.email ?? 'Email', user.email),
              const Divider(),
              _detailRow(l10n?.city ?? 'City', user.city),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('$e', isError: true);
    }
  }

  // POST: Tambah User baru berdasarkan ID NIM (1499 + 281 = 1780)
  void _showAddUserDialog() {
    final nameController = TextEditingController(text: 'Muhammad Ali Akbar');
    final emailController = TextEditingController(
      text: 'aliidrus3142@gmail.com',
    );
    final cityController = TextEditingController(text: 'Jakarta');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('POST: Tambah User Baru (ID NIM)'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'NIM: 20240801218 | N = 281\nRumus ID User: 1499 + 281 = 1780',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Kota (City)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final city = cityController.text.trim();
              if (name.isEmpty || email.isEmpty) {
                _showSnackBar('Nama dan Email wajib diisi!', isError: true);
                return;
              }
              Navigator.pop(context);
              final newUser = await ApiService.createUser(
                name,
                email,
                city: city.isEmpty ? 'Jakarta' : city,
              );
              await _fetchUsers();
              _showSnackBar(
                'POST Berhasil: User "${newUser.name}" ditambahkan dengan ID ${newUser.id}',
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Simpan (POST)'),
          ),
        ],
      ),
    );
  }

  // PUT: Memperbarui nama dan email User
  void _showPutUserDialog(User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final cityController = TextEditingController(text: user.city);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('PUT: Edit User (ID: ${user.id})'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama User',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email User',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: cityController,
                decoration: const InputDecoration(
                  labelText: 'Kota (City)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final email = emailController.text.trim();
              final city = cityController.text.trim();
              if (name.isEmpty || email.isEmpty) {
                _showSnackBar(
                  'Nama dan Email tidak boleh kosong!',
                  isError: true,
                );
                return;
              }
              Navigator.pop(context);
              final updated = await ApiService.updateUser(
                user.id,
                name,
                email,
                city: city,
              );
              await _fetchUsers();
              _showSnackBar(
                'PUT Berhasil: User ID ${updated.id} diperbarui menjadi "${updated.name}"',
              );
            },
            child: const Text('Update (PUT)'),
          ),
        ],
      ),
    );
  }

  // PATCH: Memperbarui nama User dengan menambahkan "- Flutter Developer"
  Future<void> _handlePatchUser(User user) async {
    try {
      final patched = await ApiService.patchUser(user.id);
      await _fetchUsers();
      _showSnackBar(
        'PATCH Berhasil: Nama diubah menjadi "${patched.name}"',
      );
    } catch (e) {
      _showSnackBar('Gagal PATCH: $e', isError: true);
    }
  }

  // DELETE: Menghapus User berdasarkan ID
  Future<void> _confirmDeleteUser(User user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('DELETE User'),
        content: Text(
          'Apakah Anda yakin ingin menghapus User "${user.name}" (ID: ${user.id})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus (DELETE)'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await ApiService.deleteUser(user.id);
      if (success) {
        await _fetchUsers();
        _showSnackBar('DELETE Berhasil: User ID ${user.id} telah dihapus');
      } else {
        _showSnackBar('User ID ${user.id} tidak ditemukan', isError: true);
      }
    }
  }

  // ==================== OPERASI ADMIN ====================

  // GET Detail Admin by ID
  Future<void> _showAdminDetailById(int id) async {
    final l10n = AppLocalizations.of(context);
    try {
      final admin = await AdminService.getAdmin(id);
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.admin_panel_settings, color: Color(0xFF0F766E)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${l10n?.adminDetailTitle ?? "Detail Admin"} (ID: ${admin.id})',
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detailRow('ID Admin (792 + N)', '${admin.id}'),
              const Divider(),
              _detailRow('Nama Admin', admin.name),
              const Divider(),
              _detailRow(l10n?.email ?? 'Email', admin.email),
              const Divider(),
              _detailRow(l10n?.department ?? 'Department', admin.department),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      _showSnackBar('$e', isError: true);
    }
  }

  // DELETE Admin berdasarkan ID
  Future<void> _confirmDeleteAdmin(int id, {String? adminName}) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Data Admin'),
        content: Text(
          adminName != null
              ? 'Yakin ingin menghapus Admin "$adminName" dengan ID $id?'
              : 'Yakin ingin menghapus Admin dengan ID $id?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus Admin'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final deleted = await AdminService.deleteAdmin(id);
      if (deleted) {
        await _fetchAdmins();
        _showSnackBar('DELETE Admin Berhasil: Admin ID $id telah dihapus');
      } else {
        _showSnackBar(
          'Gagal menghapus: Admin dengan ID $id tidak ditemukan',
          isError: true,
        );
      }
    }
  }

  // Dialog Cari Detail / Hapus Berdasarkan Input ID
  void _showLookupByIdDialog({required bool isAdmin, bool isDelete = false}) {
    final defaultId = isAdmin
        ? '${AdminService.nimAdminId}'
        : '${ApiService.nimUserId}';
    final idController = TextEditingController(text: defaultId);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          isDelete
              ? 'Hapus Admin Berdasarkan ID'
              : 'Cari Detail ${isAdmin ? "Admin" : "User"} Berdasarkan ID',
        ),
        content: TextField(
          controller: idController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Masukkan ID ${isAdmin ? "Admin" : "User"}',
            helperText: isAdmin
                ? 'Contoh ID Admin NIM (792 + 281): 1073'
                : 'Contoh ID User NIM (1499 + 281): 1780 atau 1..5',
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: isDelete
                ? ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade600,
                    foregroundColor: Colors.white,
                  )
                : null,
            onPressed: () {
              final id = int.tryParse(idController.text.trim());
              if (id == null) {
                _showSnackBar('Masukkan angka ID yang valid!', isError: true);
                return;
              }
              Navigator.pop(context);
              if (isAdmin) {
                if (isDelete) {
                  _confirmDeleteAdmin(id);
                } else {
                  _showAdminDetailById(id);
                }
              } else {
                _showUserDetailById(id);
              }
            },
            child: Text(isDelete ? 'Hapus Admin' : 'Lihat Detail'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BUILD UI ====================

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: Text(
          l10n?.appTitle ?? 'Direktori Mahasiswa & Admin',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        actions: [
          TextButton.icon(
            onPressed: widget.onToggleLanguage,
            icon: const Icon(Icons.language, color: Colors.amberAccent, size: 18),
            label: Text(
              widget.currentLocale.languageCode.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Refresh Data (GET)',
            onPressed: _loadAllData,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Reset Data ke Default',
            onPressed: () async {
              await ApiService.resetToDefault();
              await AdminService.resetToDefault();
              await _loadAllData();
              _showSnackBar('Data User dan Admin berhasil di-reset ke awal');
            },
            icon: const Icon(Icons.restore),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
              icon: const Icon(Icons.people),
              text: '${l10n?.usersTab ?? "Daftar User"} (${_users.length})',
            ),
            Tab(
              icon: const Icon(Icons.admin_panel_settings),
              text: '${l10n?.adminsTab ?? "Daftar Admin"} (${_admins.length})',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildNimHeaderCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUserTab(l10n),
                _buildAdminTab(l10n),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddUserDialog,
              backgroundColor: const Color(0xFF1E40AF),
              foregroundColor: Colors.white,
              icon: const Icon(Icons.person_add),
              label: const Text('POST User (ID 1780)'),
            )
          : FloatingActionButton.extended(
              onPressed: () =>
                  _showLookupByIdDialog(isAdmin: true, isDelete: true),
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.delete_forever),
              label: Text(l10n?.deleteAdmin ?? 'Hapus Admin by ID'),
            ),
    );
  }

  Widget _buildNimHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge, color: Colors.amberAccent, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Muhammad Ali Akbar — NIM: 20240801218',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _infoBadge('3 Digit Akhir: 218 → Geser Tengah: N = 281'),
              _infoBadge('ID User (1499 + 281) = 1780'),
              _infoBadge('ID Admin (792 + 281) = 1073'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ==================== TAB 1: USER ====================

  Widget _buildUserTab(AppLocalizations? l10n) {
    if (_isLoadingUsers) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showLookupByIdDialog(isAdmin: false),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('GET Detail User by ID'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showAddUserDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('POST User NIM'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _users.isEmpty
              ? Center(child: Text(l10n?.noData ?? 'Tidak ada data User'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    final isNimUser = user.id >= ApiService.nimUserId;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isNimUser
                            ? const BorderSide(
                                color: Color(0xFF2563EB),
                                width: 1.5,
                              )
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showUserDetailById(user.id),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isNimUser
                                        ? const Color(0xFF1E40AF)
                                        : Colors.blueGrey.shade700,
                                    foregroundColor: Colors.white,
                                    child: Text(
                                      '${user.id}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${user.email} • ${l10n?.city ?? "Kota"}: ${user.city}',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _actionChip(
                                    icon: Icons.visibility,
                                    label: 'GET Detail',
                                    color: Colors.blue.shade700,
                                    onTap: () => _showUserDetailById(user.id),
                                  ),
                                  _actionChip(
                                    icon: Icons.edit,
                                    label: 'PUT (Edit)',
                                    color: Colors.orange.shade800,
                                    onTap: () => _showPutUserDialog(user),
                                  ),
                                  _actionChip(
                                    icon: Icons.auto_fix_high,
                                    label: 'PATCH (- Flutter Developer)',
                                    color: Colors.purple.shade700,
                                    onTap: () => _handlePatchUser(user),
                                  ),
                                  _actionChip(
                                    icon: Icons.delete,
                                    label: 'DELETE',
                                    color: Colors.red.shade700,
                                    onTap: () => _confirmDeleteUser(user),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // ==================== TAB 2: ADMIN ====================

  Widget _buildAdminTab(AppLocalizations? l10n) {
    if (_isLoadingAdmins) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _showLookupByIdDialog(isAdmin: true, isDelete: false),
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('GET Admin by ID'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      _showLookupByIdDialog(isAdmin: true, isDelete: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade700,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('DELETE Admin by ID'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _admins.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n?.noAdminData ??
                            'Seluruh data Admin telah dihapus.',
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await AdminService.resetToDefault();
                          await _fetchAdmins();
                        },
                        icon: const Icon(Icons.restore),
                        label: const Text('Pulihkan Data Admin Default'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 80),
                  itemCount: _admins.length,
                  itemBuilder: (context, index) {
                    final admin = _admins[index];
                    final isPrimaryNimAdmin =
                        admin.id == AdminService.nimAdminId;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: isPrimaryNimAdmin
                            ? const BorderSide(
                                color: Color(0xFF0F766E),
                                width: 1.5,
                              )
                            : BorderSide.none,
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _showAdminDetailById(admin.id),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: const Color(0xFF0F766E),
                                    foregroundColor: Colors.white,
                                    child: Text(
                                      '${admin.id}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                admin.name,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            if (isPrimaryNimAdmin)
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 2,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.teal.shade50,
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                  border: Border.all(
                                                    color: Colors.teal.shade300,
                                                  ),
                                                ),
                                                child: const Text(
                                                  '792 + N',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF0F766E),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          admin.email,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${l10n?.department ?? "Department"}: ${admin.department}',
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF0F766E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  _actionChip(
                                    icon: Icons.info_outline,
                                    label: 'GET Detail (ID: ${admin.id})',
                                    color: const Color(0xFF0F766E),
                                    onTap: () => _showAdminDetailById(admin.id),
                                  ),
                                  const SizedBox(width: 8),
                                  _actionChip(
                                    icon: Icons.delete_forever,
                                    label: l10n?.deleteAdmin ?? 'DELETE Admin',
                                    color: Colors.red.shade700,
                                    onTap: () => _confirmDeleteAdmin(
                                      admin.id,
                                      adminName: admin.name,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _actionChip({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
