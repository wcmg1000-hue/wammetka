# Lecciones Aprendidas — Errores y cómo evitarlos / resolverlos

> Documento **vivo** de Código Germinación. Registra errores reales cometidos en proyectos anteriores para: **prevenir** que vuelvan a ocurrir y, si ocurren, tener a mano **cómo resolverlos rápido**.
>
> Formato de cada ficha: **Síntoma → Causa raíz → Cómo evitarlo → Cómo resolverlo**.
>
> Etiquetas de stack: `[General]` · `[Flutter]` · `[Firebase]` · `[Supabase]` · `[Web]` · `[AVD]`. Solo aplica si el proyecto usa ese stack/plataforma (`PROJECT_PROFILE`).
>
> **Regla de Código Germinación:** el asistente **lee este archivo antes de programar** y **agrega lecciones al cerrar** (regla `13`). Sin nombres de apps ni datos sensibles.

## Índice

1. [UI](#1--ui) — **1.14** ink tapado en `ListTile`
2. [Entorno y toolchain (build)](#2--entorno-y-toolchain-build) — **2.6** auto-update · **2.7** upload · **2.8** hang 2.º dispositivo · **2.9** Play Protect · **2.10–2.12** Patrol/JDK (solo si hay E2E)
3. [Base de datos y backend](#3--base-de-datos-y-backend) — Firebase + Supabase · **3.26–3.32** caja, pedidos, pull/wipe, E2E≠prod, bootstrap, tokens Auth NULL, GRANT helpers RLS
4. [Proceso de trabajo y QA](#4--proceso-de-trabajo-y-qa) — MD-first, APK+teléfono · **4.22–4.25** E2E opcional / backup
5. [Checklist preventivo](#5--checklist-preventivo)

> Etiquetas: `[General]` · `[Flutter]` · `[Firebase]` · `[Supabase]` · `[Web]` · `[AVD]`. Solo aplica lo del stack/plataforma del `PROJECT_PROFILE`.
> **Estándar de Código Germinación 2.4+:** prueba = **APK en teléfono** + auto-update; Stitch = **MD-first** (HTML opcional al final); CI = **GitHub Actions o GitLab CI**.

---

## 1 · UI

### 1.1 `[Flutter]` `borderRadius` con bordes de color no uniformes

- **Síntoma:** consola inundada con `A borderRadius can only be given on borders with uniform colors.` En Android (Impeller) el árbol de render colapsa y arrastra errores secundarios (`RenderBox was not laid out`, `BoxConstraints forces an infinite width`, `Cannot hit test a render box with no size`). En web casi no se nota.
- **Causa raíz:** un `BoxDecoration` con `borderRadius` **y** un `Border` de lados con distinto color/ancho (patrón típico de "franja de acento" a la izquierda: `Border(left: BorderSide(color: acento, width: 8), ...)`). Flutter **prohíbe** `borderRadius` cuando el borde no es uniforme. El antipatrón suele estar **replicado** en varios widgets compartidos (tarjetas, KPIs, tiles), por eso el efecto es masivo.
- **Cómo evitarlo:**
  - Regla de oro: **si necesitas `borderRadius`, el borde debe ser uniforme** (`Border.all(...)`).
  - Para una franja de acento de color en un lado, **no** la hagas con `Border(left: ...)`. Dibújala como **elemento aparte**: un `Container` de ancho fijo superpuesto con `Stack` + `Positioned` + `ClipRRect`, sobre una tarjeta de borde uniforme.
  - Centraliza el patrón de "tarjeta con acento" en **un solo widget** para no replicar el bug.
- **Cómo resolverlo (patrón aplicado):**

```dart
Stack(
  children: [
    DecoratedBox(
      decoration: BoxDecoration(
        color: ...,
        borderRadius: radius,
        border: Border.all(color: gris), // uniforme -> compatible con borderRadius
        boxShadow: [...],
      ),
      child: Padding(padding: ..., child: child),
    ),
    if (accent != null)
      Positioned(
        top: 0, bottom: 0, left: 0,
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(r), bottomLeft: Radius.circular(r),
          ),
          child: Container(width: 8, color: accent),
        ),
      ),
  ],
)
```

  - Alternativa sin `Stack`: quitar `borderRadius` del `BoxDecoration` (un borde no uniforme **sí** se permite sin `borderRadius`) y redondear envolviendo en un `ClipRRect` externo.

### 1.2 `[Flutter]` Tarjetas en blanco dentro de un `GridView` (contenido no se pinta)

- **Síntoma:** en una grid, las tarjetas aparecen como rectángulos **blancos vacíos**: se ve el fondo redondeado pero **sin texto/íconos**.
- **Causa raíz:** usar `Ink` como hijo **no posicionado de un `Stack`**. `Ink` pinta su decoración a través del `Material` ancestro, pero con las constraints que recibe dentro de un `GridView`/`Stack` **no renderiza su contenido**, dejando solo el fondo. (Suele ser una **regresión al arreglar el bug 1.1**: al envolver en `Stack` se cambia el tipo de widget de contenido.)
- **Cómo evitarlo:**
  - Evita `Ink` como contenedor de contenido dentro de `Stack`/grids. Usa `Container`/`DecoratedBox` para la superficie y deja el ripple a un `InkWell` con `Material` encima.
  - Tras cualquier refactor de un **widget compartido**, prueba **todas** sus variantes de uso (en grid, en fila de lista, con y sin `onTap`, con y sin acento).
- **Cómo resolverlo:** reemplazar `Ink` por `DecoratedBox`/`Container` para la superficie (manteniendo `Material` + `InkWell` para el efecto de toque).

### 1.3 `[Flutter]` `RenderFlex overflowed by N pixels`

- **Síntoma:** franjas amarillas/negras y mensajes `A RenderFlex overflowed by N pixels...`.
- **Causa raíz:** `Row`/`Column` cuyo contenido excede el espacio disponible: textos largos sin recorte, filas de KPIs/botones sin flexibilidad, listas sin scroll.
- **Cómo evitarlo:**
  - Textos que pueden crecer: `maxLines` + `overflow: TextOverflow.ellipsis` (o `Flexible`/`Expanded`).
  - Filas con elementos que compiten por ancho: `Expanded`/`Flexible`, o `Wrap` cuando deban bajar de línea (ej. botones de acción).
  - Números grandes en tarjetas: `FittedBox`.
  - Contenido potencialmente alto: envolver en `SingleChildScrollView` / listas con scroll.
- **Alturas cortas (splash):** `Expanded(flex:)` rígidos no caben en ciertas alturas y revientan. Preferir contenido scrollable o límites flexibles. **Probar en un rango de alturas / dispositivo real temprano** — el análisis estático no lo caza.
- **Cómo resolverlo:** identificar el `RenderFlex` culpable en el log (incluye el widget) y aplicar `Expanded`/`Flexible`/`Wrap`/`maxLines`/`FittedBox` según el caso.

### 1.4 `[Flutter]` Crash por ancho infinito / flex sin límites

- **Síntoma:** `BoxConstraints forces an infinite width` o flex sin límites → pantalla rota.
- **Causa raíz:** colocar un widget que necesita ancho acotado (ej. una tarjeta/KPI en un `Row`, o un filtro en el `trailing` de un header) en un contexto de ancho no acotado.
- **Cómo evitarlo:** dar límites explícitos (`SizedBox(width: ...)`, `Expanded`); no meter widgets "de tarjeta" directamente en un `Row` sin `Expanded`.
- **Cómo resolverlo:** envolver en `Expanded`/`SizedBox` o sacar el widget del contexto sin límites.

### 1.5 `[Flutter]` Tipo `dynamic` sin genéricos revienta con un cast en runtime

- **Síntoma:** una pantalla **crashea al renderizar** (pantalla roja en debug) con un error como `type 'List<dynamic>' is not a subtype of type 'List<DropdownMenuItem<String>>?'`. El fallo no está en el guardado, sino al **construir el formulario/lista**.
- **Causa raíz:** pasar `AsyncValue`, `List`, `Map`, etc. **sin sus genéricos** entre métodos/widgets (p. ej. `Widget _buildForm(AsyncValue categories)`). Dentro, el dato es `dynamic`, así que `.map(...).toList()` produce un `List<dynamic>` en runtime; al asignarlo a un parámetro tipado (ej. `items:` de un `DropdownButtonFormField<T>`) el cast implícito falla y tumba la pantalla.
- **Cómo evitarlo:**
  - **Nunca** pasar `AsyncValue`/`List`/`Map` **sin genéricos** entre métodos o widgets. Un `dynamic` silencioso propaga el tipo hasta que un cast en runtime lo revienta.
  - Al usar `DropdownButtonFormField<T>`, asegúrate de que `items` sea literalmente `List<DropdownMenuItem<T>>`.
  - Habilitar `strict-raw-types` en `analysis_options.yaml` ayuda a cazar estos casos en tiempo de análisis.
- **Cómo resolverlo:** tipar el parámetro (ej. `AsyncValue<List<Category>>` e importar el modelo). Con eso el `.map(...).toList()` produce el tipo correcto y el cast pasa.

### 1.6 `[Flutter]` Subida de imagen que rompe la creación + uso de `context` tras navegar

- **Síntoma:** (a) si el usuario elige imagen y el almacenamiento no está disponible/falla, la excepción del upload aborta el guardado **después** de haber creado el registro (queda creado pero muestra error, invitando a duplicarlo); (b) tras `context.replace(...)` se llama a `ScaffoldMessenger.of(context)` sobre un widget ya reemplazado → riesgo de "Looking up a deactivated widget's ancestor is unsafe".
- **Causa raíz:** la subida de imagen está en el mismo `try` que la creación (fatal, no opcional) y se usa `context` después de una navegación que desmonta el widget.
- **Cómo evitarlo:**
  - La subida de archivo debe ser **opcional y no bloqueante**: crear el registro primero y envolver el upload en su **propio `try/catch`**; si falla, dejar el registro creado y avisar.
  - **Capturar `ScaffoldMessenger`/`GoRouter` en variables locales ANTES de cualquier `await`/navegación** y no volver a tocar `context` tras `replace`/`pop`. Los `setState` finales, tras `if (mounted)`.
- **Cómo resolverlo (patrón):**

```dart
final messenger = ScaffoldMessenger.of(context);
final router = GoRouter.of(context);
// ... crear registro ...
final id = await repo.create(entidad);
var mensaje = 'Creado correctamente';
if (previewBytes != null) {
  try {
    final url = await uploadImage(...);
    await repo.update(/* con imagenUrl: url */);
  } catch (_) {
    mensaje = 'Creado (no se pudo subir la imagen; reintenta al editarlo)';
  }
}
messenger.showSnackBar(SnackBar(content: Text(mensaje)));
router.replace('/ruta/$id'); // messenger ya capturado, seguro
```

  - En formularios que **no** suben archivos, basta el patrón seguro habitual (snackbar **antes** del `pop`, sin `replace`).

### 1.7 `[Flutter]` `Spacer` dentro de `Column` en un `Stack` (aclaración, NO es bug)

- **Síntoma:** sospecha de que un `Column` con `Spacer()`, siendo hijo no posicionado de un `Stack`, queda con altura 0.
- **Realidad / causa:** **no es problema** cuando el `Stack` recibe **altura acotada (tight)**, como en un `GridView` (`childAspectRatio` o `mainAxisExtent`). El `Column` (con `mainAxisSize.max`) rellena esa altura y el `Spacer` reparte el sobrante.
- **Cómo evitarlo / nota:** solo sería un problema si el `Stack` recibe altura **no acotada**; en ese caso, dar altura explícita (`SizedBox(height:)`) o no usar `Spacer`. **No** forzar `StackFit.expand`/`Positioned.fill` a la ligera: rompería las tarjetas usadas fuera de grids (donde la altura la define el contenido).

### 1.8 `[General]` UI "parecida" pero incompleta (faltan elementos y la fuente no es la del diseño)

- **Síntoma:** la app se ve *parecida* al diseño de Stitch pero incompleta: faltan enlaces ("¿Olvidaste tu contraseña?"), indicadores ("Online"), fondos difuminados/gradientes, y la tipografía es la del sistema (p. ej. Roboto) en vez de la del diseño (p. ej. Quicksand). Los íconos aparecen rellenos cuando el diseño los usa outlined.
- **Causa raíz:** proceso equivocado — se implementaron **todas las pantallas de golpe** sin un **tema base fiel** previo (fuentes/tokens/componentes/íconos) y la **auditoría visual corrió al final** como checklist pasivo, no como bucle bloqueante por pantalla. Sin inventario de elementos, nada obliga a verificar el export 1:1.
- **Cómo evitarlo:**
  - **Tema base primero:** tokens desde el MD / specs (HTML/`DESIGN.md` solo si se adoptó HTML al final).
  - **Inventario por pantalla** desde el MD (elementos + acciones) 1:1.
  - **Una pantalla a la vez** → probar en **APK del teléfono** → siguiente. Nunca implementar todo y auditar al final.
- **Cómo resolverlo:** tema base + auditoría por pantalla en el teléfono (regla `09`). Si se adoptó HTML, alinear a ese HTML.

### 1.9 `[Flutter]` Grillas que **no se adaptan** al tamaño de pantalla (`GridView.count` con `childAspectRatio` fijo)

- **Síntoma:** al cambiar el tamaño de la ventana / rotar / usar un dispositivo más angosto o ancho, los **recuadros no se reacomodan**: mantienen el mismo número de columnas y las tarjetas se estiran/achican, provocando contenido cortado o `RenderFlex overflowed`.
- **Causa raíz:** `GridView.count(crossAxisCount: N, childAspectRatio: R)` fija el **número de columnas** y deriva la **altura** del ancho (`alto = anchoCelda ÷ R`). Al variar el ancho, la altura cambia y el contenido (que tiene una altura mínima real) desborda o se deforma. No hay reflow de columnas.
- **Cómo evitarlo:**
  - Usar un **delegate por extensión**: `SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: X, mainAxisExtent: alturaFija, ...)`. Así las **columnas se recalculan** según el ancho disponible y cada celda tiene **altura estable** (no depende del ancho) → sin desbordes.
  - Centralizar el patrón en **un widget compartido** (`AdaptiveGrid`) para no repetir el antipatrón.
  - Para contenido que crece, envolver textos con `maxLines`+`ellipsis` y usar `Flexible`/`Expanded` dentro de la celda.
- **Cómo resolverlo (patrón aplicado):**

```dart
GridView.builder(
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
    maxCrossAxisExtent: 180, // ancho máx. de celda -> define nº de columnas
    mainAxisExtent: 150,     // ALTURA FIJA de celda -> no se deforma
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
  ),
  itemCount: items.length,
  itemBuilder: (_, i) => items[i],
);
```

### 1.10 `[General]` Botones **sin acción** (controles que no hacen nada al tocarlos)

- **Síntoma:** la UI se ve completa pero hay botones/íconos (ajustes, "+", "ver todos", editar/eliminar, adjuntar) que **no responden** al toque. `onPressed: () {}` / `onTap: () {}` vacíos, o contenedores "tipo botón" sin gesto.
- **Causa raíz:** se maqueta la pantalla fiel al diseño pero se dejan los manejadores **vacíos** como placeholder y nunca se conectan; la auditoría no verifica que **cada** control tenga efecto.
- **Cómo evitarlo:**
  - **Regla:** ningún control interactivo se entrega con `onPressed/onTap` vacío **ni con un placeholder "próximamente"**. Debe **navegar**, **cambiar estado** o **abrir un diálogo/hoja** con una acción **real** (ver ficha 1.13).
  - En el **inventario por pantalla** (regla 09), listar cada botón/ícono con su acción esperada y marcarlo 1:1.
  - Los contenedores que parecen botón (`Container`/`Ink` con ícono) deben envolverse en `InkWell`/`GestureDetector` con `onTap`.
- **Cómo resolverlo:** recorrer la pantalla control por control; conectar navegación/estado real. Verificar con un grep de `onPressed: () {}`/`onTap: () {}` que no queden manejadores vacíos.

### 1.11 `[General]` Formulario que **no guarda** por validación de un campo poco obvio

- **Síntoma:** el usuario completa un formulario (p. ej. nombre y precio) y al pulsar "Guardar" **no pasa nada** / no se persiste. El registro nunca aparece en la base de datos.
- **Causa raíz:** una validación marca como **obligatorio** un campo secundario que el usuario pasa por alto (un `Dropdown` sin selección, un check, etc.). El guardado hace `return` temprano; el aviso es un `SnackBar` breve que el usuario no asocia con "por eso no guardó".
- **Cómo evitarlo:**
  - Exigir **solo lo imprescindible**; hacer opcionales los campos que puedan tener un valor por defecto sensato.
  - Etiquetar los campos opcionales como **"(opcional)"** y marcar los obligatorios; idealmente resaltar en rojo el campo que falta, no solo un `SnackBar`.
  - Nunca dejar que "Guardar" haga `return` en silencio: el feedback debe señalar **qué** campo falta.
- **Cómo resolverlo:** revisar la condición de validación previa al guardado; separar "obligatorio" de "opcional", aplicar valores por defecto y confirmar el guardado observando el dato en la BD (no solo el `SnackBar`).

### 1.12 `[Flutter]` Filtros/chips que **no responden** al toque (área transparente no captura el gesto)

- **Síntoma:** un filtro segmentado o chips (p. ej. "Todos/Activos/Inactivos") parece no hacer nada: al tocar una opción **el resultado no cambia**. A veces "a veces sí" funciona si tocas justo encima del texto.
- **Causa raíz:** el `GestureDetector` envuelve un `Container` cuyo color es `Colors.transparent` (o sin color) en el estado **inactivo**. En Flutter, `HitTestBehavior.deferToChild` (el valor por defecto) delega el hit-test al hijo, y un `ColoredBox` transparente **no responde** a los toques (`hitTestSelf` solo es `true` si `alpha > 0`). Resultado: la zona inactiva no es táctil salvo justo sobre los glifos del texto.
- **Cómo evitarlo:**
  - Poner `behavior: HitTestBehavior.opaque` en el `GestureDetector` de cualquier control cuya área pueda ser transparente. Así **toda** el área captura el toque.
  - Alternativas: usar `InkWell`/`Material` (dan feedback visual) o garantizar un color de fondo con `alpha > 0` en todos los estados.
- **Cómo resolverlo:** añadir `HitTestBehavior.opaque` a los filtros/chips; verificar tocando en los **bordes** de cada opción (no solo sobre el texto) que el filtro cambia.

### 1.13 `[General]` Botones con acción **"disponible próximamente"** (placeholder que se entrega como si estuviera listo)

- **Síntoma:** al tocar un control (ajustes, "nuevo…", buscar, adjuntar/ver archivo, "ver todos"…) aparece un aviso **"…: disponible próximamente"**. La pantalla parece terminada pero la función **no existe**.
- **Causa raíz:** se usó un feedback tipo "en construcción" como **atajo** para dejar el control "no mudo" sin implementar la funcionalidad. Es la misma deuda que un `onPressed` vacío, solo que **camuflada**: pasa la auditoría de "todo botón hace algo" pero **no entrega valor**. Cuando el placeholder queda, se convierte en trabajo pendiente invisible que el usuario descubre en producción.
- **Cómo evitarlo (regla dura de Código Germinación):**
  - **Prohibido** el patrón "disponible próximamente" en controles que se entregan. Un botón solo puede: **navegar**, **cambiar estado/datos** o **abrir un diálogo/hoja funcional**.
  - Si una función **no entra en el alcance del módulo actual**, la decisión correcta **no** es dejar un placeholder: es **quitar el control** del diseño (documentando el motivo en el inventario) **o** implementarlo. Un control visible ⇒ una acción real.
  - No introducir helpers tipo `showEnConstruccion` / "próximamente": el atajo debe ser **imposible** sin recrearlo a propósito.
  - **Verificación obligatoria:** `grep -r "próximamente"` y `grep -r "showEnConstruccion"` en el código de la app deben dar **0 resultados** antes de dar una pantalla por terminada.
- **Cómo resolverlo (patrones):**
  - **Ajustes:** hoja/diálogo con sesión (nombre, correo, rol) + **cerrar sesión** real (y aviso de entorno si aplica).
  - **Buscar:** campo que **filtra el listado** en vivo por los campos relevantes.
  - **"Nuevo X" / acción primaria:** abrir el **flujo real** de creación o selección del recurso.
  - **Adjuntar archivo:** picker + subida a Storage; guardar la URL en el documento.
  - **Ver adjunto:** mostrar la imagen/archivo real (p. ej. pantalla completa); si no hay, estado claro "sin adjunto".
  - **Reportes/listados agregados:** filtros de periodo reales + métricas **calculadas desde datos**; "ver todos" **navega** a la gestión correspondiente.

### 1.14 `[Flutter]` `DecoratedBox` encima de `ListTile` tapa el ink

- **Síntoma:** consola (y a veces test nativo) con `ListTile background color or ink splashes may be invisible`. El tap en listas es frágil.
- **Causa raíz:** tarjeta compartida con `DecoratedBox`/`Ink` mal apilado: el splash del `ListTile` no encuentra un `Material` ancestro válido.
- **Cómo evitarlo:** superficie = `Material` + `InkWell`; no poner `DecoratedBox` tapando el ink. Tras tocar el widget de tarjeta, probar **todas** las listas (ficha **1.2**).
- **Cómo resolverlo:** `Material(shape: RoundedRectangleBorder, …)` + `InkWell`; el acento lateral sigue en `Stack`/`Positioned` (ficha **1.1**).

---

## 2 · Entorno y toolchain (build)

### 2.1 `[Flutter]` Gradle / AGP — `compileSdk` y `firebase_storage`

- **Síntoma:** el build de Android (APK) falla con conflictos de Gradle/AGP.
- **Causa raíz:** `compileSdk` mal fijado y opciones incompatibles con la versión de AGP; `firebase_storage` requiere ajustes de Kotlin.
- **Cómo evitarlo / resolverlo:**
  - En `android/app/build.gradle.kts`: `compileSdk = flutter.compileSdkVersion` (no hardcodear).
  - Quitar `buildConfig` innecesario.
  - Alinear versiones desde el inicio y no mezclar plugins que fuercen KGP externo si el proyecto usa Kotlin integrado.

### 2.2 `[Flutter]` Plugins transitivos incompatibles con AGP (`path_provider_android` / `jni`)

- **Síntoma:** el APK no compila por plugins `jni`/transitivos incompatibles con la versión de AGP.
- **Causa raíz:** versión transitiva (ej. de `path_provider_android`) que arrastra un `jni` incompatible.
- **Cómo evitarlo / resolverlo:** fijar override en `pubspec.yaml` y documentar el porqué:

```yaml
dependency_overrides:
  path_provider_android: 2.2.17
```

  - Regla general: cuando un plugin transitivo rompe el build, **pinnear** una versión compatible con `dependency_overrides` y documentarlo.

### 2.3 `[General]` Compilar temprano para el entorno objetivo

- **Aprendizaje:** los conflictos de toolchain (build nativo, dependencias) aparecen tarde si solo pruebas en web/desarrollo. Compila para el **entorno objetivo real** (ej. APK Android) **desde temprano** para detectar conflictos de plugins cuando aún son baratos de arreglar.

### 2.4 `[Flutter]` Dependencias visuales (`google_fonts` y similares) rompen el primer `flutter run` (JNI / AGP 9)

- **Síntoma:** tras `pub add google_fonts` (u otro paquete cosmético con nativos), el build Android falla con errores `jni` / `Cannot query the value of this provider... compileDebugJavaWithJavac`.
- **Causa raíz:** el plugin arrastra dependencias nativas incompatibles con AGP/Gradle recientes; se añadió **antes** de tener un run verde con el scaffold mínimo.
- **Cómo evitarlo (ahorra el primer bloqueo de sesión):**
  1. `flutter create` → `flutter run` en el dispositivo/emulador objetivo **verde** con dependencias mínimas.
  2. Recién entonces añadir features; tipografía: preferir fuentes del sistema / assets locales si no son críticas.
  3. Tras cada `pub add` que toque Android: un `flutter run` inmediato (ficha 2.2 si hay JNI transitivo).
- **Cómo resolverlo:** quitar el paquete cosmético; tipografía vía `ThemeData` / `fontFamily` local; o pinnear override documentado si el paquete es imprescindible.

### 2.5 `[Flutter]` APK release sin permisos de red explícitos (“no llega a la nube”)

- **Síntoma:** en emulador/debug parece OK; en APK instalado en teléfono las escrituras a Firestore “no llegan” sin crash obvio.
- **Causa raíz:** el manifiesto no declara `INTERNET` / `ACCESS_NETWORK_STATE` de forma explícita (o se asumió el merge); el sync falla en silencio.
- **Cómo evitarlo:** checklist Android release antes del primer APK cloud: permisos de red explícitos, `google-services.json`, plugin Google Services, `minSdk`. Probar **una escritura** vista en la consola Firebase desde el dispositivo (no solo emulador).
- **Cómo resolverlo:** declarar permisos en `AndroidManifest.xml`, rebuild release, verificar sync con feedback visible (ficha 3.8).

> **También en toolchain (después de §4.13):** fichas **2.6** (pipeline auto-update), **2.7** (timeouts de upload APK) y **2.8** (hang en 2.º dispositivo).

---

## 3 · Base de datos y backend

### 3.1 `[Firebase]` Login de CLI no interactivo (código OAuth pegado en el chat)

- **Síntoma:** proceso de `firebase login` lento y confuso; el código OAuth (`4/0A...`) se pega **en el chat** en lugar de en la terminal.
- **Causa raíz:** el login del CLI abre navegador/pide código en una **ventana de terminal externa**; el asistente no puede completarlo por ti, y el código es de **un solo uso**.
- **Cómo evitarlo:**
  - Autenticar el CLI **antes** de empezar, en una terminal propia: `firebase login` (o `firebase login --reauth --no-localhost` en entornos sin navegador local). El reauth **no corre** en el shell no interactivo del agente.
  - El **código OAuth va en la ventana que dice "Enter authorization code:"**, nunca en el chat.
  - Si `login:list` parece OK pero `projects:list` falla (*credentials no longer valid*), reautenticar en terminal externa.
- **Cómo resolverlo:** volver a ejecutar `firebase login --reauth`; verificar con `firebase projects:list` (debe listar el proyecto como `(current)`).

### 3.2 `[Firebase]` Security Rules — regla comodín demasiado permisiva sobre `users/`

- **Síntoma:** roles que no deberían (ej. operativos) pueden escribir en perfiles de `users/`.
- **Causa raíz:** un `match /{collection}/{document=**}` con `allow write` para varios roles **incluye** la colección `users`.
- **Cómo evitarlo:** excluir explícitamente `users` del comodín y gestionar `users/` con un bloque propio; validar rol con función (`isAdminRole()`).
- **Cómo resolverlo (patrón):**

```
match /users/{userId} {
  allow read: if isSignedIn() && (request.auth.uid == userId || isAdminRole());
  allow create: if isSignedIn() && request.auth.uid == userId;
  allow update, delete: if isAdminRole();
}
match /{collection}/{document=**} {
  allow read: if isActiveUser() && collection != 'users';
  allow write: if isAdminRole() && collection != 'users';
}
```

  - Desplegar: `firebase deploy --only firestore:rules`.

### 3.3 `[Firebase]` Storage no activado bloquea el deploy

- **Síntoma:** `firebase deploy --only storage` falla con "Firebase Storage has not been set up on project ...".
- **Causa raíz:** el bucket de Storage no se ha inicializado en la consola.
- **Cómo evitarlo:** activar Storage en la consola (Storage → *Comenzar*) al inicio, si el proyecto subirá archivos/imágenes.
- **Cómo resolverlo:** abrir `console.firebase.google.com/project/<id>/storage`, pulsar *Comenzar*, elegir ubicación, y luego `firebase deploy --only storage`.

### 3.4 `[Firebase]` Reads bloqueados si el usuario no está `activo`

- **Síntoma:** una pantalla que lee datos queda en error/vacío si las rules exigen `isActiveUser()` y el doc `users/{uid}` no tiene `activo: true`.
- **Cómo evitarlo:** al sembrar usuarios, garantizar `activo: true` y `rol` correcto en `users/{uid}`.
- **Cómo resolverlo:** revisar el doc del usuario en Firestore; corregir `activo`/`rol`.

### 3.5 `[General]` Confirmar los datos antes de culpar a la UI

- **Aprendizaje:** antes de perseguir un supuesto bug de UI por "no se ve nada", confirma que **los datos existen y las reglas de seguridad los permiten** con una consulta de solo lectura (REST/Admin SDK/consola). Distingue "no hay datos / permiso denegado" de "crash de render".

### 3.6 `[Firebase]` Escribir en otra colección desde un rol que **no tiene permiso** (estado que debería **derivarse**)

- **Síntoma:** una acción del usuario con rol limitado falla con `permission-denied`, o "funciona" solo porque las reglas están demasiado abiertas. Caso típico: al crear un documento hijo, el cliente también intenta marcar el estado de un documento padre/recurso compartido que solo el admin puede escribir.
- **Causa raíz:** se intenta **duplicar** en otra colección un dato que en realidad es **consecuencia** de un documento que el rol sí puede escribir. Eso obliga a dar permisos de escritura extra (y a mantener dos fuentes de verdad que se desincronizan).
- **Cómo evitarlo:**
  - **Deriva** el estado en lugar de escribirlo: si "recurso ocupado/activo" = "existe un documento hijo en estado activo", calcula ese estado en el cliente a partir del stream (p. ej. un `Set` de IDs de recurso con hijo activo). No escribas el campo de estado en la colección restringida.
  - Mantén cada colección con **una sola fuente de verdad** y reglas de mínimo privilegio; no relajes rules para que "compile el flujo".
  - Si el estado derivado se consulta mucho o debe ser autoritativo en servidor, considera una Cloud Function (privilegios de admin) — nunca el cliente del rol limitado.
- **Cómo resolverlo:** quitar la escritura cruzada del cliente; centralizar el cálculo derivado (constantes de estados "activos" + `Set`/mapa reutilizado en las vistas afectadas).

### 3.7 `[Firebase]` Proyecto Firebase existe pero **no está usable** (API/DB/apps ausentes)

- **Síntoma:** el usuario dice “ya tengo la base / el proyecto”; FlutterFire o el seed fallan con 403, “No apps found” o sin base `(default)`.
- **Causa raíz:** existe el **Project ID**, pero no están habilitados Firestore API, la base `(default)`, ni apps Android/Web registradas. “Hay proyecto” ≠ “hay Firestore listo”.
- **Cómo evitarlo (pre-flight, ~2 min — evita 15–20 min de improvisación):** antes de integrar cloud, verificar en orden:
  1. CLI autenticado (`firebase projects:list` OK).
  2. `firebase apps:list` (hay al menos la plataforma objetivo).
  3. API Firestore habilitada + `firebase firestore:databases:list` muestra `(default)`.
  4. Rules desplegables / seed planificado.
- **Cómo resolverlo:** habilitar API, crear DB en la región acordada, registrar apps, `flutterfire configure`, seed, `deploy` rules. Ver `docs/database/CONECTAR_BD.md` (pre-flight).

### 3.8 `[Firebase]` Sync híbrido local→nube con errores **silenciados** (segundo APK inútil)

- **Síntoma:** la app “guarda” en local; en la consola Firebase no aparece nada. El usuario cree que “no llega a la BD”. Suele descubrirse **después** del primer APK.
- **Causa raíz:** arquitectura SQLite/local-first que “espeja” a Firestore dentro de `catch (_) {}` (o equivalentemente traga el error). Si la nube es requisito de entrega, el espejo silencioso garantiza un hotfix.
- **Cómo evitarlo (ahorra el segundo APK):**
  - Si el requisito es “la nube es la verdad”: **Firestore-first** (o escritura cloud obligatoria) desde el primer commit de datos.
  - **Prohibido** `catch` vacío alrededor de escrituras cloud. Mostrar `lastError`, reintentos y/o botón “forzar sync”.
  - Smoke: crear un registro en el dispositivo y verlo en la consola **antes** de dar por cerrado cloud.
- **Cómo resolverlo:** quitar swallow de errores; permisos de red (ficha 2.5); reintentos + UI de estado de sync; rebuild y revalidar en teléfono físico.

### 3.9 `[Firebase]` `firebase open` genérico abre el producto equivocado

- **Síntoma:** se intenta “abrir” la base y el CLI apunta a Realtime Database (u otro) y falla; se pierde tiempo.
- **Causa raíz:** `firebase open` no es específico del producto que se está usando.
- **Cómo evitarlo:** usar comandos/consola del producto concreto (`firestore:databases:*`, consola Firestore, etc.).
- **Cómo resolverlo:** abandonar `open` genérico; ir al comando o URL del servicio real.

---

## 4 · Proceso de trabajo y QA

### 4.1 `[General]` Build obsoleto en el emulador ("no muestra nada")

- **Síntoma:** una pantalla "no muestra nada" aunque el código en disco es correcto y los datos existen.
- **Causa raíz:** el emulador/navegador ejecuta un **build viejo** (no se recompiló/relanzó tras los últimos cambios).
- **Cómo evitarlo / resolverlo:**
  - Tras cambios estructurales de UI, hacer **hot restart** (`R`) o **relanzar** la app.
  - Ante un "no aparece nada" inexplicable: **primero descartar build obsoleto** recompilando, antes de buscar un bug inexistente.

### 4.2 `[Flutter]` Validar solo en web/AVD y no en APK del teléfono

- **Síntoma:** errores de Impeller/layout/red aparecen tarde, en el APK real.
- **Causa raíz:** se probó en Chrome o emulador AVD; Código Germinación ahora usa el **teléfono + APK** como entorno.
- **Cómo evitarlo:** generar APK temprano, instalar en el teléfono, usar **auto-update** para cada cambio. Revisar logcat/`EXCEPTION`/`overflowed`/`borderRadius` en dispositivo real.

### 4.3 `[General]` Distinguir "datos vacíos" de "crash de render"

- **Aprendizaje:** una pantalla que **siempre** dibuja encabezado/KPIs pero aparece totalmente en blanco indica **crash de layout**, no datos vacíos. Si muestra estructura pero sin filas, es **datos vacíos**.
- **Cómo diagnosticar rápido:**
  - Confirmar datos con una consulta de solo lectura antes de tocar UI.
  - Leer el log de ejecución buscando la excepción exacta y el widget causante.

### 4.4 `[General]` Refactors de widgets compartidos sin probar todos los usos

- **Aprendizaje:** cambiar un widget compartido (tarjeta/KPI) puede arreglar un bug e introducir otro (ej. tarjetas en blanco).
- **Cómo evitarlo:** al tocar un widget compartido, listar **todos sus usos** (grep) y verificarlos (grid, lista, con/sin acento, con/sin `onTap`). Correr el análisis estático (`flutter analyze`) y validar visualmente las pantallas afectadas.

### 4.5 `[Flutter]` `[Web]` Página web **en blanco** por `flutter run` de depuración huérfano
> **Aplica solo si la plataforma del proyecto incluye Web.** Si el perfil es solo Android/iOS/desktop, ignorar esta ficha.

- **Síntoma:** al abrir la URL local (p. ej. `http://localhost:5555`) **no se ve nada** (pantalla en blanco), pero un `GET` a la raíz devuelve **200**. El proceso padre de `flutter run` ya no existe; queda un proceso hijo sirviendo los estáticos y/o el servicio de depuración descolgado.
- **Causa raíz:** en modo **debug** (`flutter run -d chrome`), la app web carga los módulos Dart desde el **servicio de depuración (DDC)**. Si el proceso `flutter run` se mata/reinicia mal (puertos ocupados, procesos huérfanos), el servidor sigue devolviendo `index.html` (200) pero **los módulos Dart no cargan** → página en blanco. Se confunde con "no hay datos" o "bug de código".
- **Cómo evitarlo:**
  - No dejar instancias de `flutter run` a medio matar. Antes de relanzar, **liberar el puerto** y cerrar procesos `dart`/servidor huérfanos.
  - Para **revisión/demostración estable** (no desarrollo con hot reload), preferir un **build de release servido estático**: es autocontenido y **no depende del servicio de depuración**.
- **Cómo resolverlo (patrón):**

```bash
flutter build web --no-tree-shake-icons
python -m http.server 5555 --directory build/web --bind 127.0.0.1
```

  - Verificar que cargan los assets clave (deben dar 200 y tamaño > 0): `index.html`, `flutter_bootstrap.js`, `flutter.js`, `main.dart.js`.
  - Si de todos modos sigue en blanco tras un build de release limpio, entonces sí es un **error de runtime** en el código (revisar la consola del navegador), no del pipeline.

### 4.6 `[General]` Reescribir la misma pantalla **varias veces** (maqueta primero, datos y acciones después)

- **Síntoma:** una misma pantalla se toca 3–4 veces: (1) se maqueta con **datos de muestra en memoria** y manejadores **placeholder** (`onPressed: () {}`, "disponible próximamente"); (2) luego se **recablea** a datos reales; (3) luego se corrigen validaciones que bloquean el guardado, áreas táctiles que no responden, imágenes stub, etc. Cada pasada es otra reescritura del **mismo** archivo. Retrasa y da sensación de "no se hizo bien a la primera".
- **Causa raíz:** se trabajó **"UI primero"** difiriendo a una segunda vuelta la integración de datos, las acciones reales, los estados (loading/vacío/error) y los casos límite. Cada diferimiento obliga a volver a abrir y reescribir la pantalla. Esto **contradice** dos reglas de Código Germinación:
  - **Rebanada vertical**: la primera función debe cruzar UI → auth → autorización → **dato real** → prueba, no solo UI.
  - **Una pantalla a la vez**: implementar → depurar/auditar → **siguiente**; no "maquetar todo y cablear al final".
  - Los `SampleData` y los placeholders "próximamente" son cómodos para avanzar rápido en lo visual, pero son **deuda garantizada** de reescritura y ocultan trabajo pendiente (ver ficha 1.13).
- **Cómo evitarlo (hacerlo bien a la primera):**
  1. **Contrato de datos antes de maquetar:** por cada pantalla, definir primero su modelo, su **repositorio** y su **provider**. Recién ahí construir la UI leyendo de ese provider (no de listas en memoria).
  2. **Pantalla = rebanada vertical:** entregarla **completa** en una sola pasada: datos reales, **todas** las acciones conectadas (crear/editar/eliminar/navegar), estados loading/vacío/error, y validación/permisos mínimos.
  3. **Nada de placeholders (ni silenciosos ni "próximamente"):** un control solo puede quedar sin implementar si está **acordado como fuera de alcance**; en ese caso **se quita del diseño** y se anota el motivo en el spec/inventario.
  4. Usar la **definición de "pantalla terminada"** (sección 5) antes de pasar a la siguiente.
  5. Al terminar de migrar, **borrar los mocks** (`SampleData`) para no dejar dos fuentes de verdad.
- **Cómo resolverlo (cuando ya hay deuda):** migrar pantalla por pantalla a rebanada vertical, conectar datos+acciones+estados de una vez, verificar con `analyze`/prueba manual y eliminar los datos de muestra. No volver a abrir la pantalla "solo para lo visual".

### 4.7 `[Flutter]` `[Web]` `[PWA]` Cambios que **no aparecen** en web: build viejo cacheado por el **service worker**
> **Aplica solo si hay target Web/PWA.** En proyectos solo APK + teléfono, no usar esta ficha como diagnóstico.

- **Síntoma:** se corrige/implementa algo pero al abrir la URL local el navegador **sigue mostrando la versión anterior** (la UI vieja intacta). Se reporta como "el control no hace nada / no se corrigió", cuando en realidad **el código nuevo no se está ejecutando**.
- **Causa raíz:** Flutter web genera y registra un **service worker** (`flutter_service_worker.js`) que **cachea agresivamente** el `main.dart.js` y los assets. Una vez registrado en un origen (`host:puerto`), **intercepta** las peticiones y sirve la copia cacheada aunque en disco ya exista un build nuevo. Un `Ctrl+R` normal **no** basta; el SW cacheado persiste hasta que se actualiza/desregistra. Como la UI vieja se ve completa, se confunde con "el botón está roto".
- **Cómo distinguirlo de un bug real:** si en la pantalla aparecen textos/elementos que **ya no existen en el código**, es **caché**, no lógica. Verificar el código fuente actual vs. lo que se ve.
- **Cómo evitarlo:**
  - Para **revisión/desarrollo**, compilar **sin service worker**: `flutter build web --pwa-strategy=none` (no registra SW ⇒ siempre sirve lo último en el mismo puerto).
  - Alternativa inmediata sin tocar caché del usuario: **servir en un puerto nuevo** (`5556` en vez de `5555`). Un origen distinto **no tiene SW registrado** ⇒ build fresco garantizado.
  - Si se quiere seguir en el mismo puerto con SW: **desregistrar** el SW (DevTools → Application → Service Workers → *Unregister*) o "Empty cache and hard reload", y recargar dos veces.
- **Cómo resolverlo:** recompilar con `--pwa-strategy=none`, liberar el puerto anterior y servir el build en un **puerto limpio** para descartar la caché; confirmar `index.html` y `main.dart.js` = 200 con el tamaño del build recién generado.
- **Regla:** antes de afirmar "el control no funciona / no se corrigió" en web, **descartar caché**: comparar lo visible contra el código fuente y recargar sin SW. Un cambio "que no aparece" casi siempre es build cacheado, no lógica.

### 4.8 `[General]` El trabajo avanza pero el **`CHECKLIST.md` queda atrás** (checkboxes y notas desfasadas)

- **Síntoma:** el código, las lecciones y hasta `docs/evidencias/REGISTRO.md` reflejan puertas ya cerradas (commits publicados, Stitch aplicado, rebanada vertical operativa), pero `docs/CHECKLIST.md` sigue en `[ ]` / `[~]` o con **notas muertas** (“commit pendiente”, “falta pegar HTML de Stitch”). Quien lea el checklist cree que **no se hizo** lo que sí se hizo, o no sabe cuál es el siguiente paso real.
- **Causa raíz (error de proceso del asistente):** se privilegió “arreglar bugs / completar pantallas / documentar lecciones” frente a **cerrar la fase en el checklist**. La regla de Código Germinación (“marcar `[x]` solo con evidencia”) se interpretó mal: se registró evidencia y **no se sincronizó** el checkbox. Un registro sin checkbox = portal de progreso **roto**. Las notas del checklist no se revisaron al cerrar cada incremento.
- **Qué NO es la causa:** “no había evidencia”. La evidencia a menudo **sí** estaba; faltó el paso obligatorio **evidencia → checkbox → fase actual → notas vigentes**.
- **Cómo evitarlo (regla dura):**
  1. Al **cerrar cada incremento** (pantalla, rebanada, fix de puerta, commit relevante), el asistente ejecuta en el **mismo turno** este cierre documental, sin posponerlo:
     - fila en `docs/evidencias/REGISTRO.md` (si hubo comando/resultado observado);
     - actualizar `docs/CHECKLIST.md`: marcar `[x]` / `[~]` / `N/A — motivo` según la verdad actual;
     - actualizar **Fase actual** en el encabezado si cambió;
     - **borrar o reescribir** notas obsoletas (nunca dejar afirmaciones ya falsas).
  2. Un `[x]` exige evidencia observada; una evidencia nueva **obliga** a revisar el checkbox correspondiente. No es opcional.
  3. Antes de decir “fase N hecha” o proponer el siguiente paso, **releer** `CHECKLIST.md` y alinear enunciado ↔ realidad.
  4. Prioridad explícita: **cerrado en checklist = parte del Definition of Done**, al mismo nivel que `analyze`/commit. No es “paperwork al final”.
- **Cómo resolverlo (cuando ya hay lag):** una pasada de reconciliación — leer `REGISTRO.md` + commits + estado real del repo; actualizar todos los ítems y notas desfasadas en un solo commit `docs:`; anotar en Notas la fecha de reconciliación. Luego retomar solo lo que siga genuinamente `[ ]`.
- **Regla:** el checklist es la **fuente de verdad del progreso**. Si el trabajo va por delante del checklist, eso es un **defecto de proceso**, no un detalle menor.

### 4.9 `[General]` Manual de usuario describe pantallas que **el rol no puede abrir**

- **Síntoma:** el manual dice “entra a [pantalla X] / [sección Y] …” pero en la app ese rol **no ve** esa opción. El usuario reporta “falta la función” o “el manual miente”.
- **Causa raíz (doble fallo):**
  1. El manual se escribió desde **Stitch / specs / rutas del router**, no desde un **inventario de entradas visibles** (barra, FAB, menú).
  2. A menudo la pantalla **sí está implementada** (widget + `GoRoute`) pero quedó **fuera del bottom nav / menú** (pantalla **huérfana**). El índice activo de la barra puede seguir asumiendo un slot que ya no existe.
- **Por qué vuelve a pasar si no se previne:** es fácil “cerrar” un módulo por tener archivo Dart + HTML Stitch + sección en el MD, sin probar **cómo llega el usuario** con ese rol en un build instalado.
- **Cómo evitarlo (regla dura):**
  1. Mantener `docs/manual/AUDITORIA_NAVEGACION.md` actualizado: rutas router × entradas UI × spec.
  2. Antes de escribir `MANUAL_<ROL>.md`, auditar con la build real (o al menos listando la barra inferior / menú + top bars).
  3. Cada sección del manual = fila “alcanzable” en esa auditoría.
  4. Al tocar la barra de navegación, actualizar en el **mismo turno**: auditoría + manual + índices activos de la nav.
  5. Criterio de aceptación de módulo (ver 4.10): **ruta + entrada visible + manual**, o explícitamente fuera de alcance.
- **Cómo resolverlo:**
  - Si el **producto/spec exige** la función: **cablear la entrada** en la barra/menú y restaurar el paso en el manual.
  - Si **no** está en alcance: quitar del manual y marcar la ruta como deuda o eliminarla.
  - Quitar copy engañoso (“ve a la sección X”) si X no existe en la UI del rol.
- **Regla:** el manual por rol es fiel a la **app instalada**. Spec y Stitch mandan el **alcance**; la navegación debe materializar ese alcance antes del manual.

### 4.10 `[General]` Pantalla implementada pero **huérfana** (incumple el spec del rol)

- **Síntoma:** el `MODULO_*.md` dice que el rol “crea/edita/elimina [recurso]”, hay pantalla + reglas de datos, pero **no hay pestaña/botón** para llegar. QA y el cliente concluyen que “no está hecho”.
- **Causa raíz:** se priorizó maquetar/conectar datos de la pantalla aislada; la barra inferior se dejó con un **subconjunto** del diseño **sin reabrir** el módulo al cerrar la rebanada. Definition of Done incompleta: faltó “navegable por el rol”.
- **Cómo evitarlo:**
  1. Definition of Done de pantalla de rol: **(a)** datos reales, **(b)** acciones reales, **(c)** **entrada en la navegación del rol**, **(d)** fila en `AUDITORIA_NAVEGACION.md`, **(e)** sección en el manual si es deliverable.
  2. Al crear una `GoRoute` para un rol, añadir el item de nav en el mismo PR/turno (o documentar “huérfana aceptada” con dueño y fecha — raro).
  3. En la revisión de cierre de módulo: contrastar rutas del rol vs items reales de la barra/menú.
- **Cómo resolverlo:** añadir el item a la barra (u otro enlace visible), corregir índices activos, actualizar auditoría + manual + evidencia. No “arreglar” solo el manual dejando la función imposible.
- **Patrón resuelto:** recurso exigido por el spec del rol → pestaña/ítem en la nav del rol → ruta cableada; índices de la barra centralizados como constantes.

### 4.11 `[General]` Stitch MD-first: el MD manda; el HTML es opcional al final

#### Qué hace cada pieza (para no confundir)

| Pieza | Para qué sirve | ¿Bloquea el código? |
|---|---|---|
| **A — MD** `PANTALLAS_PARA_STITCH.md` | Fuente de verdad de pantallas, elementos, acciones y navegación. Se **pega** en Stitch si quieres mockups. | **No** — desde aquí se implementa la app |
| **B — HTML** en `export/screens/` (opcional) | Referencia visual si, **al terminar** el apartado visual, el usuario pasa HTML a mano | **No** — nunca esperar HTML para codear; no hay MCP ni ID Stitch |
| **C — App** | Rutas + barra/menú + widgets reales | Debe cumplir el **MD** (y el HTML solo si se adoptó) |

#### Síntoma (versión antigua del error)

Se trataba el HTML (o Stitch) como puerta: se retrasaba la app “hasta importar diseño”, o se inventariaba solo el HTML y se olvidaba la navegación del MD → pantallas huérfanas / manual inventado.

#### Causa raíz

1. Brief MD pobre (solo nombres de pantalla).
2. Confundir “diseñar en Stitch” con “puedo empezar a codear”.
3. Cerrar módulo por “hay HTML” sin entrada en la barra (fichas 4.9 / 4.10).

#### Cómo evitarlo (Código Germinación ≥ 2.2)

1. Generar MD completo (regla `06`): por pantalla → objetivo, elementos, acciones, **cómo se llega**.
2. **Implementar desde el MD** de inmediato (regla `07`). Pegar en Stitch es paralelo y opcional.
3. Matriz de alcance mientras codeas:

| Ítem del MD (A) | ¿En nav/app (C)? | ¿HTML (B) si ya existe? | Decisión |
|---|---|---|---|
| … | Sí / No / Huérfano | Sí / No / N/A | OK / cablear nav / fuera de alcance |

4. HTML solo al **finalizar el visual**, a mano, si el usuario lo quiere; entonces adaptar app ↔ HTML. Sin MCP.
5. Auditar 1:1 (regla `09`) contra MD (o HTML adoptado) + actualizar `AUDITORIA_NAVEGACION.md`.

#### Cómo resolverlo si ya falló

Releer el MD → listar destinos/nav → cablear o documentar exclusión → no bloquear por falta de HTML → evidencia + checklist.

#### Regla en una frase

**MD completo → app navegable 1:1 desde el MD. HTML opcional al final. Sin MCP/ID Stitch.**

### 4.12 `[Flutter]` `[AVD]` Ruido de emulador (EGL / Impeller / Play Services) tratado como fallo de app
> **Solo si alguien usa AVD/emulador.** El estándar de Código Germinación es **teléfono físico + APK**; no abrir AVD para “seguir” esta ficha. Si aparece en un logcat de emulador ajeno al flujo, no perder tiempo.

- **Síntoma:** logs rojos de GPU/EGL, Impeller o `ProviderInstaller` en el AVD; se investiga como bug de la app y se pierde tiempo.
- **Causa raíz:** el emulador/Play Services del AVD emite ruido cosmético aunque la UI responda.
- **Cómo evitarlo:** preferir teléfono real. Si hay que usar AVD y la UI responde, **no** depurar ruido GPU/Play Services. Priorizar `EXCEPTION`/`overflowed`/`borderRadius`.
- **Cómo resolverlo:** confirmar UI usable; ignorar ruido conocido; solo escalar si hay crash o pantallas rotas.

### 4.13 `[General]` Cerrar la sesión sin bitácora mínima (se pierden aceleradores)

- **Síntoma:** el proyecto salió rápido pero no hay registro de tiempos, bloqueadores ni aciertos; el siguiente proyecto repite los mismos 10–20 min de tooling.
- **Causa raíz:** se priorizó codear y se dejó la retrospectiva “para después” (o nunca).
- **Cómo evitarlo:** al cerrar cada sesión, fila completa en `docs/BITACORA_DESARROLLO.md` (tiempos + hitos + errores + aciertos + deuda). No documentar en paralelo cada pantalla.
- **Cómo resolverlo:** rellenar la plantilla a posteriori y volcar patrones nuevos a `LECCIONES_APRENDIDAS.md`.

---

### 2.6 `[Flutter]` `[Supabase]` Auto-actualización de APK (distribución directa, no Play)

> Equivalente Firebase: Remote Config + Storage (regla `12`). Con Supabase: **`app_config` + Storage**. Ver `docs/specs/MODULO_ACTUALIZACION.md`.

> Kit ≥ 2.12: comparar `versionCode` (`PackageInfo.buildNumber`) vs `app_config.version_code` / Remote Config `version_code`; verificar SHA-256 hex minúsculas del APK si el `sha256` remoto no está vacío. Semver `latest_version` solo si `version_code` es null.

- **Síntoma:** el teléfono sigue en versión vieja; el script no encuentra el APK; no aparece el diálogo de update.
- **Causa raíz (errores frecuentes):**
  1. Se subió el APK **universal** (`app-release.apk`) pero el flujo espera **arm64** (`app-arm64-v8a-release.apk`).
  2. Se subió a Storage pero **no** se actualizó `latest_version` / `apk_url` en config.
  3. URL no legible (bucket privado / path incorrecto).
  4. Keystore distinta → Android rechaza la instalación.
  5. Se intentó en app de **Google Play** (Play prohíbe auto-update por APK externo).
- **Cómo evitarlo — pipeline (este orden):**
  1. Bump `version: X.Y.Z+N` en `pubspec.yaml` (comparación semántica = `X.Y.Z`).
  2. `flutter build apk --release --split-per-abi` → publicar `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`.
  3. Script de publicación (p. ej. `scripts/upload_apk.ps1`): auth → subir a bucket `apk/releases/` → URL pública → `PATCH` fila `app_config` (`latest_version`, `version_code`, `sha256`, `apk_url`, `force_update`, `changelog`). En Windows: `curl.exe --http1.1` y `Expect:` vacío evitan fallos raros.
  4. App al arrancar: leer config → `package_info_plus` → comparar **semánticamente** → `dio` en background (regla `05`) → `open_filex`. Fallo de red = continuar con versión actual. **No-op en iOS**; no usar en Play.
- **Permisos:** `REQUEST_INSTALL_PACKAGES` + “instalar apps desconocidas”. Misma keystore **release** siempre (nunca debug; **2.9**).
- **DoD:** `version_code` / `latest_version` > instalada dispara el flujo; descarga en background; instala con misma firma; SHA-256 si el remoto no está vacío; URL pública verificable.
- **Cómo resolverlo:** abrir `apk_url` en el navegador del teléfono; comparar `version_code`/`latest_version` vs `package_info`; policies del bucket; confirmar que el dispositivo tiene el build recién publicado.
- **Chicken-egg:** si el dispositivo tiene UI de update **anterior al fix**, o cambió la keystore, la auto-update no puede instalar la versión nueva. Instalar a mano desde `apk_url` (desinstalar una vez si cambió la firma). Ver **2.8** y **2.9**.
- **Diálogo vs splash:** si el chequeo muestra el diálogo en `/` y el splash hace `go()`, el overlay se cierra. Esperar a una ruta distinta de splash antes de `showDialog`.

### 2.7 `[General]` `[Flutter]` Uploads grandes (APK a Storage): auth OK pero el binario no llega

- **Síntoma:** releases pequeños suben a la primera; con APK ~20–25 MB el mismo script falla: timeouts a 300 s con `0 bytes received`, `Connection was reset`, TUS que avanza 10–15 % y vuelve a 0 %. Auth y probes de 1 KB OK.
- **Causa raíz (combinada):**
  1. Red lenta (~20–30 KB/s): un APK de ~24 MB necesita ~14–18 min; cortes a `-m 300` abortan lo que necesita ~15 min (`-m 900`).
  2. Reset de conexión a mitad (no es fallo de credenciales).
  3. Cambiar de método (HttpClient / IWR / CLI sin link) en vez de dejar correr el canónico cuando la red sí puede terminar.
  4. TUS con chunks fijos no avanza si la red corta antes del primer chunk.
  5. Path con espacios (copiar APK a `%TEMP%`); `supabase link` a otra org; `SERVICE_ROLE` vacío.
- **Cómo evitarlo:**
  - Probe de velocidad antes del release. Si &lt; ~50 KB/s: no esperar éxito en &lt;5 min; o subir por Dashboard Storage y solo `PATCH app_config`.
  - Método canónico: script curl HTTP/1.1, APK desde `%TEMP%`, timeout acorde al tamaño.
  - Timeouts de exploración del agente ≤ 5 min; el **upload real del APK** es excepción: un solo intento largo o Dashboard/TUS en red estable.
  - No declarar “falta autenticar” si el login ya dio OK.
- **Cómo resolverlo:**
  1. Confirmar login OK y que existe `app-arm64-v8a-release.apk`.
  2. Un intento canónico largo. Si reset/timeout: **no** repetir el mismo hang en bucle.
  3. Alternativa: Dashboard → bucket `apk` → `releases/<app>-X.Y.Z-arm64.apk` → `PATCH app_config`.
  4. Alternativa en red estable: TUS (chunks ~6 MB + reintentos).
  5. Verificar URL pública y que `latest_version` = `pubspec`.

### 2.8 `[Flutter]` `[General]` Auto-update: en un dispositivo “se cuelga” al pulsar actualizar

- **Síntoma:** en el teléfono A funciona; en el B (mismo APK, instalado antes) al pulsar actualizar no avanza: sin %, sin diálogo de instalar, o “preparando” eterno.
- **Causa raíz (frecuente en el 2.º dispositivo):**
  1. Falta permiso runtime “Instalar apps desconocidas” **por app y por dispositivo**.
  2. PackageInstaller Session API sin feedback (`STATUS_PENDING_USER_ACTION` / `EXTRA_INTENT` nulo).
  3. Descarga sin timeouts / sin fase “instalando” / progreso 0 sin `Content-Length`.
  4. Pantalla bloqueante sin fallback a navegador / FileProvider.
- **Cómo evitarlo:**
  - Antes de descargar: `canRequestPackageInstalls()`; si falta → Ajustes + reintento al `resumed`.
  - Fases UI: permiso → descargando X% → preparando instalador → confirma sistema.
  - Timeouts `dio` + canal nativo; errores tipados (permiso / red / timeout / **firma**); no tragar excepciones.
  - **`ACTION_VIEW` + FileProvider como vía principal**; Session API solo fallback. Watchdog (~12–20 s) → reintento o abrir `apk_url` en el navegador.
  - Antes de instalar: comparar certificados APK vs app; si difieren → `signature_mismatch` + desinstalar una vez (**2.9**).
  - Probar en **segundo dispositivo limpio** (sin el permiso) antes de cerrar el módulo.
- **Cómo resolverlo:**
  1. Conceder “Instalar apps desconocidas” → Reintentar.
  2. Si la build instalada es anterior al fix de UI: **no esperar auto-update** — abrir `apk_url` e instalar a mano (misma keystore).
  3. Si cambió la firma: desinstalar → instalar APK nuevo una vez.
  4. Si ya tiene el fix: “Instalador alternativo” / abrir descarga en navegador.

### 2.9 `[Flutter]` Play Protect / “app dañina” en APK sideload

- **Síntoma:** al instalar o actualizar un APK fuera de Play aparece aviso de Play Protect / “app dañina”.
- **Causa raíz (frecuente):**
  1. Release firmado con keystore **debug** (`signingConfig = debug`) — el cert “Android Debug” es público.
  2. Cambio de firma entre builds, o permisos/queries raras (`grantUriPermission` a todos los handlers).
  3. Sideload sin ficha en Play: Google puede avisar aunque el APK sea legítimo.
- **Cómo evitarlo:** firma **release** (`key.properties` + `.jks` gitignored); `isDebuggable = false`; misma keystore en todos los APK; `ACTION_VIEW` + FileProvider; no conceder URI a todos los resolvers.
- **Cómo resolverlo:** `apksigner verify --print-certs` no debe decir `CN=Android Debug`. Si se pasa de debug → release: desinstalar una vez e instalar el APK nuevo. **No** volver a firmar con debug “para que actualice”. En sideload no se apaga Play Protect al 100%; el usuario puede “Instalar de todos modos”.

### 2.10 `[Flutter]` Plugin de instrumentación (Patrol) rompe el APK release

- **Síntoma:** `flutter build apk --release` falla con `package pl.leancode.patrol does not exist` (o el plugin de test aparece en `GeneratedPluginRegistrant`).
- **Causa raíz:** un plugin de E2E en `dev_dependencies` igual se registra en el build Android.
- **Cómo evitarlo:** Patrol **solo** en la ventana de E2E (opcional; no es puerta del kit). Al terminar: quitar `patrol`, `integration_test` runner y `androidTest/` **antes** de publicar. Compilar release **sin** el plugin.
- **Cómo resolverlo:** `pubspec` limpio → `flutter pub get` → `flutter build apk --release --split-per-abi`. No declarar release OK si el plugin sigue en el APK.

### 2.11 `[Flutter]` Java 25 (JBR) cuelga Gradle; usar JDK 21

- **Síntoma:** `gradlew` / `patrol test` se queda eterno en `dependencies`. `JAVA_HOME` apunta al JBR de Android Studio (25+).
- **Causa raíz:** AGP/tooling del proyecto no está validado con Java 25.
- **Cómo evitarlo:** `flutter config --jdk-dir` a Temurin/Adoptium **21**. En sesión E2E: `$env:JAVA_HOME = "<jdk-21>"`.
- **Cómo resolverlo:** matar el Gradle colgado, fijar JDK 21, reintentar. No depurar el test mientras Gradle no compiló.

### 2.12 `[Flutter]` Patrol: clavar 3.20 + CLI 3.11 (no 4.x) si `minSdk` &lt; 26

- **Síntoma:** CLI 4.x avisa incompatibilidad; el test APK no arranca; `minSdk` sube a 26; `PatrolJUnitRunnerFactory` “cannot find symbol”.
- **Causa raíz:** Patrol 4.x ≠ 3.20. Copiar el runner del example 4.x sobre `pubspec` 3.20 rompe el compile.
- **Cómo evitarlo (solo si se monta E2E):** `patrol: ^3.20.0` + `patrol_cli 3.11.0` si `minSdk` &lt; 26; `MainActivityTest` del example **3.20**; tabla oficial de compatibilidad **antes** de subir CLI.
- **Cómo resolverlo:** bajar CLI a 3.11, alinear Java de instrumentación, `flutter clean` y rebuild.

---

## Apéndice — Ampliar toolchain / backend / QA (continúa numeración)

### 3.10 `[Firebase]` Cadena de errores al conectar (2 CLIs + APIs sin habilitar)

- **Síntoma:** tropiezos seguidos: reauth, gcloud sin credenciales, 403 API Firestore, ADC expiradas.
- **Causa raíz:** se mezclan `firebase` y `gcloud` con sesiones distintas; APIs de GCP no habilitadas.
- **Cómo evitarlo:** pre-flight en `CAMINO_POR_STACK.md` / `CONECTAR_BD.md` antes de features (`firebase login` + `gcloud auth login` + ADC; APIs habilitadas; `firebase use`).
- **Cómo resolverlo:** reauth ambos CLIs, habilitar la API del 403, `firebase use` correcto.

### 3.11 `[Firebase]` Storage exige plan Blaze (Spark falla)

- **Síntoma:** deploy de Storage falla en plan Spark.
- **Causa raíz:** Storage/Functions requieren Blaze.
- **Cómo evitarlo:** decidir Blaze vs Spark en descubrimiento; registrar en `STACK_DB.md`.
- **Cómo resolverlo:** subir a Blaze y redesplegar Storage.

### 3.12 `[General]` Supabase/PostgREST corta listados en 1000 filas

- **Síntoma:** listas incompletas (faltan filas/letras) aunque `count(*)` en SQL es mayor.
- **Causa raíz:** PostgREST limita **1000 filas** por request; `.select()` sin `.range()` solo trae la primera página.
- **Cómo evitarlo:** paginar con `.range(from, to)` en bucle hasta agotar; no asumir “sin limit = todos”; UI con primera página + agregados en background si hace falta.
- **Cómo resolverlo:** helper `fetchAllPages`; verificar count app vs BD.

### 3.13 `[Flutter]` Offline-first: UI lee local; sync en segundo plano

- **Síntoma:** sin red la app falla o se queda en blanco; al volver se pierden cambios o se pisan ediciones.
- **Causa raíz:** repos solo remotos; sin outbox ni réplica local.
- **Cómo evitarlo:**
  - Local (Drift/SQLite) + outbox FIFO; UI **siempre** lee local.
  - Escrituras: local + encolar; worker push/pull online (no bloquear UI — regla `05`).
  - Conflictos: last-write-wins por `updated_at`; no sobrescribir filas `pending_sync`.
  - IDs offline = UUID v4; anti-duplicado coalesce; tombstones al borrar.
  - En línea: `await kickSync()` / `syncNow()` drena la cola; en multi-delete, un solo kick al final.
  - **Guardado percibido rápido (forms multi-fila):** encolar con `flush: false`, devolver el objeto local y `kickSyncDeferred()` (sync en background). **No** `await kickSync()` por cada ítem: el botón “Guardar” se congela.
  - **Anti-resurrección:** al borrar, cancelar upserts pendientes del mismo id + tombstone local; el pull reconcilia. **Nunca** `markDeleted` al evictar caché (un pull incompleto borraría remoto — **3.28**).
  - Badge “N pend.” **solo offline** (ficha **3.20**).
- **Cómo resolverlo:** init BD local al arranque; worker de conectividad; drenar al volver online.

### 3.14 `[General]` Escalación de privilegios vía UPDATE de perfil propio

- **Síntoma:** un no-admin cambia su `rol`/`activo` por API aunque la UI lo oculte.
- **Causa raíz:** RLS “update self” permite la fila completa; `WITH CHECK (id = auth.uid())` no valida columnas sensibles.
- **Cómo evitarlo:** trigger `BEFORE UPDATE` que bloquee columnas privilegiadas salvo admin/`service_role`; alta privilegiada solo vía Edge admin + rate limit; no confiar solo en UI.
- **Cómo resolverlo:** añadir trigger; probar autoascenso denegado; admin/service_role siguen pudiendo.

### 3.15 `[Supabase]` Canales: MCP vs CLI vs Management API vs SQL

| Canal | Sirve para | No sirve |
|---|---|---|
| **MCP** | tablas, SQL, migraciones, deploy Edge, advisors | secrets Edge; Auth toggles (scopes) |
| **CLI** `npx supabase` | secrets, link, functions con token | login interactivo en agente sin TTY |
| **Management API** | Auth config (MFA, password, rate limits) | sin Access Token de la org dueña |
| **SQL Editor** | seeds, `UPDATE`/`SELECT` completos | fragmentos sueltos (42601) |

- **Cómo elegir:**
  1. Tabla/RLS/RPC/migración → MCP `apply_migration` / `execute_sql` (+ archivo en `supabase/migrations/`).
  2. Código Edge Function → repo + MCP `deploy_edge_function` (o CLI).
  3. Secret `STRIPE_*` / env de Function → CLI `secrets set` con token de la **org dueña**.
  4. Toggle Auth Dashboard (HIBP, MFA, rate limit) → Management API `PATCH …/config/auth`, no el MCP.
  5. Si falla privilegio → **3.16** / **3.22**.
- **Error a no repetir:** “hazlo a mano en Dashboard” sin intentar API cuando existe endpoint.

### 3.16 `[Supabase]` Edge Secrets: 403 / org incorrecta

- **Síntoma:** `secrets set` 403; Function sin `STRIPE_*` / env.
- **Causa raíz:** token de otra org; agente sin TTY; se asumió que el MCP escribe secrets.
- **Cómo evitarlo:** `projects list` con el token debe mostrar el `ref`; token de la org dueña; nombres de secrets en docs, **nunca** valores en git.
- **Cómo resolverlo:**
  1. Access Token de la org dueña (Dashboard → Account → Access Tokens).
  2. `$env:SUPABASE_ACCESS_TOKEN` o `npx supabase login --token` (sin TTY).
  3. `secrets set --project-ref <ref>` (sin eco de la clave al usuario).
  4. `secrets list` solo nombres → **revocar** el token (**3.22**).
  5. Fallback si CLI sigue bloqueado: tabla `app_runtime_secrets` (RLS deny `anon`/`authenticated`; solo `service_role`) + Functions que lean `Deno.env` o esa fila.

### 3.17 `[Supabase]` Auth config (MFA, password, rate limits, HIBP)

- **Síntoma:** Security Advisor; o PATCH 403/402.
- **Cómo evitarlo:** intentar `PATCH …/config/auth` con token antes de checklist eterno; HIBP puede ser **Pro+** (402 Free); password ≥ 8 también en app/Edge.
- **Cómo resolverlo:** `PATCH https://api.supabase.com/v1/projects/{ref}/config/auth` (min length ≥ 8, MFA TOTP, rate limits). `password_hibp_enabled` puede ser **402** en Free. GET de verificación; documentar en `docs/SEGURIDAD.md`; revocar token. MFA “solo admin” = producto aparte (no romper login operativo).

### 3.18 `[General]` `[Supabase]` Stripe: secret en servidor; confirm por API

- **Síntoma:** “falta webhook”; cobros no desbloquean; claves pedidas al alumno o en el APK.
- **Cómo evitarlo:**
  - Autenticar MCP Stripe si hace falta; `sk_` **solo** en Edge Secrets / runtime secrets.
  - Flujo: Edge crea Checkout Session → `success_url` con `session_id` → Edge/`Ya pagué` hace `sessions.retrieve` → si `paid`, actualiza billing en BD.
  - Webhook = **opcional** (respaldo), no único camino.
- **Cómo resolverlo:** autenticar MCP Stripe si hace falta; secret en Edge (ficha **3.16**); confirm por `sessions.retrieve`; probar con `sk_test` (avisar si es `sk_live`). App al `resumed` o botón «Ya pagué» → reconfirma pendientes. Webhook = opcional.

### 3.19 `[Flutter]` Contadores / badges hardcodeados (diseño ≠ datos)

- **Síntoma:** UI muestra “3 Pendientes” pero la lista/BD está vacía.
- **Causa raíz:** literales del MD/Stitch copiados a Flutter.
- **Cómo evitarlo:** todo número de negocio desde query/RPC + refresco al mutar; ocultar badge si count=0 (salvo diseño).
- **Cómo resolverlo:** reemplazar literales; enganchar counts reales.

### 3.20 `[Flutter]` Badge de sync “pendientes” visible en línea

- **Síntoma:** “En línea · N pend.” con red OK.
- **Causa raíz:** outbox correcto pero sync fire-and-forget; badge también online; multi-delete dispara N syncs a medias.
- **Cómo evitarlo:** `await kickSync`; `flush: false` + un kick al final de lotes; número **solo offline**; en línea solo icono de conectividad.
- **Cómo resolverlo:** drenar outbox; al volver online re-sync; refrescar badge.

### 3.21 `[General]` Facturación SaaS mensual (gracia / bloqueo / prorrateo)

- **Cómo evitarlo (fijar en descubrimiento):** día 1 gracia (zona explícita); desde día 2 bloqueo si no hay pago; monto = activos × precio; alta mid-month prorrateada; estado canónico en BD tras confirm Stripe (nunca solo flag local).
- **Cómo resolverlo:** RPC de status + gate post-login; SQL de prueba **completo** (4.20).

### 3.22 `[General]` Access Tokens y secretos pegados en el chat

- **Cómo evitarlo:** preferir MCP auth / env local; si hace falta: token **temporal** → una operación → **revocar**. No reimprimir el secret en la respuesta ni en archivos del repo.
- **Cómo resolverlo:** revocar de inmediato; rotar keys. Política: *«si bloquean por privilegios → token corto → operar → revocar»*.

### 3.23 `[Firebase]` Proyecto Firestore “sin tablas” no es fallo

- **Síntoma:** tras create no hay colecciones.
- **Causa raíz:** Firestore no precrea tablas; aparecen al escribir; proyecto ≠ seed.
- **Cómo evitarlo:** documentar “vacío hasta seed”; checklist post-create.
- **Cómo resolverlo:** rules + seed del entorno correcto.

### 3.24 `[Firebase]` Bootstrap nube incompleto (APIs, Auth Email, billing)

- **Síntoma:** 403 API, Auth 404, Storage falla aunque el proyecto existe.
- **Cómo evitarlo:** checklist bootstrap antes de “nube lista” (`CAMINO_POR_STACK.md`).
- **Cómo resolverlo:** reauth → enable APIs → Blaze si aplica → DB → Auth Email → Storage → deploy rules → options → seed staging.

### 3.25 `[Firebase]` Seed en scripts: logs que corrompen UIDs

- **Síntoma:** docs Firestore con UIDs basura; login falla.
- **Causa raíz:** `Write-Output`/echo mezclado con el retorno del UID.
- **Cómo evitarlo:** logs a Host/stderr; pipeline solo UID; preferir seed tipado.
- **Cómo resolverlo:** realinear Auth uid ≡ doc perfil; borrar huérfanos.

### 3.26 `[General]` Cierre de caja: mezclar “ventas entregadas” con “cobrado real”

- **Síntoma:** el resumen diario no cuadra con el efectivo; o se cuenta dos veces (pedido entregado + abono).
- **Causa raíz:** se usó el total de pedidos entregados como “cobrado” en vez de cobros/abonos **aplicados** (con forma de pago), o se omitieron gastos.
- **Cómo evitarlo:** una sola fuente de “cobrado” (abonos/cobros aplicados); restar gastos del mismo período y forma de pago; documentar en spec (`CG.challenge` si hay regla ambigua).
- **Cómo resolverlo:** reporte = suma cobros aplicados − gastos, filtrado por fechas; probar un día con efectivo y transferencia.

### 3.27 `[Flutter]` `[Supabase]` Pedido (o documento cabecera+líneas) sube sin ítems

- **Síntoma:** un rol ve la cabecera creada en otro dispositivo, pero el detalle está vacío. En BD hay cabeceras con 0 filas de ítems.
- **Causa raíz:** cada `enqueue` disparaba sync: la cabecera subía **antes** de encolar las líneas; ítems pasaban a `failed` terminal; el 2.º dispositivo confiaba solo en el embed PostgREST (`[]`) y cacheaba vacío.
- **Cómo evitarlo:** encolar cabecera + ítems con `kick: false` y **un solo** sync al final; ítems **nunca** a `failed` terminal; tras push comparar count local vs remoto; en pull/`getById` si embed vacío → `select` directo a la tabla de ítems.
- **Cómo resolverlo:** parche push+pull; detectar huérfanos con SQL. Datos históricos pueden quedar sin líneas; lo crítico es no generar nuevos.

### 3.28 `[Flutter]` Offline: pull vacío borra caché; sync “ya corriendo” no reintenta

- **Síntoma:** el dato está en la nube, pero otra sesión en el mismo dispositivo no lo ve; o el registro nuevo queda fuera de pantalla.
- **Causa raíz:** un pull de 0 filas (401 / sesión a medias) dispara reconcile y **borra** locales ya subidos; `if (_running) return` no vuelve a sync tras login; sort por fecha de calendario aplana el nuevo; embed vacío pisa nombre local.
- **Cómo evitarlo / resolverlo:** no reconciliar-delete si `rows.isEmpty`; tras esperar un sync en curso, **correr de nuevo** si hay sesión; ordenar por `updated_at`; no overwrite de nombre denormalizado con null.
  - **Nunca** tombstone al evictar caché. Enforce de tombstones solo si hay un **delete del usuario** en la outbox. Si no, un pull incompleto **borra en el servidor**.
  - Si el negocio dice “pedidos no se eliminan”: ni UI, ni outbox, ni RLS `DELETE` — anular con estado.
  - Un E2E contra el **mismo** backend de prod dispara esto a escala (**3.29**, **4.22**).

### 3.29 `[General]` `[Flutter]` `[Supabase]` E2E / Patrol jamás contra el proyecto de producción

- **Síntoma:** tras tests instrumentados la nube queda casi vacía. Recuperar nombres puede ser imposible (Free sin PITR).
- **Causa raíz:** el E2E usó el **mismo** URL/anon key que el teléfono; Patrol corre la app real con sync real; un pull incompleto + tombstone hizo `DELETE` remoto (**3.28**).
- **Cómo evitarlo (regla dura):**
  - **Prohibido** Patrol / `integration_test` / Maestro contra **producción**.
  - E2E solo contra proyecto/branch **QA** (otro URL/secrets). Si no hay QA, **no se corre E2E** — smoke en dispositivo del perfil.
  - El test no hace `DELETE` de negocio; si limpia, solo filas que **él creó** (prefijo `QA-`) y solo en QA.
  - Flag de build de test: desactivar reconcile-delete y wipe.
  - Al terminar: **quitar Patrol** (**2.10**) y no dejar el APK de test apuntando a prod.
  - Antes de cualquier E2E: respaldo descargable verificado (**4.25**).
- **Cómo resolverlo:** parar tests; no re-syncar dispositivos viejos hasta bloquear DELETE; restaurar desde ZIP / PITR / teléfono que **no** haya sincronizado.

### 3.30 `[Flutter]` Offline: “bootstrap solo si la caché está vacía” oculta un import masivo

- **Síntoma:** miles de filas en la nube; la app muestra 10–20 viejas del teléfono. Pull-to-refresh no cambia nada.
- **Causa raíz:** `if (local.isNotEmpty) return` nunca vuelve a bajar; el sync no emite el topic de esa entidad.
- **Cómo evitarlo:** hidratar si `count local < count remoto` (o `forceRemote` en refresh); paginar por `id` (no por nombre); cargar IDs `pendingSync` una vez; tras `_pullAll` emitir los topics que las listas escuchan.
- **Cómo resolverlo:** `list(forceRemote: true)` + upsert sin pisar `pendingSync`; abrir la lista con internet y esperar el conteo remoto.

### 3.31 `[Supabase]` Login 500: `confirmation_token` NULL en seed SQL

- **Síntoma:** `signInWithPassword` responde 500 `unexpected_failure` / “Database error querying schema”. En logs de Auth: `Scan error on column index 3, name "confirmation_token": converting NULL to string is unsupported`.
- **Causa raíz:** usuarios creados con `INSERT` directo en `auth.users` dejando tokens en NULL. GoTrue espera cadena vacía, no NULL.
- **Cómo evitarlo:** crear usuarios con Admin API / `auth.admin.createUser`, o en SQL poner `confirmation_token = ''`, `recovery_token = ''`, `email_change_token_new = ''`, `email_change = ''`. Nunca dejar esos campos NULL.
- **Cómo resolverlo:** `UPDATE auth.users SET confirmation_token = coalesce(confirmation_token, ''), recovery_token = coalesce(recovery_token, ''), email_change_token_new = coalesce(email_change_token_new, ''), email_change = coalesce(email_change, '')`. Verificar login con anon key (nunca `service_role` en el cliente).

### 3.32 `[Supabase]` RLS 42501: `permission denied for function is_staff`

- **Síntoma:** tras login, `from('profiles').select()` falla con `42501 permission denied for function is_staff` (o `jwt_role`).
- **Causa raíz:** las políticas de seguridad a nivel de fila (Row Level Security, RLS) llaman helpers `SECURITY DEFINER` en schema `private`, pero se revocó `EXECUTE` a `anon`/`authenticated`. La expresión de la política corre como el rol de la sesión.
- **Cómo evitarlo:** revocar `EXECUTE` de funciones definer **expuestas** (`public.handle_new_user`, etc.). Los helpers que usan las políticas (`private.jwt_role`, `private.is_staff`) necesitan `GRANT USAGE ON SCHEMA private` + `GRANT EXECUTE` a `anon` y `authenticated`.
- **Cómo resolverlo:** aplicar esos GRANT; no mover los helpers a `public`. Reprobar SELECT del propio perfil con JWT de cliente.

### 4.14 `[General]` No usar MCP/ID Stitch; MD primero, HTML manual al final

- **Síntoma:** se pierde tiempo con MCP o pidiendo ID de proyecto Stitch.
- **Cómo evitarlo:** Código Germinación **no** usa MCP ni ID. Implementar desde `PANTALLAS_PARA_STITCH.md`; HTML solo al finalizar el visual, entregado a mano (regla `07`).
- **Cómo resolverlo:** ignorar MCP Stitch; seguir MD → APK; adoptar HTML solo si el usuario lo pega.

### 4.15 `[Flutter]` Auditoría lenta por relanzar el render

- **Síntoma:** auditar una pantalla toma 10–15 min.
- **Causa raíz:** matar/relanzar el proceso, cambiar puerto (caché) e inflar delays del splash.
- **Cómo evitarlo:** un solo proceso caliente + hot reload/restart; no cambiar puerto; **auditoría manual por defecto**; freeze solo si el usuario pide automática (**4.16**). En Código Germinación preferir captura/verificación en **teléfono/APK** (**4.17**).
- **Cómo resolverlo:** sesión caliente; inventario estático primero.

### 4.16 `[General]` Freeze/`dart-define` para splash demora demasiado

- **Cómo evitarlo:** auditoría manual por defecto; el asistente **pregunta** antes de montar automática. Freeze solo con confirmación explícita.
- **Cómo resolverlo:** inventario + comparación visual en la sesión ya abierta.

### 4.17 `[Flutter]` Probar en Chrome/AVD en lugar del APK del teléfono

- **Síntoma:** se pierde tiempo en Chrome/AVD; bugs de Impeller/red aparecen tarde.
- **Cómo evitarlo (Código Germinación ≥ 2.2):** entorno = **APK en teléfono** + auto-update. Chrome/AVD solo si el perfil es Web o el usuario lo pide.
- **Cómo resolverlo:** `flutter build apk` → publicar update → abrir en el teléfono.

### 4.18 `[General]` Al cerrar pantallas: publicar APK, no abrir navegador

- **Cómo evitarlo:** al cerrar pantalla/módulo relevante → publicar (auto-update) → verificar en el teléfono. No lanzar Chrome por costumbre. Si el perfil es solo `[Web]`: una sola sesión/puerto, sin spam de ventanas.

### 4.19 `[General]` No dejar “manual en Dashboard” sin intentar API

- **Cómo evitarlo:** buscar endpoint → MCP → CLI → Management API → token temporal → revocar (**3.22**); solo entonces dejar lo que el plan bloquea (ej. HIBP 402). Documentar HTTP en `docs/SEGURIDAD.md`.

### 4.20 `[General]` Instrucciones SQL de prueba incompletas

- **Síntoma:** alumno pega `columna = null` → `ERROR: 42601`.
- **Causa raíz:** se dio solo el fragmento, no el `UPDATE`/`SELECT` completo.
- **Cómo evitarlo:** siempre SQL ejecutable. Ejemplo:

```sql
update billing_accounts
set paid_period_start = null,
    status = 'past_due';
```

- **Cómo resolverlo:** reenviar la sentencia completa.

### 4.21 `[General]` Bitácora de tiempos para cobro

- **Síntoma:** no se puede facturar horas; se pierde cuánto duró cada ejecución.
- **Cómo evitarlo:** al inicio/fin de cada sesión Agent, fila en `BITACORA_DESARROLLO.md` (inicio, fin, minutos, hito).
- **Cómo resolverlo:** reconstruir desde commits/chat y completar totales.

### 4.22 `[Flutter]` Receta E2E nativo (opcional; no es puerta DONE)

E2E **no** forma parte de la receta 2.10 del kit. Solo si el usuario lo pide y existe **QA** (no prod).

0. Respaldo descargable verificado (**4.25**). Target ≠ producción (**3.29**). Si solo hay prod → **no correr**.
1. JDK 21 + dispositivo/`adb` (**2.11**).
2. `patrol 3.20` + `patrol_cli 3.11` si `minSdk` &lt; 26 (**2.12**).
3. Tests solo en `integration_test/` (rutas con espacios rompen el bundler — **4.23**).
4. Keys estables + `--dart-define` para saltar update/billing en QA.
5. `patrol test` **contra QA**.
6. E2E verde → **quitar Patrol** → release (**2.10**).

### 4.23 `[Flutter]` `test_bundle.dart` y rutas con espacios

- **Síntoma:** `Expected ';'` / tipos inventados / `Invalid depfile` si la ruta del repo tiene espacios.
- **Causa raíz:** el CLI 3.11 solo normaliza imports bajo `integration_test/`.
- **Cómo evitarlo:** un solo directorio `integration_test/`. Gitignore de `**/test_bundle.dart`.
- **Cómo resolverlo:** mover el test, borrar `test_bundle.dart`, `flutter clean` + `pub get`.

### 4.24 `[Flutter]` E2E: “Found 0” no significa que el widget no exista; no atar el éxito a un snackbar

- **Síntoma:** timeout `hit-testable` con key/texto que sí está en el árbol; o el test falla por un toast y el flujo de negocio **sí** ocurrió.
- **Causa raíz:** acordeón colapsado; `DropdownMenuItem` en overlay; `ListView.builder` no construye off-screen (**3.28**); snackbar ya se fue; el nombre está en el controller, no en un `Text`.
- **Cómo evitarlo:** expandir sección antes de tap; dropdown por **texto**; scroll en listas; esperar **key/pantalla siguiente**, no el toast.
- **Cómo resolverlo:** no insistir en el mismo finder; timeout + condición de salida (`key` o texto).

### 4.25 `[General]` Antes de E2E: respaldo completo de la BD

- **Síntoma:** el test corrió, la nube se vació, no hay copia. Free sin PITR.
- **Causa raíz:** se asumió que “solo testear” no necesitaba backup.
- **Cómo evitarlo:** si piden Patrol/E2E, **primero** dump descargable (script del proyecto o SQL/CSV por tabla) con conteos verificados (`clientes`, cabeceras, ítems, etc.). Si el dump falló o quedó vacío, **abortar**. El ZIP **no** se commitea. El respaldo **no** autoriza E2E contra prod.
- **Cómo resolverlo:** restaurar upsert por `id` en orden de FKs. Si hay PITR del proveedor, usarlo antes de mezclar épocas. No hace falta un script canónico en el molde: el hábito sí.

---

## 5 · Checklist preventivo

**Antes de programar UI** `[General]`
- [ ] **Tema base** desde MD/tokens (HTML/`DESIGN.md` solo si se adoptó HTML al final).
- [ ] **V1:** MD pegable completo → implementar desde MD (sin MCP/ID). HTML manual solo al final del visual.
- [ ] **Inventario** MD (o HTML adoptado) + prueba en **APK del teléfono** — regla `09`.
- [ ] **Contrato de datos primero**: modelo + repo + provider antes de maquetar.
- [ ] Una pantalla a la vez. Nunca implementar todo y auditar al final.
- [ ] Auto-update APK configurado; no usar Chrome/AVD como entorno estándar (4.17).

**Definición de "pantalla terminada"** `[General]` (evita reescribirla; ver fichas 4.6, 4.9, 4.10)
- [ ] Lee/escribe **datos reales** (no `SampleData`) por su repositorio/provider.
- [ ] **Todas** las acciones conectadas (crear/editar/eliminar/navegar/cambiar estado) con función **real**. **Cero** placeholders "disponible próximamente" (`grep "próximamente"` / `grep "showEnConstruccion"` en el código de la app = 0). Un control fuera de alcance **se quita del diseño**, no se deja como placeholder.
- [ ] Estados **loading / vacío / error** resueltos.
- [ ] **Validación mínima** que no bloquee en silencio (obligatorio vs opcional bien separados; el error dice qué falta).
- [ ] Áreas táctiles fiables (`HitTestBehavior.opaque` donde el fondo pueda ser transparente).
- [ ] Permisos/rol respetados por reglas; sin escrituras cruzadas que el rol no puede hacer (derivar estado en su lugar).
- [ ] **Entrada visible en la navegación del rol** (barra/menú/FAB); no dejar la pantalla huérfana (ficha 4.10). Actualizar `docs/manual/AUDITORIA_NAVEGACION.md` en el mismo turno.
- [ ] `flutter analyze` limpio + verificación manual del flujo antes de pasar a la siguiente pantalla.

**Antes de programar UI** `[Flutter]`
- [ ] Definir el patrón de "tarjeta con acento" en **un solo widget** compartido (borde uniforme + franja superpuesta con `ClipRRect`). Nunca `borderRadius` + borde no uniforme. Superficie con `Material` + `InkWell` (no `DecoratedBox` tapando ink; **1.14**).
- [ ] Convención: textos con `maxLines`+`ellipsis`; filas con `Expanded`/`Flexible`/`Wrap`; números grandes con `FittedBox`.
- [ ] Íconos con `material_symbols_icons` si el diseño usa Material Symbols Outlined (no `Icons.*` rellenos).
- [ ] Grillas **adaptables**: usar `SliverGridDelegateWithMaxCrossAxisExtent` (+`mainAxisExtent`) o `AdaptiveGrid`; nunca `GridView.count` con `childAspectRatio` fijo para contenido real.
- [ ] **Ningún** control con `onPressed/onTap` vacío **ni placeholder "próximamente"**: debe navegar, cambiar estado o abrir un diálogo/hoja **funcional**. Contenedores tipo botón → envolver en `InkWell`/`GestureDetector`.

**Entorno / build** `[Flutter]`
- [ ] `flutter create` → **run verde** en el dispositivo objetivo **antes** de añadir paquetes cosméticos (`google_fonts`, etc.; ficha 2.4).
- [ ] `compileSdk = flutter.compileSdkVersion` en `build.gradle.kts`.
- [ ] Compilar **APK temprano**; instalar en el teléfono; documentar `dependency_overrides`.
- [ ] Permisos `INTERNET` (2.5); APK nombrado; auto-update (**2.6–2.8**). Keystore **release** (nunca debug; **2.9**). Probar update en **2.º dispositivo** sin permiso de instalar.
- [ ] Smoke cloud: una escritura desde el **teléfono** visible en consola.
- [ ] Upload APK grande: no cortar a 5 min si el cálculo exige ~15 min; o Dashboard (**2.7**).
- [ ] E2E nativo: **opcional**. Si se monta: respaldo verificado (**4.25**); **jamás contra prod** (**3.29**); JDK 21; Patrol 3.20/CLI 3.11 si `minSdk` &lt; 26; tests en `integration_test/`; al terminar **sacar** Patrol (**2.10–2.12**, **4.22**).

**Firebase** `[Firebase]` — seguir `CAMINO_POR_STACK.md` § D2
- [ ] Pre-flight CLI + APIs + apps + DB `(default)` (+ gcloud ADC si aplica). Plan Blaze si Storage/Functions.
- [ ] Firestore-first o sync visible; nunca `catch` vacío. Seed: colecciones vacías hasta escribir; no corromper UIDs en scripts.
- [ ] Rules `users/` propias; estado derivado vs escritura cruzada (3.6).

**Supabase** `[Supabase]` — seguir `CAMINO_POR_STACK.md` § D1
- [ ] Canal correcto: MCP (SQL/migraciones) vs CLI secrets vs Management API Auth (**3.15**).
- [ ] Paginación `.range()` si puede haber >1000 filas (**3.12**).
- [ ] Offline-first: outbox + `await kickSync` + badge solo offline; hidratar si `count local < remoto` (**3.13**, **3.20**, **3.30**). Cabecera+líneas: un solo kick; ítems no `failed` terminal (**3.27**). No wipe en pull vacío; tombstone de caché **nunca** hace DELETE remoto (**3.28**).
- [ ] Trigger anti-autoascenso `rol`/`activo` (**3.14**); tokens temporales → revocar (**3.22**).
- [ ] Seed Auth: tokens `confirmation_token`/`recovery_token` como `''` no NULL (**3.31**).
- [ ] Helpers RLS en `private`: `GRANT EXECUTE` a `anon`/`authenticated` si las políticas los llaman (**3.32**).
- [ ] Auto-update: arm64 + `app_config` (**2.6**); timeouts upload (**2.7**); 2.º dispositivo (**2.8**); firma release (**2.9**).
- [ ] Stripe: secret solo Edge; confirm por API; webhook opcional (**3.18**).
- [ ] Badges = datos reales (**3.19**); facturación SaaS si aplica (**3.21**); cierre de caja = cobros aplicados − gastos (**3.26**).
- [ ] SQL de prueba completo (**4.20**); API antes de “manual Dashboard” (**4.19**).
- [ ] **E2E ≠ prod** (**3.29**, **4.22**). Sin respaldo verificado, no se ejecuta (**4.25**).
**Aceleradores (antes de codear)** `[General]`
- [ ] Decisiones cerradas + stack en `PROJECT_PROFILE.md` + camino D1/D2.
- [ ] Seed demo + roles día 1 si es demostrable.
- [ ] Un patrón de pantalla × módulos; reglas críticas junto al CRUD.
- [ ] Abrir/cerrar fila en `BITACORA_DESARROLLO.md` (tiempos + errores + aciertos + deuda).

**Tipos / Dart** `[Flutter]`
- [ ] No pasar `AsyncValue`/`List`/`Map` **sin genéricos** entre métodos o widgets (un `dynamic` silencioso revienta con un cast en runtime, p. ej. en `items` de un `DropdownButtonFormField<T>`).
- [ ] Subidas de imagen/archivo: **opcionales y no bloqueantes** (crear el registro primero, upload en su propio `try/catch`).
- [ ] Capturar `ScaffoldMessenger`/`GoRouter` **antes** de `await`/navegación; no usar `context` tras `replace`/`pop`.
- [ ] `flutter analyze` tras cada bloque grande de archivos nuevos.

**QA / proceso** `[General]`
- [ ] Tras cambios de UI: **hot restart**/relanzar antes de reportar bugs.
- [ ] Ante "no muestra nada": descartar build obsoleto y confirmar datos por consulta antes de buscar bug de código.
- [ ] Web en blanco con `flutter run` (debug): descartar **proceso huérfano / servicio de depuración caído** (liberar puerto, relanzar limpio) o servir un **build de release estático** para revisión (ficha 4.5).
- [ ] **Cambios que "no aparecen" en web**: descartar **service worker/caché** (ficha 4.7) — comparar lo visible contra el código fuente; compilar con `--pwa-strategy=none` y/o servir en un **puerto nuevo**.
- [ ] Al tocar widgets compartidos: revisar **todos** los usos + análisis estático + validación visual.
- [ ] Revisar la consola buscando `EXCEPTION`/`overflowed`/`borderRadius` en cada pantalla nueva; **no** perseguir ruido EGL/Impeller del emulador si la UI responde (ficha 4.12).
- [ ] **Cierre documental del incremento (obligatorio; ficha 4.8):** en el mismo turno — evidencia en `REGISTRO.md` (si hubo resultado observado) **y** sincronizar `CHECKLIST.md` (`[x]`/`[~]`/`N/A`, Fase actual, notas vigentes). Evidencia sin checkbox = incompleto. Prohibido dejar notas ya falsas.
- [ ] **Manual por rol (ficha 4.9):** cada sección debe mapear a una entrada de navegación **observable** en la build; no documentar pantallas/rutas huérfanas ni specs Stitch sin enlace en UI.
- [ ] **Pantallas de rol (ficha 4.10):** ninguna ruta de alcance en `MODULO_*.md` queda sin entrada visible; actualizar `docs/manual/AUDITORIA_NAVEGACION.md` al tocar el router o el bottom nav.
- [ ] **Stitch (4.11):** MD completo → app 1:1 desde el MD; HTML opcional al final; sin MCP.
- [ ] **Al cerrar sesión (4.21):** fila completa en `BITACORA_DESARROLLO.md` (tiempos + retrospectiva).
- [ ] Antes de “hazlo en Dashboard”: intentar API/CLI (4.19). SQL de prueba = sentencia completa (4.20).
- [ ] Si piden E2E: preguntar *¿este URL es QA o producción?* Si es prod → abortar. Respaldo primero (**4.25**). Finders: expandir / texto / scroll; esperar key, no snackbar (**4.24**).
- [ ] **Nunca** dejar secretos/tokens en el chat sin instrucción de revocar (**3.22**).
- [ ] Timeouts de exploración ≤ 5 min; upload canónico de APK puede necesitar ~15 min (**2.7**).

---

## Cómo crece este documento

Al **cerrar cada proyecto** (Fase 4/5), el asistente debe:

1. Revisar los errores encontrados durante ese proyecto.
2. Agregar una ficha nueva **generalizada** (sin nombre de app ni datos sensibles) en la categoría que corresponda, con el formato Síntoma → Causa → Evitar → Resolver y su etiqueta de stack.
3. Si un error ya estaba fichado, reforzar la ficha existente en vez de duplicarla.
4. Actualizar el checklist preventivo si surge una nueva regla general.

---

## Referencias del proyecto

- Expediente técnico: [`docs/EXPEDIENTE_TECNICO.md`](EXPEDIENTE_TECNICO.md)
- Progreso y changelog: [`docs/CHECKLIST.md`](CHECKLIST.md)
- Evidencias: [`docs/evidencias/REGISTRO.md`](evidencias/REGISTRO.md)
- Auditoría de navegación (manual): [`docs/manual/AUDITORIA_NAVEGACION.md`](manual/AUDITORIA_NAVEGACION.md) — crear/actualizar cuando haya UI por roles
- Base de datos y rules: [`docs/database/STACK_DB.md`](database/STACK_DB.md)
- Auto-update APK (Supabase/Firebase): [`docs/specs/MODULO_ACTUALIZACION.md`](specs/MODULO_ACTUALIZACION.md), regla `12`, fichas **2.6–2.9**
- Seguridad: [`docs/SEGURIDAD.md`](SEGURIDAD.md)
- Camino por stack: [`docs/database/CAMINO_POR_STACK.md`](database/CAMINO_POR_STACK.md)
- Conexión BD: [`docs/database/CONECTAR_BD.md`](database/CONECTAR_BD.md)
- Reglas: `.cursor/rules/13-lecciones-aprendidas.mdc`, `14-flutter-ui-calidad.mdc`, `12-auto-update-apk.mdc`
- Bitácora: [`docs/BITACORA_DESARROLLO.md`](BITACORA_DESARROLLO.md)


