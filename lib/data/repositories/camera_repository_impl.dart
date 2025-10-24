import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class CameraRepositoryImpl {
  late CameraController _controller;
  late List<CameraDescription> _cameras;

  Future<void> _init() async {
    _cameras = await availableCameras();
    _controller = CameraController(_cameras[0], ResolutionPreset.high);
    await _controller.initialize();
  }

  Future<String?> takePicture() async {
    try {
      // Pedir permisos de cámara y almacenamiento
      await Permission.camera.request();
      await Permission.photos.request();
      await Permission.storage.request();

      // Si no se conceden permisos, salir
      if (!(await Permission.camera.isGranted)) return null;

      await _init();
      final XFile picture = await _controller.takePicture();

      // Directorio público (Pictures)
      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir == null) return null;

      // Crear carpeta si no existe
      final Directory picturesDir =
          Directory('${extDir.parent.parent.parent.parent.path}/Pictures/FlutterPhotos');
      if (!await picturesDir.exists()) {
        await picturesDir.create(recursive: true);
      }

      // Nuevo archivo con timestamp
      final String newPath =
          '${picturesDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(picture.path).copy(newPath);

      await _controller.dispose();
      return newPath;
    } catch (e) {
      try {
        if (_controller.value.isInitialized) await _controller.dispose();
      } catch (_) {}
      return null;
    }
  }
}

