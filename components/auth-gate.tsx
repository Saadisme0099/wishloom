'use client'
import {useEffect,useState} from 'react';import {useRouter} from 'next/navigation';import {supabase} from '@/lib/supabase';import Nav from './nav'
export default function AuthGate({children}:{children:React.ReactNode}){const [ok,setOk]=useState(false);const router=useRouter();useEffect(()=>{supabase().auth.getUser().then(({data})=>{if(!data.user)router.replace('/login');else setOk(true)})},[router]);if(!ok)return <div className="min-h-screen grid place-items-center text-[#746d79]">Opening your loom…</div>;return <><Nav/><main>{children}</main></>}
