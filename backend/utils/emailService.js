const nodemailer = require('nodemailer');

async function sendEmail(to, subject, text, html) {
  try {
    // Prevent hanging/timeouts in dev if no real credentials provided
    const user = process.env.EMAIL_USER || 'placeholder';
    if (user === 'placeholder') {
      console.log(`[Email-Simulation] Would send email to ${to}: ${subject}`);
      console.log(`[Email-Simulation] Content: ${text}`);
      return { messageId: 'simulated-id' };
    }

    let transporter = nodemailer.createTransport({
      host: process.env.EMAIL_HOST || 'smtp.ethereal.email',
      port: process.env.EMAIL_PORT || 587,
      secure: false, // true for 465, false for other ports
      auth: {
        user: user, 
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
