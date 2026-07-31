import React, { useState } from 'react';

export default function AdminLoginPage({ onLoginSuccess }) {
  const [email, setEmail] = useState('admin@geartrail.com');
  const [password, setPassword] = useState('admin123');
  const [showPassword, setShowPassword] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = (e) => {
    e.preventDefault();
    setErrorMsg('');

    if (!email.trim() || !password.trim()) {
      setErrorMsg('Email dan password wajib diisi.');
      return;
    }

    setIsLoading(true);

    // Simulasi & Verifikasi Login Admin
    setTimeout(() => {
      if ((email.trim() === 'admin@geartrail.com' || email.trim() === 'admin') && password === 'admin123') {
        const adminData = {
          name: 'Administrator Utama',
          email: 'admin@geartrail.com',
          role: 'Super Admin',
          loginTime: new Date().toISOString()
        };
        localStorage.setItem('isAdminLoggedIn', 'true');
        localStorage.setItem('adminUser', JSON.stringify(adminData));
        setIsLoading(false);
        onLoginSuccess(adminData);
      } else {
        setIsLoading(false);
        setErrorMsg('Email atau password admin salah. Coba: admin@geartrail.com / admin123');
      }
    }, 600);
  };

  return (
    <div style={{
      minHeight: '100vh',
      width: '100vw',
      backgroundColor: '#1E3A2F',
      backgroundImage: 'radial-gradient(circle at 80% 20%, rgba(234, 88, 12, 0.15) 0%, transparent 40%), radial-gradient(circle at 20% 80%, rgba(4, 120, 87, 0.25) 0%, transparent 50%)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      padding: '20px',
      fontFamily: "'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif"
    }}>
      <div style={{
        width: '100%',
        maxWidth: '440px',
        backgroundColor: 'rgba(255, 255, 255, 0.98)',
        borderRadius: '24px',
        padding: '40px 32px',
        boxShadow: '0 20px 50px rgba(0, 0, 0, 0.3)',
        border: '1px solid rgba(255, 255, 255, 0.2)'
      }}>
        {/* Brand Header */}
        <div style={{ textAlign: 'center', marginBottom: '28px' }}>
          <img
            src="/logo.png"
            alt="Gear & Trail Logo"
            style={{
              height: '120px',
              maxWidth: '100%',
              objectFit: 'contain',
              margin: '0 auto 16px',
              display: 'block',
              filter: 'drop-shadow(0 6px 16px rgba(0,0,0,0.12))'
            }}
          />
          <h1 style={{
            fontSize: '1.6rem',
            fontWeight: 800,
            color: '#1E3A2F',
            marginBottom: '4px',
            letterSpacing: '-0.5px'
          }}>
            Gear & Trail Admin
          </h1>
          <p style={{ fontSize: '0.88rem', color: '#64748B' }}>
            Portal Manajemen Toko & Katalog Sepeda
          </p>
        </div>

        {/* Error Notification Alert */}
        {errorMsg && (
          <div style={{
            backgroundColor: '#FEF2F2',
            border: '1px solid #FCA5A5',
            color: '#991B1B',
            padding: '12px 16px',
            borderRadius: '12px',
            fontSize: '0.85rem',
            marginBottom: '20px',
            display: 'flex',
            alignItems: 'center',
            gap: '10px'
          }}>
            <span>⚠️</span>
            <span>{errorMsg}</span>
          </div>
        )}

        {/* Form */}
        <form onSubmit={handleLogin} style={{ display: 'flex', flexDirection: 'column', gap: '18px' }}>
          <div>
            <label style={{
              display: 'block',
              fontSize: '0.82rem',
              fontWeight: 700,
              color: '#334155',
              marginBottom: '6px',
              textTransform: 'uppercase',
              letterSpacing: '0.5px'
            }}>
              Email Admin / Username
            </label>
            <input
              type="text"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              placeholder="Masukkan email admin"
              style={{
                width: '100%',
                padding: '14px 16px',
                borderRadius: '12px',
                border: '1.5px solid #CBD5E1',
                fontSize: '0.95rem',
                outline: 'none',
                transition: 'border-color 0.2s',
                boxSizing: 'border-box'
              }}
              onFocus={(e) => e.target.style.borderColor = '#1E3A2F'}
              onBlur={(e) => e.target.style.borderColor = '#CBD5E1'}
            />
          </div>

          <div>
            <label style={{
              display: 'block',
              fontSize: '0.82rem',
              fontWeight: 700,
              color: '#334155',
              marginBottom: '6px',
              textTransform: 'uppercase',
              letterSpacing: '0.5px'
            }}>
              Password
            </label>
            <div style={{ position: 'relative' }}>
              <input
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Masukkan password admin"
                style={{
                  width: '100%',
                  padding: '14px 44px 14px 16px',
                  borderRadius: '12px',
                  border: '1.5px solid #CBD5E1',
                  fontSize: '0.95rem',
                  outline: 'none',
                  boxSizing: 'border-box'
                }}
                onFocus={(e) => e.target.style.borderColor = '#1E3A2F'}
                onBlur={(e) => e.target.style.borderColor = '#CBD5E1'}
              />
              <button
                type="button"
                onClick={() => setShowPassword(!showPassword)}
                title={showPassword ? "Sembunyikan password" : "Tampilkan password"}
                style={{
                  position: 'absolute',
                  right: '12px',
                  top: '50%',
                  transform: 'translateY(-50%)',
                  background: 'none',
                  border: 'none',
                  cursor: 'pointer',
                  padding: '4px',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: '#64748B',
                  transition: 'color 0.2s'
                }}
              >
                {showPassword ? (
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19m-6.72-1.07a3 3 0 1 1-4.24-4.24"></path>
                    <line x1="1" y1="1" x2="23" y2="23"></line>
                  </svg>
                ) : (
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                    <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"></path>
                    <circle cx="12" cy="12" r="3"></circle>
                  </svg>
                )}
              </button>
            </div>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            style={{
              marginTop: '10px',
              padding: '16px',
              backgroundColor: '#1E3A2F',
              color: '#FFFFFF',
              border: 'none',
              borderRadius: '12px',
              fontSize: '1rem',
              fontWeight: 700,
              cursor: isLoading ? 'wait' : 'pointer',
              boxShadow: '0 4px 14px rgba(30, 58, 47, 0.3)',
              transition: 'background-color 0.2s',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '8px'
            }}
          >
            {isLoading ? (
              <span>Memverifikasi Admin...</span>
            ) : (
              <>
                <span>Masuk ke Web Admin</span>
                <span>➔</span>
              </>
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
