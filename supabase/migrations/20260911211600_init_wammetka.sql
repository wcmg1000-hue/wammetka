-- Wammetka P0: identidad, oferta, pedido, auto-update.
-- Roles viven en public.profiles.rol (nunca en user_metadata).

create extension if not exists pgcrypto;

create schema if not exists private;

create type public.app_role as enum (
  'cliente',
  'comercio',
  'repartidor',
  'operacion',
  'finanzas',
  'admin'
);

create type public.comercio_estado as enum (
  'pendiente',
  'activo',
  'suspendido'
);

create type public.pedido_estado as enum (
  'creado',
  'pendiente_comercio',
  'aceptado',
  'preparado',
  'asignado',
  'recogido',
  'entregado',
  'cerrado',
  'cancelado',
  'rechazado_comercio'
);

create type public.metodo_pago as enum (
  'contraentrega',
  'pasarela'
);

create table public.municipios (
  id uuid primary key default gen_random_uuid(),
  nombre text not null unique,
  habilitado boolean not null default true
);

create table public.zonas (
  id uuid primary key default gen_random_uuid(),
  municipio_id uuid not null references public.municipios (id),
  nombre text not null,
  tarifa_domicilio_centavos integer not null check (tarifa_domicilio_centavos >= 0),
  vigente_desde date not null default current_date,
  unique (municipio_id, nombre)
);

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  rol public.app_role not null default 'cliente',
  nombre text not null,
  telefono text,
  municipio_id uuid references public.municipios (id),
  comercio_id uuid,
  activo boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.comercios (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id),
  nombre text not null,
  municipio_id uuid not null references public.municipios (id),
  zona_id uuid not null references public.zonas (id),
  abierto boolean not null default false,
  hora_apertura time,
  hora_cierre time,
  estado_aprobacion public.comercio_estado not null default 'pendiente',
  telefono text,
  created_at timestamptz not null default now()
);

alter table public.profiles
  add constraint profiles_comercio_fk
  foreign key (comercio_id) references public.comercios (id);

create table public.productos (
  id uuid primary key default gen_random_uuid(),
  comercio_id uuid not null references public.comercios (id) on delete cascade,
  nombre text not null,
  sku text,
  precio_centavos integer not null check (precio_centavos > 0),
  stock integer not null default 0 check (stock >= 0),
  disponible boolean not null default true,
  impuesto_bps integer not null default 0 check (impuesto_bps >= 0),
  deleted_at timestamptz
);

create table public.pedidos (
  id uuid primary key default gen_random_uuid(),
  cliente_id uuid not null references public.profiles (id),
  comercio_id uuid not null references public.comercios (id),
  repartidor_id uuid references public.profiles (id),
  zona_id uuid not null references public.zonas (id),
  estado public.pedido_estado not null default 'pendiente_comercio',
  metodo_pago public.metodo_pago not null default 'contraentrega',
  subtotal_centavos integer not null default 0,
  domicilio_centavos integer not null default 0,
  propina_centavos integer not null default 0,
  comision_centavos integer not null default 0,
  total_centavos integer not null default 0,
  direccion_texto text not null,
  notas text,
  aceptar_antes timestamptz,
  created_at timestamptz not null default now()
);

create table public.pedido_items (
  id uuid primary key default gen_random_uuid(),
  pedido_id uuid not null references public.pedidos (id) on delete cascade,
  producto_id uuid references public.productos (id),
  nombre_snapshot text not null,
  precio_centavos integer not null,
  cantidad integer not null check (cantidad >= 1),
  subtotal_centavos integer not null
);

create table public.pedido_eventos (
  id uuid primary key default gen_random_uuid(),
  pedido_id uuid not null references public.pedidos (id) on delete cascade,
  de_estado public.pedido_estado,
  a_estado public.pedido_estado not null,
  actor_id uuid references public.profiles (id),
  nota text,
  created_at timestamptz not null default now()
);

create table public.app_config (
  id smallint primary key default 1 check (id = 1),
  latest_version text,
  version_code integer,
  apk_url text,
  sha256 text,
  force_update boolean not null default false,
  changelog text
);

create index profiles_rol_idx on public.profiles (rol);
create index profiles_municipio_idx on public.profiles (municipio_id);
create index comercios_municipio_idx on public.comercios (municipio_id);
create index comercios_owner_idx on public.comercios (owner_id);
create index productos_comercio_idx on public.productos (comercio_id, disponible);
create index pedidos_cliente_idx on public.pedidos (cliente_id);
create index pedidos_comercio_idx on public.pedidos (comercio_id, estado);
create index pedido_items_pedido_idx on public.pedido_items (pedido_id);
create index pedido_eventos_pedido_idx on public.pedido_eventos (pedido_id);
