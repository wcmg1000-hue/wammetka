drop policy if exists apk_insert_admin on storage.objects;
create policy apk_insert_admin
  on storage.objects
  for insert
  to authenticated
  with check (
    bucket_id = 'apk'
    and private.jwt_role() = 'admin'
  );

drop policy if exists apk_update_admin on storage.objects;
create policy apk_update_admin
  on storage.objects
  for update
  to authenticated
  using (bucket_id = 'apk' and private.jwt_role() = 'admin')
  with check (bucket_id = 'apk' and private.jwt_role() = 'admin');
