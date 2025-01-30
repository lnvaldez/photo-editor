import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui' as ui;
import '../models/filter_option.dart';
import '../utils/filter_presets.dart';
import '../services/permission_service.dart';
import '../services/image_saver.dart';
import '../services/media_scanner.dart';
import '../widgets/filter_list.dart';
import '../widgets/image_preview.dart';

class EditScreen extends StatefulWidget {
  final XFile imageFile;

  const EditScreen({super.key, required this.imageFile});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {
  final GlobalKey _globalKey = GlobalKey();
  late Image _image;
  late FilterOption _currentFilter;

  @override
  void initState() {
    super.initState();
    _image = Image.file(File(widget.imageFile.path));
    _currentFilter = FilterPresets.filters.first;
  }

  Future<void> _saveImage() async {
    if (!await PermissionService.requestStoragePermission()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission is required')),
        );
      }
      return;
    }

    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);

      final String? savedPath = await ImageSaver.saveImage(image);

      if (savedPath != null) {
        await MediaScanner.scanFile(savedPath);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Image saved to gallery successfully!')),
          );
        }
      }
    } catch (e) {
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
          ImagePreview(
            globalKey: _globalKey,
            image: _image,
            currentFilter: _currentFilter,
          ),
          FilterList(
            image: _image,
            currentFilter: _currentFilter,
            onFilterSelected: (filter) {
              setState(() => _currentFilter = filter);
            },
          ),
        ],
      ),
    );
  }
}
