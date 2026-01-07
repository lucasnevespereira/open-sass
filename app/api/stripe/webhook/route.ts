import { NextRequest, NextResponse } from "next/server";
import { stripe } from "@/lib/stripe";
import { db } from "@/lib/db";
import { users } from "@/lib/db/schema";
import { eq } from "drizzle-orm";
import { env } from "@/lib/env";
import Stripe from "stripe";

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = request.headers.get("stripe-signature");

  if (!signature) {
    return NextResponse.json({ error: "No signature" }, { status: 400 });
  }

  let event: Stripe.Event;

  try {
    event = stripe.webhooks.constructEvent(
      body,
      signature,
      env.STRIPE_WEBHOOK_SECRET
    );
  } catch (err) {
    console.error("Webhook signature verification failed:", err);
    return NextResponse.json({ error: "Invalid signature" }, { status: 400 });
  }

  try {
    switch (event.type) {
      case "checkout.session.completed": {
        const session = event.data.object as Stripe.Checkout.Session;
        const userId = session.metadata?.userId;
        const plan = session.metadata?.plan as "monthly" | "yearly" | "lifetime";

        if (userId) {
          await db
            .update(users)
            .set({
              isPro: true,
              stripeCustomerId: session.customer as string,
              subscriptionStatus: "active",
              subscriptionPlan: plan,
              subscriptionExpiresAt:
                plan === "lifetime"
                  ? null
                  : new Date(Date.now() + (plan === "yearly" ? 365 : 30) * 24 * 60 * 60 * 1000),
            })
            .where(eq(users.id, userId));
        }
        break;
      }

      case "customer.subscription.updated": {
        const subscription = event.data.object as Stripe.Subscription;
        const customerId = subscription.customer as string;

        const [user] = await db
          .select()
          .from(users)
          .where(eq(users.stripeCustomerId, customerId));

        if (user) {
          await db
            .update(users)
            .set({
              subscriptionStatus: subscription.status === "active" ? "active" : "canceled",
              subscriptionExpiresAt: new Date(subscription.current_period_end * 1000),
            })
            .where(eq(users.id, user.id));
        }
        break;
      }

      case "customer.subscription.deleted": {
        const subscription = event.data.object as Stripe.Subscription;
        const customerId = subscription.customer as string;

        const [user] = await db
          .select()
          .from(users)
          .where(eq(users.stripeCustomerId, customerId));

        if (user) {
          await db
            .update(users)
            .set({
              isPro: false,
              subscriptionStatus: "canceled",
            })
            .where(eq(users.id, user.id));
        }
        break;
      }
    }

    return NextResponse.json({ received: true });
  } catch (error) {
    console.error("Webhook handler error:", error);
    return NextResponse.json({ error: "Webhook handler failed" }, { status: 500 });
  }
}
