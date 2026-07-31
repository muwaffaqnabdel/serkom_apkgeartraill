import React from 'react';

export default function Sidebar({ activeTab, setActiveTab, onLogout }) {
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
        paddingBottom: '20px',
        marginBottom: '24px',
        borderBottom: '1px solid rgba(250, 248, 245, 0.15)'
      }}>
        <img
          src="/logo.png"
          alt="Gear & Trail Logo"
          style={{
            height: '48px',
            width: '48px',
            objectFit: 'contain'
          }}
        />
        <div>
          <h2 style={{
            fontFamily: "'Playfair Display', Georgia, serif",
            fontSize: '1.3rem',
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

      {/* Footer Info & Logout Button */}
      <div style={{ marginTop: 'auto', display: 'flex', flexDirection: 'column', gap: '10px' }}>
        {onLogout && (
          <button
            onClick={onLogout}
            style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px',
              padding: '10px 16px',
              borderRadius: '10px',
              border: '1px solid rgba(220, 38, 38, 0.4)',
              backgroundColor: 'rgba(220, 38, 38, 0.15)',
              color: '#FCA5A5',
              fontSize: '0.88rem',
              fontWeight: 600,
              cursor: 'pointer',
              transition: 'all 0.2s ease'
            }}
          >
            <span>🚪</span>
            <span>Keluar Admin</span>
          </button>
        )}
        <div style={{
          padding: '12px',
          backgroundColor: 'rgba(0, 0, 0, 0.2)',
          borderRadius: '10px',
          fontSize: '0.8rem',
          color: '#D4A373',
          textAlign: 'center'
        }}>
          <p style={{ fontWeight: 600, marginBottom: '2px' }}>REST API Connected</p>
          <p style={{ fontSize: '0.72rem', color: '#A08C82' }}>http://localhost:5000</p>
        </div>
      </div>
    </aside>
  );
}
