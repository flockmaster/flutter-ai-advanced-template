import 'package:flutter_template/app/app.locator.dart';
import 'package:flutter_template/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

void setupBottomSheetUI() {
  final bottomSheetService = locator<BottomSheetService>();

  final builders = {
    // TODO: Add your custom bottom sheet builders here
    // BottomSheetType.basic: (context, sheetRequest, completer) => BasicSheet(request: sheetRequest, completer: completer),
  };

  bottomSheetService.setCustomSheetBuilders(builders);
}
