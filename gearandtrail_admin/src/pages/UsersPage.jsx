import React, { useState, useEffect } from 'react';
import UserModal from '../components/UserModal';

export default function UsersPage() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedUser, setSelectedUser] = useState(null);
  const [modalMode, setModalMode] = useState('view');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [alertMsg, setAlertMsg] = useState(null);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const res = await fetch('http://localhost:5000/api/auth/users');
      const json = await res.json();
      if (json.success) {
        setUsers(json.data || []);
      }
    } catch (err) {
      console.error('Error fetching users:', err);
      showAlert('Gagal mengambil data akun pengguna dari server REST API', 'error');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchUsers();
  }, []);

  const showAlert = (msg, type = 'success') => {
    setAlertMsg({ msg, type });
    setTimeout(() => setAlertMsg(null), 4000);
  };

  const handleViewDetail = (user) => {
    setSelectedUser(user);
    setModalMode('view');
    setIsModalOpen(true);
  };

  const handleEditUser = (user) => {
    setSelectedUser(user);
    setModalMode('edit');
    setIsModalOpen(true);
  };

  const handleSaveUser = async (userId, formData) => {
    const res = await fetch(`http://localhost:5000/api/auth/users/${userId}`, {
      method: 'PUT',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(formData)
    });
    const json = await res.json();

    if (!res.ok || !json.success) {
      throw new Error(json.message || 'Gagal memperbarui data pengguna');
    }

    showAlert(`Akun "${json.data.name}" berhasil diperbarui!`, 'success');
    fetchUsers();
  };

  const handleDeleteUser = async (user) => {
    if (!window.confirm(`Apakah Anda yakin ingin menghapus akun pengguna "${user.name}" (${user.email})?`)) {
      return;
    }

    try {
      const res = await fetch(`http://localhost:5000/api/auth/users/${user.id}`, {
        method: 'DELETE'
      });
      const json = await res.json();

      if (json.success) {
        showAlert(json.message || 'Pengguna berhasil dihapus', 'success');
        fetchUsers();
      } else {
        showAlert(json.message || 'Gagal menghapus pengguna', 'error');
      }
    } catch (err) {
      console.error('Delete user error:', err);
      showAlert('Terjadi kesalahan saat menghapus pengguna', 'error');
    }
  };

  const filteredUsers = users.filter((u) => {
    const q = searchTerm.toLowerCase();
    return (
      (u.name && u.name.toLowerCase().includes(q)) ||
      (u.email && u.email.toLowerCase().includes(q)) ||
      (u.phone && u.phone.toLowerCase().includes(q)) ||
      (u.role && u.role.toLowerCase().includes(q))
    );
  });

  const formatDate = (dateStr) => {
    if (!dateStr) return '-';
    try {
      return new Date(dateStr).toLocaleDateString('id-ID', {
        day: 'numeric',
        month: 'short',
        year: 'numeric'
      });
    } catch {
      return dateStr;
    }
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Alert Banner */}
      {alertMsg && (
        <div style={{
          backgroundColor: alertMsg.type === 'error' ? '#FEE2E2' : '#D1FAE5',
          color: alertMsg.type === 'error' ? '#991B1B' : '#065F46',
          padding: '14px 20px',
          borderRadius: '10px',
          fontWeight: 600,
          fontSize: '0.9rem',
          display: 'flex',
          alignItems: 'center',
          gap: '10px',
          boxShadow: '0 4px 12px rgba(0,0,0,0.05)'
        }}>
          <span>{alertMsg.type === 'error' ? '⚠️' : '✅'}</span>
          <span>{alertMsg.msg}</span>
        </div>
      )}

      {/* Top Toolbar */}
      <div className="card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', gap: '16px', flexWrap: 'wrap' }}>
        <div style={{ flex: 1, minWidth: '280px' }}>
          <div style={{ position: 'relative' }}>
            <input
              type="text"
              placeholder="🔍 Cari nama, email, atau nomor HP pengguna..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
              style={{
                width: '100%',
                padding: '12px 16px',
                borderRadius: '10px',
                border: '1px solid #CBD5E1',
                fontSize: '0.92rem',
                backgroundColor: '#F8FAFC'
              }}
            />
          </div>
        </div>

        <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
          <span style={{ fontSize: '0.85rem', color: '#7A6B63', fontWeight: 600 }}>
            Total: <strong>{filteredUsers.length}</strong> Akun
          </span>
          <button className="btn btn-outline" onClick={fetchUsers} title="Refresh Data">
            🔄 Refresh
          </button>
        </div>
      </div>

      {/* Main Table */}
      <div className="card">
        <div className="table-container">
          <table>
            <thead>
              <tr>
                <th>Pengguna</th>
                <th>Email</th>
                <th>No. HP</th>
                <th>Peran (Role)</th>
                <th>Terdaftar</th>
                <th style={{ textAlign: 'center' }}>Aksi</th>
              </tr>
            </thead>
            <tbody>
              {loading ? (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', color: '#7A6B63', padding: '40px' }}>
                    Memuat data pengguna terdaftar...
                  </td>
                </tr>
              ) : filteredUsers.length > 0 ? (
                filteredUsers.map((u) => (
                  <tr key={u.id}>
                    <td>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '12px' }}>
                        <div style={{
                          width: '36px',
                          height: '36px',
                          borderRadius: '50%',
                          backgroundColor: u.role === 'Administrator' ? '#D4A373' : '#1E3A2F',
                          color: '#FFFFFF',
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'center',
                          fontWeight: 700,
                          fontSize: '14px',
                          flexShrink: 0
                        }}>
                          {u.name ? u.name.charAt(0).toUpperCase() : '👤'}
                        </div>
                        <div>
                          <div style={{ fontWeight: 700, color: '#1E3A2F' }}>{u.name}</div>
                          <div style={{ fontSize: '0.75rem', color: '#7A6B63' }}>ID: {u.id}</div>
                        </div>
                      </div>
                    </td>
                    <td style={{ color: '#4A2C2A', fontWeight: 500 }}>{u.email}</td>
                    <td>{u.phone || '-'}</td>
                    <td>
                      <span style={{
                        display: 'inline-block',
                        padding: '4px 10px',
                        borderRadius: '20px',
                        fontSize: '0.75rem',
                        fontWeight: 700,
                        backgroundColor: u.role === 'Administrator' ? '#FEF3C7' : '#E0E7FF',
                        color: u.role === 'Administrator' ? '#92400E' : '#3730A3'
                      }}>
                        {u.role || 'Member Gear & Trail'}
                      </span>
                    </td>
                    <td style={{ fontSize: '0.82rem', color: '#7A6B63' }}>
                      {formatDate(u.createdAt)}
                    </td>
                    <td>
                      <div style={{ display: 'flex', justifyContent: 'center', gap: '8px' }}>
                        <button
                          className="btn btn-outline"
                          onClick={() => handleViewDetail(u)}
                          title="Lihat Rincian Akun"
                          style={{ padding: '6px 12px', fontSize: '0.82rem' }}
                        >
                          👁️ Detail
                        </button>
                        <button
                          className="btn btn-outline"
                          onClick={() => handleEditUser(u)}
                          title="Edit Data Pengguna"
                          style={{ padding: '6px 12px', fontSize: '0.82rem', borderColor: '#EA580C', color: '#EA580C' }}
                        >
                          ✏️ Edit
                        </button>
                        <button
                          className="btn btn-crimson"
                          onClick={() => handleDeleteUser(u)}
                          title="Hapus Akun Pengguna"
                          style={{ padding: '6px 12px', fontSize: '0.82rem' }}
                        >
                          🗑️ Hapus
                        </button>
                      </div>
                    </td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="6" style={{ textAlign: 'center', color: '#7A6B63', padding: '40px' }}>
                    {searchTerm ? `Tidak ada akun pengguna yang cocok dengan "${searchTerm}"` : 'Belum ada akun pengguna terdaftar.'}
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </div>
      </div>

      {/* Modal Detail / Edit */}
      <UserModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        user={selectedUser}
        mode={modalMode}
        onSave={handleSaveUser}
      />
    </div>
  );
}
