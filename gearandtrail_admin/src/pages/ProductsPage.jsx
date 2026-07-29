import React, { useState, useEffect } from 'react';
import ProductModal from '../components/ProductModal';

export default function ProductsPage({ onNavigateToCategories }) {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [selectedCategory, setSelectedCategory] = useState('Semua');
  const [categories, setCategories] = useState([]);
  
  // Modal state
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [editingProduct, setEditingProduct] = useState(null);

  const fetchCategories = async () => {
    try {
      const res = await fetch('http://localhost:5000/api/categories');
      const json = await res.json();
      if (json.success && json.data) {
        const catNames = json.data.map(c => (typeof c === 'string' ? c : c.name));
        setCategories(['Semua', ...catNames]);
      }
    } catch (err) {
      console.error(err);
    }
  };

  const fetchProducts = async () => {
    setLoading(true);
    try {
      let url = `http://localhost:5000/api/products?search=${encodeURIComponent(search)}`;
      if (selectedCategory !== 'Semua') {
        url += `&category=${encodeURIComponent(selectedCategory)}`;
      }
      const res = await fetch(url);
      const json = await res.json();
      if (json.success) {
        setProducts(json.data);
      }
    } catch (err) {
      console.error('Failed fetching products:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchCategories();
  }, []);

  useEffect(() => {
    fetchProducts();
  }, [search, selectedCategory]);

  const handleCreateProduct = () => {
    setEditingProduct(null);
    setIsModalOpen(true);
  };

  const handleEditProduct = (product) => {
    setEditingProduct(product);
    setIsModalOpen(true);
  };

  const handleDeleteProduct = async (id, name) => {
    if (!window.confirm(`Apakah Anda yakin ingin menghapus produk "${name}"?`)) return;

    try {
      const res = await fetch(`http://localhost:5000/api/products/${id}`, {
        method: 'DELETE'
      });
      const json = await res.json();
      if (json.success) {
        fetchProducts();
      } else {
        alert(json.message);
      }
    } catch (err) {
      alert('Gagal menghapus produk!');
    }
  };

  const handleSaveProduct = async (productData) => {
    try {
      const method = editingProduct ? 'PUT' : 'POST';
      const url = editingProduct
        ? `http://localhost:5000/api/products/${editingProduct.id}`
        : 'http://localhost:5000/api/products';

      const res = await fetch(url, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(productData)
      });

      const json = await res.json();
      if (json.success) {
        setIsModalOpen(false);
        fetchProducts();
      } else {
        alert(json.message);
      }
    } catch (err) {
      alert('Gagal menyimpan produk!');
    }
  };

  const formatRupiah = (num) => {
    return new Intl.NumberFormat('id-ID', { style: 'currency', currency: 'IDR', maximumFractionDigits: 0 }).format(num || 0);
  };

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: '24px' }}>
      {/* Action & Filter Bar */}
      <div className="card" style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', flexWrap: 'wrap', gap: '16px' }}>
        <div style={{ display: 'flex', gap: '12px', flexWrap: 'wrap', alignItems: 'center' }}>
          <input
            type="text"
            className="form-input"
            style={{ width: '260px' }}
            placeholder="🔍 Cari sepeda & perlengkapan..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
          />

          <select
            className="form-select"
            style={{ width: '200px' }}
            value={selectedCategory}
            onChange={(e) => setSelectedCategory(e.target.value)}
          >
            {categories.map((cat) => (
              <option key={cat} value={cat}>{cat === 'Semua' ? 'Semua Katalog' : cat}</option>
            ))}
          </select>
        </div>

        <button className="btn btn-crimson" onClick={handleCreateProduct}>
          + Tambah Produk Sepeda & Gear
        </button>
      </div>

      {/* Products Table */}
      <div className="table-container">
        <table>
          <thead>
            <tr>
              <th>Foto</th>
              <th>Nama Produk</th>
              <th>Katalog / Kategori</th>
              <th>Harga</th>
              <th>Stok</th>
              <th>Status / Badge</th>
              <th style={{ textAlign: 'right' }}>Aksi</th>
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', padding: '30px', color: '#7A6B63' }}>
                  Memuat data produk sepeda & gear...
                </td>
              </tr>
            ) : products.length > 0 ? (
              products.map((p) => (
                <tr key={p.id}>
                  <td>
                    <img
                      src={p.imageUrl}
                      alt={p.name}
                      style={{
                        width: '54px',
                        height: '54px',
                        borderRadius: '10px',
                        objectFit: 'cover',
                        border: '1px solid #E8E2D8'
                      }}
                    />
                  </td>
                  <td>
                    <div style={{ fontWeight: 700, color: '#4A2C2A', fontSize: '0.95rem' }}>{p.name}</div>
                    <div style={{ fontSize: '0.8rem', color: '#7A6B63', maxWidth: '300px', whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {p.description}
                    </div>
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '4px', flexWrap: 'wrap' }}>
                      {p.categories?.map((c) => (
                        <span key={c} style={{
                          padding: '3px 9px',
                          borderRadius: '6px',
                          backgroundColor: '#FAF8F5',
                          border: '1px solid #E8E2D8',
                          fontSize: '0.78rem',
                          fontWeight: 600,
                          color: '#4A2C2A'
                        }}>
                          🏷️ {c}
                        </span>
                      ))}
                    </div>
                  </td>
                  <td style={{ fontWeight: 700, color: '#B71C1C' }}>
                    {formatRupiah(p.price)}
                  </td>
                  <td style={{ fontWeight: 600 }}>
                    {p.stock ?? 30} pcs
                  </td>
                  <td>
                    <div style={{ display: 'flex', gap: '6px', alignItems: 'center' }}>
                      {p.isFavorite && (
                        <span className="badge badge-favorit">⭐ Favorit</span>
                      )}
                      {p.badge && (
                        <span className="badge badge-terlaris">{p.badge}</span>
                      )}
                      {!p.isFavorite && !p.badge && (
                        <span style={{ fontSize: '0.8rem', color: '#7A6B63' }}>Standard</span>
                      )}
                    </div>
                  </td>
                  <td style={{ textAlign: 'right' }}>
                    <div style={{ display: 'flex', justifyContent: 'flex-end', gap: '8px' }}>
                      <button className="btn btn-outline" style={{ padding: '6px 12px', fontSize: '0.8rem' }} onClick={() => handleEditProduct(p)}>
                        ✏️ Edit
                      </button>
                      <button className="btn btn-danger" style={{ padding: '6px 12px', fontSize: '0.8rem' }} onClick={() => handleDeleteProduct(p.id, p.name)}>
                        🗑️ Hapus
                      </button>
                    </div>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center', padding: '30px', color: '#7A6B63' }}>
                  Tidak ada produk sepeda & gear ditemukan.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>

      {/* Modal Add/Edit Product */}
      <ProductModal
        isOpen={isModalOpen}
        onClose={() => setIsModalOpen(false)}
        onSave={handleSaveProduct}
        initialData={editingProduct}
        onNavigateToCategories={onNavigateToCategories}
      />
    </div>
  );
}
