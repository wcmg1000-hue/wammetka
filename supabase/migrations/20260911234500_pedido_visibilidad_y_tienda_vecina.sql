-- El comercio ve nombre/teléfono del cliente de SUS pedidos (bandeja).
-- Segunda tienda seed para no mezclar carritos (AC-06).

create policy profiles_select_pedido_comercio on public.profiles
  for select using (
    exists (
      select 1
      from public.pedidos p
      join public.comercios c on c.id = p.comercio_id
      where p.cliente_id = profiles.id
        and c.owner_id = auth.uid()
    )
  );

insert into public.comercios (
  owner_id, nombre, municipio_id, zona_id, abierto, estado_aprobacion, telefono
)
select
  p.id,
  'Tienda Vecina Fonseca',
  p.municipio_id,
  z.id,
  true,
  'activo',
  '3007654321'
from public.profiles p
join public.zonas z on z.municipio_id = p.municipio_id and z.nombre = 'Centro'
where p.rol = 'admin'
  and p.municipio_id is not null
  and not exists (
    select 1 from public.comercios c where c.nombre = 'Tienda Vecina Fonseca'
  )
limit 1;

insert into public.productos (comercio_id, nombre, precio_centavos, stock, disponible)
select c.id, 'Café molido 250 g', 800000, 8, true
from public.comercios c
where c.nombre = 'Tienda Vecina Fonseca'
  and not exists (
    select 1 from public.productos p
    where p.comercio_id = c.id and p.nombre = 'Café molido 250 g'
  );
