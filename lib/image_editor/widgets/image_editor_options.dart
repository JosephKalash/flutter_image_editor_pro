import 'dart:math';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_editor_pro/image_editor/tools/size_config.dart';
import 'package:styled_widget/styled_widget.dart';
import 'package:unicons/unicons.dart';
import '../tools/utils.dart';
import 'custom_image_filters.dart';
import 'slider_widget.dart';

class ImageEditorOptions extends StatefulWidget {
  const ImageEditorOptions(this.filter, this.editImgCon, this.onChange, {super.key});

  final CustomImageCropController editImgCon;
  final VoidCallback onChange;
  final ImageFilterParams filter;

  @override
  State<ImageEditorOptions> createState() => _ImageEditorOptionsState();
}

class _ImageEditorOptionsState extends State<ImageEditorOptions> {
  int selectedIndex = 0;
  final pageCon = PageController(initialPage: 0, keepPage: true);
  final _options = [
    {Icons.rotate_right_rounded, 'Straighten'},
    {Icons.filter, 'Filters'},
    {Icons.brightness_1, 'Saturation'},
    {Icons.contrast, 'Contrast'},
    {Icons.wb_sunny_rounded, 'Brightness'},
    {UniconsLine.eye, 'Sepia'},
  ];
  onSelected(int index) {
    selectedIndex = index;
    if (selectedIndex == 0) {
      widget.editImgCon.resumeEditing();
    } else {
      widget.editImgCon.stopEditing();
    }
    pageCon.animateToPage(selectedIndex, duration: const Duration(milliseconds: 150), curve: Curves.bounceIn);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PageView(
          controller: pageCon,
          physics: const BouncingScrollPhysics(),
          children: getOptionsWidgets,
        ).height(80).decorated(color: Colors.black),
        Theme(
          data: Theme.of(context).copyWith(iconTheme: IconTheme.of(context).copyWith(color: Colors.white)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ..._options
                  .map(
                    (item) => Material(
                      color: Colors.transparent,
                      shadowColor: Colors.transparent,
                      child: InkWell(
                        onTap: () => onSelected(_options.indexOf(item)),
                        child: Column(
                          children: [
                            Icon(
                              item.first as IconData,
                              color: selectedIndex == _options.indexOf(item)
                                  ? Theme.of(context).primaryColor
                                  : Colors.white,
                            ).padding(horizontal: 5.wPercent, top: 5.wPercent),
                            Text(
                              item.last as String,
                              style: TextStyle(
                                color: selectedIndex == _options.indexOf(item)
                                    ? Theme.of(context).primaryColor
                                    : Colors.white,
                              ),
                            ),
                            if (selectedIndex == _options.indexOf(item))
                              Container(color: Theme.of(context).primaryColor, height: 3, width: 14.wPercent)
                                  .decorated()
                                  .padding(top: 10)
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList()
            ],
          ).safeArea(top: false).decorated(color: Colors.black),
        ),
      ],
    );
  }

  List<Widget> get getOptionsWidgets {
    return [
      SliderWidget(
        widget.filter.degree,
        label: 'Straighten',
        min: 0,
        max: 360,
        divisions: 360,
        onChanged: (val) {
          widget.filter.degree = val.round();
          widget.onChange();
          widget.editImgCon.cropImageData?.angle = (val * pi) / 180;
          widget.editImgCon.setData(widget.editImgCon.cropImageData!);
        },
      ),
      CustomImageFilters(
        filter: widget.filter,
        onChange: widget.onChange,
        imgController: widget.editImgCon,
      ),
      SliderWidget(
        widget.filter.saturation,
        label: 'Saturation',
        onChanged: (val) {
          widget.filter.saturation = val;
          widget.onChange();
        },
      ),
      SliderWidget(
        widget.filter.contrast,
        label: 'Contrast',
        onChanged: (val) {
          widget.filter.contrast = val;
          widget.onChange();
        },
      ),
      SliderWidget(
        widget.filter.exposure,
        label: 'Brightness',
        onChanged: (val) {
          widget.filter.exposure = val;
          widget.onChange();
        },
      ),
      SliderWidget(
        widget.filter.sepia,
        label: 'Sepia',
        min: 0,
        max: 1,
        divisions: 10,
        onChanged: (val) {
          widget.filter.sepia = val;
          widget.onChange();
        },
      ),
    ];
  }
}
