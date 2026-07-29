# 🍡 LaliOmah Backend REST API Server

Server REST API berbasis **Node.js** dan **Express.js** untuk mendukung aplikasi Flutter `laliomah` dan Web Admin `laliomah_ui_admin`.

## 🚀 Fitur Server & REST API Endpoint

1. **Health Check**
   - `GET /api/health` -> Status server & timestamp.

2. **Autentikasi (Auth)**
   - `POST /api/auth/login` -> Autentikasi akun pelanggan/admin.
   - `GET /api/auth/profile` -> Detail data profil pengguna.

3. **Katalog & Produk (Products)**
   - `GET /api/products` -> Ambil seluruh produk jajanan (Dukungan query filter `?category=Kue Basah`, `?search=lemper`, `?isFavorite=true`).
   - `GET /api/products/:id` -> Ambil detail 1 produk.
   - `POST /api/products` -> Tambah jajanan baru.
   - `PUT /api/products/:id` -> Update data jajanan (harga, stok, deskripsi, foto).
   - `DELETE /api/products/:id` -> Hapus jajanan dari katalog.

4. **Kategori (Categories)**
   - `GET /api/categories` -> Daftar kategori (Kue Basah, Kue Kering, Roti, Camilan, Gurih, Manis, Kukus).

5. **Pemesanan & Checkout (Orders)**
   - `GET /api/orders` -> Ambil seluruh pesanan untuk admin.
   - `POST /api/orders` -> Buat pesanan baru dari aplikasi mobile Flutter.
   - `PUT /api/orders/:id/status` -> Ubah status pengiriman (`Diproses`, `Sedang Dikirim`, `Selesai`).

6. **Statistik Admin (Stats)**
   - `GET /api/stats` -> Ringkasan total pendapatan, total transaksi, jumlah produk aktif, dan pesanan terbaru.

## 🛠️ Cara Jalankan Server

```bash
# Instalasi dependensi
npm install

# Jalankan server (port 5000)
npm start

# Atau jalankan dev mode (auto reload)
npm run dev
```

URL API: `http://localhost:5000/api`
