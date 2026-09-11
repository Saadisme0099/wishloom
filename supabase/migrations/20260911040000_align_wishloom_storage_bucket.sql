insert into storage.buckets(id,name,public,file_size_limit)
values ('wishloom','wishloom',false,26214400)
on conflict (id) do update set public=false,file_size_limit=26214400;

drop policy if exists wishloom_owner_select on storage.objects;
drop policy if exists wishloom_owner_insert on storage.objects;
drop policy if exists wishloom_owner_update on storage.objects;
drop policy if exists wishloom_owner_delete on storage.objects;

create policy wishloom_owner_select on storage.objects
for select to authenticated
using (bucket_id='wishloom' and (storage.foldername(name))[1]=auth.uid()::text);

create policy wishloom_owner_insert on storage.objects
for insert to authenticated
with check (bucket_id='wishloom' and (storage.foldername(name))[1]=auth.uid()::text);

create policy wishloom_owner_update on storage.objects
for update to authenticated
using (bucket_id='wishloom' and (storage.foldername(name))[1]=auth.uid()::text)
with check (bucket_id='wishloom' and (storage.foldername(name))[1]=auth.uid()::text);

create policy wishloom_owner_delete on storage.objects
for delete to authenticated
using (bucket_id='wishloom' and (storage.foldername(name))[1]=auth.uid()::text);
