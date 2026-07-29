import React, { useState, useEffect } from 'react';
import CategoryModal from '../components/CategoryModal';

export default function CategoriesPage({ onSelectCategoryForProduct }) {
  const [categories, setCategories] = useState([]);
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');

  // Modal State
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingCategory, setEditingCategory] = useState(null);

  const fetchData = async () => {
    setLoading(true);
    try {
      const [resCat, resProd] = await Promise.all([
        fetch('http://localhost:5000/api/categories'),
        fetch('http://localhost:5000/api/products')
      ]);

      const jsonCat = await resCat.json();
      const jsonProd = await resProd.json();

      if (jsonCat.success) setCategories(jsonCat.data || []);
      if (jsonProd.success) setProducts(jsonProd.data || []);
    } catch (err) {
      console.error('Failed fetching categories or products:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchData();
  }, []);

  const handleCreateCategory = () => {
    setEditingCategory(null);
    setIsModalOpen(true);
  };

  const handleEditCategory = (category) => {
    setEditingCategory(category);
    setIsModalOpen(true);
  };

  const handleDeleteCategory = async (category) => {
    if (!window.confirm(`Apakah Anda yakin ingin menghapus katalog "${category.name}"?\n(Katalog ini juga akan dihapus dari produk-produk terkait)`)) {
      return;
    }

    try {
      const res = await fetch(`http://localhost:5000/api/categories/${category.id}`, {
        method: 'DELETE'
      });
      const json = await res.json();
      if (json.success) {
        fetchData();
      } else {
        alert(json.message);
      }
    } catch (err) {
      alert('Gagal menghapus katalog!');
    }
  };

  const handleSaveCategory = async (catData) => {
    try {
      const method = editingCategory ? 'PUT' : 'POST';
      const url = editingCategory
        ? `http://localhost:5000/api/categories/${editingCategory.id}`
        : 'http://localhost:5000/api/categories';

      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(catData)
      });

      const json = await res.json();
      if (json.success) {
        setIsModalOpen(false);
        fetchData();
      } else {
        alert(json.message);
      }
    } catch (err) {
      alert('Gagal menyimpan katalog!');
    }
  };

  const getProductCount = (categoryName) => {
    return products.filter(p => p.categories && p.categories.includes(categoryName)).length;
  };

  const filteredCategories = categories.filter(c => 
    c.name.toLowerCase().includes(search.toLowerCase()) || 
    (c.description && c.description.toLowerCase().includes(search.toLowerCase()))
  );

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Top Action & Search Bar */}
      <div className="card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div>
          <h3 style={{ fontFamily: "'Playfair Display', serif", fontSize: '1.2rem', color: '#4A2C2A' }}>
            Manajemen Katalog Sepeda & Gear Outdoor
          </h3>
          <p style={{ fontSize: '0.85rem', color: '#7A6B63' }}>
            Kelola daftar katalog/kategori produk gowes seperti MTB, Helm, Aksesori, dan Sparepart
          </p>
        </div>

        <div style={{ display: 'flex', gap: '12px', alignItems: 'center' }}>
          <input
            type="text"
            className="form-input"
            style={{ width: '240px' }}
            placeholder="🔍 Cari nama katalog..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />
          <button className="btn btn-crimson" onClick={handleCreateCategory}>
            + Tambah Katalog Baru
          </button>
        </div>
      </div>

      {/* Categories Table */}
      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>ID Katalog</th>
              <th>Nama Katalog</th>
              <th>Deskripsi Katalog</th>
              <th>Jumlah Produk Terkait</th>
              <th style={{ textAlign: 'right' }}>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '30px', color: '#7A6B63' }}>
                  Memuat data katalog...
                </td>
              </tr>
            ) : filteredCategories.length > 0 ? (
              filteredCategories.map((c) => {
                const count = getProductCount(c.name);
                return (
                  <tr key={c.id || c.name}>
                    <td style={{ fontWeight: 600, color: '#7A6B63', fontSize: '0.85rem' }}>
                      {c.id || 'N/A'}
                    </td>
                    <td>
                      <div style={{ fontWeight: 700, color: '#4A2C2A', fontSize: '1rem' }}>
                        🏷️ {c.name}
                      </div>
                    </td>
                    <td style={{ color: '#7A6B63', fontSize: '0.88rem' }}>
                      {c.description || '-'}
                    </td>
                    <td>
                      <span style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        padding: '4px 10px',
                        borderRadius: '999px',
                        backgroundColor: count > 0 ? '#FAF3E0' : '#F4F3EF',
                        color: count > 0 ? '#4A2C2A' : '#9E9188',
                        fontWeight: 700,
                        fontSize: '0.8rem'
                      }}>
                        {count} Produk
                      </span>
                    </td>
                    <td style={{ textAlign: 'right' }}>
                      <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                        <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.8rem' }} onClick={() => handleEditCategory(c)}>
                          ✏️ Edit
                        </button>
                        <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.8rem' }} onClick={() => handleDeleteCategory(c)}>
                          🗑️ Hapus
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })
            ) : (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center', padding: '30px', color: '#7A6B63' }}>
                  Belum ada katalog tersedia. Silakan klik "+ Tambah Katalog Baru".
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Modal Add / Edit Category */}
      <CategoryModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSaveCategory}
        initialData={editingCategory}
      />
    </div>
  );
}
