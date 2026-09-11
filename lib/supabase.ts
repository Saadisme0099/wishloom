import { createBrowserClient } from '@supabase/ssr'
const url=process.env.NEXT_PUBLIC_SUPABASE_URL||'https://eohrmlftexayzgiaedpq.supabase.co'
const key=process.env.NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY||'sb_publishable_7mwNrxrI_yjp3d4FT9Oofw_lmLJBwci'
export function supabase(){return createBrowserClient(url,key)}
export async function hashPin(pin:string){const data=new TextEncoder().encode(pin);const hash=await crypto.subtle.digest('SHA-256',data);return Array.from(new Uint8Array(hash)).map(x=>x.toString(16).padStart(2,'0')).join('')}
