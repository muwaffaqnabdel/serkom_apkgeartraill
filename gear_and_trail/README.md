# 🍡 LaliOmah - Aplikasi E-Commerce Jajanan Tradisional

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![GetX](https://img.shields.io/badge/State_Management-GetX-8B5CF6?style=for-the-badge)
![Material 3](https://img.shields.io/badge/UI_Design-Material_3-757575?style=for-the-badge)

**LaliOmah** adalah aplikasi *mobile* e-commerce berbasis **Flutter** yang menyajikan pengalaman belanja jajanan pasar tradisional nusantara dengan rasa rumahan yang otentik. Aplikasi ini dirancang menggunakan arsitektur **GetX Pattern** modern, antarmuka UI/UX premium yang hangat, responsif, dan kaya akan detail visual.

---

## 📋 Daftar Isi

- [Fitur Utama](#-fitur-utama)
- [Arsitektur & Struktur Proyek](#-arsitektur--struktur-proyek)
- [Teknologi & Palet Warna](#-teknologi--palet-warna)
- [Alur Rute & Navigasi](#-alur-rute--navigasi)
- [Cara Menjalankan Aplikasi](#-cara-menjalankan-aplikasi)
- [Tangkapan Layar & UI Highlights](#-tangkapan-layar--ui-highlights)

---

## ✨ Fitur Utama

1. **🔐 Halaman Masuk (Auth & Login Module)**
   - Latar belakang krem hangat khas visual otentik (`#F9F6F0`) dengan logo serif Georgia yang elegan.
   - Form input *Email/Username* dan *Password* interaktif dengan skema validasi.
   - Alternatif autentikasi cepat (*"Lanjutkan dengan Google"*).
   - Tautan pendaftaran akun baru & pemulihan kata sandi.

2. **🏠 Halaman Beranda (Home Module)**
   - Header aplikasi dinamis dengan nama brand, menu Drawer, dan ikon keranjang belanja berserta *badge* jumlah item reaktif.
   - Banner promo *Hero* berukuran besar: *"Jajanan Tradisional, Rasa Rumahan"* dilengkapi tombol aksi *"Pesan Sekarang"*.
   - Pintasan kategori pilihan (Kue Basah, Kue Kering, Roti, Camilan).
   - Grid 2-kolom **Rekomendasi Hari Ini** dilengkapi lencana *"Favorit"* dan tombol pintas *"Tambah"* langsung ke keranjang.

3. **🛍️ Halaman Katalog & Filter (Catalog Module)**
   - Filter kategori dinamis berbasis chip interaktif (*Semua*, *Gurih*, *Manis*, *Kukus*, *Kering*, dll.).
   - Grid produk responsif dengan lencana bintang merah melingkar di atas foto produk.
   - Integrasi langsung dengan **Product Detail Bottom Sheet** saat kartu produk diklik.

4. **🔍 Detail Produk (Product Detail Bottom Sheet Widget)**
   - Modal dialog halus (*Bottom Sheet*) menampilkan gambar produk resolusi tinggi & tombol tutup melayang.
   - Informasi detail produk: judul, deskripsi bahan/rasa, dan penetapan harga.
   - Kontrol selector jumlah pesanan (min-plus) reaktif.
   - Tombol *"Tambah ke Keranjang"* yang langsung terintegrasi dengan state global `CartController`.

5. **🛒 Halaman Keranjang & Checkout (Cart Module)**
   - Manajemen item keranjang belanja secara reaktif (tambah, kurangi kuantitas, hapus item).
   - Pendeteksi lokasi/alamat pengiriman pengguna.
   - Formulir Detail Pengiriman (Nama Lengkap, Nomor HP, Alamat Lengkap) dengan skema validasi input.
   - Ringkasan Biaya Dinamis: Kalkulasi Subtotal, Biaya Pengiriman (Ongkir), dan Total Pembayaran secara *real-time*.
   - Dialog konfirmasi pesanan berhasil yang mengosongkan keranjang secara otomatis setelah checkout.

6. **👤 Halaman Profil Pengguna (Profile Module)**
   - Informasi pengguna (Avatar profil, Nama, Email, No. Handphone) dan status peran (*Role*).
   - Pengelolaan Alamat Utama dengan lencana badge *"Rumah Utama"*.
   - Blok Riwayat Pesanan lengkap dengan penanda status pengiriman (*Sedang Dikirim*, *Selesai*) serta aksi *"Lacak Pesanan"* dan *"Beli Lagi"*.
   - Tombol *"Keluar"* untuk mengakhiri sesi autentikasi dan kembali ke halaman login.

---

## 🏗️ Arsitektur & Struktur Proyek

Aplikasi ini menggunakan pola **GetX Pattern** untuk memisahkan logika bisnis, antarmuka pengguna (UI), *bindings*, dan manajemen rute secara bersih (*clean architecture*).

```text
lib/
├── main.dart                      # Titik masuk aplikasi & konfigurasi GetMaterialApp
└── app/
    ├── data/                      # Model data & penyedia data dummy
    │   ├── models/
    │   │   ├── product.dart       # Model objek Produk
    │   │   └── cart_item.dart     # Model objek Item Keranjang Belanja
    │   └── providers/
    │       └── dummy_data.dart    # Mock/dummy dataset jajanan pasar
    │
    ├── modules/                   # Fitur berbasis Modul GetX (Binding, Controller, View)
    │   ├── auth/                  # Modul Autentikasi / Login
    │   │   ├── bindings/
    │   │   ├── controllers/
    │   │   └── views/
    │   ├── main/                  # Modul Utama (Bottom Navigation Bar Wrapper)
    │   │   ├── bindings/
    │   │   ├── controllers/
    │   │   └── views/
    │   ├── home/                  # Modul Beranda (Dashboard utama)
    │   │   └── views/
    │   ├── catalog/               # Modul Katalog Produk & Filter
    │   │   └── views/
    │   ├── cart/                  # Modul Keranjang Belanja & Form Checkout
    │   │   ├── bindings/
    │   │   ├── controllers/
    │   │   └── views/
    │   └── profile/               # Modul Profil Pengguna & Riwayat
    │       └── views/
    │
    ├── routes/                    # Manajemen Rute & Navigasi GetX
    │   ├── app_pages.dart         # Deklarasi GetPage dan dependency bindings
    │   └── app_routes.dart        # Constant rute (/login, /main, /home, dll.)
    │
    ├── theme/                     # Sistem Tema Visual Aplikasi
    │   └── app_theme.dart         # Konfigurasi ThemeData, Tipografi, & Warna (Material 3)
    │
    └── widgets/                   # Komponen Reusable UI
        ├── product_card.dart      # Kartu Tampilan Produk Grid
        └── product_detail_sheet.dart # Modal Sheet Detail Produk
```

---

## 🎨 Teknologi & Palet Warna

### Tech Stack
- **Framework**: Flutter (`>=3.9.2`)
- **Bahasa**: Dart
- **State Management & Routing**: [GetX](https://pub.dev/packages/get) (`^4.6.6`)
- **Design System**: Material 3

### Design System & Palet Warna
- **Tipografi**: Mix Serif (`Georgia` untuk Headings/Judul) dan Sans-Serif modern untuk body text guna menciptakan nuansa otentik, klasik, namun tetap modern.
- **Warna Utama & Aksen**:
  | Elemen | Kode Hex | Deskripsi |
  | :--- | :--- | :--- |
  | **Background Utama** | `#FAF8F5` | Krem sangat muda, memberikan rasa hangat & bersih |
  | **Background Login** | `#F9F6F0` | Krem hangat premium |
  | **Brand / Header** | `#4A2C2A` | Cokelat kayu / Maroon gelap otentik |
  | **Primary Action / Price** | `#B71C1C` / `#6B1512` | Crimson Merah / Merah Gelap untuk tombol aksi & total harga |
  | **Accent Card / Button** | `#FAF3E0` | Kuning gading muda untuk tombol tambah & sorotan |

---

## 🗺️ Alur Rute & Navigasi

| Route Name | Path | Deskripsi |
| :--- | :--- | :--- |
| `Routes.login` | `/login` | Halaman autentikasi awal |
| `Routes.main` | `/main` | Wrapper navigasi utama (Bottom Navigation Bar) |
| `Routes.home` | `/home` | Tab Beranda |
| `Routes.catalog` | `/catalog` | Tab Katalog Produk |
| `Routes.cart` | `/cart` | Tab Keranjang Belanja |
| `Routes.profile` | `/profile` | Tab Profil Pengguna |

---

## 🚀 Cara Menjalankan Aplikasi

### Prasyarat
- **Flutter SDK** telah terinstall di perangkat Anda. Cek menggunakan perintah:
  ```bash
  flutter --version
  ```

### Langkah Jalankan
1. **Clone repository & masuk ke direktori proyek**:
   ```bash
   cd laliomah
   ```

2. **Unduh seluruh dependensi Flutter**:
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**:
   - Menjalankan di browser Google Chrome:
     ```bash
     flutter run -d chrome
     ```
   - Menjalankan di Perangkat Android / iOS / Emulator:
     ```bash
     flutter run
     ```
   - Menjalankan sebagai Web Server (Development Mode):
     ```bash
     flutter run -d web-server --web-port=8080 --web-hostname=127.0.0.1
     ```

4. **Build untuk Rilis Produksi**:
   - Build Web Production Bundle:
     ```bash
     flutter build web
     ```
   - Build APK Android:
     ```bash
     flutter build apk --release
     ```

---

## 📝 Lisensi & Catatan Tambahan

Proyek **LaliOmah** dikembangkan untuk kebutuhan demonstrasi aplikasi e-commerce modern dengan arsitektur Flutter + GetX. Dibuat dengan cinta untuk melestarikan dan memperkenalkan kekayaan kuliner jajanan tradisional Indonesia. 🇮🇩🍡

