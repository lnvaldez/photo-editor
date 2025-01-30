import 'package:flutter/material.dart';
import '../models/filter_option.dart';

class ImagePreview extends StatelessWidget {
  final GlobalKey globalKey;
  final Image image;
  final FilterOption currentFilter;

  const ImagePreview({
    super.key,
    required this.globalKey,
    required this.image,
    required this.currentFilter,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: RepaintBoundary(
        key: globalKey,
        child: ColorFiltered(
          colorFilter: ColorFilter.matrix(currentFilter.matrix),
          child: image,
        ),
      ),
    );
  }
}
