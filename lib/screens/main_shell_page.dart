import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../widgets/demo_scaffold.dart';
import 'home_tab_page.dart';
import 'course_grid_page.dart';
import 'favorites_page.dart';
import 'profile_tab_page.dart';

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  static const _pages = <Widget>[
    HomeTabPage(),
    CourseGridPage(),
    FavoritesPage(),
    ProfileTabPage(),
  ];

  static const _dest = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.school_outlined, Icons.school, 'Courses'),
    (Icons.star_border, Icons.star, 'Favorites'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 840;
        return DemoScaffold(
          bottomNavigationBar: wide
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: _select,
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.primarySoft,
                  destinations: [
                    for (final d in _dest)
                      NavigationDestination(
                        icon: Icon(d.$1),
                        selectedIcon: Icon(d.$2, color: AppColors.primary),
                        label: d.$3,
                      ),
                  ],
                ),
          body: Row(children: [
            if (wide) ...[
              NavigationRail(
                selectedIndex: _index,
                onDestinationSelected: _select,
                backgroundColor: Colors.white,
                indicatorColor: AppColors.primarySoft,
                labelType: NavigationRailLabelType.all,
                destinations: [
                  for (final d in _dest)
                    NavigationRailDestination(
                      icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2, color: AppColors.primary),
                      label: Text(d.$3),
                    ),
                ],
              ),
              const VerticalDivider(width: 1, thickness: 1),
            ],
            Expanded(
              key: const ValueKey('content'),
              child: IndexedStack(index: _index, children: _pages),
            ),
          ]),
        );
      });
}