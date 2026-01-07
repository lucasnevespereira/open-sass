function required(key: string): string {
  const value = process.env[key];
  if (!value) {
    throw new Error(`Missing required env var: ${key}`);
  }
  return value;
}

function optional(key: string, defaultValue = ""): string {
  return process.env[key] || defaultValue;
}

export const env = {
  // App
  NODE_ENV: optional("ENV", "development"),
  APP_URL: optional("NEXT_PUBLIC_APP_URL", "http://localhost:3000"),

  // Database
  DATABASE_URL: required("DATABASE_URL"),

  // Auth
  BETTER_AUTH_SECRET: required("BETTER_AUTH_SECRET"),
  BETTER_AUTH_URL: optional("BETTER_AUTH_URL", "http://localhost:3000"),

  // Stripe
  STRIPE_SECRET_KEY: optional("STRIPE_SECRET_KEY"),
  STRIPE_PUBLISHABLE_KEY: optional("STRIPE_PUBLISHABLE_KEY"),
  STRIPE_WEBHOOK_SECRET: optional("STRIPE_WEBHOOK_SECRET"),
  STRIPE_PRICE_MONTHLY: optional("STRIPE_PRICE_MONTHLY"),
  STRIPE_PRICE_YEARLY: optional("STRIPE_PRICE_YEARLY"),
  STRIPE_PRICE_LIFETIME: optional("STRIPE_PRICE_LIFETIME"),

  // Email
  RESEND_API_KEY: optional("RESEND_API_KEY"),
} as const;
