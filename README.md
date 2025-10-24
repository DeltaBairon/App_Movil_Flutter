# 📸 Aplicación de Cámara con Flutter

Aplicación móvil desarrollada en Flutter que permite capturar fotografías desde la cámara del dispositivo Android y almacenarlas localmente siguiendo principios de **POO, SOLID** y **Arquitectura Limpia (Clean Architecture)**.

---

## 📋 Descripción del Proyecto

Este proyecto corresponde a la **Actividad Evaluable 6** del curso **Programación de Móviles IS0213 - 210** del programa de **Ingeniería de Sistemas**.

El objetivo es crear una aplicación móvil que utilice la cámara del dispositivo Android para **tomar una foto y guardarla en la galería**, aplicando buenas prácticas de desarrollo móvil y separando responsabilidades mediante una arquitectura limpia.

> **Carácter:** Individual (aunque desarrollada en grupo, la entrega es personal).

---

## 🎯 Objetivo

Desarrollar una aplicación móvil en Flutter que permita al usuario capturar fotografías y almacenarlas localmente en el dispositivo Android, asegurando una estructura modular y mantenible mediante **Clean Architecture**.

---

## 🧩 Requisitos Previos

Antes de iniciar, asegúrate de tener instalado lo siguiente:

| Herramienta | Descripción |
|--------------|-------------|
| **Flutter SDK** | Framework para desarrollo multiplataforma |
| **Android Studio** | IDE con emulador y soporte completo para Android |
| **Plugin de Flutter** | Debe estar instalado en Android Studio |
| **Emulador o dispositivo físico** | Para probar la aplicación |
| **Comando `flutter doctor`** | Asegúrate de que no haya errores críticos |

---

## 🏗️ Arquitectura del Proyecto

La aplicación sigue una **Arquitectura Limpia** (Clean Architecture) dividida en tres capas principales:

### 1. 🖥️ Capa de Presentación (Presentation)
- **Responsabilidad:** Contiene los *Widgets (UI)*, gestión del estado y lógica de la vista.
- **Conoce el framework Flutter.**
- **Componentes:** 
  - Páginas (`pages/`)
  - Widgets (`widgets/`)
  - Controladores o Providers

---

### 2. 🧠 Capa de Dominio (Domain)
- **Responsabilidad:** Contiene la lógica de negocio y las reglas del dominio.
- **Independiente de frameworks externos.**
- **Componentes:**
  - Entidades (`entities/`)
  - Casos de uso (`usecases/`)
  - Abstracciones de Repositorios (`repositories/`)

---

### 3. 💾 Capa de Datos (Data)
- **Responsabilidad:** Implementa las abstracciones del dominio y gestiona el acceso a fuentes externas (hardware, API, etc.).
- **Componentes:**
  - Repositorios (`repositories/`)
  - Fuentes de datos (`datasources/`)

---

## 🚀 Pasos de Implementación

### 🧩 Paso 1: Crear el Proyecto

Abre una terminal y ejecuta los comandos:

```bash
flutter create camera_app
cd camera_app
```

---

### 📦 Paso 2: Añadir Dependencias

Edita el archivo `pubspec.yaml` e incluye las siguientes librerías:

```yaml
dependencies:
  flutter:
    sdk: flutter
  camera: ^0.10.5+9          # Interacción con la cámara
  path_provider: ^2.0.11     # Manejo de rutas del sistema
  gallery_saver: ^2.3.2      # Guardar imágenes en la galería
```

Luego instala las dependencias:

```bash
flutter pub get
```

---

### ⚙️ Paso 3: Configurar Permisos

Abre el archivo `android/app/src/main/AndroidManifest.xml` y agrega el siguiente permiso dentro de la etiqueta `<manifest>`:

```xml
<uses-permission android:name="android.permission.CAMERA" />
```

---

### 📁 Paso 4: Estructurar el Proyecto

Crea la siguiente estructura de carpetas dentro de `lib/`:

```
lib/
├── data/
│   ├── datasources/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
├── presentation/
│   ├── pages/
│   └── widgets/
└── main.dart
```

---

## 💡 Implementación de las Capas

### 🧠 Capa de Dominio

#### 1. Entidad: `domain/entities/photo.dart`
Define la estructura básica del objeto foto.

```dart
class Photo {
  final String path;
  Photo(this.path);
}
```

#### 2. Abstracción del Repositorio: `domain/repositories/camera_repository.dart`
Define el contrato que la capa de datos debe cumplir.

```dart
abstract class CameraRepository {
  Future<String?> takePicture();
}
```

#### 3. Caso de Uso: `domain/usecases/take_picture.dart`
Encapsula la lógica para tomar una foto.

```dart
import '../repositories/camera_repository.dart';

class TakePicture {
  final CameraRepository repository;
  TakePicture(this.repository);

  Future<String?> call() async {
    return await repository.takePicture();
  }
}
```

---

### 💾 Capa de Datos

#### Implementación del Repositorio: `data/repositories/camera_repository_impl.dart`

```dart
import 'package:camera/camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import '../../domain/repositories/camera_repository.dart';

class CameraRepositoryImpl implements CameraRepository {
  late CameraController _controller;
  late List<CameraDescription> _cameras;

  Future<void> _initializeController() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    await _controller.initialize();
  }

  @override
  Future<String?> takePicture() async {
    try {
      await _initializeController();
      if (!_controller.value.isInitialized) {
        return null;
      }

      final XFile file = await _controller.takePicture();
      await GallerySaver.saveImage(file.path);
      return file.path;
    } catch (e) {
      print('Error al tomar la foto: $e');
      return null;
    } finally {
      await _controller.dispose();
    }
  }
}
```

---

### 🖥️ Capa de Presentación

#### Página Principal: `presentation/pages/home_page.dart`

```dart
import 'package:flutter/material.dart';
import '../../domain/usecases/take_picture.dart';
import '../../data/repositories/camera_repository_impl.dart';

class HomePage extends StatelessWidget {
  final TakePicture takePictureUseCase = TakePicture(CameraRepositoryImpl());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📸 Cámara Flutter")),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final path = await takePictureUseCase();
            final message = path != null
                ? "📷 Foto guardada en:\n$path"
                : "❌ No se pudo tomar la foto";
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message)),
            );
          },
          child: const Text("Tomar Foto"),
        ),
      ),
    );
  }
}
```

#### Archivo principal: `main.dart`

```dart
import 'package:flutter/material.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const CameraApp());
}

class CameraApp extends StatelessWidget {
  const CameraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera App',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
```

---

## 📱 Ejecución del Proyecto

1. Conecta tu dispositivo o inicia el emulador Android.  
2. Ejecuta desde la terminal:

```bash
flutter run
```

3. La aplicación abrirá una interfaz con un botón “Tomar Foto”.  
4. Al capturar la imagen, se guardará automáticamente en la galería del dispositivo.

---

## 🧰 Solución de Problemas

| Problema | Posible Solución |
|-----------|------------------|
| **La cámara no abre** | Verifica el permiso en `AndroidManifest.xml`. |
| **No se guarda la foto** | Asegúrate de que `gallery_saver` esté instalado y configurado. |
| **Error al inicializar el controlador** | Prueba en un dispositivo físico; algunos emuladores no soportan cámara. |

---

## 🧩 Posibles Mejoras

- [ ] Implementar almacenamiento local con SQLite o Hive.  
- [ ] Agregar vista previa de la última foto tomada.  
- [ ] Integrar reconocimiento facial o filtros básicos.  
- [ ] Crear una galería interna dentro de la app.  
- [ ] Agregar selector de cámara (frontal/trasera).  

---

## 📝 Estructura del Proyecto

```
camera_app/
│
├── lib/
│   ├── data/
│   │   ├── datasources/
│   │   └── repositories/
│   ├── domain/
│   │   ├── entities/
│   │   ├── repositories/
│   │   └── usecases/
│   ├── presentation/
│   │   ├── pages/
│   │   └── widgets/
│   └── main.dart
├── pubspec.yaml
└── README.md
```

---

## 📄 Licencia

Proyecto educativo desarrollado como parte de la **Actividad Evaluable 6** del curso **Programación de Móviles IS0213 - 210**.  
Código abierto bajo la licencia **MIT**.

---

## 👨‍💻 Autor

**Nombre del Estudiante:** *[Tu nombre completo]*  
**Código:** *[Tu código estudiantil]*  
**Programa:** Ingeniería de Sistemas  
**Institución:** *[Nombre de la universidad]*  
