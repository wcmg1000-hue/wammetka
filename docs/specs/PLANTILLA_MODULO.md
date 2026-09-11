# Módulo: [NOMBRE]

> Plantilla — el asistente la copia como `MODULO_NOMBRE.md` y la rellena en la fase de arquitectura.
> No dejar secciones vacías: si algo no aplica, escribir "No aplica" y por qué.

## 1. Objetivo del módulo

_(Qué resuelve este módulo en una o dos frases.)_

## 2. Usuarios autorizados

| Rol | Qué puede hacer en este módulo |
|-----|--------------------------------|
| | |

## 3. Pantallas y rutas

| Pantalla | Ruta | Rol | Fuente UI |
|----------|------|-----|-----------|
| | | | `docs/stitch/PANTALLAS_PARA_STITCH.md` (por defecto). HTML `docs/stitch/export/screens/____.html` **solo si se adoptó**. |

## 4. Flujo de navegación acordado

_(De dónde se entra, a dónde va cada acción, flujos alternativos: error, sin permiso, sesión expirada.)_

## 5. Inventario visual por pantalla (1:1 con el MD)

_Por defecto 1:1 con `docs/stitch/PANTALLAS_PARA_STITCH.md`. HTML del export solo si el proyecto **adoptó** ese HTML al final del visual. Repetir este bloque por cada pantalla. Es la lista de verificación de la auditoría (regla `09`)._

### Pantalla: [Nombre]  (fuente: MD / HTML adoptado)

Elementos (todos los del MD; o del HTML si ya se adoptó):
- [ ] _(encabezado / logo)_
- [ ] _(campos / inputs)_
- [ ] _(enlaces — ej. "¿Olvidaste tu contraseña?")_
- [ ] _(indicadores — ej. "Online", badges)_
- [ ] _(botones con su texto exacto)_
- [ ] _(fondos / gradientes / difuminados)_
- [ ] _(íconos: estilo outlined/filled según la fuente)_

Acciones:
- [ ] _(acción → pantalla/resultado)_

## 6. Datos de entrada y salida

| Dato | Tipo | Origen/Destino | Validación |
|------|------|----------------|------------|
| | | | |

## 7. Tablas o colecciones

| Nombre | Campos clave | Relaciones |
|--------|--------------|------------|
| | | |

## 8. Reglas de negocio

- _(numeradas)_

## 9. Validaciones

- _(campos requeridos, formatos, límites)_

## 10. APIs necesarias

- _(endpoints o servicios; "No aplica" si no hay)_

## 11. Tareas en segundo plano

- _(qué corre en background, feedback visual; ver regla `05`)_

## 12. Casos límite

- _(vacío, sin conexión, permiso denegado, datos inválidos)_

## 13. Criterios de aceptación

- [ ] _(verificables, uno por función acordada)_

## 14. Pruebas mínimas

- [ ] _(qué se prueba y cómo antes de dar el módulo por terminado)_

Incluir siempre que aplique: unitarias, componente/widget, integración, permisos positivos/negativos, error, vacío, offline y concurrencia/idempotencia.

## 15. Seguridad y privacidad

| Dato/acción sensible | Amenaza | Control | Prueba/evidencia |
|---|---|---|---|
| | | | |

- Autorización del lado servidor/BD: _(cómo)_
- Datos personales y retención: _(qué y cuánto tiempo / No aplica)_
- Rate limit/antiabuso: _(cómo / No aplica)_
- Logs y auditoría: _(qué se registra sin datos sensibles)_

## 16. Observabilidad y operación

- Métricas/logs/crashes relevantes: _(detalle)_
- Comportamiento degradado y reintentos: _(detalle)_
- Rollback o desactivación: _(detalle)_

## 17. Comandos de verificación

| Control | Comando | Resultado esperado |
|---|---|---|
| | | |

