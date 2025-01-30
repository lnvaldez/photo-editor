import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class EditScreen extends StatefulWidget {
  final XFile imageFile;

  const EditScreen({super.key, required this.imageFile});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final GlobalKey _globalKey = GlobalKey();
  late Image _image;
  ColorFilter _currentFilter = const ColorFilter.matrix([
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
  ]); // Normal filter (no effect)

  final List<FilterOption> _filters = [
    FilterOption(
      name: 'Normal',
      matrix: [
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ],
    ),
    FilterOption(
      name: 'Sepia',
      matrix: [
        0.393,
        0.769,
        0.189,
        0,
        0,
        0.349,
        0.686,
        0.168,
        0,
        0,
        0.272,
        0.534,
        0.131,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ],
    ),
    FilterOption(
      name: 'Greyscale',
      matrix: [
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0.2126,
        0.7152,
        0.0722,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ],
    ),
    FilterOption(
      name: 'Vintage',
      matrix: [
        0.9,
        0.5,
        0.1,
        0,
        0,
        0.3,
        0.8,
        0.1,
        0,
        0,
        0.2,
        0.3,
        0.5,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ],
    ),
    FilterOption(
      name: 'Sweet',
      matrix: [
        1.0,
        0.0,
        0.2,
        0,
        0,
        0.0,
        1.0,
        0.0,
        0,
        0,
        0.0,
        0.0,
        1.0,
        0,
        0,
        0,
        0,
        0,
        1,
        0,
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _image = Image.file(File(widget.imageFile.path));
  }

  Future<bool> _requestStoragePermission() async {
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

  Future<void> _saveImage() async {
    bool hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Storage permission is required to save images')),
        );
      }
      return;
    }

    try {
      const String dirPath = '/storage/emulated/0/DCIM/Camera';
      final Directory dir = Directory(dirPath);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }

      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final bytes = byteData.buffer.asUint8List();

        final String fileName =
            'edited_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final String galleryPath = '$dirPath/$fileName';

        final decodedImage = img.decodeImage(bytes);
        if (decodedImage != null) {
          final jpg = img.encodeJpg(decodedImage, quality: 90);
          final File file = File(galleryPath);
          await file.writeAsBytes(jpg);

          try {
            final result = await Process.run('am', [
              'broadcast',
              '-a',
              'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
              '-d',
              'file://$galleryPath'
            ]);
            print('Media scan result: ${result.stdout}');
          } catch (e) {
            print('Error scanning media: $e');
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Image saved to: $galleryPath'),
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error saving image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Photo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveImage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RepaintBoundary(
              key: _globalKey,
              child: ColorFiltered(
                colorFilter: _currentFilter,
                child: _image,
              ),
            ),
          ),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentFilter =
                          ColorFilter.matrix(_filters[index].matrix);
                    });
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _currentFilter.toString() ==
                                ColorFilter.matrix(_filters[index].matrix)
                                    .toString()
                            ? Colors.blue
                            : Colors.grey,
                      ),
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ColorFiltered(
                            colorFilter:
                                ColorFilter.matrix(_filters[index].matrix),
                            child: _image,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            _filters[index].name,
                            style: const TextStyle(fontSize: 12),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOption {
  final String name;
  final List<double> matrix;

  FilterOption({
    required this.name,
    required this.matrix,
  });
}
