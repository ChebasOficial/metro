import 'package:flutter/material.dart';

class AppConfig {
  // Nome do aplicativo
  static const String appName = 'Metro SP - Monitoramento de Obras';
  static const String appVersion = '1.0.0';

  // Cores do tema
  static const Color primaryColor = Color(0xFF0066CC); // Azul Metrô SP
  static const Color secondaryColor = Color(0xFF00A859); // Verde
  static const Color accentColor = Color(0xFFFFB600); // Amarelo
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color successColor = Color(0xFF388E3C);
  static const Color warningColor = Color(0xFFF57C00);
  
  // Cores de status
  static const Color statusPending = Color(0xFFFFB600);
  static const Color statusProcessing = Color(0xFF0066CC);
  static const Color statusCompleted = Color(0xFF388E3C);
  static const Color statusFailed = Color(0xFFD32F2F);
  
  // Cores de severidade de alertas
  static const Color severityLow = Color(0xFF4CAF50);
  static const Color severityMedium = Color(0xFFFF9800);
  static const Color severityHigh = Color(0xFFFF5722);
  static const Color severityCritical = Color(0xFFD32F2F);
  
  // Tamanhos de texto
  static const double textSizeSmall = 12.0;
  static const double textSizeNormal = 14.0;
  static const double textSizeMedium = 16.0;
  static const double textSizeLarge = 18.0;
  static const double textSizeXLarge = 24.0;
  
  // Espaçamentos
  static const double paddingSmall = 8.0;
  static const double paddingNormal = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingXLarge = 32.0;
  
  // Border radius
  static const double radiusSmall = 4.0;
  static const double radiusNormal = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  
  // Tema claro
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusNormal),
      ),
      filled: true,
      fillColor: Colors.grey[100],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: paddingLarge,
          vertical: paddingNormal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusNormal),
        ),
      ),
    ),
  );
  
  // Tema escuro
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusNormal),
      ),
      filled: true,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: paddingLarge,
          vertical: paddingNormal,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusNormal),
        ),
      ),
    ),
  );
  
  // Obter cor de status
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'processing':
        return statusProcessing;
      case 'completed':
        return statusCompleted;
      case 'failed':
        return statusFailed;
      default:
        return Colors.grey;
    }
  }
  
  // Obter cor de severidade
  static Color getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'baixa':
        return severityLow;
      case 'media':
        return severityMedium;
      case 'alta':
        return severityHigh;
      case 'critica':
        return severityCritical;
      default:
        return Colors.grey;
    }
  }
  
  // Obter ícone de status
  static IconData getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule;
      case 'processing':
        return Icons.sync;
      case 'completed':
        return Icons.check_circle;
      case 'failed':
        return Icons.error;
      default:
        return Icons.help;
    }
  }
}

