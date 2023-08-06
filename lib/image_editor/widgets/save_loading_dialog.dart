import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';

void showSaveLoadingDialog(context, Future Function() onSave) {
  showDialog<void>(
    context: context,
    builder: (BuildContext ctx) => WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: FutureBuilder(
          future: onSave(),
          builder: (_, snap) {
            if (snap.connectionState == ConnectionState.done) Navigator.pop(context);
            return SizedBox(
              height: 90,
              width: 90,
              child: const CircularProgressIndicator.adaptive().center().decorated(color: Colors.white).clipRRect(all: 12),
            );
          },
        ),
      ).center(),
    ),
  );
}
