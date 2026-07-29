# 🍡 LaliOmah - Web Admin Dashboard UI

Aplikasi Web Admin Dashboard berbasis **React** dan **Vite** untuk mengelola toko **LaliOmah Jajanan Pasar Tradisional**.

## 🎨 Tampilan & Fitur Utama

- **Theme & Aesthetic**: Dibuat presisi selaras dengan palet warna LaliOmah (`#FAF8F5` Warm Cream, `#4A2C2A` Deep Maroon Wood, `#B71C1C` Crimson Accent).
- **Dashboard Utama**: Menampilkan total pendapatan, total transaksi, statistik menu jajanan favorit, serta daftar pesanan masuk paling baru.
- **Katalog Jajanan (CRUD)**:
  - Pencarian real-time & Filter berdasarkan Kategori.
  - Tambah menu jajanan baru (Nama, Harga, Stok, Foto, Kategori, Badge, Rekomendasi Favorit).
  - Edit & Hapus jajanan.
- **Manajemen Pesanan**:
  - Rincian item pesanan, alamat pengiriman, dan biaya transaksi.
  - Pengubah status pengiriman interaktif (`Diproses` -> `Sedang Dikirim` -> `Selesai`).

## 🚀 Cara Jalankan Web Admin

```bash
# Instalasi dependensi
npm install

# Jalankan server React dev (port 5173)
npm run dev
```

Buka browser di: `http://localhost:5173`
Connects to API: `http://localhost:5000/api`
