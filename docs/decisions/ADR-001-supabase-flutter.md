# ADR-001 — Supabase + Flutter para Wammetka

**Fecha:** 2026-09-11  
**Estado:** aceptada  
**Contexto:** Los tomos I–VI describen marketplace + ERP + liquidación, sin elegir proveedor cloud ni framework.

## Decisión

- Cliente: **Flutter** (Android APK directo + Web).
- Datos: **Supabase (D1)** — Postgres, Auth, Storage, políticas de seguridad a nivel de fila (Row Level Security, RLS).
- Integración Continua (Continuous Integration, CI): **GitHub Actions**.

## Alternativas

| Opción | Por qué no en P0 |
|---|---|
| Firebase / Firestore | Modelo de pedido, split y liquidación es relacional; RLS SQL encaja mejor |
| ERP monolítico (Odoo, etc.) | Retrasa la rebanada móvil; se puede integrar por eventos después (Tomo IV) |
| Cuatro apps nativas | Rework de auth, tema y CI × 4 |
| GitLab CI | Conector GitLab no autenticado en este entorno; el kit ya trae YAML de GitHub |

## Consecuencias

- Project-ref **nuevo** llamado Wammetka; no reutilizar otros proyectos de la organización.
- Dinero en centavos enteros; estados de pedido append-only en `pedido_eventos`.
- Auto-update vía tabla `app_config` + bucket `apk` (no Remote Config).
