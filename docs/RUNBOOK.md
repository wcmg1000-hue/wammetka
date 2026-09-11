# Runbook de operación

Se completa antes de producción.

## Servicio

- URL/identificador: _(pendiente)_
- Versión/commit: _(pendiente)_
- Responsable técnico: _(pendiente)_
- Canal de soporte: _(pendiente)_

## Despliegue

1. _(comando o pipeline exacto del remoto GitHub Actions o GitLab CI)_
2. _(migraciones)_
3. _(smoke test)_

## Rollback

- Aplicación: _(versión previa y procedimiento)_
- Base de datos: _(estrategia compatible/restore)_
- Feature flag/kill switch: _(si aplica)_

## Backup y restauración

- Frecuencia/retención: _(pendiente)_
- Ubicación y cifrado: _(pendiente)_
- Última restauración probada: _(fecha/evidencia)_

## Monitoreo y alertas

| Señal | Herramienta | Umbral | Responsable |
|---|---|---|---|
| errores/crashes | | | |
| disponibilidad | | | |
| latencia | | | |
| costo/cuota | | | |

## Incidentes

1. Confirmar impacto y preservar evidencia sin datos sensibles.
2. Mitigar: rollback, desactivar función o limitar acceso.
3. Comunicar al responsable y usuarios afectados cuando corresponda.
4. Corregir, validar en staging y desplegar.
5. Registrar causa raíz y lección generalizada.

