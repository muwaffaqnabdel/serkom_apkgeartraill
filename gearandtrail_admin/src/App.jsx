import React, { useState, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import Header from './components/Header';
import DashboardPage from './pages/DashboardPage';
import CategoriesPage from './pages/CategoriesPage';
import ProductsPage from './pages/ProductsPage';
import OrdersPage from './pages/OrdersPage';
import UsersPage from './pages/UsersPage';
import AdminLoginPage from './pages/AdminLoginPage';

export default function App() {
  const [activeTab, setActiveTab] = useState('dashboard');
  const [isLoggedIn, setIsLoggedIn] = useState(false);
  const [adminUser, setAdminUser] = useState(null);

  useEffect(() => {
    const savedLoggedIn = localStorage.getItem('isAdminLoggedIn');
    const savedUser = localStorage.getItem('adminUser');
    if (savedLoggedIn === 'true' && savedUser) {
      try {
        setIsLoggedIn(true);
        setAdminUser(JSON.parse(savedUser));
      } catch (e) {
        setIsLoggedIn(false);
      }
    }
  }, []);

  const handleLoginSuccess = (userData) => {
    setIsLoggedIn(true);
    setAdminUser(userData);
  };

  const handleLogout = () => {
    localStorage.removeItem('isAdminLoggedIn');
    localStorage.removeItem('adminUser');
    setIsLoggedIn(false);
    setAdminUser(null);
  };

  if (!isLoggedIn) {
    return <AdminLoginPage onLoginSuccess={handleLoginSuccess} />;
  }

  const getPageDetails = () => {
    switch (activeTab) {
      case 'dashboard':
        return {
          title: 'Dashboard Utama',
          subtitle: 'Ringkasan performa penjualan dan aktivitas terkini toko Gear & Trail'
        };
      case 'categories':
        return {
          title: 'Katalog Sepeda',
          subtitle: 'Kelola daftar kelompok/katalog sepeda & peralatan gowes (Tambah, Edit, Hapus)'
        };
      case 'products':
        return {
          title: 'Produk MTB & Gear',
          subtitle: 'Kelola daftar produk sepeda, harga, stok, foto, dan pilihan katalog'
        };
      case 'orders':
        return {
          title: 'Daftar Pesanan',
          subtitle: 'Pantau transaksi pemesanan masuk dan perbarui status pengiriman'
        };
      case 'users':
        return {
          title: 'Akun Pengguna',
          subtitle: 'Kelola data pengguna terdaftar, perbarui profil, atau hapus akun'
        };
      default:
        return { title: 'Dashboard', subtitle: 'Gear & Trail Web Admin' };
    }
  };

  const { title, subtitle } = getPageDetails();

  return (
    <div className="app-container">
      <Sidebar activeTab={activeTab} setActiveTab={setActiveTab} onLogout={handleLogout} />
      <div className="main-content">
        <Header title={title} subtitle={subtitle} onLogout={handleLogout} adminUser={adminUser} />
        <main className="page-container">
          {activeTab === 'dashboard' && <DashboardPage setActiveTab={setActiveTab} />}
          {activeTab === 'categories' && <CategoriesPage />}
          {activeTab === 'products' && (
            <ProductsPage onNavigateToCategories={() => setActiveTab('categories')} />
          )}
          {activeTab === 'orders' && <OrdersPage />}
          {activeTab === 'users' && <UsersPage />}
        </main>
      </div>
    </div>
  );
}
