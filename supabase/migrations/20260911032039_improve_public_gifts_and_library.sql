create index if not exists gifts_published_slug_idx on public.gifts(slug) where published=true;
create index if not exists gift_assets_gift_order_idx on public.gift_assets(gift_id,sort_order);
alter table public.gifts add column if not exists view_count bigint not null default 0;
alter table public.gifts add column if not exists cover_asset_id uuid references public.assets(id) on delete set null;

create or replace function public.increment_gift_view(p_slug text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.gifts set view_count=view_count+1 where slug=p_slug and published=true;
end;
$$;
revoke all on function public.increment_gift_view(text) from public,anon,authenticated;
