-- T08: ofertas de zona para repartidor + transiciones asignado/recogido/entregado.
-- El repartidor no usa UPDATE directo; solo RPC security definer.

drop policy if exists pedidos_select on public.pedidos;
create policy pedidos_select on public.pedidos
  for select using (
    cliente_id = auth.uid()
    or repartidor_id = auth.uid()
    or private.is_staff()
    or exists (
      select 1 from public.comercios c
      where c.id = pedidos.comercio_id and c.owner_id = auth.uid()
    )
    or (
      private.jwt_role() = 'repartidor'
      and repartidor_id is null
      and estado in ('aceptado', 'preparado')
      and exists (
        select 1
        from public.profiles pr
        join public.zonas z on z.id = pedidos.zona_id
        where pr.id = auth.uid()
          and pr.municipio_id is not distinct from z.municipio_id
      )
    )
  );

drop policy if exists pedido_items_select on public.pedido_items;
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
          or (
            private.jwt_role() = 'repartidor'
            and p.repartidor_id is null
            and p.estado in ('aceptado', 'preparado')
            and exists (
              select 1
              from public.profiles pr
              join public.zonas z on z.id = p.zona_id
              where pr.id = auth.uid()
                and pr.municipio_id is not distinct from z.municipio_id
            )
          )
        )
    )
  );

drop policy if exists pedido_eventos_select on public.pedido_eventos;
create policy pedido_eventos_select on public.pedido_eventos
  for select using (
    exists (
      select 1 from public.pedidos p
      where p.id = pedido_eventos.pedido_id
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

create or replace function public.aceptar_servicio(p_pedido_id uuid)
returns public.pedidos
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pedido public.pedidos;
  v_de public.pedido_estado;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión';
  end if;
  if private.jwt_role() is distinct from 'repartidor' then
    raise exception 'Solo un repartidor puede aceptar el servicio';
  end if;

  select * into v_pedido from public.pedidos where id = p_pedido_id for update;
  if not found then
    raise exception 'Pedido no encontrado';
  end if;
  if v_pedido.repartidor_id is not null then
    raise exception 'Este servicio ya tiene repartidor';
  end if;
  if v_pedido.estado not in ('aceptado', 'preparado') then
    raise exception 'Este pedido aún no está listo para despacho';
  end if;
  if not exists (
    select 1
    from public.profiles pr
    join public.zonas z on z.id = v_pedido.zona_id
    where pr.id = auth.uid()
      and pr.municipio_id is not distinct from z.municipio_id
  ) then
    raise exception 'Esta oferta no es de tu zona';
  end if;

  v_de := v_pedido.estado;
  update public.pedidos
    set estado = 'asignado', repartidor_id = auth.uid()
    where id = v_pedido.id
    returning * into v_pedido;

  insert into public.pedido_eventos (pedido_id, de_estado, a_estado, actor_id, nota)
  values (p_pedido_id, v_de, 'asignado', auth.uid(), 'Servicio aceptado');

  return v_pedido;
end;
$$;

create or replace function public.marcar_pedido_recogido(p_pedido_id uuid)
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
  if private.jwt_role() is distinct from 'repartidor' then
    raise exception 'Solo el repartidor asignado puede marcar recogido';
  end if;

  select * into v_pedido from public.pedidos where id = p_pedido_id for update;
  if not found then
    raise exception 'Pedido no encontrado';
  end if;
  if v_pedido.repartidor_id is distinct from auth.uid() then
    raise exception 'Este servicio no está asignado a ti';
  end if;
  if v_pedido.estado <> 'asignado' then
    raise exception 'Solo un pedido asignado se puede marcar recogido';
  end if;

  update public.pedidos set estado = 'recogido' where id = v_pedido.id
    returning * into v_pedido;

  insert into public.pedido_eventos (pedido_id, de_estado, a_estado, actor_id, nota)
  values (p_pedido_id, 'asignado', 'recogido', auth.uid(), 'Recogido en el comercio');

  return v_pedido;
end;
$$;

create or replace function public.marcar_pedido_entregado(
  p_pedido_id uuid,
  p_nota text
)
returns public.pedidos
language plpgsql
security definer
set search_path = public
as $$
declare
  v_pedido public.pedidos;
  v_nota text;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión';
  end if;
  if private.jwt_role() is distinct from 'repartidor' then
    raise exception 'Solo el repartidor asignado puede marcar entregado';
  end if;

  v_nota := nullif(trim(coalesce(p_nota, '')), '');
  if v_nota is null or char_length(v_nota) < 3 then
    raise exception 'Escribe una nota de entrega';
  end if;
  if char_length(v_nota) > 180 then
    raise exception 'La nota no puede pasar de 180 caracteres';
  end if;

  select * into v_pedido from public.pedidos where id = p_pedido_id for update;
  if not found then
    raise exception 'Pedido no encontrado';
  end if;
  if v_pedido.repartidor_id is distinct from auth.uid() then
    raise exception 'Este servicio no está asignado a ti';
  end if;
  if v_pedido.estado <> 'recogido' then
    raise exception 'Solo un pedido recogido se puede marcar entregado';
  end if;

  update public.pedidos set estado = 'entregado' where id = v_pedido.id
    returning * into v_pedido;

  insert into public.pedido_eventos (pedido_id, de_estado, a_estado, actor_id, nota)
  values (p_pedido_id, 'recogido', 'entregado', auth.uid(), v_nota);

  return v_pedido;
end;
$$;

revoke all on function public.aceptar_servicio(uuid) from public, anon;
revoke all on function public.marcar_pedido_recogido(uuid) from public, anon;
revoke all on function public.marcar_pedido_entregado(uuid, text) from public, anon;
grant execute on function public.aceptar_servicio(uuid) to authenticated;
grant execute on function public.marcar_pedido_recogido(uuid) to authenticated;
grant execute on function public.marcar_pedido_entregado(uuid, text) to authenticated;
