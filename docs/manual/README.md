# Manuales de usuario

Aquí se generan los manuales de uso, **uno por rol**, al final del proyecto.

## Cómo pedirlo

En modo **Agent**, al terminar la app:

```
Crea el manual de usuario por rol en docs/manual/.
Un archivo por rol, con el paso a paso de cada función y capturas de pantalla.
Usa capturas automáticas (integration_test / Playwright); si no se pueden,
deja marcadores [CAPTURA: ...] para agregarlas.
```

## Estructura

```
docs/manual/
├── MANUAL_<ROL>.md      ← uno por cada rol
└── capturas/            ← imágenes de las pantallas
```

## Estado

_Pendiente — se genera en la fase de cierre del proyecto._
