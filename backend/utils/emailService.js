const nodemailer = require('nodemailer');

// For now, this is a placeholder. 
// You will need to provide real SMTP credentials to send actual emails.
// Example for Gmail:
// host: 'smtp.gmail.com',
// auth: { user: 'your-email@gmail.com', pass: 'your-app-password' }

async function sendEmail(to, subject, text, html) {
  try {
    // Creating a test account if no real credentials provided
    // In production, use a real service.
    let transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.ethereal.email',
      port: process.env.EMAIL_PORT || 587,
      secure: false, // true for 465, false for other ports
      auth: {
        user: process.env.EMAIL_USER || 'placeholder', 
        pass: process.env.EMAIL_PASS || 'placeholder',
      },
    });

    let info = await transporter.sendMail({
      from: '"Eternia Sanctuary" <noreply@eternia.com>',
      to: to,
      subject: subject,
      text: text,
      html: html,
    });

    console.log(`[Email] Message sent to ${to}: ${info.messageId}`);
    return info;
  } catch (error) {
    console.error('[Email] Error sending email:', error);
    // Don't throw error to prevent blocking the whole process in dev
    return null;
  }
}

module.exports = { sendEmail };
