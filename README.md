# Wishloom

Wishloom is a private, personal gift-site builder for friends and family.

It turns photos, songs, videos and words into a small interactive world that can be shared through a private link with an optional PIN.

## Stack

- Next.js + React + TypeScript
- Supabase Auth, Postgres, RLS and private Storage
- Supabase Edge Function for public gift delivery
- Vercel for hosting

## Principles

- No public gift directory
- Private assets are stored in a private bucket
- Published gifts expose only the data needed by the recipient
- PINs are stored as SHA-256 hashes, never plaintext
- Library assets are reusable across gifts
- No payment or monetization features

## Local development

Create `.env.local` from `.env.example`, then run:

```bash
npm install
npm run dev
```

For a production check:

```bash
npm run typecheck
npm run build
```

Never commit Supabase service-role keys or other secrets.
