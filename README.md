# gestor_cafeteria

Aplicación Flutter para gestionar los pedidos de una cafetería. Consume la API REST de **mini_backend** mediante un cliente HTTP (`ApiClient`) que convierte cada error de la API en un `Failure` tipado (`NotFoundFailure`, `ConflictFailure`, `ValidationFailure`, `ServerFailure`, `UnexpectedFailure` y `NetworkFailure`). El cliente está cubierto por pruebas automatizadas que no necesitan red ni servidor.

Proyecto de la asignatura Desarrollo Móvil Integral (10.º A, septiembre–diciembre 2026).

## Requisitos

- **Flutter** (canal stable) con Dart 3.13 o superior. Comprueba con `flutter --version`.
- **Node.js 22.13 o superior**, para ejecutar mini_backend. Comprueba con `node --version`.
- **Git**.

## Servidor: mini_backend

El servidor de pedidos es **otro repositorio** y no se incluye en este proyecto:

- Repositorio: https://github.com/DMI-2026/mini_backend
- Versión con la que se probó: commit `94d2533` (8 de octubre de 2026), rama `master`.

### Cómo levantarlo

```bash
git clone https://github.com/DMI-2026/mini_backend.git
cd mini_backend
node server.js
```

No hace falta `npm install`. El servidor queda en el puerto 8000. Para comprobar que funciona, abre `http://localhost:8000/health`; debe responder `{"status":"ok"}`.

## Cómo ejecutar la app

```bash
flutter pub get
```

En Chrome:

```bash
flutter run -d chrome --dart-define=API_URL=http://localhost:8000
```

En el emulador de Android (`10.0.2.2` es la dirección de tu computadora vista desde el emulador):

```bash
flutter run --dart-define=API_URL=http://10.0.2.2:8000
```

Si no se indica `API_URL`, el cliente usa `http://localhost:8000` en web y `http://10.0.2.2:8000` en Android.

## Cómo correr las pruebas

```bash
flutter test
flutter analyze
```

Las pruebas usan `MockClient` (de `package:http/testing.dart`), así que **no necesitan** que mini_backend esté encendido.

## Estructura de carpetas

```
lib/
  main.dart              Punto de entrada de la app
  core/
    failure.dart         Jerarquía sellada de errores (Failure)
    http_client.dart     ApiClient: peticiones HTTP y mapeo de errores
test/
  core/
    failure_test.dart    Pruebas de la jerarquía de Failure
    http_client_test.dart Pruebas del ApiClient con MockClient
android/, web/           Configuración de cada plataforma
```
