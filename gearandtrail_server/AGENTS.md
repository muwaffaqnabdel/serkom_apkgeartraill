# AGENTS.md - Gear & Trail Backend REST API Server

Panduan arsitektur, standar pengkodean, dan instruksi agen untuk **Gear & Trail REST API Server**.

---

## 🚀 Ringkasan Project & Tech Stack

- **Nama Project**: `gearandtrail_server`
- **Tipe**: REST API Service
- **Port Server**: `5000` (`http://localhost:5000/api`)
- **Teknologi Utama**:
  - **Runtime**: Node.js (Express.js Framework)
  - **Database Persistence**: File-based JSON (`data/database.json`)
  - **Middleware**: `cors`, `express.json()`, `express.urlencoded()`

---

## 📁 Struktur Direktori Backend Server

```text
gearandtrail_server/
├── data/
│   └── database.json          # Database JSON utama (categories, products, orders, users)
├── node_modules/
├── index.js                   # Entry point Express.js server & seluruh API routes
├── package.json               # Konfigurasi package & dependencies
└── AGENTS.md                  # Dokumentasi & aturan agen AI
```

---

## 📡 Rincian API Endpoints & Respons Standard

Seluruh respons API menggunakan format JSON standar:
```json
{
  "success": true,
  "message": "Pesan status",
  "data": []
}
```

### 1. Health Check
- `GET /api/health` ➔ Memeriksa status kesehatan server.

### 2. Autentikasi & Pengguna (`/api/auth`)
- `POST /api/auth/login` ➔ Otentikasi pengguna berdasarkan email/username & password.
- `POST /api/auth/register` ➔ Pendaftaran akun baru dan langsung disimpan ke `database.json`.
- `GET /api/auth/profile` ➔ Mengambil profil pengguna secara dinamis.
- `GET /api/auth/users` ➔ Mengambil daftar seluruh pengguna terdaftar.

### 3. Produk & Kategori (`/api/products` & `/api/categories`)
- `GET /api/products` ➔ Mengambil produk (dukungan query: `category`, `search`, `isFavorite`).
- `GET /api/categories` ➔ Mengambil daftar kategori produk sepeda gunung & outdoor gear.

### 4. Transaksi & Pesanan (`/api/orders`)
- `POST /api/orders` ➔ Membuat transaksi pesanan baru.
- `GET /api/orders` ➔ Mengambil seluruh riwayat pesanan.

---

## ⚠️ Aturan & Standar Pengkodean (Rules)

1. **Persistensi Data DB**: Setiap kali ada penambahan data baru (misal `users` atau `orders`), fungsi `writeDb(data)` **wajib dipanggil** agar data tersimpan permanen di `database.json`.
2. **Kesesuaian Port**: Server berjalan di Port `5000`. Jika port sibuk (`EADDRINUSE`), pastikan proses node sebelumnya dihentikan secara bersih.
3. **Penyaringan Data Sensitif**: Saat mengembalikan data user pada respons API login/profile/register, hapus bidang `password` demi keamanan.
