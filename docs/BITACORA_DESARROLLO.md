# Bitácora de desarrollo

> **Documento único** de tiempos (cobro) + retrospectiva por sesión.  
> Sin secretos ni datos sensibles del cliente.

**Proyecto:** Wammetka  
**Stack:** Flutter + Supabase (D1)  
**Ritmo:** proyecto completo  
**Tarifa de referencia (opcional):** _(ej. USD/hora)_  
**Ruta APK / consola / Project ID (sin secretos):** `entregas/apk/` · `wwhyypadkjjbgkmlbpss`  

| Totales | Valor |
|---------|-------|
| Total minutos acumulados | 260 |
| Total horas (min ÷ 60) | 4.33 |
| Horas facturables | 4.33 (redondeo a criterio de cobro) |
| Notas cobro (redondeo, no cobrables) | revisión de tomos + docs CG + T01–T07 + Converge P0 + T08 |

---

## Registro de ejecuciones

| # | Fecha | Inicio | Fin | Minutos | Modo* | Stack | Hito (qué se hizo) | Errores / bloqueadores | Aciertos a repetir | Deuda consciente | Evidencia / commit / APK |
|---|-------|--------|-----|---------|-------|-------|--------------------|------------------------|--------------------|------------------|--------------------------|
| 1 | 2026-09-11 | 14:46 | 15:50 | 64 | proyecto completo | Flutter+Supabase | Huecos tomos PDF vs molde; Clarify/Specify/Challenge/Plan; T01 scaffold APK | Tomos sin plataforma/CI/G/W/T; `adb` sin teléfono | Mapear PDF → expediente CG; no reutilizar otro project-ref | T01 sin DONE hasta smoke teléfono; T02 repo GitHub; T03 Supabase nuevo | REGISTRO + `entregas/apk/wammetka-v0.1.0+1-arm64.apk` |
| 2 | 2026-09-11 | 15:46 | 16:25 | 39 | proyecto completo | Flutter+Supabase | T02 git local; T03 proyecto Supabase + RLS + seed | GitHub create repo 404; sin Docker; sin teléfono | Proyecto cloud nuevo no reutilizado | T02 espera permiso GitHub; T01 smoke teléfono | project-ref wwhyypadkjjbgkmlbpss |
| 3 | 2026-09-11 | 16:29 | 16:52 | 23 | proyecto completo | Flutter+Supabase | T05 cliente Auth + tests núcleo; arreglo seed tokens + GRANT helpers RLS | `adb` vacío; repo GitHub inexistente; login 500 por tokens NULL luego 42501 is_staff | Una sola DOING (T05); live test sin secretos en git | T01/T02/T05 sin DONE (teléfono / remoto / smoke APK) | REGISTRO T05 analyze/test/live; APK v0.1.0+1 sin redeploy |
| 4 | 2026-09-11 | 17:55 | 18:12 | 17 | proyecto completo | Flutter+Supabase | T02: repo creado a mano; commit auth; push `main`; Actions verde | Primer HTTPS hung (GCM); retry `GCM_INTERACTIVE=never` | Repo vacío 409 ≠ 404; no force | T01/T05 sin teléfono | `46441d8` · https://github.com/wcmg1000-hue/wammetka/actions/runs/34656548482 |
| 5 | 2026-09-11 | 18:13 | 18:26 | 13 | proyecto completo | Flutter+Supabase | APK +2 con dart-define cliente; botón Guardar perfil | Xiaomi `INSTALL_FAILED_USER_RESTRICTED` | Teléfono físico no AVD; defines sin seed | T01/T04/T05 esperan aceptar install USB | `entregas/apk/wammetka-v0.1.0+2-arm64.apk` |
| 6 | 2026-09-11 | 18:29 | 18:36 | 7 | proyecto completo | Flutter+Supabase | Reintento install + smoke T01/T04/T05 en Redmi | — | USB install al 2.º intento; uiautomator sin secretos | T06 catálogo/pedido | APK +2 · `telefono=3001234567` |
| 7 | 2026-09-11 | 18:34 | 19:01 | 27 | proyecto completo | Flutter+Supabase | T06 catálogo+carrito+confirmar+bandeja; RPC aceptar; APK +3; smoke AC-03/10 | uiautomator content-desc con tab; tap AppBar vs botón Confirmar | Seed 2 tiendas para no-mezclar; tap el Confirmar de abajo | T07 auto-update; AC-09 cancelar no smoke | pedido `a6fb5a34-…360e` aceptado; `entregas/apk/wammetka-v0.1.0+3-arm64.apk` |
| 8 | 2026-09-11 | 19:05 | 19:50 | 45 | proyecto completo | Flutter+Supabase | T07 auto-update `app_config`+SHA-256; APK +4 instalada; remoto +5 | diálogo perdido si se muestra en splash (`go()`); Xiaomi aviso de riesgos | Esperar ruta ≠ `/` antes del diálogo; hash minúsculas | Converge P0 / T08 | `8084d00`; CI https://github.com/wcmg1000-hue/wammetka/actions/runs/34662746664 |
| 9 | 2026-09-11 | 19:56 | 20:16 | 20 | proyecto completo | Flutter+Supabase | Converge P0; T08 RPC despacho hasta entregado; APK +6 | login Redmi `No hay red` | AC-09 test cierra huérfano; RPC definer | T08 smoke UI | pedido `a6fb5a34-…360e` entregado; T08 no DONE |

\*Modo: `proyecto completo` / `demo rápido` / `solo fix` / `solo docs`

### Cómo llenar (asistente + alumno)

1. Al **empezar** una sesión Agent: fecha + hora de inicio.
2. Al **cerrar** la sesión: fin, minutos, hito, errores/bloqueadores (1–3), aciertos (1–3), deuda, evidencia (commit / APK / consola).
3. Actualizar totales de minutos/horas.
4. Si hay lección nueva → volcar a `LECCIONES_APRENDIDAS.md` (generalizado).
5. Sync `CHECKLIST.md` si se cerró una puerta.

### Plantilla rápida (pegar en el chat al cerrar)

```text
BITACORA_EJECUCION
Fecha:
Inicio:
Fin:
Minutos:
Modo: proyecto completo / demo rápido / solo fix / solo docs
Stack: Firebase / Supabase / otro
Hito:
Errores/bloqueadores (1–3):
Aciertos (1–3):
Deuda consciente:
Ruta APK / consola / Project ID (sin secretos):
Evidencia/commit:
```

El asistente **vuelca esa fila** a la tabla en el mismo turno.

---

## Receta de velocidad (recordatorio)

**Antes (5–10 min):** brief · decisiones en `PROJECT_PROFILE.md` · camino D1/D2 · fuera de alcance · CLI cloud OK.

**Durante:** scaffold → APK instalable → seed · un patrón UI × módulos · sync cloud visible · `analyze` por bloque · publicar update (auto-update) al teléfono.

**Al cerrar (~10 min):** esta bitácora completa · sync checklist · una escritura cloud vista en consola desde el teléfono.

---

## Relación con otros docs

- Progreso de fases: `CHECKLIST.md` + `evidencias/REGISTRO.md`.
- Esta bitácora es la **única fuente de verdad** de tiempo (cobro) y cierre cualitativo de sesión.
