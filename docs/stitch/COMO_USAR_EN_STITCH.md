# Cómo usar `PANTALLAS_PARA_STITCH.md`

El archivo **`docs/stitch/PANTALLAS_PARA_STITCH.md`** tiene **dos usos** (mismo texto):

1. **Fuente para que la IA implemente las pantallas** (sin HTML).
2. **Texto para pegar en Google Stitch** y generar diseños en paralelo.

No hace falta MCP ni ID de proyecto Stitch.

---

## Paso 1 — Revisar el MD

Abre `docs/stitch/PANTALLAS_PARA_STITCH.md` y confirma el alcance. Si falta algo, pídeselo al asistente.

---

## Paso 2 — La IA programa desde el MD

El asistente implementa la UI desde el MD.  
La prueba se hace en el **dispositivo del perfil** (Android → APK en el teléfono + auto-update cuando aplique).

---

## Paso 3 — Pegar en Stitch (opcional, en paralelo)

1. Ctrl+A → Copiar el MD completo  
2. Pegar en Stitch donde pida la descripción  
3. Generar diseños  

| Situación | Qué hacer |
|-----------|-----------|
| App grande | Pegar por módulos |
| Falta pantalla | Pedir actualizar el MD |
| Cambio de alcance | Regenerar el MD |

---

## Paso 4 — Al finalizar el apartado visual

Cuando **todas** las pantallas del alcance estén en la app:

1. Compara la app (dispositivo del perfil) con Stitch.
2. Si prefieres Stitch en alguna pantalla, di:

```
Prefiero el diseño de Stitch para [pantalla(s)].
Te paso el HTML (lo pego o lo dejo en docs/stitch/export/screens/).
Adapta la app a ese diseño.
```

3. El asistente adapta solo esas pantallas.

**No** se usa import por MCP. Solo HTML manual.
