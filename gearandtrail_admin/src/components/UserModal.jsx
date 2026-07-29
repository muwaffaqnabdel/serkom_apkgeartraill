import React, { useState, useEffect } from 'react';

export default function UserModal({ isOpen, onClose, user, mode = 'view', onSave }) {
  const [formData, setFormData] = useState({
    name: '',
    email: '',
    phone: '',
    role: 'Member Gear & Trail',
    password: ''
  });
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState('');

  useEffect(() => {
    if (user) {
      setFormData({
        name: user.name || '',
        email: user.email || '',
        phone: user.phone || '',
        role: user.role || 'Member Gear & Trail',
        password: ''
      });
    }
    setErrorMsg('');
  }, [user, mode, isOpen]);

  if (!isOpen || !user) return null;

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!formData.name.trim() || !formData.email.trim()) {
      setErrorMsg('Nama dan Email wajib diisi');
      return;
    }

    setLoading(true);
    setErrorMsg('');

    try {
      await onSave(user.id, formData);
      onClose();
    } catch (err) {
      setErrorMsg(err.message || 'Gagal menyimpan perubahan');
    } finally {
      setLoading(false);
    }
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return '-';
    try {
      return new Date(dateStr).toLocaleString('id-ID', {
        day: 'numeric',
        month: 'long',
        year: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      });
    } catch {
      return dateStr;
    }
  };

  return (
    <div style={{
      position: 'fixed',
      top: 0,
      left: 0,
      right: 0,
      bottom: 0,
      backgroundColor: 'rgba(15, 38, 29, 0.65)',
      backdropFilter: 'blur(4px)',
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      zIndex: 1000,
      padding: '20px'
    }}>
      <div style={{
        backgroundColor: '#FFFFFF',
        borderRadius: '16px',
        width: '100%',
        maxWidth: '520px',
        boxShadow: '0 20px 40px rgba(0,0,0,0.2)',
        overflow: 'hidden',
        animation: 'modalSlide 0.25s ease-out'
      }}>
        {/* Header */}
        <div style={{
          backgroundColor: '#1E3A2F',
          color: '#FFFFFF',
          padding: '20px 24px',
          display: 'flex',
          justify: 'space-between',
          alignItems: 'center'
        }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
            <div style={{
              width: '40px',
              height: '40px',
              borderRadius: '50%',
              backgroundColor: '#EA580C',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              fontSize: '18px',
              color: '#FFFFFF',
              fontWeight: 700
            }}>
              {user.name ? user.name.charAt(0).toUpperCase() : '👤'}
            </div>
            <div>
              <h3 style={{ fontFamily: "'Playfair Display', Georgia, serif", fontSize: '1.25rem', margin: 0, color: '#FAF3E0' }}>
                {mode === 'view' ? 'Rincian Akun Pengguna' : 'Edit Profil Pengguna'}
              </h3>
              <p style={{ fontSize: '0.78rem', color: '#D4A373', margin: 0 }}>ID: {user.id}</p>
            </div>
          </div>
          <button
            onClick={onClose}
            style={{
              background: 'none',
              border: 'none',
              color: '#E8E2D8',
              fontSize: '1.5rem',
              cursor: 'pointer',
              lineHeight: 1
            }}
          >
            &times;
          </button>
        </div>

        {/* Content Body */}
        <div style={{ padding: '24px' }}>
          {errorMsg && (
            <div style={{
              backgroundColor: '#FEE2E2',
              color: '#991B1B',
              padding: '12px 16px',
              borderRadius: '8px',
              fontSize: '0.85rem',
              marginBottom: '16px',
              borderLeft: '4px solid #B71C1C'
            }}>
              ⚠️ {errorMsg}
            </div>
          )}

          {mode === 'view' ? (
            <div style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div style={{
                display: 'grid',
                gridTemplateColumns: '1fr 1fr',
                gap: '16px',
                backgroundColor: '#F8FAFC',
                padding: '16px',
                borderRadius: '12px'
              }}>
                <div>
                  <label style={{ fontSize: '0.75rem', color: '#7A6B63', fontWeight: 600, display: 'block' }}>NAMA LENGKAP</label>
                  <span style={{ fontSize: '0.95rem', fontWeight: 700, color: '#1E3A2F' }}>{user.name}</span>
                </div>

                <div>
                  <label style={{ fontSize: '0.75rem', color: '#7A6B63', fontWeight: 600, display: 'block' }}>PERAN / ROLE</label>
                  <span style={{
                    display: 'inline-block',
                    padding: '4px 10px',
                    borderRadius: '20px',
                    fontSize: '0.75rem',
                    fontWeight: 700,
                    backgroundColor: user.role === 'Administrator' ? '#FEF3C7' : '#E0E7FF',
                    color: user.role === 'Administrator' ? '#92400E' : '#3730A3',
                    marginTop: '4px'
                  }}>
                    {user.role || 'Member Gear & Trail'}
                  </span>
                </div>

                <div>
                  <label style={{ fontSize: '0.75rem', color: '#7A6B63', fontWeight: 600, display: 'block' }}>ALAMAT EMAIL</label>
                  <span style={{ fontSize: '0.9rem', color: '#4A2C2A' }}>{user.email}</span>
                </div>

                <div>
                  <label style={{ fontSize: '0.75rem', color: '#7A6B63', fontWeight: 600, display: 'block' }}>NOMOR TELEPON</label>
                  <span style={{ fontSize: '0.9rem', color: '#4A2C2A' }}>{user.phone || '-'}</span>
                </div>
              </div>

              <div style={{ padding: '0 4px', fontSize: '0.82rem', color: '#7A6B63', display: 'flex', flexDirection: 'column', gap: '6px' }}>
                <div>🗓️ <strong>Tanggal Mendaftar:</strong> {formatDate(user.createdAt)}</div>
                {user.updatedAt && (
                  <div>✏️ <strong>Terakhir Diperbarui:</strong> {formatDate(user.updatedAt)}</div>
                )}
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '16px' }}>
                <button
                  className="btn btn-outline"
                  onClick={onClose}
                >
                  Tutup
                </button>
              </div>
            </div>
          ) : (
            <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '16px' }}>
              <div>
                <label style={{ fontSize: '0.85rem', fontWeight: 600, color: '#1E3A2F', marginBottom: '6px', display: 'block' }}>
                  Nama Lengkap *
                </label>
                <input
                  type="text"
                  required
                  value={formData.name}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    borderRadius: '8px',
                    border: '1px solid #CBD5E1',
                    fontSize: '0.95rem'
                  }}
                />
              </div>

              <div>
                <label style={{ fontSize: '0.85rem', fontWeight: 600, color: '#1E3A2F', marginBottom: '6px', display: 'block' }}>
                  Alamat Email *
                </label>
                <input
                  type="email"
                  required
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    borderRadius: '8px',
                    border: '1px solid #CBD5E1',
                    fontSize: '0.95rem'
                  }}
                />
              </div>

              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px' }}>
                <div>
                  <label style={{ fontSize: '0.85rem', fontWeight: 600, color: '#1E3A2F', marginBottom: '6px', display: 'block' }}>
                    Nomor WhatsApp / HP
                  </label>
                  <input
                    type="text"
                    value={formData.phone}
                    onChange={(e) => setFormData({ ...formData, phone: e.target.value })}
                    style={{
                      width: '100%',
                      padding: '10px 14px',
                      borderRadius: '8px',
                      border: '1px solid #CBD5E1',
                      fontSize: '0.95rem'
                    }}
                  />
                </div>

                <div>
                  <label style={{ fontSize: '0.85rem', fontWeight: 600, color: '#1E3A2F', marginBottom: '6px', display: 'block' }}>
                    Peran Pengguna
                  </label>
                  <select
                    value={formData.role}
                    onChange={(e) => setFormData({ ...formData, role: e.target.value })}
                    style={{
                      width: '100%',
                      padding: '10px 14px',
                      borderRadius: '8px',
                      border: '1px solid #CBD5E1',
                      fontSize: '0.95rem',
                      backgroundColor: '#FFFFFF'
                    }}
                  >
                    <option value="Member Gear & Trail">Member Gear & Trail</option>
                    <option value="Administrator">Administrator</option>
                  </select>
                </div>
              </div>

              <div>
                <label style={{ fontSize: '0.85rem', fontWeight: 600, color: '#1E3A2F', marginBottom: '4px', display: 'block' }}>
                  Password Baru (Opsional)
                </label>
                <input
                  type="password"
                  placeholder="Biarkan kosong jika tidak ingin merubah"
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  style={{
                    width: '100%',
                    padding: '10px 14px',
                    borderRadius: '8px',
                    border: '1px solid #CBD5E1',
                    fontSize: '0.95rem'
                  }}
                />
                <span style={{ fontSize: '0.72rem', color: '#7A6B63', marginTop: '2px', display: 'block' }}>
                  Minimal 6 karakter jika diisi.
                </span>
              </div>

              <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '12px' }}>
                <button
                  type="button"
                  className="btn btn-outline"
                  onClick={onClose}
                  disabled={loading}
                >
                  Batal
                </button>
                <button
                  type="submit"
                  className="btn btn-crimson"
                  style={{ backgroundColor: '#1E3A2F', borderColor: '#1E3A2F' }}
                  disabled={loading}
                >
                  {loading ? 'Menyimpan...' : 'Simpan Perubahan'}
                </button>
              </div>
            </form>
          )}
        </div>
      </div>
    </div>
  );
}
