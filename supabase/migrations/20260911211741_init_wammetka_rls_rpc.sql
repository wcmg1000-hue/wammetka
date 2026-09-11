-- Helpers, RLS, trigger de perfil y RPC crear_pedido.

create or replace function private.jwt_role()
returns public.app_role
language sql
stable
security definer
set search_path = public
as $$
  select rol from public.profiles where id = auth.uid();
$$;

create or replace function private.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select private.jwt_role() in ('admin', 'operacion', 'finanzas');
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, rol, nombre, telefono, activo)
  values (
    new.id,
    'cliente',
    coalesce(new.raw_user_meta_data ->> 'nombre', split_part(new.email, '@', 1)),
    new.raw_user_meta_data ->> 'telefono',
    true
  );
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

create or replace function private.protect_profile_privs()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'UPDATE'
     and (new.rol is distinct from old.rol or new.activo is distinct from old.activo)
     and private.jwt_role() is distinct from 'admin'
     and auth.uid() is not null then
    raise exception 'No puedes cambiar rol ni activo';
  end if;
  return new;
end;
$$;

create trigger protect_profile_privs
  before update on public.profiles
  for each row execute function private.protect_profile_privs();

revoke all on function private.jwt_role() from public, anon, authenticated;
revoke all on function private.is_staff() from public, anon, authenticated;
revoke all on function private.protect_profile_privs() from public, anon, authenticated;

alter table public.municipios enable row level security;
alter table public.zonas enable row level security;
alter table public.profiles enable row level security;
alter table public.comercios enable row level security;
alter table public.productos enable row level security;
alter table public.pedidos enable row level security;
alter table public.pedido_items enable row level security;
alter table public.pedido_eventos enable row level security;
alter table public.app_config enable row level security;

create policy municipios_select on public.municipios
  for select using (habilitado or private.is_staff());

create policy zonas_select on public.zonas
  for select using (true);

create policy profiles_select_own on public.profiles
  for select using (id = auth.uid() or private.is_staff());

create policy profiles_update_own on public.profiles
  for update using (id = auth.uid())
  with check (id = auth.uid());

create policy profiles_admin_all on public.profiles
  for all using (private.jwt_role() = 'admin')
  with check (private.jwt_role() = 'admin');

create policy comercios_select on public.comercios
  for select using (
    estado_aprobacion = 'activo'
    or owner_id = auth.uid()
    or private.is_staff()
  );

create policy comercios_update_owner on public.comercios
  for update using (owner_id = auth.uid() or private.is_staff())
  with check (owner_id = auth.uid() or private.is_staff());

create policy productos_select on public.productos
  for select using (
    deleted_at is null
    and (
      disponible
      or exists (
        select 1 from public.comercios c
        where c.id = productos.comercio_id
          and (c.owner_id = auth.uid() or private.is_staff())
      )
    )
  );

create policy productos_write_owner on public.productos
  for all using (
    exists (
      select 1 from public.comercios c
      where c.id = productos.comercio_id
        and (c.owner_id = auth.uid() or private.is_staff())
    )
  )
  with check (
    exists (
      select 1 from public.comercios c
      where c.id = productos.comercio_id
        and (c.owner_id = auth.uid() or private.is_staff())
    )
  );

create policy pedidos_select on public.pedidos
  for select using (
    cliente_id = auth.uid()
    or repartidor_id = auth.uid()
    or private.is_staff()
    or exists (
      select 1 from public.comercios c
      where c.id = pedidos.comercio_id and c.owner_id = auth.uid()
    )
  );

create policy pedidos_update_comercio on public.pedidos
  for update using (
    exists (
      select 1 from public.comercios c
      where c.id = pedidos.comercio_id and c.owner_id = auth.uid()
    )
    or cliente_id = auth.uid()
    or private.is_staff()
  )
  with check (
    exists (
      select 1 from public.comercios c
      where c.id = pedidos.comercio_id and c.owner_id = auth.uid()
    )
    or cliente_id = auth.uid()
    or private.is_staff()
  );

create policy pedido_items_select on public.pedido_items
  for select using (
    exists (
      select 1 from public.pedidos p
      where p.id = pedido_items.pedido_id
        and (
          p.cliente_id = auth.uid()
          or p.repartidor_id = auth.uid()
          or private.is_staff()
          or exists (
            select 1 from public.comercios c
            where c.id = p.comercio_id and c.owner_id = auth.uid()
          )
        )
    )
  );

create policy pedido_eventos_select on public.pedido_eventos
  for select using (
    exists (
      select 1 from public.pedidos p
      where p.id = pedido_eventos.pedido_id
        and (
          p.cliente_id = auth.uid()
          or private.is_staff()
          or exists (
            select 1 from public.comercios c
            where c.id = p.comercio_id and c.owner_id = auth.uid()
          )
        )
    )
  );

create policy app_config_select on public.app_config
  for select using (true);

create policy app_config_admin on public.app_config
  for all using (private.jwt_role() = 'admin')
  with check (private.jwt_role() = 'admin');

insert into public.app_config (id, latest_version, version_code, sha256, force_update)
values (1, '0.1.0', 1, '', false);
