export const SITE = {
  name: "{{PROJECT_NAME}}",
  tagline: "Your SaaS tagline here",
  description: "A brief description of your SaaS product.",
  url: process.env.NEXT_PUBLIC_APP_URL || "http://localhost:3000", // Must use process.env for client components
  twitter: "@yourusername",
};
