import React, { useEffect, useState } from 'react';
import OrderStatusBadge from '../components/OrderStatusBadge';

export default function DashboardPage({ setActiveTab }) {
  const [stats, setStats] = useState(null);
  const [loading, setLoading] = useState(true);

  const fetchStats = async () => {
    try {
      const res = await fetch('http://localhost:5000/api/stats');
      const json = await res.json();
      if (json.success) {
        setStats(json.data);
      }
    } catch (err) {
      console.error('Failed fetching stats:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const formatRupiah = (number) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(number || 0);
  };

  if (loading) {
    return (
      <div style={{ padding: '40px', textAlign: 'center', color: '#7A6B63' }}>
        Memuat statistik dashboard...
      </div>
    );
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '28px' }}>
      {/* Stat Cards Grid */}
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: '20px' }}>
        <div className="card" style={{ borderLeft: '4px solid #B71C1C' }}>
          <div style={{ fontSize: '0.85rem', color: '#7A6B63', fontWeight: 600, textTransform: 'uppercase', marginBottom: '8px' }}>
            Total Pendapatan
          </div>
          <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#B71C1C', fontFamily: "'Playfair Display', serif" }}>
            {formatRupiah(stats?.totalRevenue)}
          </div>
          <div style={{ fontSize: '0.75rem', color: '#10B981', marginTop: '6px', fontWeight: 600 }}>
            ↑ Terhitung dari pesanan masuk
          </div>
        </div>

        <div className="card" style={{ borderLeft: '4px solid #4A2C2A' }}>
          <div style={{ fontSize: '0.85rem', color: '#7A6B63', fontWeight: 600, textTransform: 'uppercase', marginBottom: '8px' }}>
            Total Pesanan
          </div>
          <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#4A2C2A', fontFamily: "'Playfair Display', serif" }}>
            {stats?.totalOrders || 0} Trx
          </div>
          <div style={{ fontSize: '0.75rem', color: '#7A6B63', marginTop: '6px' }}>
            Transaksi dari aplikasi Flutter
          </div>
        </div>

        <div className="card" style={{ borderLeft: '4px solid #D4A373' }}>
          <div style={{ fontSize: '0.85rem', color: '#7A6B63', fontWeight: 600, textTransform: 'uppercase', marginBottom: '8px' }}>
            Produk Sepeda Aktif
          </div>
          <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#2C1810', fontFamily: "'Playfair Display', serif" }}>
            {stats?.activeProducts || 0} Produk
          </div>
          <div style={{ fontSize: '0.75rem', color: '#7A6B63', marginTop: '6px' }}>
            {stats?.favoriteProductsCount || 0} Produk Favorit ⭐
          </div>
        </div>

        <div
          className="card"
          onClick={() => setActiveTab('users')}
          style={{
            borderLeft: '4px solid #EA580C',
            cursor: 'pointer',
            transition: 'transform 0.2s ease, box-shadow 0.2s ease'
          }}
        >
          <div style={{ fontSize: '0.85rem', color: '#7A6B63', fontWeight: 600, textTransform: 'uppercase', marginBottom: '8px', display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
            <span>Akun Pengguna</span>
            <span style={{ fontSize: '1.1rem' }}>👥</span>
          </div>
          <div style={{ fontSize: '1.8rem', fontWeight: 800, color: '#EA580C', fontFamily: "'Playfair Display', serif" }}>
            {stats?.totalUsers || 0} Akun
          </div>
          <div style={{ fontSize: '0.75rem', color: '#EA580C', marginTop: '6px', fontWeight: 600 }}>
            Klik untuk kelola / detail →
          </div>
        </div>
      </div>

      {/* Hero Welcome Card */}
      <div className="card" style={{
        background: 'linear-gradient(135deg, #1E3A2F 0%, #0F261D 100%)',
        color: '#FFFFFF',
        position: 'relative',
        overflow: 'hidden',
        padding: '32px'
      }}>
        <div style={{ maxWidth: '600px', position: 'relative', zIndex: 1 }}>
          <h2 style={{ fontFamily: "'Playfair Display', serif", fontSize: '1.8rem', marginBottom: '10px', color: '#FAF3E0' }}>
            Toko Sepeda Gunung & Gear Outdoor 🚴‍♂️
          </h2>
          <p style={{ fontSize: '0.95rem', color: '#E8E2D8', marginBottom: '20px', lineHeight: 1.6 }}>
            Selamat datang di Web Admin Panel Gear & Trail. Anda dapat mengelola katalog sepeda gunung, perlengkapan outdoor, pesanan terkini, dan pengiriman.
          </p>
          <div style={{ display: 'flex', gap: '12px' }}>
            <button className="btn btn-crimson" onClick={() => setActiveTab('products')}>
              + Kelola Produk Sepeda & Gear
            </button>
            <button className="btn btn-outline" style={{ color: '#FFFFFF', borderColor: 'rgba(255,255,255,0.4)' }} onClick={() => setActiveTab('orders')}>
              Lihat Pesanan Masuk
            </button>
          </div>
        </div>
      </div>

      {/* Recent Orders Table */}
      <div className="card">
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '20px' }}>
          <div>
            <h3 style={{ fontFamily: "'Playfair Display', serif", fontSize: '1.3rem', color: '#4A2C2A' }}>
              Pesanan Terbaru Masuk
            </h3>
            <p style={{ fontSize: '0.85rem', color: '#7A6B63' }}>5 transaksi paling akhir dari aplikasi Gear & Trail</p>
          </div>
          <button className="btn btn-outline" onClick={() => setActiveTab('orders')}>
            Lihat Semua Pesanan →
          </button>
        </div>

        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>ID Pesanan</th>
                <th>Nama Pelanggan</th>
                <th>Item Pesanan</th>
                <th>Total Bayar</th>
                <th>Status Pengiriman</th>
                <th>Waktu</th>
              </tr>
            </thead>
            <tbody>
              {stats?.recentOrders && stats.recentOrders.length > 0 ? (
                stats.recentOrders.map((order) => (
                  <tr key={order.id}>
                    <td style={{ fontWeight: 700, color: '#4A2C2A' }}>{order.id}</td>
                    <td>
                      <div style={{ fontWeight: 600 }}>{order.customerName}</div>
                      <div style={{ fontSize: '0.78rem', color: '#7A6B63' }}>{order.customerPhone}</div>
                    </td>
                    <td>
                      <div style={{ fontSize: '0.85rem' }}>
                        {order.items?.map(i => `${i.productName} (${i.quantity}x)`).join(', ')}
                      </div>
                    </td>
                    <td style={{ fontWeight: 700, color: '#B71C1C' }}>
                      {formatRupiah(order.totalAmount)}
                    </td>
                    <td>
                      <OrderStatusBadge status={order.status} />
                    </td>
                    <td style={{ fontSize: '0.8rem', color: '#7A6B63' }}>
                      {new Date(order.createdAt).toLocaleDateString('id-ID', { hour: '2-digit', minute: '2-digit' })}
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', color: '#7A6B63', padding: '30px' }}>
                    Belum ada data pesanan masuk.
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  );
}
