import 'package:flutter/material.dart';
import '../models/filter_option.dart';

class FilterThumbnail extends StatelessWidget {
  final FilterOption filter;
  final FilterOption currentFilter;
  final Image image;
  final VoidCallback onTap;

  const FilterThumbnail({
    super.key,
    required this.filter,
    required this.currentFilter,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: currentFilter == filter ? Colors.blue : Colors.grey,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ColorFiltered(
                colorFilter: ColorFilter.matrix(filter.matrix),
                child: image,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                filter.name,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
