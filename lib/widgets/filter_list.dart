import 'package:flutter/material.dart';
import '../models/filter_option.dart';
import '../utils/filter_presets.dart';
import 'filter_thumbnail.dart';

class FilterList extends StatelessWidget {
  final Image image;
  final FilterOption currentFilter;
  final Function(FilterOption) onFilterSelected;

  const FilterList({
    super.key,
    required this.image,
    required this.currentFilter,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: FilterPresets.filters.length,
        itemBuilder: (context, index) {
          return FilterThumbnail(
            filter: FilterPresets.filters[index],
            currentFilter: currentFilter,
            image: image,
            onTap: () => onFilterSelected(FilterPresets.filters[index]),
          );
        },
      ),
    );
  }
}
