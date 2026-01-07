import Stripe from "stripe";
import { env } from "./env";

export const stripe = env.STRIPE_SECRET_KEY
  ? new Stripe(env.STRIPE_SECRET_KEY, {
      apiVersion: "2025-11-17.clover",
    })
  : (null as unknown as Stripe);

export const PRICE_IDS = {
  monthly: env.STRIPE_PRICE_MONTHLY,
  yearly: env.STRIPE_PRICE_YEARLY,
  lifetime: env.STRIPE_PRICE_LIFETIME,
};

// Create a checkout session for Pro subscription
export async function createCheckoutSession(
  userId: string,
  userEmail: string,
  plan: "monthly" | "yearly" | "lifetime",
  customerId?: string
): Promise<string> {
  const baseUrl = env.APP_URL;
  const priceId = PRICE_IDS[plan];

  if (!priceId) {
    throw new Error(`Price ID for ${plan} plan is not configured`);
  }

  const sessionParams: Stripe.Checkout.SessionCreateParams = {
    mode: plan === "lifetime" ? "payment" : "subscription",
    payment_method_types: ["card"],
    line_items: [{ price: priceId, quantity: 1 }],
    success_url: `${baseUrl}/dashboard?upgraded=true`,
    cancel_url: `${baseUrl}/dashboard`,
    metadata: { userId, plan },
    allow_promotion_codes: true,
    customer_email: customerId ? undefined : userEmail,
    customer: customerId || undefined,
  };

  const session = await stripe.checkout.sessions.create(sessionParams);
  return session.url!;
}

// Create a customer portal session for managing subscription
export async function createPortalSession(customerId: string): Promise<string> {
  const baseUrl = env.APP_URL;

  const session = await stripe.billingPortal.sessions.create({
    customer: customerId,
    return_url: `${baseUrl}/dashboard`,
  });

  return session.url;
}
