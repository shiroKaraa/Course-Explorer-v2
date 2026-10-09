import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';

class DemoScaffold extends StatelessWidget {
  final Widget body;
  final Widget? bottomNavigationBar;

  const DemoScaffold({super.key, required this.body, this.bottomNavigationBar});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: const Text(appTitle),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      );
}