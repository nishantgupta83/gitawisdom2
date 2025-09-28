// lib/main.dart

import 'package:flutter/material.dart';
import 'core/app_initializer.dart';
import 'core/ui/app_widget.dart';
import 'widgets/error_widgets.dart';

/// GitaWisdom - Bhagavad Gita wisdom for modern life
/// Clean, modular main.dart following Flutter best practices
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize critical services only
    await AppInitializer.initializeCriticalServices();
    
    // Run the clean modular app
    runApp(const AppWidget());
    
  } catch (error, stackTrace) {
    debugPrint('❌ Critical initialization failed: $error');
    debugPrint('Stack trace: $stackTrace');
    
    // Show error app if initialization fails
    runApp(ErrorWidgets.initializationError(error));
  }
}