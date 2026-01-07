"use client";

import { useRouter } from "next/navigation";
import { signOut } from "@/lib/auth-client";
import { Button } from "@/components/ui/button";
import { SITE } from "@/constants";
import type { User } from "@/lib/db/schema";

interface DashboardContentProps {
  user: User;
}

export function DashboardContent({ user }: DashboardContentProps) {
  const router = useRouter();

  const handleSignOut = async () => {
    await signOut();
    router.push("/");
  };

  return (
    <div className="min-h-screen">
      {/* Header */}
      <header className="border-b border-border">
        <div className="container mx-auto px-4 h-16 flex items-center justify-between">
          <span className="text-xl font-semibold">{SITE.name}</span>
          <div className="flex items-center gap-4">
            <span className="text-sm text-muted-foreground">{user.email}</span>
            <Button variant="ghost" onClick={handleSignOut}>
              Sign out
            </Button>
          </div>
        </div>
      </header>

      {/* Main */}
      <main className="container mx-auto px-4 py-8">
        <div className="mb-8">
          <h1 className="text-3xl font-bold">Welcome, {user.name}!</h1>
          <p className="text-muted-foreground mt-2">
            This is your dashboard. Start building something amazing.
          </p>
        </div>

        {/* Status Card */}
        <div className="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
          <div className="rounded-lg border border-border p-6">
            <h3 className="font-semibold mb-2">Account Status</h3>
            <p className="text-sm text-muted-foreground">
              {user.isPro ? (
                <span className="text-green-500">Pro Member</span>
              ) : (
                <span>Free Plan</span>
              )}
            </p>
          </div>

          <div className="rounded-lg border border-border p-6">
            <h3 className="font-semibold mb-2">Email</h3>
            <p className="text-sm text-muted-foreground">{user.email}</p>
          </div>

          <div className="rounded-lg border border-border p-6">
            <h3 className="font-semibold mb-2">Member Since</h3>
            <p className="text-sm text-muted-foreground">
              {new Date(user.createdAt).toLocaleDateString()}
            </p>
          </div>
        </div>

        {/* Upgrade CTA for free users */}
        {!user.isPro && (
          <div className="mt-8 rounded-lg border border-primary/50 bg-primary/5 p-6">
            <h3 className="font-semibold mb-2">Upgrade to Pro</h3>
            <p className="text-sm text-muted-foreground mb-4">
              Unlock all features and take your experience to the next level.
            </p>
            <Button>Upgrade Now</Button>
          </div>
        )}
      </main>
    </div>
  );
}
