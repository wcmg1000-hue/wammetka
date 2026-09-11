# Seguridad y privacidad verificables

No marcar controles sin evidencia. Ajustar el rigor al riesgo y registrar excepciones.

## Datos y amenazas

- [ ] Datos clasificados: públicos, internos, personales, sensibles o financieros.
- [ ] Flujo de datos y límites de confianza documentados.
- [ ] Amenazas principales evaluadas: suplantación, acceso indebido, manipulación, fuga, abuso y denegación.
- [ ] Retención, exportación y eliminación definidas.
- [ ] Privacidad, consentimiento y requisitos legales revisados según país/sector.

## Identidad y autorización

- [ ] Autenticación, recuperación y revocación de sesión probadas.
- [ ] Autorización aplicada en servidor/BD, no solo en UI.
- [ ] Matriz rol × acción con pruebas positivas y negativas.
- [ ] MFA evaluado para administración o riesgo alto.
- [ ] Rate limit y antiabuso en login, registro y endpoints públicos.

## Datos, cliente y secretos

- [ ] Validación en cada límite de confianza.
- [ ] RLS/Security Rules probadas localmente y en staging.
- [ ] Configuración pública separada de secretos del servidor.
- [ ] Ninguna clave privada, service role, contraseña o token permanente en web/APK/app.
- [ ] Logs sin secretos ni datos sensibles.
- [ ] Firebase App Check o equivalente evaluado cuando aplica.

## Cadena de suministro y operación

- [ ] Dependencias bloqueadas y vulnerabilidades revisadas.
- [ ] Secret scanning y SAST/CodeQL o equivalente ejecutados cuando aplica.
- [ ] Permisos móviles mínimos y justificados.
- [ ] Artefactos firmados; claves de firma fuera del repo.
- [ ] Local, staging y producción separados.
- [ ] Backup y restauración probados cuando hay persistencia.
- [ ] Rollback, monitoreo, alertas e incidentes documentados.

## Riesgos aceptados

| Riesgo | Impacto | Mitigación | Responsable | Vencimiento |
|---|---|---|---|---|
| Reutilizar proyecto Supabase de otro aplicativo | Alto (mezcla PII) | Project-ref nuevo Wammetka en T03 | Tecnología | 2026-09-18 |
| Pedidos contraentrega masivos | Medio | Tope 3 pendientes / cliente (R4) | Producto | P0 |
| Pasarela ausente en P0 | Medio (caja no real) | Campos split listos; módulo T09 | Finanzas | P1 |
| MFA admin no activo | Medio | Evaluar al crear proyecto | Admin | T03 |
