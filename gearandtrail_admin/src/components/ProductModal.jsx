import React, { useState, useEffect } from 'react';

export default function ProductModal({ isOpen, onClose, onSave, initialData, onNavigateToCategories }) {
  const [name, setName] = useState('');
  const [description, setDescription] = useState('');
  const [price, setPrice] = useState('');
  const [imageUrl, setImageUrl] = useState('');
  const [selectedCategories, setSelectedCategories] = useState([]);
  const [availableCategories, setAvailableCategories] = useState([]);
  const [badge, setBadge] = useState('');
  const [isFavorite, setIsFavorite] = useState(false);
  const [stock, setStock] = useState('30');
  const [loadingCategories, setLoadingCategories] = useState(false);

  // Fetch available categories from server API
  const fetchAvailableCategories = async () => {
    setLoadingCategories(true);
    try {
      const res = await fetch('http://localhost:5000/api/categories');
      const json = await res.json();
      if (json.success && json.data) {
        setAvailableCategories(json.data);
      }
    } catch (err) {
      console.error('Failed fetching available categories:', err);
    } finally {
      setLoadingCategories(false);
    }
  };

  useEffect(() => {
    if (isOpen) {
      fetchAvailableCategories();
    }
  }, [isOpen]);

  useEffect(() => {
    if (initialData) {
      setName(initialData.name || '');
      setDescription(initialData.description || '');
      setPrice(initialData.price ? String(initialData.price) : '');
      setImageUrl(initialData.imageUrl || '');
      setSelectedCategories(Array.isArray(initialData.categories) ? initialData.categories : []);
      setBadge(initialData.badge || '');
      setIsFavorite(Boolean(initialData.isFavorite));
      setStock(initialData.stock ? String(initialData.stock) : '30');
    } else {
      setName('');
      setDescription('');
      setPrice('');
      setImageUrl('');
      setSelectedCategories([]);
      setBadge('');
      setIsFavorite(false);
      setStock('30');
    }
  }, [initialData, isOpen]);

  if (!isOpen) return null;

  const handleCategoryToggle = (categoryName) => {
    setSelectedCategories((prev) => {
      if (prev.includes(categoryName)) {
        return prev.filter((c) => c !== categoryName);
      } else {
        return [...prev, categoryName];
      }
    });
  };

  const handleSubmit = (e) => {
    e.preventDefault();
    if (!name || !price) return alert('Nama dan harga wajib diisi!');
    if (selectedCategories.length === 0) {
      return alert('Pilih minimal 1 katalog untuk produk jajanan ini!');
    }

    onSave({
      name,
      description,
      price: Number(price),
      imageUrl: imageUrl || 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&auto=format&fit=crop&q=80',
      categories: selectedCategories,
      badge: badge.trim() || null,
      isFavorite,
      stock: Number(stock)
    });
  };

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        <div style={{
          display: 'flex',
          justifyContent: 'space-between',
          alignItems: 'center',
          marginBottom: '20px',
          paddingBottom: '12px',
          borderBottom: '1px solid #E8E2D8'
        }}>
          <h2 style={{ fontFamily: "'Playfair Display', serif", color: '#4A2C2A', fontSize: '1.4rem' }}>
            {initialData ? 'Edit Produk Jajanan' : 'Tambah Produk Jajanan Baru'}
          </h2>
          <button onClick={onClose} style={{ background: 'none', border: 'none', fontSize: '1.5rem', cursor: 'pointer', color: '#7A6B63' }}>
            &times;
          </button>
        </div>

        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label className="form-label">Nama Produk Jajanan *</label>
            <input
              type="text"
              className="form-input"
              value={name}
              onChange={(e) => setName(e.target.value)}
              placeholder="Contoh: Lemper Ayam Special"
              required
            />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px' }}>
            <div className="form-group">
              <label className="form-label">Harga (Rp) *</label>
              <input
                type="number"
                className="form-input"
                value={price}
                onChange={(e) => setPrice(e.target.value)}
                placeholder="8000"
                required
              />
            </div>
            <div className="form-group">
              <label className="form-label">Stok Produk</label>
              <input
                type="number"
                className="form-input"
                value={stock}
                onChange={(e) => setStock(e.target.value)}
                placeholder="30"
              />
            </div>
          </div>

          {/* Select Catalog / Category Section */}
          <div className="form-group">
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '8px' }}>
              <label className="form-label" style={{ margin: 0 }}>
                Pilih Katalog Produk *
              </label>
              {onNavigateToCategories && (
                <button
                  type="button"
                  style={{
                    background: 'none',
                    border: 'none',
                    color: '#B71C1C',
                    fontWeight: 700,
                    fontSize: '0.8rem',
                    cursor: 'pointer'
                  }}
                  onClick={() => {
                    onClose();
                    onNavigateToCategories();
                  }}
                >
                  + Tambah Katalog Baru
                </button>
              )}
            </div>

            {loadingCategories ? (
              <div style={{ fontSize: '0.85rem', color: '#7A6B63' }}>Memuat pilihan katalog...</div>
            ) : availableCategories.length > 0 ? (
              <div style={{
                display: 'flex',
                flexWrap: 'wrap',
                gap: '8px',
                padding: '12px',
                border: '1px solid #E8E2D8',
                borderRadius: '8px',
                backgroundColor: '#FAF8F5'
              }}>
                {availableCategories.map((cat) => {
                  const catName = typeof cat === 'string' ? cat : cat.name;
                  const isChecked = selectedCategories.includes(catName);
                  return (
                    <label
                      key={catName}
                      style={{
                        display: 'flex',
                        alignItems: 'center',
                        gap: '6px',
                        padding: '6px 12px',
                        borderRadius: '20px',
                        backgroundColor: isChecked ? '#4A2C2A' : '#FFFFFF',
                        color: isChecked ? '#FFFFFF' : '#4A2C2A',
                        border: '1px solid ' + (isChecked ? '#4A2C2A' : '#E8E2D8'),
                        fontSize: '0.85rem',
                        fontWeight: isChecked ? 700 : 500,
                        cursor: 'pointer',
                        transition: 'all 0.15s ease'
                      }}
                    >
                      <input
                        type="checkbox"
                        checked={isChecked}
                        onChange={() => handleCategoryToggle(catName)}
                        style={{ display: 'none' }}
                      />
                      🏷️ {catName}
                    </label>
                  );
                })}
              </div>
            ) : (
              <div style={{ fontSize: '0.85rem', color: '#B71C1C' }}>
                Belum ada katalog. Silakan buat katalog terlebih dahulu!
              </div>
            )}
          </div>

          <div className="form-group">
            <label className="form-label">URL Foto Produk</label>
            <input
              type="text"
              className="form-input"
              value={imageUrl}
              onChange={(e) => setImageUrl(e.target.value)}
              placeholder="https://images.unsplash.com/..."
            />
          </div>

          <div className="form-group">
            <label className="form-label">Deskripsi Jajanan</label>
            <textarea
              className="form-textarea"
              rows="3"
              value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Ketan pulen dengan isian ayam suwir bumbu rempah..."
            />
          </div>

          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '16px', alignItems: 'center' }}>
            <div className="form-group">
              <label className="form-label">Lencana Badge (Optional)</label>
              <input
                type="text"
                className="form-input"
                value={badge}
                onChange={(e) => setBadge(e.target.value)}
                placeholder="Favorit / Terlaris"
              />
            </div>
            <div className="form-group" style={{ display: 'flex', alignItems: 'center', gap: '8px', paddingTop: '20px' }}>
              <input
                type="checkbox"
                id="isFav"
                checked={isFavorite}
                onChange={(e) => setIsFavorite(e.target.checked)}
                style={{ width: '18px', height: '18px', accentColor: '#B71C1C', cursor: 'pointer' }}
              />
              <label htmlFor="isFav" style={{ fontSize: '0.9rem', fontWeight: 600, cursor: 'pointer', color: '#4A2C2A' }}>
                Tandai Rekomendasi Favorit ⭐
              </label>
            </div>
          </div>

          <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '12px', marginTop: '24px' }}>
            <button type="button" className="btn btn-outline" onClick={onClose}>
              Batal
            </button>
            <button type="submit" className="btn btn-primary">
              Simpan Produk
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
