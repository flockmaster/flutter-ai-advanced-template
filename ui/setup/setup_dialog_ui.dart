import 'package:flutter_template/app/app.locator.dart';
import 'package:flutter_template/app/app.router.dart';
import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';

void setupDialogUI() {
  final dialogService = locator<DialogService>();

  final builders = {
    // TODO: Add your custom dialog builders here
    // DialogType.basic: (context, sheetRequest, completer) => BasicDialog(request: sheetRequest, completer: completer),
  };

  dialogService.registerCustomDialogBuilders(builders);
}
