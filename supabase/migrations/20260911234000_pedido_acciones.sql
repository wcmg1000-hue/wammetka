-- Acciones de pedido: aceptar/rechazar (comercio) y cancelar (cliente).
-- Revierte stock si se cancela o rechaza. Eventos solo vía definer.

create or replace function private.responder_pedido(
  p_pedido_id uuid,
  p_aceptar boolean,
  p_nota text
)
returns public.pedidos
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pedido public.pedidos;
  v_item public.pedido_items;
  v_nuevo public.pedido_estado;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión';
  end if;

  select * into v_pedido from public.pedidos where id = p_pedido_id for update;
  if not found then
    raise exception 'Pedido no encontrado';
  end if;
  if not exists (
    select 1 from public.comercios c
    where c.id = v_pedido.comercio_id and c.owner_id = auth.uid()
  ) then
    raise exception 'No puedes gestionar este pedido';
  end if;
  if v_pedido.estado <> 'pendiente_comercio' then
    raise exception 'Este pedido ya no está pendiente';
  end if;

  if p_aceptar then
    v_nuevo := 'aceptado';
  else
    v_nuevo := 'rechazado_comercio';
    for v_item in select * from public.pedido_items where pedido_id = v_pedido.id
    loop
      update public.productos
        set stock = stock + v_item.cantidad
        where id = v_item.producto_id;
    end loop;
  end if;

  update public.pedidos
    set estado = v_nuevo
    where id = v_pedido.id
    returning * into v_pedido;

  insert into public.pedido_eventos (pedido_id, de_estado, a_estado, actor_id, nota)
  values (p_pedido_id, 'pendiente_comercio', v_nuevo, auth.uid(), nullif(trim(coalesce(p_nota, '')), ''));

  return v_pedido;
end;
$$;

create or replace function public.responder_pedido(
  p_pedido_id uuid,
  p_aceptar boolean,
  p_nota text default null
)
returns public.pedidos
language sql
security definer
set search_path = public, private
as $$
  select * from private.responder_pedido(p_pedido_id, p_aceptar, p_nota);
$$;

create or replace function private.cancelar_pedido(p_pedido_id uuid)
returns public.pedidos
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pedido public.pedidos;
  v_item public.pedido_items;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión';
  end if;
  select * into v_pedido from public.pedidos where id = p_pedido_id for update;
  if not found then
    raise exception 'Pedido no encontrado';
  end if;
  if v_pedido.cliente_id <> auth.uid() then
    raise exception 'No puedes cancelar este pedido';
  end if;
  if v_pedido.estado <> 'pendiente_comercio' then
    raise exception 'Solo puedes cancelar mientras espera al comercio';
  end if;

  for v_item in select * from public.pedido_items where pedido_id = v_pedido.id
  loop
    update public.productos
      set stock = stock + v_item.cantidad
      where id = v_item.producto_id;
  end loop;

  update public.pedidos
    set estado = 'cancelado'
    where id = v_pedido.id
    returning * into v_pedido;

  insert into public.pedido_eventos (pedido_id, de_estado, a_estado, actor_id, nota)
  values (p_pedido_id, 'pendiente_comercio', 'cancelado', auth.uid(), 'Cancelado por el cliente');

  return v_pedido;
end;
$$;

create or replace function public.cancelar_pedido(p_pedido_id uuid)
returns public.pedidos
language sql
security definer
set search_path = public, private
as $$
  select * from private.cancelar_pedido(p_pedido_id);
$$;

create or replace function public.marcar_pedido_preparado(p_pedido_id uuid)
returns public.pedidos
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pedido public.pedidos;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión';
  end if;
  select * into v_pedido from public.pedidos where id = p_pedido_id for update;
  if not found then
    raise exception 'Pedido no encontrado';
  end if;
  if not exists (
    select 1 from public.comercios c
    where c.id = v_pedido.comercio_id and c.owner_id = auth.uid()
  ) then
    raise exception 'No puedes gestionar este pedido';
  end if;
  if v_pedido.estado <> 'aceptado' then
    raise exception 'Solo un pedido aceptado se puede marcar preparado';
  end if;
  update public.pedidos set estado = 'preparado' where id = v_pedido.id
    returning * into v_pedido;
  insert into public.pedido_eventos (pedido_id, de_estado, a_estado, actor_id, nota)
  values (p_pedido_id, 'aceptado', 'preparado', auth.uid(), null);
  return v_pedido;
end;
$$;

revoke all on function private.responder_pedido(uuid, boolean, text) from public, anon, authenticated;
revoke all on function private.cancelar_pedido(uuid) from public, anon, authenticated;
grant execute on function public.responder_pedido(uuid, boolean, text) to authenticated;
grant execute on function public.cancelar_pedido(uuid) to authenticated;
grant execute on function public.marcar_pedido_preparado(uuid) to authenticated;
