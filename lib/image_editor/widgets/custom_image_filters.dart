
import 'dart:typed_data';
import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

import '../tools/utils.dart';
import 'mixed_color_filter.dart';

class _OptionData {
  final String? label;
  final ImageFilterParams? filter;
  _OptionData({this.filter, this.label});
}

class CustomImageFilters extends StatefulWidget {
  const CustomImageFilters({required this.filter, required this.onChange, required this.imgController, super.key});
  final ImageFilterParams filter;
  final VoidCallback onChange;
  final CustomImageCropController imgController;

  @override
  State<CustomImageFilters> createState() => _CustomImageFiltersState();
}

class _CustomImageFiltersState extends State<CustomImageFilters> {
  late final List<_OptionData> _filters;
  int selectedFilter = -1;
  Uint8List? imageData;

  @override
  void initState() {
    cropImageSample();
    _filters = [
      _OptionData(label: 'Original', filter: ImageFilterParams()),
      _OptionData(label: 'Prime', filter: ImageFilterParams(contrast: 2)),
      _OptionData(label: 'Spotlight', filter: ImageFilterParams(exposure: 1.2)),
      _OptionData(label: 'Studio', filter: ImageFilterParams(sepia: 0.3)),
      _OptionData(label: 'Classic', filter: ImageFilterParams(grayscale: 1)),
      _OptionData(label: 'Edge', filter: ImageFilterParams(saturation: 2)),
    ];

    super.initState();
  }

  onSelected(ImageFilterParams filter, int index) {
    widget.filter.cloneValues(filter);
    selectedFilter = index;
    widget.onChange();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ..._filters
            .map((e) => InkWell(
                  onTap: () => onSelected(e.filter!, _filters.indexOf(e)),
                  child: Column(
                    children: [
                      MixedColorFilter(
                        filter: e.filter!,
                        child: imageData != null
                            ? CircleAvatar(
                                backgroundImage: MemoryImage(imageData!),
                                radius: 22,
                              )
                            : const SizedBox(),
                      ).padding(all: 3).decorated(
                            color: selectedFilter == _filters.indexOf(e)
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                      Text(
                        e.label!,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ))
            .toList()
      ],
    );
  }

  ImageProvider getProvider() {
    if (widget.filter.image == null) {
      return NetworkImage(widget.filter.imageUrl!, scale: .8);
    } else {
      return FileImage(widget.filter.image!, scale: .8);
    }
  }

  void cropImageSample() async {
    imageData = (await widget.imgController.onCropImage())!.bytes;
    if (mounted) setState(() {});
  }
}
