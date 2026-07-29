# AGENTS.md - Gear & Trail Flutter Mobile & Web Application

Panduan arsitektur, skema warna, standar pengkodean, dan instruksi agen untuk **Gear & Trail Mobile App**.

---

## 🎨 Design System & Visual Palette (Forest Trail & Alpine Amber)

Seluruh widget dan tampilan aplikasi **wajib mengikuti tokens warna resmi** yang terdefinisi pada [app_theme.dart](file:///d:/S6/GEAR&TRAIL/gear_and_trail/lib/app/theme/app_theme.dart):

- **Primary Color (`#1E3A2F`)**: *Deep Pine Green* (Warna utama login, header `AppBar`, icon brand, dan tombol utama).
- **Secondary / Accent (`#EA580C`)**: *Trail Amber Orange* (Aksen tombol belanja, badge favorit, harga produk, dan link navigasi).
- **Scaffold Background (`#F8FAFC`)**: *Clean Light Slate* (Background utama seluruh halaman).
- **Surface / Card (`#FFFFFF`)**: Warna putih bersih dengan border slate halus (`#E2E8F0`) dan sudut membulat 16px.
- **Text Primary (`#0F172A`)**: Slate Charcoal untuk judul dan teks utama.
- **Text Muted (`#64748B`)**: Slate Gray untuk sub-deskripsi dan placeholder.

---

## 📁 Struktur Arsitektur Codebase (GetX Pattern)

```text
gear_and_trail/
├── lib/
│   ├── app/
│   │   ├── data/
│   │   │   ├── models/          # Product, CartItem, Order, User models
│   │   │   └── providers/       # ProductProvider (REST API) & LocalStorageService (GetStorage)
│   │   ├── modules/             # Modul Fitur Aplikasi
│   │   │   ├── auth/            # LoginView, RegisterView, AuthController, AuthBinding
│   │   │   ├── cart/            # CartView, CartController, CartBinding
│   │   │   ├── catalog/         # CatalogView, CatalogController
│   │   │   ├── home/            # HomeView, HomeController
│   │   │   ├── main/            # MainView (Bottom Navigation Bar)
│   │   │   └── profile/         # ProfileView, ProfileController
│   │   ├── routes/              # AppPages (GetPage List) & AppRoutes (Named Paths)
│   │   ├── theme/               # AppTheme (ThemeData Material 3)
│   │   └── widgets/             # Reusable UI Widgets (ProductCard, ProductDetailSheet)
│   └── main.dart                # Application entry point & permanent controller initialization
├── pubspec.yaml                 # Package dependencies configuration
└── AGENTS.md                    # AI Agent Guidelines & Architecture Rules
```

---

## 💾 Data Persistence & Offline Mode (Unit 2)

- **Engine Database Lokal**: Menggunakan `GetStorage` dengan instance name `'GearTrailDB'`.
- **Global Service**: `LocalStorageService` diinisialisasi secara permanen di `main.dart`.
- **Aturan Auto-Save**:
  - Keranjang belanja (`cart_items`) tersimpan otomatis setiap kali ada perubahan.
  - Sesi token login (`user_session` & `auth_token`) tersimpan otomatis untuk fitur *auto-login*.
  - Produk favorit (`favorite_product_ids`) tersimpan di memori HP.

---

## ⚠️ Aturan Pengkodean (Rules for Agents)

1. **Bebas Error Analisis**: Setiap kali melakukan modifikasi kode Dart, pastikan perintah `flutter analyze` menghasilkan **`No issues found!`** (0 Error, 0 Warning).
2. **Material 3 Standards**: Gunakan `useMaterial3: true` dengan komponen bertema konsisten.
3. **GetX Dependency Management**:
   - `ProductProvider` & `LocalStorageService` didaftarkan secara permanen di `main.dart`.
   - `AuthController` di-put secara `permanent: true` untuk mencegah exception `AuthController not found` saat navigasi antar layar.
