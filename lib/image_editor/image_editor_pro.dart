import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_editor_pro/image_editor/tools/size_config.dart';
import 'package:flutter_image_editor_pro/image_editor/tools/utils.dart';
import 'package:styled_widget/styled_widget.dart';

import 'widgets/image_editor_options.dart';
import 'widgets/mixed_color_filter.dart';
import 'widgets/save_loading_dialog.dart';

class ImageEditorPro extends StatefulWidget {
  const ImageEditorPro({
    Key? key,
    required this.onDelete,
    required this.onUpload,
    required this.onSave,
    this.onReset,
    required this.cropController,
    required this.imageProvider,
    required this.filter,
    this.backgroundColor = Colors.white,
  }) : super(key: key);
  final ImageFilterParams filter;
  final VoidCallback onDelete, onUpload;
  final VoidCallback? onReset;
  final Color backgroundColor;
  final Future Function() onSave;
  final CustomImageCropController cropController;
  final ImageProvider? imageProvider;

  @override
  State<ImageEditorPro> createState() => _ImageEditorProState();
}

class _ImageEditorProState extends State<ImageEditorPro> {
  @override
  void didChangeDependencies() {
    SizeConfig.init(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          backgroundColor: Colors.black,
          title: Text('Editing', style: TextStyle(color: Colors.white)),
          actions: [
            InkWell(
              onTap: widget.onDelete,
              child:  Icon(Icons.delete_forever_outlined).padding(right: 10),
            ),
            InkWell(
              onTap: widget.onUpload,
              child: const Icon(Icons.upload_file_outlined).padding(right: 10),
            ),
            _CustomTextButton(
              textColor: Colors.white,
              onPressed: () {
                widget.filter.reset();
                widget.cropController.reset();
                widget.cropController.resumeEditing();
                setState(() {});
                widget.onReset?.call();
              },
              label: 'Reset',
            ),
            _CustomTextButton(
              textColor: Theme.of(context).primaryColor,
              onPressed: () => showSaveLoadingDialog(context, widget.onSave),
              label: 'Save',
              isBold: true,
            )
          ],
        ),
        SizedBox(
          height: 65.hPercent,
          width: 100.wPercent,
          child: widget.imageProvider != null
              ? CustomImageCrop(
                  cropController: widget.cropController,
                  backgroundColor: widget.backgroundColor,
                  cropPercentage: .75,
                  shape: widget.filter.isCover ? CustomCropShape.Rectangle : CustomCropShape.Circle,
                  overlayColor: const Color.fromRGBO(0, 0, 0, 0.75),
                  image: widget.imageProvider!,
                  child: MixedColorFilter(
                    filter: widget.filter,
                    child: Image(
                      image: widget.imageProvider!,
                    ),
                  ),
                )
              : InkWell(
                  onTap: widget.onUpload,
                  child: Text(
                    'Upload a image',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ).center().decorated(color: widget.backgroundColor),
                ),
        ).expanded(),
        IgnorePointer(
          ignoring: widget.imageProvider == null,
          child: ImageEditorOptions(
            widget.filter,
            widget.cropController,
            () => setState(() {}),
          ),
        ),
      ],
    );
  }
}

class _CustomTextButton extends StatelessWidget {
  const _CustomTextButton({
    required this.onPressed,
    required this.label,
    this.textColor,
    this.isBold = false,
  });
  final bool isBold;
  final Color? textColor;
  final String label;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
          // padding: EdgeInsets.all(12),
          ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor ?? Colors.blue,
          fontWeight: isBold ? FontWeight.bold : null,
          fontSize: 18,
        ),
      ),
    );
  }
}
