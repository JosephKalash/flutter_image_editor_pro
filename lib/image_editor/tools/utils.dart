import 'dart:io';
import 'dart:math';

import 'package:custom_image_crop/custom_image_crop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_editor_pro/image_editor/tools/size_config.dart';
import 'package:image_picker/image_picker.dart' as ip;
import 'package:ml_linalg/linalg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:styled_widget/styled_widget.dart';

import '../widgets/mixed_color_filter.dart';

class ImageFilterParams {
  double exposure;
  double contrast;
  double sepia;
  double saturation;
  double grayscale;
  double zoom;
  int degree;
  File? image;
  String? imageUrl;
  bool isCover;

  ImageFilterParams({
    this.contrast = 1,
    this.isCover = false,
    this.zoom = 1,
    this.grayscale = 0,
    this.degree = 0,
    this.exposure = 1,
    this.sepia = 0,
    this.image,
    this.saturation = 1,
  });
  void reset() {
    contrast = exposure = saturation = 1.0;
    grayscale = 0;
    degree = 0;
    sepia = 0;
  }

  void cloneValues(ImageFilterParams other) {
    grayscale = other.grayscale;
    exposure = other.exposure;
    contrast = other.contrast;
    sepia = other.sepia;
    zoom = other.zoom;
    saturation = other.saturation;
    degree = other.degree;
  }

  @override
  String toString() => 'exposure: $exposure, contrast: $contrast, sepia: $sepia, saturation: $saturation';

  List<double> getFilteredMatrix() {
    List<double> filteredMatrix = [];
    late Matrix matrix = Matrix.fromList(normalFilter);

    if (sepia != 0) matrix *= Matrix.fromList(getSepia(sepia));

    if (grayscale == 1) matrix *= Matrix.fromList(grayFilter);

    if (exposure != 1 || saturation != 1) {
      matrix *= Matrix.fromList(getColorFilterMatrix(exposure: exposure, saturation: saturation));
    }

    if (contrast != 1) matrix *= Matrix.fromList(getContrastMatrix(contrast));

    for (int i = 0; i < 4; i++) {
      filteredMatrix.addAll(matrix[i]);
    }
    return filteredMatrix;
  }

  factory ImageFilterParams.fromMap(Map<String, dynamic> map) => ImageFilterParams(
        exposure: double.parse(map['brightness'] ?? '1'),
        contrast: double.parse(map['contrast'] ?? '1'),
        sepia: double.parse(map['sepia'] ?? '0'),
        saturation: double.parse(map['saturate'] ?? '1'),
        grayscale: double.parse(map['grayscale'] ?? '0'),
        zoom: double.parse(map['zoom'] ?? '1'),
        degree: num.parse(map['rotate'] ?? '0').round(),
      );
}

Future<File?> pickImage() async {
  final file = await ip.ImagePicker().pickImage(
    source: ip.ImageSource.gallery,
    maxWidth: 100.wPercent,
  );
  // final bytes = await file?.readAsBytes();
  // path = (await getTemporaryDirectory()).path;
  // return decodeImage(bytes!)!;
  if (file == null) return null;
  return File(file.path);
}

Future<File?> saveImage(
  BuildContext context,
  CustomImageCropController imgController,
  ImageFilterParams filter,
) async {
  final image = await imgController.onCropImage();
  if (image == null) return null;

  final bytes = await ScreenshotController().captureFromWidget(
    MixedColorFilter(
      filter: filter,
      child: Image.memory(image.bytes, height: 300, width: filter.isCover ? 600 : 300)
          .clipRRect(all: filter.isCover ? 0 : 160),
    ),
    context: context,
  );

  final temp = (await getTemporaryDirectory()).path;
  final fileName = '$temp/tempImg${Random().nextDouble()}.png';

  if (await File(fileName).exists()) await File(fileName).delete();
  return File(fileName).writeAsBytes(bytes, flush: true);
}

List<List<double>> getSepia([amount = 0]) => [
      [amount * 0.393 + (1 - amount), amount * 0.769, amount * 0.189, 0, 0], //1
      [amount * 0.349, amount * 0.686 + (1 - amount), amount * 0.168, 0, 0], //2
      [amount * 0.272, amount * 0.534, amount * 0.131 + (1 - amount), 0, 0], //3
      [0, 0, 0, 1, 0],
      [0, 0, 0, 0, 0],
    ];

const double _rwgt = 0.3086;
const double _gwgt = 0.6094;
const double _bwgt = 0.0820;

List<List<double>> getColorFilterMatrix({double exposure = 1, double saturation = 1}) => [
      [
        exposure * ((1.0 - saturation) * _rwgt + saturation), // RR
        exposure * ((1.0 - saturation) * _gwgt), // RG
        exposure * ((1.0 - saturation) * _bwgt), // RB
        0.0, // RA
        0 // R-OFFSET
      ],
      [
        exposure * ((1.0 - saturation) * _rwgt), // GR
        exposure * ((1.0 - saturation) * _gwgt + saturation), // GG
        exposure * ((1.0 - saturation) * _bwgt), // GB
        0.0, // GA
        0 // R-OFFSET
      ],
      [
        exposure * ((1.0 - saturation) * _rwgt), // BR
        exposure * ((1.0 - saturation) * _gwgt), // BG
        exposure * ((1.0 - saturation) * _bwgt + saturation), // BB
        0.0, // BA
        0
      ],
      [0.0, 0.0, 0.0, 1, 0.0], // A-OFFSET
      [0.0, 0.0, 0.0, 0, 0.0],
    ];

double _getContrastOffset(double value) => (1.0 - (value)) / 2.0 * 255;
List<List<double>> getContrastMatrix([double constrast = 1]) => [
      [constrast, 0, 0, 0, _getContrastOffset(constrast)], //* 2
      [0, constrast, 0, 0, _getContrastOffset(constrast)], //* 3
      [0, 0, constrast, 0, _getContrastOffset(constrast)], //* 4
      [0, 0, 0, 1, 0],
      [0, 0, 0, 0, 0],
    ];

List<List<double>> get grayFilter => const [
      [0.0, 1.0, 0.0, 0.0, 0.0],
      [0.0, 1.0, 0.0, 0.0, 0.0],
      [0.0, 1.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 1.0, 0.0],
      [0.0, 0.0, 0.0, 0.0, 0.0],
    ];
List<List<double>> get normalFilter => [
      [1.0, 0.0, 0.0, 0.0, 0.0],
      [0.0, 1.0, 0.0, 0.0, 0.0],
      [0.0, 0.0, 1.0, 0.0, 0.0],
      [0.0, 0.0, 0.0, 1.0, 0.0],
      [0.0, 0.0, 0.0, 0.0, 0.0]
    ];
