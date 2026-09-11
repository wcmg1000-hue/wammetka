create or replace function private.crear_pedido(
  p_items jsonb,
  p_direccion text,
  p_zona_id uuid
)
returns public.pedidos
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cliente public.profiles;
  v_comercio public.comercios;
  v_zona public.zonas;
  v_item jsonb;
  v_prod public.productos;
  v_subtotal integer := 0;
  v_pedido public.pedidos;
  v_qty integer;
  v_comercio_id uuid;
  v_pendientes integer;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión';
  end if;
  if p_direccion is null or char_length(trim(p_direccion)) < 10 then
    raise exception 'Escribe una dirección de al menos 10 caracteres';
  end if;
  if jsonb_typeof(p_items) <> 'array' or jsonb_array_length(p_items) < 1 then
    raise exception 'El carrito está vacío';
  end if;

  select * into v_cliente from public.profiles where id = auth.uid();
  if v_cliente.rol <> 'cliente' or not v_cliente.activo then
    raise exception 'Solo un cliente activo puede pedir';
  end if;

  select count(*) into v_pendientes
  from public.pedidos
  where cliente_id = auth.uid()
    and estado not in ('entregado', 'cerrado', 'cancelado', 'rechazado_comercio');
  if v_pendientes >= 3 then
    raise exception 'Tienes 3 pedidos en curso. Espera o cancela uno';
  end if;

  select * into v_zona from public.zonas where id = p_zona_id;
  if not found then
    raise exception 'Zona no válida';
  end if;
  if not exists (
    select 1 from public.municipios m
    where m.id = v_zona.municipio_id and m.habilitado
  ) then
    raise exception 'Tu municipio no está habilitado';
  end if;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_qty := (v_item ->> 'cantidad')::integer;
    select * into v_prod from public.productos where id = (v_item ->> 'producto_id')::uuid;
    if not found or not v_prod.disponible or v_prod.deleted_at is not null then
      raise exception 'Un producto ya no está disponible';
    end if;
    if v_comercio_id is null then
      v_comercio_id := v_prod.comercio_id;
    elsif v_comercio_id <> v_prod.comercio_id then
      raise exception 'El carrito es de un solo comercio';
    end if;
    if v_qty is null or v_qty < 1 then
      raise exception 'Cantidad inválida';
    end if;
    if v_prod.stock < v_qty then
      raise exception 'No hay stock suficiente de %', v_prod.nombre;
    end if;
    v_subtotal := v_subtotal + (v_prod.precio_centavos * v_qty);
  end loop;

  select * into v_comercio from public.comercios where id = v_comercio_id;
  if not v_comercio.abierto or v_comercio.estado_aprobacion <> 'activo' then
    raise exception 'Este comercio no recibe pedidos ahora';
  end if;

  insert into public.pedidos (
    cliente_id, comercio_id, zona_id, estado, metodo_pago,
    subtotal_centavos, domicilio_centavos, comision_centavos, total_centavos,
    direccion_texto, aceptar_antes
  ) values (
    auth.uid(),
    v_comercio_id,
    p_zona_id,
    'pendiente_comercio',
    'contraentrega',
    v_subtotal,
    v_zona.tarifa_domicilio_centavos,
    (v_subtotal * 12) / 100,
    v_subtotal + v_zona.tarifa_domicilio_centavos,
    trim(p_direccion),
    now() + interval '10 minutes'
  ) returning * into v_pedido;

  for v_item in select * from jsonb_array_elements(p_items)
  loop
    v_qty := (v_item ->> 'cantidad')::integer;
    update public.productos
      set stock = stock - v_qty
      where id = (v_item ->> 'producto_id')::uuid
        and stock >= v_qty
    returning * into v_prod;
    if not found then
      raise exception 'No hay stock suficiente';
    end if;
    insert into public.pedido_items (
      pedido_id, producto_id, nombre_snapshot, precio_centavos, cantidad, subtotal_centavos
    ) values (
      v_pedido.id,
      v_prod.id,
      v_prod.nombre,
      v_prod.precio_centavos,
      v_qty,
      v_prod.precio_centavos * v_qty
    );
  end loop;

  insert into public.pedido_eventos (pedido_id, de_estado, a_estado, actor_id, nota)
  values (v_pedido.id, null, 'pendiente_comercio', auth.uid(), 'Pedido creado');

  return v_pedido;
end;
$$;

create or replace function public.crear_pedido(
  p_items jsonb,
  p_direccion text,
  p_zona_id uuid
)
returns public.pedidos
language sql
security definer
set search_path = public, private
as $$
  select * from private.crear_pedido(p_items, p_direccion, p_zona_id);
$$;

revoke all on function private.crear_pedido(jsonb, text, uuid) from public, anon, authenticated;
grant execute on function public.crear_pedido(jsonb, text, uuid) to authenticated;
