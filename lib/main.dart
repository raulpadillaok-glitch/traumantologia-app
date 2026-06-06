import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'services/db_service.dart';

import 'services/theme_service.dart'; // NEW

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Base de Datos Local
  await DBService.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeService,
      builder: (context, child) {
        return MaterialApp(
          title: 'Ankle Rehab',
          debugShowCheckedModeBanner: false,
          themeMode: themeService.themeMode,
          theme: themeService.lightTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(themeService.lightTheme.textTheme),
          ),
          darkTheme: themeService.darkTheme.copyWith(
            textTheme: GoogleFonts.poppinsTextTheme(themeService.darkTheme.textTheme),
          ),
          builder: (context, widget) {
            return Container(
              decoration: BoxDecoration(gradient: themeService.currentGradient),
              child: widget,
            );
          },
          home: const SplashScreen(),
        );
      },
    );
  }
}

