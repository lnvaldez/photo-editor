import 'dart:io';

class MediaScanner {
  static Future<void> scanFile(String filePath) async {
    try {
      final result = await Process.run('am', [
        'broadcast',
        '-a',
        'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
        '-d',
        'file://$filePath'
      ]);
      print('Media scan result: ${result.stdout}');
    } catch (e) {
      print('Error scanning media: $e');
    }
  }
}
