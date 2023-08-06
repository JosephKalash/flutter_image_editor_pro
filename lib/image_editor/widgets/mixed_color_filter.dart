import 'package:flutter/material.dart';

import '../tools/utils.dart';

class MixedColorFilter extends StatelessWidget {
  const MixedColorFilter({
    Key? key,
    required this.filter,
    this.child,
  }) : super(key: key);

  final ImageFilterParams filter;
  final Widget? child;
  @override
  Widget build(BuildContext context) {

    return ColorFiltered(
      colorFilter: ColorFilter.matrix(filter.getFilteredMatrix()),
      child: child,
    );
  }
}
