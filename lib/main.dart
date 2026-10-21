import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/app_colors.dart';
import 'core/app_strings.dart';
import 'core/app_config.dart';
import 'providers/course_provider.dart';
import 'repositories/course_repository.dart';
import 'screens/main_shell_page.dart';
import 'services/course_data_source.dart';
import 'services/course_supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabaseAnonKey,
  );

  final CourseDataSource dataSource = CourseSupabaseService();

  final CourseRepository repository = CourseRepository(dataSource);

  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final CourseRepository repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) =>
      ChangeNotifierProvider<CourseProvider>(
        create: (_) => CourseProvider(repository),
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