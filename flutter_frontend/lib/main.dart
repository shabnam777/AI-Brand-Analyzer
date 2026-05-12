import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/landing_screen.dart';
import 'theme.dart';
import 'widgets/responsive_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const AEOApp());
}

class AEOApp extends StatelessWidget {
  const AEOApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AEO Diagnostic',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => ResponsiveShell(child: child ?? const SizedBox()),
      home: const LandingScreen(),
    );
  }
}
// test again
// test again
