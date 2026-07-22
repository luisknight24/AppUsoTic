# Tics en la literatura: Aplicación móvil educativa y gamificada para el repaso interactivo de obras literarias

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=flat-square) ![Dart](https://img.shields.io/badge/Dart-%230175C2.svg?style=flat-square)


El presente proyecto consiste en una aplicación móvil desarrollada en Flutter, cuyo objetivo principal es fomentar el aprendizaje de la literatura universal e hispanoamericana mediante la integración de recursos interactivos. En este sentido, la plataforma proporciona un entorno gamificado, facilitando a los usuarios el repaso de obras clásicas como La Ilíada, La Odisea, La Eneida, Las cruces sobre el agua y Cien años de soledad.

## Características principales

- **Interfaz y tutorial guiado**: Cuenta con un diseño adaptativo y un recorrido paso a paso para nuevos usuarios, optimizando la curva de aprendizaje inicial.
- **Módulos multimedia**: Dispone de secciones con sinopsis literarias y reproductores de YouTube integrados para la visualización de material audiovisual complementario.
- **Gamificación literaria**: Integra cuatro dinámicas interactivas (Sopa de letras, Ahorcado literario, Cuestionario y Relación de citas) diseñadas para evaluar y reforzar el conocimiento adquirido.
- **Sistema de métricas y clasificaciones**: Emplea almacenamiento local para guardar de manera persistente los récords de cada jugador, permitiendo consultar los mejores desempeños a través de un panel de trofeos dedicado.

## Arquitectura y herramientas

El desarrollo de la aplicación emplea la tecnología Flutter para asegurar la compatibilidad multiplataforma y garantizar un rendimiento similar al nativo. Por otro lado, la persistencia de datos del sistema de puntuaciones se gestiona localmente mediante el paquete de preferencias compartidas, evitando la necesidad de un servidor externo para el almacenamiento de progreso.

> [!NOTE]
> Para el correcto funcionamiento de los videos embebidos en la interfaz, el dispositivo cliente debe contar con una conexión a internet activa.

## Despliegue en desarrollo

Para compilar y ejecutar la aplicación en un entorno local, se requiere disponer del SDK de Flutter previamente configurado. Posteriormente, basta con ejecutar el siguiente comando en la raíz del repositorio para iniciar la aplicación en el dispositivo o emulador seleccionado.

```bash
flutter run
```
