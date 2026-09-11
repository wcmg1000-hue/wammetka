# QA mínimo — menos errores sin E2E

No es plan QA formal ni Patrol. Objetivo: **cada G/W/T del flujo crítico tiene dueño**.

## 1. Trazabilidad (Specify / Challenge → Converge)

Completar en expediente §12 (o aquí si §12 es N/A). Cada fila = un escenario.

| ID | Given / When / Then (1 línea) | Prueba | Evidencia |
|---|---|---|---|
| AC-01 | Cliente seed entra y carga `profiles.rol` | `test` (live opcional) + smoke pendiente | `test/auth_live_optional_test.dart` · REGISTRO T05 |
| AC-02 | Cliente no puede autoascender a admin | `test` | `auth_policy` + live update rol |
| AC-03 | Correo/contraseña inválidos no fingen éxito | `test` | `test/auth_nucleo_test.dart` + widget login |

**Regla:** no hay Converge si queda un G/W/T del módulo sin `test` ni `smoke`.

- `test` = test de núcleo (`flutter test` u equiv.).
- `smoke` = DoD en **dispositivo del perfil** + PASS en `REGISTRO.md`.

## 2. Tres tests mínimos (T05 / T06) — obligatorios

No cerrar rebanada con suite vacía. Crear estos tres (nombres orientativos):

| # | Qué cubre | Ejemplo |
|---|---|---|
| 1 | Auth OK / auth fallido | entra con seed / rechaza clave mala |
| 2 | Rol que **no puede** | el caso del challenge / matriz |
| 3 | Validación que guarda dato | campo obligatorio o regla de negocio |

Ampliar solo si un bug se repite. No un test por widget. E2E = `LECCIONES` **4.22** (opcional, nunca prod).

## 3. Regresión corta (solo al Converge)

Máx. ~10 minutos. 8–12 casos del flujo crítico, no de todo el sistema.

- [ ] Happy path del flujo crítico (rol principal)
- [ ] Caso error / validación
- [ ] Vacío o sin datos
- [ ] Rol que **no puede** (permiso denegado)
- [ ] Excepción acordada en `CG.challenge` (si hubo)
- [ ] Smoke cloud / dato visible (si nube)
- [ ] RLS/rules +/− ya pasaron en 2D (o se re-verifica lo tocado)
- [ ] Si Android APK: auto-update o N/A; ideal **2.º dispositivo** si el módulo es update
- [ ] Nav del rol: la función no está huérfana
- [ ] Sin placeholders / `onPressed` vacío

Marcar solo con evidencia (REGISTRO o test). El resto del Converge sigue en `TASKS.md`.
