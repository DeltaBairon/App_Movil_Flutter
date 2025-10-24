import '../repositories/camera_repository.dart';
class TakePicture {
 final CameraRepository repository;
 TakePicture(this.repository);
 Future<String?> call() async {
 return await repository.takePicture();
 }
}