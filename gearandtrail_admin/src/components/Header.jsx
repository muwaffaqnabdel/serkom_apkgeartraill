import React from 'react';

export default function Header({ title, subtitle, onLogout, adminUser }) {
  const name = adminUser?.name || 'Administrator';
  const email = adminUser?.email || 'admin@geartrail.com';

  return (
    <header style={{
      padding: '20px 32px',
      backgroundColor: '#FFFFFF',
      borderBottom: '1px solid #E8E2D8',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'space-between',
      boxShadow: '0 2px 8px rgba(74, 44, 42, 0.03)'
    }}>
      <div>
        <h1 style={{
          fontFamily: "'Playfair Display', Georgia, serif",
          fontSize: '1.6rem',
          color: '#4A2C2A',
          marginBottom: '2px'
        }}>
          {title}
        </h1>
        <p style={{ fontSize: '0.88rem', color: '#7A6B63' }}>
          {subtitle}
        </p>
      </div>

      <div style={{ display: 'flex', alignItems: 'center', gap: '16px' }}>
        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '10px',
          padding: '6px 14px',
          backgroundColor: '#FAF8F5',
          border: '1px solid #E8E2D8',
          borderRadius: '999px'
        }}>
          <div style={{
            width: '10px',
            height: '10px',
            borderRadius: '50%',
            backgroundColor: '#10B981'
          }} />
          <span style={{ fontSize: '0.82rem', fontWeight: 600, color: '#4A2C2A' }}>
            Server Online
          </span>
        </div>

        <div style={{
          display: 'flex',
          alignItems: 'center',
          gap: '12px',
          paddingLeft: '16px',
          borderLeft: '1px solid #E8E2D8'
        }}>
          <div style={{
            width: '38px',
            height: '38px',
            borderRadius: '50%',
            backgroundColor: '#1E3A2F',
            color: '#FFFFFF',
            fontWeight: 700,
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            fontSize: '1rem'
          }}>
            {name.charAt(0).toUpperCase()}
          </div>
          <div>
            <div style={{ fontSize: '0.9rem', fontWeight: 700, color: '#2C1810' }}>
              {name}
            </div>
            <div style={{ fontSize: '0.75rem', color: '#7A6B63' }}>
              {email}
            </div>
          </div>
          {onLogout && (
            <button
              onClick={onLogout}
              title="Keluar Admin"
              style={{
                marginLeft: '8px',
                padding: '6px 10px',
                backgroundColor: '#FEF2F2',
                border: '1px solid #FCA5A5',
                borderRadius: '8px',
                color: '#DC2626',
                cursor: 'pointer',
                fontSize: '0.8rem',
                fontWeight: 600
              }}
            >
              Logout
            </button>
          )}
        </div>
      </div>
    </header>
  );
}
