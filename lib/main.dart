import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_colors.dart';
import 'core/app_strings.dart';
import 'core/app_config.dart';
import 'core/legacy_globals.dart';
import 'providers/course_provider.dart';
import 'screens/main_shell_page.dart';
import 'services/course_api_service.dart'; 

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _testFetch();
  }

  Future<void> _testFetch() async {
    final apiService = CourseApiService(AppConfig.apiBaseUrl);
    try {
      debugPrint('--- Memulai HTTP GET Tahap 2 ---');
      final courses = await apiService.fetchCourses();
      debugPrint('Berhasil mengambil data!');
      debugPrint('Jumlah item: ${courses.length}');
      debugPrint('Contoh item pertama: ${courses.first}');
      debugPrint('---------------------------------');
    } catch (e) {
      debugPrint('Error fetching data: $e');
    }
  }

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