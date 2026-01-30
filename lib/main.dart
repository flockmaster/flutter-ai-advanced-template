import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app/app.locator.dart';
import 'ui/setup/setup_dialog_ui.dart';
import 'ui/setup/setup_bottom_sheet_ui.dart';

// 应用主组件
import 'app/template_app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Stacked Locator
  await setupLocator();

  // Initialize UI Builders
  setupDialogUI();
  setupBottomSheetUI();

  runApp(const TemplateApp());
}