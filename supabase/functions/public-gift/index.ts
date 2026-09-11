import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const cors={"Access-Control-Allow-Origin":"*","Access-Control-Allow-Headers":"content-type","Access-Control-Allow-Methods":"GET,POST,OPTIONS","Content-Type":"application/json"};

async function sha(pin:string){const h=await crypto.subtle.digest("SHA-256",new TextEncoder().encode(pin));return Array.from(new Uint8Array(h)).map(x=>x.toString(16).padStart(2,"0")).join("")}

Deno.serve(async(req)=>{
  if(req.method==="OPTIONS")return new Response("ok",{headers:cors});
  try{
    const url=new URL(req.url);const slug=url.searchParams.get("slug");
    if(!slug)return new Response(JSON.stringify({error:"Missing slug."}),{status:400,headers:cors});
    const admin=createClient(Deno.env.get("SUPABASE_URL")!,Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,{auth:{autoRefreshToken:false,persistSession:false}});
    const {data:gift,error}=await admin.from("gifts").select("id,title,occasion,recipient_name,config,pin_hash,slug,cover_asset_id").eq("slug",slug).eq("published",true).maybeSingle();
    if(error||!gift)return new Response(JSON.stringify({error:"Gift not found."}),{status:404,headers:cors});
    if(gift.pin_hash){
      if(req.method==="GET")return new Response(JSON.stringify({pin_required:true,title:gift.title,occasion:gift.occasion,recipient_name:gift.recipient_name}),{status:401,headers:cors});
      const body=await req.json().catch(()=>({}));
      if(await sha(String(body.pin||""))!==gift.pin_hash)return new Response(JSON.stringify({error:"Wrong PIN."}),{status:401,headers:cors});
    }
    const {data:links}=await admin.from("gift_assets").select("sort_order,role,assets(id,name,kind,storage_path)").eq("gift_id",gift.id).order("sort_order",{ascending:true});
    const assets=[];
    for(const row of links??[]){const asset=row.assets as any;if(!asset)continue;const {data:signed}=await admin.storage.from("wishloom").createSignedUrl(asset.storage_path,86400);assets.push({id:asset.id,name:asset.name,kind:asset.kind,role:row.role,url:signed?.signedUrl??null})}
    await admin.rpc("increment_gift_view",{p_slug:slug});
    delete gift.pin_hash;
    return new Response(JSON.stringify({...gift,assets}),{headers:cors});
  }catch{return new Response(JSON.stringify({error:"Unexpected error."}),{status:500,headers:cors})}
});
