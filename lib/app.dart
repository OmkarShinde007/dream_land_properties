import 'package:flutter/material.dart';

import 'data/repositories/static_company_repository.dart';
import 'presentation/home_page.dart';

class DreamLandPropertiesApp extends StatelessWidget {
  const DreamLandPropertiesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFB78628),
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dream Land Properties',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
        scaffoldBackgroundColor: const Color(0xFFF5EFE4),
        textTheme: ThemeData.light().textTheme.apply(
              bodyColor: const Color(0xFF1F2721),
              displayColor: const Color(0xFF1F2721),
              fontFamily: 'Georgia',
            ),
        cardTheme: CardThemeData(
          color: Colors.white.withOpacity(0.92),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      home: HomePage(
        repository: const StaticCompanyRepository(),
      ),
    );
  }
}
