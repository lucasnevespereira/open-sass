import { Resend } from "resend";
import { env } from "./env";

const resend = env.RESEND_API_KEY
  ? new Resend(env.RESEND_API_KEY)
  : null;

export async function sendPasswordResetEmail(email: string, resetUrl: string) {
  if (!resend) {
    console.log("Resend not configured. Reset URL:", resetUrl);
    return;
  }

  await resend.emails.send({
    from: "noreply@yourdomain.com", // Update this
    to: email,
    subject: "Reset your password",
    html: `
      <h1>Reset your password</h1>
      <p>Click the link below to reset your password:</p>
      <a href="${resetUrl}">${resetUrl}</a>
      <p>If you didn't request this, you can safely ignore this email.</p>
    `,
  });
}

export async function sendWelcomeEmail(email: string, name: string) {
  if (!resend) {
    console.log("Resend not configured. Welcome email for:", email);
    return;
  }

  await resend.emails.send({
    from: "noreply@yourdomain.com", // Update this
    to: email,
    subject: "Welcome!",
    html: `
      <h1>Welcome, ${name}!</h1>
      <p>Thanks for signing up. We're excited to have you!</p>
    `,
  });
}
