create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now()
);

create table if not exists public.gifts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  slug text not null unique,
  title text not null default 'A little something for you',
  occasion text not null default 'Just Because',
  recipient_name text,
  pin_hash text,
  config jsonb not null default '{}'::jsonb,
  published boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.assets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  kind text not null check (kind in ('image','audio','video','file')),
  name text not null,
  storage_path text not null unique,
  mime_type text,
  size_bytes bigint,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.gift_assets (
  gift_id uuid not null references public.gifts(id) on delete cascade,
  asset_id uuid not null references public.assets(id) on delete cascade,
  role text not null default 'media',
  sort_order integer not null default 0,
  primary key (gift_id,asset_id)
);

create or replace function public.set_updated_at()
returns trigger language plpgsql set search_path = public as $$
begin new.updated_at=now(); return new; end;
$$;

drop trigger if exists gifts_set_updated_at on public.gifts;
create trigger gifts_set_updated_at before update on public.gifts for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles(id,display_name) values (new.id,new.raw_user_meta_data->>'display_name') on conflict (id) do nothing;
  return new;
end;
$$;

revoke all on function public.handle_new_user() from public,anon,authenticated;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.gifts enable row level security;
alter table public.assets enable row level security;
alter table public.gift_assets enable row level security;

create policy profiles_owner_select on public.profiles for select to authenticated using (id=auth.uid());
create policy profiles_owner_update on public.profiles for update to authenticated using (id=auth.uid()) with check (id=auth.uid());

create policy gifts_owner_all on public.gifts for all to authenticated using (owner_id=auth.uid()) with check (owner_id=auth.uid());
create policy assets_owner_all on public.assets for all to authenticated using (owner_id=auth.uid()) with check (owner_id=auth.uid());
create policy gift_assets_owner_all on public.gift_assets for all to authenticated using (exists(select 1 from public.gifts g where g.id=gift_assets.gift_id and g.owner_id=auth.uid())) with check (exists(select 1 from public.gifts g where g.id=gift_assets.gift_id and g.owner_id=auth.uid()) and exists(select 1 from public.assets a where a.id=gift_assets.asset_id and a.owner_id=auth.uid()));

create index if not exists gifts_owner_updated_idx on public.gifts(owner_id,updated_at desc);
create index if not exists assets_owner_created_idx on public.assets(owner_id,created_at desc);
create index if not exists gift_assets_gift_order_idx on public.gift_assets(gift_id,sort_order);

insert into storage.buckets(id,name,public) values ('wishloom','wishloom',false) on conflict (id) do nothing;
create policy wishloom_owner_select on storage.objects for select to authenticated using (bucket_id='wishloom' and (storage.foldername(name))[1]=auth.uid()::text);
create policy wishloom_owner_insert on storage.objects for insert to authenticated with check (bucket_id='wishloom' and (storage.foldername(name))[1]=auth.uid()::text);
create policy wishloom_owner_delete on storage.objects for delete to authenticated using (bucket_id='wishloom' and (storage.foldername(name))[1]=auth.uid()::text);
