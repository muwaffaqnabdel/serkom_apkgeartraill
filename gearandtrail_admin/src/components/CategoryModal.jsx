import React, { useState, useEffect } from 'react';

export default function CategoryModal({ isOpen, onClose, onSave, initialData }) {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');

  useEffect(() => {
    if (initialData) {
      setName(initialData.name || '');
      setDescription(initialData.description || '');
    } else {
      setName('');
      setDescription('');
    }
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name.trim()) return alert('Nama katalog wajib diisi!');

    onSave({
      name: name.trim(),
      description: description.trim()
    });
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()} style={{ maxWidth: '480px' }}>
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '20px',
          paddingBottom: '12px',
          borderBottom: '1px solid #E8E2D8'
        }}>
          <h2 style={{ fontFamily: "'Playfair Display', serif", color: '#4A2C2A', fontSize: '1.4rem' }}>
            {initialData ? 'Edit Katalog / Kategori' : 'Tambah Katalog Baru'}
          </h2>
          <button onClick={onClose} style={{ background: 'none', border: 'none', fontSize: '1.5rem', cursor: 'pointer', color: '#7A6B63' }}>
            &times;
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Nama Katalog *</label>
            <input
              type="text"
              className="form-input"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Contoh: Kue Basah, Kue Kering, Camilan"
              required
            />
          </div>

          <div className="form-group">
            <label className="form-label">Deskripsi Katalog</label>
            <textarea
              className="form-textarea"
              rows="3"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Deskripsi singkat mengenai jenis jajanan dalam katalog ini..."
            />
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '24px' }}>
            <button type="button" className="btn btn-outline" onClick={onClose}>
              Batal
            </button>
            <button type="submit" className="btn btn-primary">
              Simpan Katalog
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
