import React, { useEffect, useState } from 'react';
import OrderStatusBadge from '../components/OrderStatusBadge';

export default function OrdersPage() {
  const [orders, setOrders] = useState([]);
  const [loading, setLoading] = useState(true);

  const fetchOrders = async () => {
    setLoading(true);
    try {
      const res = await fetch('http://localhost:5000/api/orders');
      const json = await res.json();
      if (json.success) {
        setOrders(json.data);
      }
    } catch (err) {
      console.error('Failed fetching orders:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchOrders();
  }, []);

  const handleUpdateStatus = async (orderId, newStatus) => {
    try {
      const res = await fetch(`http://localhost:5000/api/orders/${orderId}/status`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ status: newStatus })
      });
      const json = await res.json();
      if (json.success) {
        fetchOrders();
      } else {
        alert(json.message);
      }
    } catch (err) {
      alert('Gagal memperbarui status pesanan!');
    }
  };

  const formatRupiah = (num) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num || 0);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      <div className="card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center' }}>
        <div>
          <h3 style={{ fontFamily: "'Playfair Display', serif", fontSize: '1.2rem', color: '#4A2C2A' }}>
            Manajemen Transaksi & Pengiriman
          </h3>
          <p style={{ fontSize: '0.85rem', color: '#7A6B63' }}>
            Kelola dan perbarui status pengiriman untuk pembeli sepeda & peralatan Gear & Trail
          </p>
        </div>
        <button className="btn btn-outline" onClick={fetchOrders}>
          🔄 Refresh Pesanan
        </button>
      </div>

      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>ID Pesanan</th>
              <th>Data Pemesan & Alamat</th>
              <th>Detail Item Belanja</th>
              <th>Total Biaya</th>
              <th>Status Pengiriman</th>
              <th style={{ textAlign: 'right' }}>Ubah Status</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '30px', color: '#7A6B63' }}>
                  Memuat daftar pesanan...
                </td>
              </tr>
            ) : orders.length > 0 ? (
              orders.map((o) => (
                <tr key={o.id}>
                  <td style={{ fontWeight: 700, color: '#4A2C2A' }}>
                    {o.id}
                    <div style={{ fontSize: '0.75rem', color: '#7A6B63', fontWeight: 400, marginTop: '4px' }}>
                      {new Date(o.createdAt).toLocaleString('id-ID')}
                    </div>
                  </td>
                  <td>
                    <div style={{ fontWeight: 700, color: '#2C1810' }}>{o.customerName}</div>
                    <div style={{ fontSize: '0.8rem', color: '#B71C1C', fontWeight: 600 }}>📞 {o.customerPhone}</div>
                    <div style={{ fontSize: '0.82rem', color: '#7A6B63', marginTop: '4px', maxWidth: '280px', lineHeight: 1.4 }}>
                      📍 {o.shippingAddress}
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', flexDirection: 'column', gap: '4px' }}>
                      {o.items?.map((item, idx) => (
                        <div key={idx} style={{ fontSize: '0.85rem' }}>
                          <span style={{ fontWeight: 600 }}>{item.productName}</span> x{item.quantity} 
                          <span style={{ color: '#7A6B63', fontSize: '0.78rem' }}> ({formatRupiah(item.totalPrice)})</span>
                        </div>
                      ))}
                    </div>
                  </td>
                  <td>
                    <div style={{ fontSize: '0.78rem', color: '#7A6B63' }}>
                      Subtotal: {formatRupiah(o.subtotal)}
                    </div>
                    <div style={{ fontSize: '0.78rem', color: '#7A6B63' }}>
                      Ongkir: {formatRupiah(o.shippingFee)}
                    </div>
                    <div style={{ fontWeight: 800, color: '#B71C1C', fontSize: '1rem', marginTop: '2px' }}>
                      {formatRupiah(o.totalAmount)}
                    </div>
                  </td>
                  <td>
                    <OrderStatusBadge status={o.status} />
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <select
                      className="form-select"
                      style={{ width: '150px', fontSize: '0.82rem', padding: '6px 10px' }}
                      value={o.status}
                      onChange={(e) => handleUpdateStatus(o.id, e.target.value)}
                    >
                      <option value="Diproses">Diproses</option>
                      <option value="Sedang Dikirim">Sedang Dikirim</option>
                      <option value="Selesai">Selesai</option>
                    </select>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center', padding: '30px', color: '#7A6B63' }}>
                  Belum ada pesanan terdaftar.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
