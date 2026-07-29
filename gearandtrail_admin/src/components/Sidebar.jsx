import React from 'react';

export default function Sidebar({ activeTab, setActiveTab }) {
  const menuItems = [
    { id: 'dashboard', label: 'Dashboard Utama', icon: '📊' },
    { id: 'categories', label: 'Katalog Sepeda', icon: '🏷️' },
    { id: 'products', label: 'Produk MTB & Gear', icon: '🚲' },
    { id: 'orders', label: 'Daftar Pesanan', icon: '🛍️' },
    { id: 'users', label: 'Akun Pengguna', icon: '👥' },
  ];

  return (
    <aside style={{
      width: '260px',
      backgroundColor: '#1E3A2F',
      color: '#F8FAFC',
      display: 'flex',
      flexDirection: 'column',
      padding: '24px 16px',
      boxShadow: '4px 0 16px rgba(0,0,0,0.1)'
    }}>
      {/* Brand Header */}
      <div style={{
        display: 'flex',
        alignItems: 'center',
        gap: '12px',
        paddingBottom: '24px',
        marginBottom: '24px',
        borderBottom: '1px solid rgba(250, 248, 245, 0.15)'
      }}>
        <div style={{
          fontSize: '32px',
          background: '#FAF3E0',
          width: '48px',
          height: '48px',
          borderRadius: '12px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          boxShadow: '0 4px 10px rgba(0,0,0,0.15)'
        }}>
          🚴‍♂️
        </div>
        <div>
          <h2 style={{
            fontFamily: "'Playfair Display', Georgia, serif",
            fontSize: '1.4rem',
            color: '#FFFFFF',
            letterSpacing: '0.5px'
          }}>
            Gear & Trail
          </h2>
          <span style={{
            fontSize: '0.75rem',
            color: '#D4A373',
            fontWeight: 600,
            textTransform: 'uppercase',
            letterSpacing: '1px'
          }}>
            Web Admin Panel
          </span>
        </div>
      </div>

      {/* Nav Menu */}
      <nav style={{ display: 'flex', flexDirection: 'column', gap: '8px', flex: 1 }}>
        {menuItems.map((item) => {
          const isActive = activeTab === item.id;
          return (
            <button
              key={item.id}
              onClick={() => setActiveTab(item.id)}
              style={{
                display: 'flex',
                alignItems: 'center',
                gap: '12px',
                padding: '12px 16px',
                borderRadius: '10px',
                border: 'none',
                backgroundColor: isActive ? '#EA580C' : 'transparent',
                color: isActive ? '#FFFFFF' : '#E8E2D8',
                fontSize: '0.95rem',
                fontWeight: isActive ? 700 : 500,
                cursor: 'pointer',
                textAlign: 'left',
                transition: 'all 0.2s ease'
              }}
            >
              <span style={{ fontSize: '1.2rem' }}>{item.icon}</span>
              <span>{item.label}</span>
            </button>
          );
        })}
      </nav>

      {/* Footer Info */}
      <div style={{
        marginTop: 'auto',
        padding: '16px',
        backgroundColor: 'rgba(0, 0, 0, 0.2)',
        borderRadius: '10px',
        fontSize: '0.8rem',
        color: '#D4A373',
        textAlign: 'center'
      }}>
        <p style={{ fontWeight: 600, marginBottom: '2px' }}>REST API Connected</p>
        <p style={{ fontSize: '0.72rem', color: '#A08C82' }}>http://localhost:5000</p>
      </div>
    </aside>
  );
}
