-- Seed piloto Fonseca. Contraseña de prueba (solo staging): Wammetka.Seed.2026
-- No usar en producción.

insert into public.municipios (nombre, habilitado) values
  ('Albania', true),
  ('Hatonuevo', true),
  ('Barrancas', true),
  ('Fonseca', true),
  ('Distracción', true),
  ('San Juan del Cesar', true)
on conflict (nombre) do nothing;

insert into public.zonas (municipio_id, nombre, tarifa_domicilio_centavos)
select id, 'Centro', 500000 from public.municipios where nombre = 'Fonseca'
on conflict (municipio_id, nombre) do nothing;

-- Usuarios de prueba: aplicar en SQL editor / execute_sql (requiere auth.users).
-- Correos: admin@wammetka.test, comercio@wammetka.test,
-- cliente@wammetka.test, reparto@wammetka.test
-- Contraseña de seed (solo staging): ver SEED_PASSWORD en `.env` local.
