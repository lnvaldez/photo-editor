import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    var photosStatus = await Permission.photos.status;
    if (photosStatus.isDenied) {
      photosStatus = await Permission.photos.request();
    }

    var manageStorageStatus = await Permission.manageExternalStorage.status;
    if (manageStorageStatus.isDenied) {
      manageStorageStatus = await Permission.manageExternalStorage.request();
    }

    return status.isGranted ||
        photosStatus.isGranted ||
        manageStorageStatus.isGranted;
  }
}
