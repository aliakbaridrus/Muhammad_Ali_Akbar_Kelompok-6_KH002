# Laporan Hasil Praktikum 08 — Pengelolaan Data User & Admin (REST API / Local JSON Service)

**Nama:** Muhammad Ali Akbar  
**NIM:** 20240801218  
**Program Studi:** Teknik Informatika  

---

## 1. Perhitungan Ketentuan Angka Berdasarkan NIM

Berdasarkan ketentuan praktikum:
- **NIM:** `20240801218`
- **Tiga digit terakhir NIM:** `218`
- **Nilai $N$ (angka tengah `1` digeser ke belakang):** `281`
- **Rumus ID User:** $1499 + N = 1499 + 281 = \mathbf{1780}$
- **Rumus ID Admin:** $792 + N = 792 + 281 = \mathbf{1073}$

---

## 2. Struktur File Model, Service, dan Lokalisasi yang Dibuat

Struktur proyek Flutter `praktikum-08` disusun mengikuti struktur `belajar_api` lengkap dengan lokalisasi (`l10n`), pemisahan Model (`user_model.dart` & `admin.dart`), dan Service (`api_service.dart` & `admin_service.dart`):

```text
praktikum-08/
├── android/
├── ios/
├── web/
├── windows/
├── linux/
├── macos/
├── l10n.yaml
├── pubspec.yaml
└── lib/
    ├── main.dart                     # Tampilan utama (Tab Daftar User & Daftar Admin + Lokalisasi ID/EN)
    ├── l10n/
    │   ├── app_en.arb                # File kamus bahasa Inggris
    │   ├── app_id.arb                # File kamus bahasa Indonesia
    │   ├── app_localizations.dart    # Kelas lokalisasi utama hasil generate
    │   ├── app_localizations_en.dart # Implementasi lokalisasi bahasa Inggris
    │   └── app_localizations_id.dart # Implementasi lokalisasi bahasa Indonesia
    ├── models/
    │   ├── user_model.dart           # Model User (id, name, email, city)
    │   └── admin.dart                # Model Admin (id, name, email, department)
    └── services/
        ├── api_service.dart          # Service CRUD untuk User (GET, POST, PUT, PATCH, DELETE)
        └── admin_service.dart        # Service untuk Admin (getAdmins, getAdmin, deleteAdmin)
```

---

## 3. Implementasi Model User dan Model Admin

1. **Model `User` (`lib/models/user_model.dart`)**
   - Properti: `id` (`int`), `name` (`String`), `email` (`String`), dan `city` (`String`).
   - Memiliki factory constructor `User.fromJson(Map<String, dynamic> json)` yang mengambil nilai `city` dari objek `json['address']['city']` atau langsung dari `json['city']`.

2. **Model `Admin` (`lib/models/admin.dart`)**
   - Properti: `id` (`int`), `name` (`String`), `email` (`String`), dan `department` (`String`).
   - Memiliki factory constructor `Admin.fromJson(Map<String, dynamic> json)` untuk mengonversi data JSON menjadi objek `Admin`.

---

## 4. Proses Pengambilan Data Menggunakan GET

- **`ApiService.getUsers()`**: Mengambil seluruh daftar `User` dan mengubahnya menjadi `List<User>` melalui `User.fromJson()`.
- **`ApiService.getUser(int id)`**: Mengambil detail satu `User` berdasarkan parameter `id`.
- **`AdminService.getAdmins()`**: Mengambil seluruh daftar `Admin` (dimulai dari ID `1073` sesuai rumus $792 + 281$) dan mengonversinya menjadi `List<Admin>` melalui `Admin.fromJson()`.
- **`AdminService.getAdmin(int id)`**: Mengambil satu data `Admin` berdasarkan parameter `id` (contoh: `1073`).

---

## 5. Proses Penambahan, Perubahan, dan Penghapusan Data User

1. **POST (`ApiService.createUser`)**: Menambahkan `User` baru berdasarkan ID dari NIM ($1499 + 281 = \mathbf{1780}$).
2. **PUT (`ApiService.updateUser`)**: Memperbarui nama dan email `User` berdasarkan ID.
3. **PATCH (`ApiService.patchUser`)**: Memperbarui nama `User` dengan menambahkan teks **` - Flutter Developer`**.
4. **DELETE (`ApiService.deleteUser`)**: Menghapus `User` berdasarkan ID.

---

## 6. Proses Penghapusan Data Admin

- **DELETE (`AdminService.deleteAdmin(int id)`)**:
  - Mencari data `Admin` berdasarkan `id` (misalnya `1073`).
  - Menghapus data Admin tersebut dari daftar penyimpanan JSON dan memperbarui tampilan secara langsung.

---

## 7. Tampilan Akhir Aplikasi dan Hasil Pengujian Setiap Fitur

- **Header Identitas NIM**: Menampilkan `Muhammad Ali Akbar — NIM: 20240801218`, `N = 281`, `ID User = 1780`, dan `ID Admin = 1073`.
- **Switch Bahasa (ID / EN)**: Menggunakan `AppLocalizations` (`app_en.arb` & `app_id.arb`) untuk mengganti bahasa antarmuka secara langsung.
- **Tab Daftar User**: Seluruh fitur `GET`, `GET by ID`, `POST (ID 1780)`, `PUT`, `PATCH (- Flutter Developer)`, dan `DELETE` berjalan sesuai fungsinya.
- **Tab Daftar Admin**: Menampilkan daftar Admin dengan ID `1073` ($792 + 281$), fitur `GET Admin by ID`, serta `DELETE Admin by ID` berjalan sesuai fungsinya.
