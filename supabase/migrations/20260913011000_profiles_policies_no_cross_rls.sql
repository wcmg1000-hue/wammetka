-- Políticas de profiles no deben reentrar RLS vía jwt_role/is_staff/joins.
drop policy if exists profiles_admin_all on public.profiles;
drop policy if exists profiles_select_pedido_comercio on public.profiles;

create or replace function private.comercio_puede_ver_perfil(_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
set row_security = off
as $$
  select exists (
    select 1
    from public.pedidos p
    join public.comercios c on c.id = p.comercio_id
    where p.cliente_id = _id
      and c.owner_id = auth.uid()
  );
$$;

create or replace function private.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
set row_security = off
as $$
  select exists (
    select 1 from public.profiles where id = auth.uid() and rol = 'admin'
  );
$$;

grant execute on function private.comercio_puede_ver_perfil(uuid) to authenticated;
grant execute on function private.is_admin() to authenticated;

create policy profiles_select_pedido_comercio on public.profiles
  for select using (private.comercio_puede_ver_perfil(id));

create policy profiles_admin_all on public.profiles
  for all using (private.is_admin())
  with check (private.is_admin());
