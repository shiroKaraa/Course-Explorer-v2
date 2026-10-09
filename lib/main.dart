import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_colors.dart';
import 'core/app_strings.dart';
import 'core/legacy_globals.dart';
import 'providers/course_provider.dart';
import 'screens/main_shell_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<CourseProvider>(
        create: (_) => CourseProvider(courseRepository),
        child: const MaterialAppShell(),
      );
}

class MaterialAppShell extends StatelessWidget {
  const MaterialAppShell({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: appTitle,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.success,
          ),
        ),
        home: const MainShellPage(),
      );
}