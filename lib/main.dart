import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Clipboard, ClipboardData;
import 'quiz_data.dart';

// ===== IDENTITAS =====

const String studentName = 'I Kadek Dwi Bajaskara';
const String studentId = '2415051068';
const String appTitle = 'Course Explorer v2';

class AppColors { static const primary = Color(0xFF1565C0);
  static const primarySoft = Color(0xFFE3F0FC);
  static const success = Color(0xFF2E7D32);
  static const successSoft = Color(0xFFE6F4EA);
  static const warn = Color(0xFFEF6C00);
  static const muted = Color(0xFF607D8B);
  static const bg = Color(0xFFF5F8FC);
  static const border = Color(0xFFE3E8EF);
  static const errorSoft = Color(0xFFFFEBEE);
}

typedef Json = Map<String, dynamic>;
final Future<Json> studentDataFuture = rootBundle
    .loadString('assets/data/student_data.json')
    .then((s) => jsonDecode(s) as Json);
final favorites = ValueNotifier<Set<String>>(<String>{});
final quizScore = ValueNotifier<int?>(null);
final courseFilter = ValueNotifier<String>('all');

extension CourseX on Json {
  String str(String k, [String d = '-']) => this[k]?.toString() ?? d;
  String get code => str('code', '');
  String get title => str('title', 'Tanpa Judul');
  String get status => str('status', 'planned');
}
void go(BuildContext c, Widget page) =>
    Navigator.push(c, MaterialPageRoute(builder: (_) => page));
void showMsg(BuildContext c, String msg,
    {Color color = AppColors.primary, SnackBarAction? action}) {
  ScaffoldMessenger.of(c)
    ..clearSnackBars()
    ..showSnackBar(SnackBar( content: Text(msg),
      backgroundColor: color, duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating, action: action, ));
}
final _btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));
ButtonStyle filled(Color bg, {double pad = 14}) => ElevatedButton.styleFrom(
      backgroundColor: bg, foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: pad),
      shape: _btnShape, );
ButtonStyle outlined(Color c, {double pad = 14}) => OutlinedButton.styleFrom(
      foregroundColor: c, side: BorderSide(color: c),
      padding: EdgeInsets.symmetric(vertical: pad),
      shape: _btnShape, );
TextStyle ts(double size, {Color color = Colors.black87,
        FontWeight? w, FontStyle? italic, double? height}) =>
    TextStyle( fontSize: size, color: color, fontWeight: w,
        fontStyle: italic, height: height);
Widget gap([double h = 16]) => SizedBox(height: h);
Widget sectionTitle(String t) => Text(t, style: ts(16, w: FontWeight.bold, color: Colors.black));
Widget hint(String t) => Text(t, style: ts(12, color: Colors.black54));
List<Widget> section(String title, Widget child) =>
    [sectionTitle(title), gap(8), child, gap()];
Widget cardHeader(IconData icon, String title, Widget trailing,
        {Color color = AppColors.success, double iconSize = 20}) =>
    Row(children: [ Icon(icon, color: color, size: iconSize),
      const SizedBox(width: 8),
      Text(title, style: ts(15, w: FontWeight.bold, color: color)),
      const Spacer(), trailing, ]);
Widget withCourses(Widget Function(Json data, List<Json> courses) build,
    {bool handleStates = true}) { return FutureBuilder<Json>(
    future: studentDataFuture, builder: (context, snap) {
      if (handleStates) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) { return Center(
              child: Text('Gagal memuat data: ${snap.error}',
                  style: const TextStyle(color: Colors.red)));
        }
      }
      final data = snap.data ?? {};
      return build(data, ((data['courses'] as List?) ?? []).cast<Json>());
    }, );
}
int columnsFor(double width) => width < 600 ? 1 : (width < 840 ? 2 : 3);
void _setFavorite(String code, bool value) => favorites.value =
    value ? {...favorites.value, code} : ({...favorites.value}..remove(code));
Future<void> openCourse(BuildContext context, Json course) async {
  final code = course.code;
  final result = await Navigator.push<bool>( context,
    MaterialPageRoute( builder: (_) => CourseDetailPage(
          course: course, isFavorite: favorites.value.contains(code)),
    ), );
  if (result == null || !context.mounted) return;
  _setFavorite(code, result);
  showMsg( context, '${course.str('title', 'Course')} '
    '${result ? 'ditandai sebagai favorite!' : 'dihapus dari favorite.'}',
    color: result ? AppColors.success : AppColors.primary, );
}
Future<void> _confirmRemoveFavorite(BuildContext context, Json course) async {
  final code = course.code;
  if (!favorites.value.contains(code)) return;
  final ok = await showDialog<bool>( context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus Favorite?'),
      content: Text('Hapus "${course.str('title', 'Course')}" dari daftar favorite?'),
      actions: [ TextButton(
            onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        ElevatedButton( onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Hapus'), ), ], ), );
  if (ok != true || !context.mounted) return;
  _setFavorite(code, false);
  showMsg(context, 'Dihapus dari favorite.', color: Colors.red);
}
class AppCard extends StatelessWidget { final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final VoidCallback? onTap, onLongPress;
  const AppCard({ super.key, required this.child,
    this.padding = const EdgeInsets.all(14), this.borderColor,
    this.onTap, this.onLongPress, });
  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(14);
    Widget inner = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) { inner = InkWell(
          borderRadius: r, onTap: onTap, onLongPress: onLongPress, child: inner);
    }
    return Container( decoration: BoxDecoration(
        color: Colors.white, borderRadius: r,
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
        ], ),
      child: Material(type: MaterialType.transparency, child: inner),
    );
  }
}
class DemoScaffold extends StatelessWidget { final Widget body;
  final Widget? bottomNavigationBar;
  const DemoScaffold({super.key, required this.body, this.bottomNavigationBar});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.bg, appBar: AppBar(
          title: const Text(appTitle),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white, ), body: body,
        bottomNavigationBar: bottomNavigationBar, );
}
class ScrollPage extends StatelessWidget {
  final List<Widget> children;
  const ScrollPage(this.children, {super.key});
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
}
class IdentityCard extends StatelessWidget { final String name, nim;
  final String? subtitle;
  const IdentityCard(
      {super.key, this.name = studentName, this.nim = studentId, this.subtitle});
  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(children: [ CircleAvatar( radius: 26,
            backgroundColor: AppColors.primarySoft, child: ClipOval(
              child: Image.asset( 'assets/images/profile.jpg',
                width: 52, height: 52, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const Icon(Icons.person, size: 30, color: AppColors.primary),
              ), ), ), const SizedBox(width: 14), Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, overflow: TextOverflow.ellipsis,
                  style: ts(15, w: FontWeight.bold, color: Colors.black)),
              Text('NIM: $nim', style: ts(12, color: Colors.black54)),
              if (subtitle != null)
                Text(subtitle!, overflow: TextOverflow.ellipsis,
                    style: ts(11, color: Colors.black45)), ]), ),
        ]), );
}
class StatusHelper { static const _map = {
    'done': (AppColors.success, Icons.check_circle, 'Selesai', 1.0),
    'active': (AppColors.warn, Icons.play_circle, 'Berjalan', 0.5),
  };
  static (Color, IconData, String, double) _of(String s) =>
      _map[s] ?? (AppColors.muted, Icons.schedule, 'Belum', 0.0);
  static Color color(String s) => _of(s).$1;
  static IconData icon(String s) => _of(s).$2;
  static String label(String s) => _of(s).$3;
  static double progressOf(String s) => _of(s).$4;
  static Widget badge(String s) { final c = color(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration( color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20), ),
      child: Text(label(s), style: ts(11, w: FontWeight.bold, color: c)),
    );
  }
}
class InfoRow extends StatelessWidget { final IconData icon;
  final String label, value;
  const InfoRow(this.icon, this.label, this.value, {super.key});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(label, style: ts(13, color: Colors.black54)),
        const Spacer(), Flexible( child: Text(value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: ts(13, w: FontWeight.w600)), ), ]);
}
class InfoCard extends StatelessWidget { final List<InfoRow> rows;
  final EdgeInsets padding;
  const InfoCard(this.rows, {super.key, this.padding = const EdgeInsets.all(14)});
  @override
  Widget build(BuildContext context) => AppCard( padding: padding,
        child: Column(children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 20), rows[i], ], ]), );
}
// ===== MINI QUIZ =====
class MiniQuizCard extends StatefulWidget {
  const MiniQuizCard({super.key});
  @override
  State<MiniQuizCard> createState() => _MiniQuizCardState();
}
class _MiniQuizCardState extends State<MiniQuizCard> {
  int _index = 0, _score = 0;
  String? _selected;
  bool _finished = false;
  void _pilih(String opsi) { if (_selected != null) return;
    setState(() { _selected = opsi;
      if (opsi == quizQuestions[_index]['answer']) _score++;
    });
  }
  void _next() => setState(() {
        if (_index < quizQuestions.length - 1) { _index++;
          _selected = null;
        } else { _finished = true;
          quizScore.value = _score;
        }
      });
  void _reset() => setState(() { _index = _score = 0;
        _selected = null;
        _finished = false;
      });
  @override
  Widget build(BuildContext context) {
    final total = quizQuestions.length;
    final border = AppColors.primary.withValues(alpha: 0.3);
    if (total == 0) { return AppCard(
          borderColor: border, child: hint('Belum ada soal pada quiz_data.dart.'));
    }
    return AppCard( padding: const EdgeInsets.all(16),
      borderColor: border,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader( Icons.quiz_outlined, 'Mini Quiz',
          Text(_finished ? 'Selesai' : 'Soal ${_index + 1}/$total',
              style: ts(12, color: Colors.black54)), ), gap(12),
        _finished ? _buildHasil(total) : _buildSoal(), ]), );
  }
  Widget _buildOption(String opsi, String answer) {
    final show = _selected != null;
    final correct = show && opsi == answer;
    final wrong = show && opsi == _selected && !correct;
    final red = Colors.red.shade400;
    final borderColor = correct ? AppColors.success : (wrong ? red : AppColors.border);
    final bg = correct
        ? AppColors.successSoft
        : (wrong ? AppColors.errorSoft : Colors.white);
    final icon = correct
        ? Icons.check_circle
        : (wrong ? Icons.cancel : Icons.radio_button_unchecked);
    final iconColor = correct ? AppColors.success : (wrong ? red : AppColors.muted);
    return Padding( padding: const EdgeInsets.only(bottom: 8),
      child: InkWell( onTap: () => _pilih(opsi),
        borderRadius: BorderRadius.circular(10), child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration( color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor), ),
          child: Row(children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(child: Text(opsi, style: const TextStyle(fontSize: 13))),
          ]), ), ), );
  }
  Widget _buildSoal() { final item = quizQuestions[_index];
    final options = (item['options'] as List).cast<String>();
    final answer = item['answer'] as String;
    final isLast = _index == quizQuestions.length - 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(item['q'] as String, style: ts(13, w: FontWeight.w600)),
      gap(10),
      for (final opsi in options) _buildOption(opsi, answer),
      if (_selected != null)
        Align( alignment: Alignment.centerRight,
          child: TextButton.icon( onPressed: _next,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(isLast ? 'Lihat Skor' : 'Soal Berikutnya'),
          ), ), ]);
  }
  Widget _buildHasil(int total) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Skor kamu: $_score / $total',
              style: ts(15, w: FontWeight.bold, color: AppColors.success)),
          gap(4),
          Text('Nilai: ${(_score / total * 100).round()}', style: ts(13, color: Colors.black54)),
          gap(12), ElevatedButton.icon( onPressed: _reset,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Ulangi Quiz'),
            style: filled(AppColors.success), ), ], );
}
class FavoriteSectionCard extends StatelessWidget {
  const FavoriteSectionCard({super.key});
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
        valueListenable: favorites,
        builder: (context, favs, _) => withCourses(handleStates: false, (_, courses) {
          final favCourses = courses.where((c) => favs.contains(c.code)).toList();
          return AppCard(
            borderColor: AppColors.success.withValues(alpha: 0.35),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              cardHeader( Icons.star, 'Course Favorite',
                Text('${favCourses.length}',
                    style: ts(13, w: FontWeight.bold, color: AppColors.success)),
              ), gap(10), if (favCourses.isEmpty)
                hint('Belum ada course favorite. Tap ikon ⭐ di halaman detail course.')
              else
                for (final c in favCourses) _favItem(context, c),
            ]), );
        }), );
  Widget _favItem(BuildContext context, Json c) => Padding(
        padding: const EdgeInsets.only(bottom: 6), child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => go(context, CourseDetailPage(course: c, isFavorite: true)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(children: [
              const Icon(Icons.bookmark, size: 16, color: AppColors.success),
              const SizedBox(width: 8), Expanded(
                child: Text(c.title,
                    overflow: TextOverflow.ellipsis,
                    style: ts(13, w: FontWeight.w500, color: Colors.black)),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
            ]), ), ), );
}
class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});
  @override
  State<MainShellPage> createState() => _MainShellPageState();
}
class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;
  static const _pages = <Widget>[ _HomeTabPage(), CourseGridPage(),
    _ProfileTabPage(), ];
  static const _dest = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.school_outlined, Icons.school, 'Courses'),
    (Icons.person_outline, Icons.person, 'Profile'), ];
  void _select(int i) => setState(() => _index = i);
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, c) {
        final wide = c.maxWidth >= 840;
        return DemoScaffold( bottomNavigationBar: wide
              ? null
              : NavigationBar( selectedIndex: _index,
                  onDestinationSelected: _select,
                  backgroundColor: Colors.white,
                  indicatorColor: AppColors.primarySoft,
                  destinations: [ for (final d in _dest)
                      NavigationDestination( icon: Icon(d.$1),
                        selectedIcon: Icon(d.$2, color: AppColors.primary),
                        label: d.$3, ), ], ), body: Row(children: [
            if (wide) ...[ NavigationRail( selectedIndex: _index,
                onDestinationSelected: _select,
                backgroundColor: Colors.white,
                indicatorColor: AppColors.primarySoft,
                labelType: NavigationRailLabelType.all,
                destinations: [ for (final d in _dest)
                    NavigationRailDestination( icon: Icon(d.$1),
                      selectedIcon: Icon(d.$2, color: AppColors.primary),
                      label: Text(d.$3), ), ], ),
              const VerticalDivider(width: 1, thickness: 1), ],
            Expanded( key: const ValueKey('content'),
              child: IndexedStack(index: _index, children: _pages),
            ), ]), );
      });
}
// ===== TAB: HOME =====
class _HomeTabPage extends StatelessWidget { const _HomeTabPage();
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16), children: [
          const IdentityCard(), gap(), const MiniQuizCard(),
          gap(12), const FavoriteSectionCard(), gap(),
          sectionTitle('Course Terbaru'), gap(8),
          const _RecentCourses(), ], );
}
class _RecentCourses extends StatelessWidget {
  const _RecentCourses();
  @override
  Widget build(BuildContext context) => withCourses(
        (_, courses) => Column(children: [
          for (final c in courses.take(3))
            Padding( padding: const EdgeInsets.only(bottom: 10),
              child: AppCard( padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(StatusHelper.icon(c.status),
                      color: StatusHelper.color(c.status)),
                  title: Text(c.title),
                  subtitle: Text('${c.str('code')} • ${c.str('credits')} SKS'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openCourse(context, c), ), ), ), ]),
      );
}
// ===== TAB: PROFILE =====
class _StatTile extends StatelessWidget { final IconData icon;
  final String label, value;
  final Color color;
  const _StatTile(this.icon, this.label, this.value,
      {this.color = AppColors.primary});
  @override
  Widget build(BuildContext context) => Expanded( child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: ts(18, w: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: ts(12, color: Colors.black54)), ]),
        ), );
}
class _ProfileTabPage extends StatelessWidget {
  const _ProfileTabPage();
  @override
  Widget build(BuildContext context) => ScrollPage([
        const IdentityCard(subtitle: 'Pendidikan Teknik Informatika • Semester 5'),
        gap(), ListenableBuilder(
          listenable: Listenable.merge([favorites, quizScore]),
          builder: (_, __) => Row(children: [
            const _StatTile(Icons.book_outlined, 'Topik', '5'),
            const SizedBox(width: 10),
            _StatTile(Icons.star_outline, 'Favorite', '${favorites.value.length}',
                color: AppColors.success),
            const SizedBox(width: 10),
            _StatTile(Icons.emoji_events_outlined, 'Quiz',
                quizScore.value?.toString() ?? '-',
                color: AppColors.warn), ]), ), gap(), ...section(
          'Informasi Mahasiswa', const InfoCard([
            InfoRow(Icons.person_outline, 'Nama', studentName),
            InfoRow(Icons.badge_outlined, 'NIM', studentId),
            InfoRow(Icons.school_outlined, 'Program Studi',
                'Pendidikan Teknik Informatika'),
            InfoRow(Icons.calendar_today_outlined, 'Semester', '5'),
          ], padding: EdgeInsets.all(16)), ), ...section(
          'About Me', AppCard( child: hint(
              'Mahasiswa Pendidikan Teknik Informatika', ), ), ),
        ...section( 'About Application', AppCard(
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: hint(
              'Course Explorer v2', ), ), ),
        ...section('Daftar Favorite', const FavoriteSectionCard()),
      ]);
}

const _filterOptions = <(String, String, IconData)>[
  ('all', 'Semua', Icons.apps),
  ('done', 'Selesai', Icons.check_circle),
  ('active', 'Berjalan', Icons.play_circle),
  ('planned', 'Belum', Icons.schedule),
  ('favorite', 'Favorite', Icons.star), ];
bool _matchesFilter(String filter, Json c, Set<String> favs) => switch (filter) {
      'done' || 'active' || 'planned' => c.status == filter,
      'favorite' => favs.contains(c.code), _ => true, };
class CourseGridPage extends StatelessWidget {
  final bool standalone;
  const CourseGridPage({super.key, this.standalone = false});
  @override
  Widget build(BuildContext context) {
    final content = withCourses((data, courses) {
      final s = (data['student'] as Json?) ?? {};
      return Column(children: [ Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: IdentityCard( name: s['name'] ?? studentName,
            nim: s['nim'] ?? studentId, subtitle:
                '${s['program'] ?? 'Mahasiswa'} • Semester ${s['semester'] ?? '-'}',
          ), ), const _FilterBar(), Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([favorites, courseFilter]),
            builder: (_, __) { final favs = favorites.value;
              final filtered = courses
                  .where((c) => _matchesFilter(courseFilter.value, c, favs))
                  .toList();
              return filtered.isEmpty ? _emptyState() : _grid(filtered, favs);
            }, ), ), ]);
    });
    return standalone ? DemoScaffold(body: content) : content;
  }
  Widget _emptyState() => Center( child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.filter_alt_off, size: 48, color: AppColors.muted),
            gap(10), hint('Tidak ada course dengan filter ini.'),
          ]), ), );
  Widget _grid(List<Json> items, Set<String> favs) => LayoutBuilder(
        builder: (context, c) => GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsFor(c.maxWidth),
            crossAxisSpacing: 12, mainAxisSpacing: 12,
            mainAxisExtent: 170, ), itemCount: items.length,
          itemBuilder: (_, i) => CourseCard( course: items[i],
            isFavorite: favs.contains(items[i].code),
            onTap: () => openCourse(context, items[i]),
            onLongPress: () => _confirmRemoveFavorite(context, items[i]),
          ), ), );
}
class _FilterBar extends StatelessWidget { const _FilterBar();
  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: courseFilter,
        builder: (_, active, __) => SizedBox( height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _filterOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final (key, label, icon) = _filterOptions[i];
              final selected = active == key;
              return ChoiceChip( selected: selected,
                onSelected: (_) => courseFilter.value = key,
                avatar: Icon(icon,
                    size: 16, color: selected ? Colors.white : AppColors.primary),
                label: Text(label), labelStyle: ts(12,
                    w: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white, side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              );
            }, ), ), );
}
class CourseCard extends StatelessWidget { final Json course;
  final bool isFavorite;
  final VoidCallback? onTap, onLongPress;
  const CourseCard({ super.key, required this.course,
    this.isFavorite = false, this.onTap, this.onLongPress, });
  @override
  Widget build(BuildContext context) { final status = course.status;
    final color = StatusHelper.color(status);
    return AppCard( padding: const EdgeInsets.all(12), onTap: onTap,
      onLongPress: onLongPress, borderColor: isFavorite
          ? AppColors.success.withValues(alpha: 0.6)
          : color.withValues(alpha: 0.25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(StatusHelper.icon(status), color: color, size: 20),
          const SizedBox(width: 6), Expanded(
            child: Text(course.title, maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ts(14, w: FontWeight.bold, color: Colors.black)),
          ),
          if (isFavorite) const Icon(Icons.star, color: AppColors.success, size: 18),
        ]), gap(4),
        Text('${course.str('code')} • ${course.str('credits')} SKS',
            style: ts(11, color: Colors.black54)), gap(4), Expanded(
          child: Text(course.str('description', ''), maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: ts(11, color: Colors.black45, height: 1.3)), ),
        Row(children: [ Expanded(
            child: Text('Dosen: ${course.str('dosen')}',
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: ts(10, color: Colors.black45, italic: FontStyle.italic)),
          ), StatusHelper.badge(status), ]), ]), );
  }
}
class CourseDetailPage extends StatelessWidget { final Json course;
  final bool isFavorite;
  const CourseDetailPage({super.key, required this.course, this.isFavorite = false});
  @override
  Widget build(BuildContext context) { final status = course.status;
    final color = StatusHelper.color(status);
    final credits = course.str('credits');
    final progress = StatusHelper.progressOf(status);
    final code = course.str('code');
    return DemoScaffold( body: ScrollPage([ AppCard(
          padding: const EdgeInsets.all(16),
          borderColor: color.withValues(alpha: 0.4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(StatusHelper.icon(status), color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(child: Text(course.title, style: ts(18, w: FontWeight.bold))),
            ]), gap(10), Row(children: [
              Text('$code • $credits SKS', style: ts(13, color: Colors.black54)),
              const Spacer(), StatusHelper.badge(status), ]),
            gap(14), ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator( value: progress,
                minHeight: 8, backgroundColor: AppColors.border,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
              ), ), gap(6), Row(children: [
              const Icon(Icons.trending_up, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Text('Progress: ${(progress * 100).round()}%',
                  style: ts(12, w: FontWeight.w600, color: AppColors.success)),
            ]), ]), ), gap(), ...section( 'Deskripsi', AppCard(
            child: Text(course.str('description', 'Tidak ada deskripsi.'),
                style: ts(13, height: 1.5)), ), ), ...section(
          'Informasi Course', InfoCard([
            InfoRow(Icons.tag, 'Kode', code),
            InfoRow(Icons.credit_card, 'SKS', '$credits SKS'),
            InfoRow(Icons.person, 'Dosen', course.str('dosen')),
            InfoRow(Icons.info_outline, 'Status', StatusHelper.label(status)),
          ]), ),
        ...section('Identitas Mahasiswa', const IdentityCard()),
        OutlinedButton.icon( onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (!context.mounted) return;
            showMsg(context, 'Kode course "$code" disalin.');
          }, icon: const Icon(Icons.copy, size: 18),
          label: const Text('Salin Kode Course'),
          style: outlined(AppColors.primary), ), gap(10),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, !isFavorite),
          icon: Icon(isFavorite ? Icons.star_border : Icons.star, size: 18),
          label: Text(isFavorite
              ? 'Hapus dari Favorite & Kembali'
              : 'Tandai Favorite & Kembali'),
          style: filled(isFavorite ? AppColors.muted : AppColors.success),
        ), ]), );
  }
}

// ===== APP =====
class MyApp extends StatelessWidget { const MyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false, title: appTitle,
        theme: ThemeData( scaffoldBackgroundColor: AppColors.bg,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.success, ), ),
        home: const MainShellPage(), );
}
void main() => runApp(const MyApp());
