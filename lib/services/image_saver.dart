import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

class ImageSaver {
  static Future<String?> saveImage(ui.Image image) async {
    try {
      const String dirPath = '/storage/emulated/0/DCIM/Camera';
      final Directory dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final bytes = byteData.buffer.asUint8List();
      final String fileName =
          'edited_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String galleryPath = '$dirPath/$fileName';

      final decodedImage = img.decodeImage(bytes);
      if (decodedImage != null) {
        final jpg = img.encodeJpg(decodedImage, quality: 90);
        final File file = File(galleryPath);
        await file.writeAsBytes(jpg);
        return galleryPath;
      }
      return null;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
}
