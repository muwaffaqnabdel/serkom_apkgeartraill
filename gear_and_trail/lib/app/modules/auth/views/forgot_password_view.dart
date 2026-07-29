import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/providers/product_provider.dart';
import '../../auth/controllers/auth_controller.dart';

/// ForgotPasswordView — 3 langkah: Email → OTP → Password Baru
class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _provider = Get.find<ProductProvider>();
  final _authController = Get.find<AuthController>();

  // Step control: 1 = email, 2 = OTP, 3 = password baru
  int _step = 1;
  bool _isLoading = false;

  // Step 1 — email
  final _emailController = TextEditingController();

  // Step 2 — OTP
  final _otpController = TextEditingController();
  String _resetToken = '';

  // Step 3 — new password
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ------------------------------------------------
  // Step 1: Request OTP
  // ------------------------------------------------
  Future<void> _sendOtp() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showError('Harap masukkan email Anda');
      return;
    }
    if (!GetUtils.isEmail(email)) {
      _showError('Format email tidak valid');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await _provider.forgotPassword(email);
      if (res == null) {
        _showError('Gagal terhubung ke server. Coba lagi.');
        return;
      }
      if (res['success'] == true) {
        _resetToken = res['resetToken']?.toString() ?? '';
        setState(() => _step = 2);

        Get.snackbar(
          'Kode OTP Terkirim!',
          'Silakan periksa Kotak Masuk (Inbox) atau Folder Spam Gmail Anda.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E3A2F),
          colorText: Colors.white,
          duration: const Duration(seconds: 6),
          margin: const EdgeInsets.all(16),
        );
      } else {
        _showError(res['message'] ?? 'Terjadi kesalahan');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------
  // Step 2: Verify OTP
  // ------------------------------------------------
  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      _showError('Masukkan kode OTP 6 digit');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await _provider.verifyResetOtp(_emailController.text.trim(), otp);
      if (res == null) {
        _showError('Gagal terhubung ke server. Coba lagi.');
        return;
      }
      if (res['success'] == true) {
        _resetToken = res['resetToken']?.toString() ?? _resetToken;
        setState(() => _step = 3);
      } else {
        _showError(res['message'] ?? 'Kode OTP tidak valid');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ------------------------------------------------
  // Step 3: Reset Password
  // ------------------------------------------------
  Future<void> _resetPassword() async {
    final newPw = _newPasswordController.text.trim();
    final confirmPw = _confirmPasswordController.text.trim();
    if (newPw.isEmpty || newPw.length < 6) {
      _showError('Password minimal 6 karakter');
      return;
    }
    if (newPw != confirmPw) {
      _showError('Konfirmasi password tidak cocok');
      return;
    }
    setState(() => _isLoading = true);
    try {
      final res = await _provider.resetPassword(
        _emailController.text.trim(),
        _resetToken,
        newPw,
      );
      if (res == null) {
        _showError('Gagal terhubung ke server. Coba lagi.');
        return;
      }
      if (res['success'] == true) {
        Get.snackbar(
          'Password Berhasil Direset!',
          'Anda akan diarahkan ke halaman login.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF047857),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
        await Future.delayed(const Duration(seconds: 2));
        // Logout otomatis setelah reset password — hapus sesi & redirect ke login
        _authController.logout();
      } else {
        _showError(res['message'] ?? 'Gagal mereset password');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Perhatian',
      msg,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFDC2626),
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1E3A2F), size: 20),
          onPressed: () {
            if (_step > 1) {
              setState(() => _step--);
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          _step == 1 ? 'Lupa Password' : _step == 2 ? 'Verifikasi OTP' : 'Buat Password Baru',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A2F),
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Progress indicator
            _buildStepIndicator(),
            const SizedBox(height: 32),

            // Icon
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFA7F3D0), width: 2),
              ),
              child: Icon(
                _step == 1
                    ? Icons.email_outlined
                    : _step == 2
                        ? Icons.lock_clock_outlined
                        : Icons.lock_reset_outlined,
                size: 42,
                color: const Color(0xFF1E3A2F),
              ),
            ),
            const SizedBox(height: 20),

            Text(
              _step == 1
                  ? 'Masukkan Email Terdaftar'
                  : _step == 2
                      ? 'Masukkan Kode OTP'
                      : 'Buat Password Baru',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3A2F),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _step == 1
                  ? 'Kami akan mengirimkan kode OTP ke email Anda untuk memulai proses reset password.'
                  : _step == 2
                      ? 'Masukkan kode 6 digit yang dikirimkan ke email ${_emailController.text.trim()}'
                      : 'Buat password baru yang kuat dan mudah diingat. Minimal 6 karakter.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Form card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  if (_step == 1) _buildStep1(),
                  if (_step == 2) _buildStep2(),
                  if (_step == 3) _buildStep3(),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () {
                            if (_step == 1) _sendOtp();
                            if (_step == 2) _verifyOtp();
                            if (_step == 3) _resetPassword();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3A2F),
                      disabledBackgroundColor: const Color(0xFF94A3B8),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            _step == 1
                                ? 'Kirim Kode OTP'
                                : _step == 2
                                    ? 'Verifikasi Kode'
                                    : 'Reset Password',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                  ),
                  if (_step == 2) ...[
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: _isLoading ? null : () => setState(() => _step = 1),
                      child: const Text(
                        'Kirim ulang kode OTP',
                        style: TextStyle(
                          color: Color(0xFFEA580C),
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        final active = i + 1 == _step;
        final done = i + 1 < _step;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: active ? 32 : 12,
              height: 12,
              decoration: BoxDecoration(
                color: done || active ? const Color(0xFF1E3A2F) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            if (i < 2)
              Container(
                width: 24,
                height: 2,
                color: done ? const Color(0xFF1E3A2F) : const Color(0xFFCBD5E1),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStep1() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'email@contoh.com',
        hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
        prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF64748B)),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E3A2F),
            letterSpacing: 12,
          ),
          decoration: InputDecoration(
            hintText: '------',
            hintStyle: const TextStyle(color: Color(0xFFCBD5E1), letterSpacing: 8, fontSize: 24),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFECFDF5),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFA7F3D0)),
          ),
          child: const Row(
            children: [
              Icon(Icons.mark_email_unread_outlined, color: Color(0xFF047857), size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Cek Kotak Masuk (Inbox) atau Folder Spam di Gmail Anda untuk melihat kode OTP 6-digit.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF047857), fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNew,
          decoration: InputDecoration(
            hintText: 'Password baru (min. 6 karakter)',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF64748B)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNew ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
              ),
              onPressed: () => setState(() => _obscureNew = !_obscureNew),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirm,
          decoration: InputDecoration(
            hintText: 'Ulangi password baru',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            prefixIcon: const Icon(Icons.lock_reset_outlined, color: Color(0xFF64748B)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1E3A2F), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
