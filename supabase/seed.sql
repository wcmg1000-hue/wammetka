-- Seed piloto Fonseca. Contraseña de prueba solo en `.env` (SEED_PASSWORD).
-- No usar en producción. GoTrue exige tokens de auth como '' no NULL.

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

-- Usuarios de prueba: Admin API o SQL con tokens en '' (no NULL).
-- Correos: admin@wammetka.test, comercio@wammetka.test,
-- cliente@wammetka.test, reparto@wammetka.test
-- Contraseña de seed (solo staging): ver SEED_PASSWORD en `.env` local.
-- Si login da 500 Scan confirmation_token: ficha 3.31 en LECCIONES_APRENDIDAS.md.
