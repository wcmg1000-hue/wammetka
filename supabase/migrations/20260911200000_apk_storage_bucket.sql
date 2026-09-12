-- Bucket público de lectura para auto-update APK. Escritura solo service_role.

insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'apk',
  'apk',
  true,
  52428800,
  array['application/vnd.android.package-archive', 'application/octet-stream']
)
on conflict (id) do update
  set public = excluded.public,
      file_size_limit = excluded.file_size_limit;

drop policy if exists apk_select_public on storage.objects;
create policy apk_select_public
  on storage.objects
  for select
  using (bucket_id = 'apk');
