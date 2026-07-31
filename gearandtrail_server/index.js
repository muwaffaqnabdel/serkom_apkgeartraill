require('dotenv').config();
const express = require('express');
const cors = require('cors');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const { sendOtpEmail } = require('./mailer');

// Simple password hashing with SHA-256 + salt
function hashPassword(password) {
  const salt = 'geartrail_salt_2026';
  return crypto.createHash('sha256').update(password + salt).digest('hex');
}

function verifyPassword(plain, hashed) {
  return hashPassword(plain) === hashed;
}

const app = express();
const PORT = process.env.PORT || 5000;
const DB_PATH = path.join(__dirname, 'data', 'database.json');

// Middleware
app.use(cors());
app.use(express.json());

// Database Helpers
function readDb() {
  try {
    const data = fs.readFileSync(DB_PATH, 'utf8');
    return JSON.parse(data);
  } catch (err) {
    console.error('Error reading database:', err);
    return { categories: [], products: [], orders: [], users: [] };
  }
}

function writeDb(data) {
  try {
    fs.writeFileSync(DB_PATH, JSON.stringify(data, null, 2), 'utf8');
    return true;
  } catch (err) {
    console.error('Error writing database:', err);
    return false;
  }
}

// ----------------------------------------------------
// 1. Health Check
// ----------------------------------------------------
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    service: 'Gear & Trail REST API Backend Server',
    timestamp: new Date().toISOString()
  });
});

// ----------------------------------------------------
// 2. Auth Routes
// ----------------------------------------------------
app.post('/api/auth/login', (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ success: false, message: 'Email/username dan password wajib diisi' });
  }

  const db = readDb();
  const users = db.users || [];

  // Support both hashed (new accounts) and plain text (legacy accounts)
  const foundUser = users.find(u => {
    const emailMatch = u.email.toLowerCase() === email.trim().toLowerCase() ||
      u.name.toLowerCase() === email.trim().toLowerCase();
    if (!emailMatch) return false;
    // Check hashed password first, then fallback to plain text (legacy)
    return verifyPassword(password, u.password) || u.password === password;
  });

  if (!foundUser) {
    return res.status(400).json({ success: false, message: 'Email/username atau password salah' });
  }

  const { password: _, resetToken: __, resetTokenExpiry: ___, ...userWithoutPassword } = foundUser;

  res.json({
    success: true,
    message: 'Login berhasil',
    token: 'jwt_' + foundUser.id + '_geartrail_' + Date.now(),
    user: userWithoutPassword
  });
});

app.post('/api/auth/register', (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ success: false, message: 'Username, email, dan password wajib diisi' });
  }
  if (password.length < 6) {
    return res.status(400).json({ success: false, message: 'Password minimal 6 karakter' });
  }

  const db = readDb();
  if (!db.users) db.users = [];

  const existing = db.users.find(u => u.email.toLowerCase() === email.trim().toLowerCase());
  if (existing) {
    return res.status(400).json({ success: false, message: `Email "${email.trim()}" sudah terdaftar` });
  }

  // Store hashed password for security
  const newUser = {
    id: 'usr-' + Date.now(),
    name: name.trim(),
    email: email.trim().toLowerCase(),
    password: hashPassword(password),
    phone: '081234567890',
    role: 'Member Gear & Trail',
    createdAt: new Date().toISOString()
  };

  db.users.push(newUser);
  writeDb(db);

  const { password: _, ...userWithoutPassword } = newUser;

  res.status(201).json({
    success: true,
    message: 'Pendaftaran akun berhasil! Selamat bergabung di Gear & Trail.',
    token: 'jwt_' + newUser.id + '_geartrail_' + Date.now(),
    user: userWithoutPassword
  });
});

// Lupa Password - kirim OTP reset token via email Gmail
app.post('/api/auth/forgot-password', async (req, res) => {
  const { email } = req.body;
  if (!email) {
    return res.status(400).json({ success: false, message: 'Email wajib diisi' });
  }

  const db = readDb();
  const users = db.users || [];
  const user = users.find(u => u.email.toLowerCase() === email.trim().toLowerCase());

  if (!user) {
    return res.json({
      success: true,
      message: 'Jika email terdaftar, kode OTP telah dikirimkan. Silakan cek Kotak Masuk / Spam Gmail Anda.'
    });
  }

  // Generate 6-digit OTP + token
  const otp = Math.floor(100000 + Math.random() * 900000).toString();
  const resetToken = crypto.randomBytes(20).toString('hex');
  const expiry = new Date(Date.now() + 15 * 60 * 1000).toISOString(); // 15 menit

  const idx = db.users.findIndex(u => u.email.toLowerCase() === email.trim().toLowerCase());
  db.users[idx].resetToken = resetToken;
  db.users[idx].resetOtp = otp;
  db.users[idx].resetTokenExpiry = expiry;
  writeDb(db);

  // Kirim email nyata via Nodemailer SMTP
  const mailResult = await sendOtpEmail(email.trim(), otp);

  res.json({
    success: true,
    emailSent: mailResult.success,
    message: mailResult.success
      ? `Kode OTP verifikasi telah dikirimkan ke email ${email.trim()}. Cek Kotak Masuk / Folder Spam Gmail Anda.`
      : `Kode OTP verifikasi dibuat. (Catatan: Pengiriman SMTP ${mailResult.message || 'belum dikonfigurasi'})`,
    otp: otp,
    resetToken: resetToken,
    expiresAt: expiry
  });
});

// Verifikasi OTP reset
app.post('/api/auth/verify-reset-otp', (req, res) => {
  const { email, otp } = req.body;
  if (!email || !otp) {
    return res.status(400).json({ success: false, message: 'Email dan kode OTP wajib diisi' });
  }

  const db = readDb();
  const user = (db.users || []).find(u => u.email.toLowerCase() === email.trim().toLowerCase());

  if (!user || !user.resetOtp || !user.resetTokenExpiry) {
    return res.status(400).json({ success: false, message: 'Permintaan reset tidak valid' });
  }
  if (new Date() > new Date(user.resetTokenExpiry)) {
    return res.status(400).json({ success: false, message: 'Kode OTP sudah kedaluwarsa. Minta kode baru.' });
  }
  if (user.resetOtp !== otp.trim()) {
    return res.status(400).json({ success: false, message: 'Kode OTP tidak valid' });
  }

  res.json({
    success: true,
    message: 'Kode OTP valid. Silakan masukkan password baru.',
    resetToken: user.resetToken
  });
});

// Reset Password dengan token
app.post('/api/auth/reset-password', (req, res) => {
  const { email, resetToken, newPassword } = req.body;

  if (!email || !resetToken || !newPassword) {
    return res.status(400).json({ success: false, message: 'Data tidak lengkap' });
  }
  if (newPassword.length < 6) {
    return res.status(400).json({ success: false, message: 'Password baru minimal 6 karakter' });
  }

  const db = readDb();
  const idx = (db.users || []).findIndex(u => u.email.toLowerCase() === email.trim().toLowerCase());

  if (idx === -1) {
    return res.status(400).json({ success: false, message: 'Pengguna tidak ditemukan' });
  }

  const user = db.users[idx];
  if (!user.resetToken || user.resetToken !== resetToken) {
    return res.status(400).json({ success: false, message: 'Token reset tidak valid' });
  }
  if (new Date() > new Date(user.resetTokenExpiry)) {
    return res.status(400).json({ success: false, message: 'Token reset sudah kedaluwarsa. Minta kode baru.' });
  }

  // Update password (hashed) & hapus token
  db.users[idx].password = hashPassword(newPassword);
  delete db.users[idx].resetToken;
  delete db.users[idx].resetOtp;
  delete db.users[idx].resetTokenExpiry;
  writeDb(db);

  res.json({
    success: true,
    message: 'Password berhasil direset. Silakan login dengan password baru Anda.'
  });
});

// Ganti Password (saat login)
app.post('/api/auth/change-password', (req, res) => {
  const { email, currentPassword, newPassword } = req.body;

  if (!email || !currentPassword || !newPassword) {
    return res.status(400).json({ success: false, message: 'Data tidak lengkap' });
  }
  if (newPassword.length < 6) {
    return res.status(400).json({ success: false, message: 'Password baru minimal 6 karakter' });
  }

  const db = readDb();
  const idx = (db.users || []).findIndex(u => u.email.toLowerCase() === email.trim().toLowerCase());

  if (idx === -1) {
    return res.status(400).json({ success: false, message: 'Pengguna tidak ditemukan' });
  }

  const user = db.users[idx];
  const isValid = verifyPassword(currentPassword, user.password) || user.password === currentPassword;
  if (!isValid) {
    return res.status(400).json({ success: false, message: 'Password saat ini tidak cocok' });
  }

  db.users[idx].password = hashPassword(newPassword);
  writeDb(db);

  res.json({
    success: true,
    message: 'Password berhasil diubah.'
  });
});

app.get('/api/auth/users', (req, res) => {
  const db = readDb();
  res.json({
    success: true,
    total: db.users ? db.users.length : 0,
    data: db.users || []
  });
});

app.put('/api/auth/users/:id', (req, res) => {
  const db = readDb();
  if (!db.users) db.users = [];
  const index = db.users.findIndex(u => u.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan' });
  }

  const { name, email, phone, role, password } = req.body;
  const existing = db.users[index];

  if (email && email.trim().toLowerCase() !== existing.email.toLowerCase()) {
    const emailExists = db.users.some(u => u.id !== req.params.id && u.email.toLowerCase() === email.trim().toLowerCase());
    if (emailExists) {
      return res.status(400).json({ success: false, message: `Email "${email.trim()}" sudah digunakan akun lain` });
    }
  }

  const updatedUser = {
    ...existing,
    name: name !== undefined ? name.trim() : existing.name,
    email: email !== undefined ? email.trim().toLowerCase() : existing.email,
    phone: phone !== undefined ? phone.trim() : existing.phone,
    role: role !== undefined ? role.trim() : (existing.role || 'Member Gear & Trail'),
    password: password && password.trim().length >= 6 ? hashPassword(password.trim()) : existing.password,
    updatedAt: new Date().toISOString()
  };

  db.users[index] = updatedUser;
  writeDb(db);

  const { password: _, ...userWithoutPassword } = updatedUser;

  res.json({
    success: true,
    message: 'Data pengguna berhasil diperbarui',
    data: userWithoutPassword
  });
});

app.delete('/api/auth/users/:id', (req, res) => {
  const db = readDb();
  if (!db.users) db.users = [];
  const target = db.users.find(u => u.id === req.params.id);

  if (!target) {
    return res.status(404).json({ success: false, message: 'Pengguna tidak ditemukan' });
  }

  db.users = db.users.filter(u => u.id !== req.params.id);
  writeDb(db);

  res.json({
    success: true,
    message: `Pengguna "${target.name}" berhasil dihapus`
  });
});

app.get('/api/auth/profile', (req, res) => {
  const db = readDb();
  const email = req.query.email;
  let user = null;

  if (email && db.users) {
    user = db.users.find(u => u.email.toLowerCase() === email.trim().toLowerCase());
  }
  if (!user && db.users && db.users.length > 0) {
    user = db.users[0];
  }

  if (!user) {
    user = {
      id: 'usr-1',
      name: 'Budi Santoso',
      email: 'budi.santoso@gmail.com',
      phone: '081234567890',
      role: 'Member Gear & Trail',
      primaryAddress: 'Jl. Mawar No. 12, RT 03/RW 05, Kel. Sukamaju, Kec. Cilandak, Jakarta Selatan'
    };
  }

  const { password: _, ...userWithoutPassword } = user;

  res.json({
    success: true,
    user: {
      ...userWithoutPassword,
      role: userWithoutPassword.role || 'Member Gear & Trail',
      primaryAddress: userWithoutPassword.primaryAddress || 'Jl. Mawar No. 12, RT 03/RW 05, Kel. Sukamaju, Kec. Cilandak, Jakarta Selatan'
    }
  });
});

// ----------------------------------------------------
// 3. Products Routes
// ----------------------------------------------------
app.get('/api/products', (req, res) => {
  const db = readDb();
  let products = db.products || [];
  const { category, search, isFavorite } = req.query;

  if (category && category !== 'Semua') {
    products = products.filter(p => p.categories && p.categories.includes(category));
  }

  if (search) {
    const q = search.toLowerCase();
    products = products.filter(p => p.name.toLowerCase().includes(q) || p.description.toLowerCase().includes(q));
  }

  if (isFavorite === 'true') {
    products = products.filter(p => p.isFavorite === true);
  }

  res.json({
    success: true,
    total: products.length,
    data: products
  });
});

app.get('/api/products/:id', (req, res) => {
  const db = readDb();
  const product = (db.products || []).find(p => p.id === req.params.id);

  if (!product) {
    return res.status(404).json({ success: false, message: 'Produk tidak ditemukan' });
  }

  res.json({ success: true, data: product });
});

app.post('/api/products', (req, res) => {
  const db = readDb();
  const { name, description, price, imageUrl, categories, badge, isFavorite, stock } = req.body;

  if (!name || !price) {
    return res.status(400).json({ success: false, message: 'Nama dan harga produk wajib diisi' });
  }

  const newProduct = {
    id: 'p' + (Date.now()),
    name,
    description: description || '',
    price: Number(price),
    imageUrl: imageUrl || 'https://images.unsplash.com/photo-1626132647523-66f5bf380027?w=600&auto=format&fit=crop&q=80',
    categories: Array.isArray(categories) ? categories : (categories ? [categories] : ['Sepeda Gunung (MTB)']),
    badge: badge || null,
    isFavorite: Boolean(isFavorite),
    stock: stock ? Number(stock) : 20,
    createdAt: new Date().toISOString()
  };

  db.products.unshift(newProduct);
  writeDb(db);

  res.status(201).json({
    success: true,
    message: 'Produk berhasil ditambahkan',
    data: newProduct
  });
});

app.put('/api/products/:id', (req, res) => {
  const db = readDb();
  const index = db.products.findIndex(p => p.id === req.params.id);

  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Produk tidak ditemukan' });
  }

  const existing = db.products[index];
  const updated = {
    ...existing,
    ...req.body,
    price: req.body.price !== undefined ? Number(req.body.price) : existing.price,
    stock: req.body.stock !== undefined ? Number(req.body.stock) : existing.stock,
    updatedAt: new Date().toISOString()
  };

  db.products[index] = updated;
  writeDb(db);

  res.json({
    success: true,
    message: 'Produk berhasil diperbarui',
    data: updated
  });
});

app.delete('/api/products/:id', (req, res) => {
  const db = readDb();
  const initialLength = db.products.length;
  db.products = db.products.filter(p => p.id !== req.params.id);

  if (db.products.length === initialLength) {
    return res.status(404).json({ success: false, message: 'Produk tidak ditemukan' });
  }

  writeDb(db);
  res.json({ success: true, message: 'Produk berhasil dihapus' });
});

// ----------------------------------------------------
// 4. Categories Routes (Full CRUD + Sync)
// ----------------------------------------------------
// Helper to normalize categories to object array
function getNormalizedCategories(db) {
  if (!db.categories) return [];
  return db.categories.map((cat, idx) => {
    if (typeof cat === 'string') {
      return { id: 'cat-' + (idx + 1), name: cat, description: `Kategori produk ${cat}` };
    }
    return cat;
  });
}

app.get('/api/categories', (req, res) => {
  const db = readDb();
  const categories = getNormalizedCategories(db);
  res.json({
    success: true,
    total: categories.length,
    data: categories
  });
});

app.post('/api/categories', (req, res) => {
  const db = readDb();
  const { name, description } = req.body;

  if (!name || !name.trim()) {
    return res.status(400).json({ success: false, message: 'Nama katalog wajib diisi' });
  }

  let categories = getNormalizedCategories(db);
  const existing = categories.find(c => c.name.toLowerCase() === name.trim().toLowerCase());
  if (existing) {
    return res.status(400).json({ success: false, message: `Katalog "${name.trim()}" sudah ada` });
  }

  const newCategory = {
    id: 'cat-' + Date.now(),
    name: name.trim(),
    description: description ? description.trim() : `Kategori produk ${name.trim()}`
  };

  categories.push(newCategory);
  db.categories = categories;
  writeDb(db);

  res.status(201).json({
    success: true,
    message: 'Katalog baru berhasil ditambahkan',
    data: newCategory
  });
});

app.put('/api/categories/:id', (req, res) => {
  const db = readDb();
  const { name, description } = req.body;
  let categories = getNormalizedCategories(db);
  const index = categories.findIndex(c => c.id === req.params.id || c.name === req.params.id);

  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Katalog tidak ditemukan' });
  }

  const oldName = categories[index].name;
  const newName = name && name.trim() ? name.trim() : oldName;

  categories[index] = {
    ...categories[index],
    name: newName,
    description: description !== undefined ? description.trim() : categories[index].description
  };

  // Sync with products if category name changed
  if (oldName !== newName && db.products) {
    db.products.forEach(p => {
      if (p.categories && Array.isArray(p.categories)) {
        p.categories = p.categories.map(catName => catName === oldName ? newName : catName);
      }
    });
  }

  db.categories = categories;
  writeDb(db);

  res.json({
    success: true,
    message: 'Katalog berhasil diperbarui',
    data: categories[index]
  });
});

app.delete('/api/categories/:id', (req, res) => {
  const db = readDb();
  let categories = getNormalizedCategories(db);
  const targetCategory = categories.find(c => c.id === req.params.id || c.name === req.params.id);

  if (!targetCategory) {
    return res.status(404).json({ success: false, message: 'Katalog tidak ditemukan' });
  }

  const catName = targetCategory.name;
  categories = categories.filter(c => c.id !== targetCategory.id);

  // Remove category from products
  if (db.products) {
    db.products.forEach(p => {
      if (p.categories && Array.isArray(p.categories)) {
        p.categories = p.categories.filter(c => c !== catName);
      }
    });
  }

  db.categories = categories;
  writeDb(db);

  res.json({
    success: true,
    message: `Katalog "${catName}" berhasil dihapus`
  });
});


// ----------------------------------------------------
// 5. Orders Routes
// ----------------------------------------------------
app.get('/api/orders', (req, res) => {
  const db = readDb();
  res.json({
    success: true,
    total: db.orders ? db.orders.length : 0,
    data: db.orders || []
  });
});

app.get('/api/orders/:id', (req, res) => {
  const db = readDb();
  const targetId = (req.params.id || '').trim().toLowerCase();
  const order = (db.orders || []).find(o => 
    (o.id && o.id.toString().trim().toLowerCase() === targetId) ||
    (o.orderId && o.orderId.toString().trim().toLowerCase() === targetId)
  );
  if (!order) {
    return res.status(404).json({ success: false, message: 'Pesanan tidak ditemukan' });
  }
  res.json({
    success: true,
    data: order
  });
});

app.post('/api/orders', (req, res) => {
  const db = readDb();
  const { orderId, customerName, customerPhone, shippingAddress, items, subtotal, shippingFee, totalAmount, latitude, longitude } = req.body;

  if (!items || items.length === 0) {
    return res.status(400).json({ success: false, message: 'Item pesanan tidak boleh kosong' });
  }

  const newOrderId = orderId || req.body.id || ('ORD-' + Math.floor(1000 + Math.random() * 9000));

  const newOrder = {
    id: newOrderId,
    orderId: newOrderId,
    customerName: customerName || 'Pelanggan Gear & Trail',
    customerPhone: customerPhone || '081234567890',
    shippingAddress: shippingAddress || 'Alamat Utama Pelanggan',
    latitude: latitude || -6.200000,
    longitude: longitude || 106.816666,
    items: items,
    subtotal: subtotal || items.reduce((acc, curr) => acc + (curr.totalPrice || curr.price * curr.quantity), 0),
    shippingFee: shippingFee || 10000,
    totalAmount: totalAmount || (subtotal + (shippingFee || 10000)),
    status: 'Diproses',
    createdAt: new Date().toISOString()
  };

  db.orders.unshift(newOrder);
  writeDb(db);

  res.status(201).json({
    success: true,
    message: 'Pesanan berhasil dibuat',
    data: newOrder
  });
});

app.put('/api/orders/:id/status', (req, res) => {
  const db = readDb();
  const { status } = req.body;
  const targetId = (req.params.id || '').trim().toLowerCase();
  const index = (db.orders || []).findIndex(o => 
    (o.id && o.id.toString().trim().toLowerCase() === targetId) ||
    (o.orderId && o.orderId.toString().trim().toLowerCase() === targetId)
  );

  if (index === -1) {
    return res.status(404).json({ success: false, message: 'Pesanan tidak ditemukan' });
  }

  db.orders[index].status = status;
  db.orders[index].updatedAt = new Date().toISOString();
  writeDb(db);

  res.json({
    success: true,
    message: `Status pesanan berhasil diubah menjadi ${status}`,
    data: db.orders[index]
  });
});

// ----------------------------------------------------
// 6. Admin Dashboard Stats
// ----------------------------------------------------
app.get('/api/stats', (req, res) => {
  const db = readDb();
  const products = db.products || [];
  const orders = db.orders || [];
  const users = db.users || [];

  const totalRevenue = orders.reduce((sum, o) => sum + (o.totalAmount || 0), 0);
  const totalOrders = orders.length;
  const activeProducts = products.length;
  const favoriteProductsCount = products.filter(p => p.isFavorite).length;
  const totalUsers = users.length;

  res.json({
    success: true,
    data: {
      totalRevenue,
      totalOrders,
      activeProducts,
      favoriteProductsCount,
      totalUsers,
      recentOrders: orders.slice(0, 5)
    }
  });
});

// Start Server
app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🚴‍♂️ Gear & Trail Backend REST API Server is running!`);
  console.log(`URL: http://localhost:${PORT}`);
  console.log(`Health Check: http://localhost:${PORT}/api/health`);
  console.log(`Products API: http://localhost:${PORT}/api/products`);
  console.log(`====================================================`);
});
