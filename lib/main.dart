import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/splash_screen.dart';
import 'database/db_helper.dart';
import 'services/notification_service.dart';
import 'services/theme_service.dart';
import 'utils/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper().initDatabase();
  await NotificationService().init();
  await ThemeService().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService().themeMode,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Product Hub',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: AppColors.primary,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              primary: AppColors.primary,
              secondary: AppColors.secondary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.bgLight,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.white,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
              iconTheme: const IconThemeData(color: AppColors.dark),
            ),
            fontFamily: GoogleFonts.poppins().fontFamily,
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primaryDark,
              primary: AppColors.primaryDark,
              secondary: AppColors.secondary,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: AppColors.bgDark,
            appBarTheme: AppBarTheme(
              backgroundColor: AppColors.dark,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
              iconTheme: const IconThemeData(color: AppColors.white),
            ),
            fontFamily: GoogleFonts.poppins().fontFamily,
            useMaterial3: true,
          ),
          themeMode: mode,
          home: const SplashScreen(),
        );
      },
    );
  }
}