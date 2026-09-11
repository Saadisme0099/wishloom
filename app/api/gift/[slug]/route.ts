import {NextRequest,NextResponse} from 'next/server'
const FN=process.env.NEXT_PUBLIC_SUPABASE_URL!+'/functions/v1/public-gift'
export async function GET(_r:NextRequest,{params}:{params:Promise<{slug:string}>}){const {slug}=await params;const r=await fetch(`${FN}?slug=${encodeURIComponent(slug)}`,{cache:'no-store'});return new NextResponse(await r.text(),{status:r.status,headers:{'Content-Type':'application/json'}})}
export async function POST(req:NextRequest,{params}:{params:Promise<{slug:string}>}){const {slug}=await params;const body=await req.text();const r=await fetch(`${FN}?slug=${encodeURIComponent(slug)}`,{method:'POST',headers:{'Content-Type':'application/json'},body});return new NextResponse(await r.text(),{status:r.status,headers:{'Content-Type':'application/json'}})}
