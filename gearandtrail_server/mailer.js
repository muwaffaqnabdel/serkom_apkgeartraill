const nodemailer = require('nodemailer');

/**
 * Modul Pengirim Email OTP menggunakan Nodemailer + Gmail SMTP
 */
function createTransporter() {
  const user = process.env.EMAIL_USER;
  const pass = process.env.EMAIL_PASS ? process.env.EMAIL_PASS.replace(/\s+/g, '') : '';

  if (!user || !pass) {
    return null;
  }

  return nodemailer.createTransport({
    service: 'gmail',
    host: 'smtp.gmail.com',
    port: 465,
    secure: true,
    auth: {
      user: user,
      pass: pass
    }
  });
}

/**
 * Kirim Email Kode OTP Reset Password
 * @param {string} toEmail - Alamat Gmail penerima
 * @param {string} otpCode - Kode OTP 6 digit
 */
async function sendOtpEmail(toEmail, otpCode) {
  const transporter = createTransporter();

  if (!transporter) {
    console.log(`[Mailer Info] SMTP belum dikonfigurasi di .env. Kode OTP [${otpCode}] untuk [${toEmail}] dapat dilihat di log/response.`);
    return {
      success: false,
      reason: 'SMTP_NOT_CONFIGURED',
      message: 'SMTP Email belum diisi di .env'
    };
  }

  const mailOptions = {
    from: `"Gear & Trail Support" <${process.env.EMAIL_USER}>`,
    to: toEmail,
    subject: `🔐 Kode OTP Reset Password Anda: ${otpCode}`,
    html: `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <style>
          body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f8fafc; margin: 0; padding: 20px; color: #0f172a; }
          .container { max-width: 540px; margin: 0 auto; background: #ffffff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 20px rgba(0,0,0,0.06); border: 1px solid #e2e8f0; }
          .header { background-color: #1E3A2F; padding: 32px 24px; text-align: center; color: #ffffff; }
          .header h1 { margin: 0; font-size: 24px; letter-spacing: 1.5px; font-weight: 900; }
          .content { padding: 32px 24px; text-align: center; }
          .otp-box { background-color: #ECFDF5; border: 2px dashed #A7F3D0; border-radius: 12px; padding: 20px; margin: 24px 0; display: inline-block; width: 80%; }
          .otp-code { font-size: 36px; font-weight: 900; letter-spacing: 10px; color: #1E3A2F; margin: 0; }
          .warning { font-size: 13px; color: #64748b; line-height: 1.6; margin-top: 20px; }
          .footer { background-color: #f1f5f9; padding: 16px 24px; text-align: center; font-size: 12px; color: #94a3b8; border-top: 1px solid #e2e8f0; }
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>🚴‍♂️ GEAR & TRAIL</h1>
            <p style="margin: 6px 0 0 0; font-size: 13px; opacity: 0.85;">Verifikasi Keamanan Akun</p>
          </div>
          <div class="content">
            <h2 style="color: #1E3A2F; margin-top: 0;">Kode OTP Reset Password</h2>
            <p style="font-size: 14px; color: #475569; line-height: 1.5;">
              Halo! Kami menerima permintaan reset password untuk akun <strong>${toEmail}</strong>.
              Gunakan kode OTP 6-digit di bawah ini untuk melanjutkan:
            </p>
            <div class="otp-box">
              <p class="otp-code">${otpCode}</p>
            </div>
            <p class="warning">
              ⏳ Kode OTP ini berlaku selama <strong>15 menit</strong>.<br>
              ⚠️ Jangan berikan kode ini kepada siapa pun, termasuk pihak Gear & Trail.
            </p>
          </div>
          <div class="footer">
            © 2026 Ekosistem Gear & Trail. Hak Cipta Dilindungi.<br>
            Email ini dikirim secara otomatis, harap jangan membalas pesan ini.
          </div>
        </div>
      </body>
      </html>
    `
  };

  try {
    const info = await transporter.sendMail(mailOptions);
    console.log(`✅ [Mailer Success] Email OTP terkirim ke ${toEmail}. Message ID: ${info.messageId}`);
    return {
      success: true,
      messageId: info.messageId
    };
  } catch (error) {
    console.error(`❌ [Mailer Error] Gagal mengirim email OTP ke ${toEmail}:`, error.message);
    return {
      success: false,
      reason: 'SEND_FAILED',
      error: error.message
    };
  }
}

module.exports = {
  sendOtpEmail
};
