# Análisis crítico de reglas de negocio y casos límite

Plantilla + instrucción para el Agent. Frase: **`CG.challenge`**.

Se ejecuta **después de Specify** y **antes de Plan** (o al añadir una regla nueva en un módulo).  
Demo: solo reglas del **flujo crítico** (máx. ~6). Proyecto completo: por módulo con restricciones nuevas.

## Rol del Agent

Actúa como **Analista Crítico de Reglas de Negocio y Casos Límite**.

Cuestiona cada regla, configuración y restricción. No te limites a “funciona en el caso feliz”: busca excepciones reales, contradicciones, vulnerabilidades lógicas y consecuencias no previstas.

## Por cada regla planteada (7 puntos)

1. **Problema que intenta resolver** — en una frase.
2. **Preguntas con escenarios reales de excepción** — al menos 3.
3. **Qué podría salir mal** — fallos operativos, datos inconsistentes, bloqueos.
4. **Usuarios afectados** — roles concretos.
5. **Abusos o evasiones** — cómo saltarse la regla.
6. **Alternativas** — mantener control sin bloquear operaciones legítimas.
7. **Permisos / validaciones / registros / autorizaciones** necesarios (quién corrige, auditoría, estados).

## Formato de salida (copiar al expediente §6.1)

### Regla: “…”

| # | Punto | Respuesta |
|---|---|---|
| 1 | Problema que resuelve | |
| 2 | Preguntas / excepciones | |
| 3 | Qué puede salir mal | |
| 4 | Usuarios afectados | |
| 5 | Abusos / evasiones | |
| 6 | Alternativa propuesta | |
| 7 | Permisos / auditoría / estados | |

**Decisión acordada:** _(mantener / suavizar / reemplazar)_ · **G/W/T a añadir:** _(sí/no — resumen)_

## Ejemplo

**Regla:** “Los vendedores no pueden editar pedidos después de guardarlos”.

Cuestionamientos:

- ¿Qué sucede si el cliente solicita agregar o retirar un producto?
- ¿Qué pasa si pide cambiar la fecha o dirección de entrega?
- ¿Cómo se corrige un error al ingresar el pedido?
- ¿Quién estará autorizado para modificarlo?
- ¿Debe quedar registrado quién cambió qué y cuándo?
- ¿Conviene permitir cambios solo antes de producción/despacho?

**Alternativa típica:** edición permitida en estado `borrador`/`confirmado`; bloqueada desde `en_producción`; correcciones por rol supervisor con audit log.

## Puerta

No pasar a **`CG.plan`** (primera vez) sin:

- [x] Reglas del flujo crítico listadas en expediente §6.
- [x] `CG.challenge` hecho (2026-09-11 — R1–R7 en expediente §6.1).
- [x] Excepciones acordadas reflejadas en G/W/T o en §6.1 (AC-02…AC-09).

Al implementar un módulo con reglas nuevas: repetir challenge solo de esas reglas antes de codear restricciones.
