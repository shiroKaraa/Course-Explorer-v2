import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle, Clipboard, ClipboardData;
import 'package:provider/provider.dart';
import 'course_provider.dart';
import 'models/course.dart';
import 'repositories/course_repository.dart';
import 'services/course_service.dart';
import 'quiz_data.dart';

// ===== IDENTITAS =====

const String studentName = 'I Kadek Dwi Bajaskara';
const String studentId = '2415051068';
const String appTitle = 'Course Explorer v2';

class AppColors {
  static const primary = Color(0xFF1565C0);
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

// ===== SHARED STATE =====
final favorites = ValueNotifier<Set<String>>(<String>{});
final quizScore = ValueNotifier<int?>(null);
final courseFilter = ValueNotifier<String>('all');
final favoriteCounter = ValueNotifier<int>(0);
final courseService = CourseService();
final courseRepository = CourseRepositoryImpl(courseService);


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
    ..showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      action: action,
    ));
}

final _btnShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(10));

ButtonStyle filled(Color bg, {double pad = 14}) => ElevatedButton.styleFrom(
      backgroundColor: bg,
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(vertical: pad),
      shape: _btnShape,
    );

ButtonStyle outlined(Color c, {double pad = 14}) => OutlinedButton.styleFrom(
      foregroundColor: c,
      side: BorderSide(color: c),
      padding: EdgeInsets.symmetric(vertical: pad),
      shape: _btnShape,
    );

TextStyle ts(double size,
        {Color color = Colors.black87,
        FontWeight? w,
        FontStyle? italic,
        double? height}) =>
    TextStyle(
      fontSize: size,
      color: color,
      fontWeight: w,
      fontStyle: italic,
      height: height,
    );

Widget gap([double h = 16]) => SizedBox(height: h);

Widget sectionTitle(String t) =>
    Text(t, style: ts(16, w: FontWeight.bold, color: Colors.black));

Widget hint(String t) => Text(t, style: ts(12, color: Colors.black54));

List<Widget> section(String title, Widget child) =>
    [sectionTitle(title), gap(8), child, gap()];

Widget cardHeader(IconData icon, String title, Widget trailing,
        {Color color = AppColors.success, double iconSize = 20}) =>
    Row(children: [
      Icon(icon, color: color, size: iconSize),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          title,
          style: ts(15, w: FontWeight.bold, color: color),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      const Spacer(),
      trailing,
    ]);

Widget withCourses(Widget Function(Json data, List<Json> courses) build,
    {bool handleStates = true}) {
  return FutureBuilder<Json>(
    future: studentDataFuture,
    builder: (context, snap) {
      if (handleStates) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || snap.data == null) {
          return Center(
            child: Text('Gagal memuat data: ${snap.error}',
                style: const TextStyle(color: Colors.red)),
          );
        }
      }
      final data = snap.data ?? {};
      return build(data, ((data['courses'] as List?) ?? []).cast<Json>());
    },
  );
}

int columnsFor(double width) => width < 600 ? 1 : (width < 840 ? 2 : 3);

void _setFavorite(String code, bool value) => favorites.value = value
    ? {...favorites.value, code}
    : ({...favorites.value}..remove(code));

Future<void> openCourse(BuildContext context, Json course) async {
  final code = course.code;
  final result = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) => CourseDetailPage(
        course: course,
        isFavorite: favorites.value.contains(code),
      ),
    ),
  );
  if (result == null || !context.mounted) return;
  _setFavorite(code, result);
  showMsg(
    context,
    '${course.str('title', 'Course')} '
    '${result ? 'ditandai sebagai favorite!' : 'dihapus dari favorite.'}',
    color: result ? AppColors.success : AppColors.primary,
  );
}

Future<void> _confirmRemoveFavorite(BuildContext context, Json course) async {
  final code = course.code;
  if (!favorites.value.contains(code)) return;
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Hapus Favorite?'),
      content:
          Text('Hapus "${course.str('title', 'Course')}" dari daftar favorite?'),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red, foregroundColor: Colors.white),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  _setFavorite(code, false);
  showMsg(context, 'Dihapus dari favorite.', color: Colors.red);
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final Color? borderColor;
  final VoidCallback? onTap, onLongPress;

  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(14);
    Widget inner = Padding(padding: padding, child: child);
    if (onTap != null || onLongPress != null) {
      inner = InkWell(
        borderRadius: r,
        onTap: onTap,
        onLongPress: onLongPress,
        child: inner,
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: r,
        border: Border.all(color: borderColor ?? AppColors.border),
        boxShadow: const [
          BoxShadow(
              color: Color(0x0F000000), blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Material(type: MaterialType.transparency, child: inner),
    );
  }
}

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

class IdentityCard extends StatelessWidget {
  final String name, nim;
  final String? subtitle;

  const IdentityCard(
      {super.key, this.name = studentName, this.nim = studentId, this.subtitle});

  @override
  Widget build(BuildContext context) => AppCard(
        child: Row(children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primarySoft,
            child: ClipOval(
              child: Image.asset(
                'assets/images/profile.jpg',
                width: 52,
                height: 52,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person,
                    size: 30, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: ts(15, w: FontWeight.bold, color: Colors.black)),
                  Text('NIM: $nim', style: ts(12, color: Colors.black54)),
                  if (subtitle != null)
                    Text(subtitle!,
                        overflow: TextOverflow.ellipsis,
                        style: ts(11, color: Colors.black45)),
                ]),
          ),
        ]),
      );
}

class StatusHelper {
  static const _map = {
    'done': (AppColors.success, Icons.check_circle, 'Selesai', 1.0),
    'active': (AppColors.warn, Icons.play_circle, 'Berjalan', 0.5),
  };

  static (Color, IconData, String, double) _of(String s) =>
      _map[s] ?? (AppColors.muted, Icons.schedule, 'Belum', 0.0);

  static Color color(String s) => _of(s).$1;
  static IconData icon(String s) => _of(s).$2;
  static String label(String s) => _of(s).$3;
  static double progressOf(String s) => _of(s).$4;

  static Widget badge(String s) {
    final c = color(s);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label(s), style: ts(11, w: FontWeight.bold, color: c)),
    );
  }
}

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label, value;

  const InfoRow(this.icon, this.label, this.value, {super.key});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(label, style: ts(13, color: Colors.black54)),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: ts(13, w: FontWeight.w600)),
        ),
      ]);
}

class InfoCard extends StatelessWidget {
  final List<InfoRow> rows;
  final EdgeInsets padding;

  const InfoCard(this.rows, {super.key, this.padding = const EdgeInsets.all(14)});

  @override
  Widget build(BuildContext context) => AppCard(
        padding: padding,
        child: Column(children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            rows[i],
          ],
        ]),
      );
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

  void _pilih(String opsi) {
    if (_selected != null) return;
    setState(() {
      _selected = opsi;
      if (opsi == quizQuestions[_index]['answer']) _score++;
    });
  }

  void _next() => setState(() {
        if (_index < quizQuestions.length - 1) {
          _index++;
          _selected = null;
        } else {
          _finished = true;
          quizScore.value = _score;
        }
      });

  void _reset() => setState(() {
        _index = _score = 0;
        _selected = null;
        _finished = false;
      });

  @override
  Widget build(BuildContext context) {
    final total = quizQuestions.length;
    final border = AppColors.primary.withValues(alpha: 0.3);
    if (total == 0) {
      return AppCard(
          borderColor: border,
          child: hint('Belum ada soal pada quiz_data.dart.'));
    }
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: border,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.quiz_outlined,
          'Mini Quiz',
          Text(_finished ? 'Selesai' : 'Soal ${_index + 1}/$total',
              style: ts(12, color: Colors.black54)),
        ),
        gap(12),
        _finished ? _buildHasil(total) : _buildSoal(),
      ]),
    );
  }

  Widget _buildOption(String opsi, String answer) {
    final show = _selected != null;
    final correct = show && opsi == answer;
    final wrong = show && opsi == _selected && !correct;
    final red = Colors.red.shade400;
    final borderColor =
        correct ? AppColors.success : (wrong ? red : AppColors.border);
    final bg = correct
        ? AppColors.successSoft
        : (wrong ? AppColors.errorSoft : Colors.white);
    final icon = correct
        ? Icons.check_circle
        : (wrong ? Icons.cancel : Icons.radio_button_unchecked);
    final iconColor = correct ? AppColors.success : (wrong ? red : AppColors.muted);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _pilih(opsi),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: Row(children: [
            Icon(icon, size: 18, color: iconColor),
            const SizedBox(width: 10),
            Expanded(child: Text(opsi, style: const TextStyle(fontSize: 13))),
          ]),
        ),
      ),
    );
  }

  Widget _buildSoal() {
    final item = quizQuestions[_index];
    final options = (item['options'] as List).cast<String>();
    final answer = item['answer'] as String;
    final isLast = _index == quizQuestions.length - 1;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(item['q'] as String, style: ts(13, w: FontWeight.w600)),
      gap(10),
      for (final opsi in options) _buildOption(opsi, answer),
      if (_selected != null)
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _next,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(isLast ? 'Lihat Skor' : 'Soal Berikutnya'),
          ),
        ),
    ]);
  }

  Widget _buildHasil(int total) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Skor kamu: $_score / $total',
              style: ts(15, w: FontWeight.bold, color: AppColors.success)),
          gap(4),
          Text('Nilai: ${(_score / total * 100).round()}',
              style: ts(13, color: Colors.black54)),
          gap(12),
          ElevatedButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Ulangi Quiz'),
            style: filled(AppColors.success),
          ),
        ],
      );
}

// ===== KARTU KLASIFIKASI STATE =====
class StateClassificationCard extends StatelessWidget {
  const StateClassificationCard({super.key});

  static const _items = <(String, String, String, String)>[
    (
      'Tab aktif MainShellPage',
      'Local',
      'Hanya dipakai MainShellPage untuk memilih IndexedStack.',
      'setState()',
    ),
    (
      'Progress MiniQuiz',
      'Local',
      'Hanya relevan selama user mengerjakan quiz.',
      'setState()',
    ),
    (
      'Show/hide deskripsi CourseCard',
      'Local',
      'Setiap kartu punya preferensi buka/tutup sendiri.',
      'setState()',
    ),
    (
      'Show full description di CourseDetailPage',
      'Local',
      'Hanya mengatur tampilan satu halaman detail.',
      'setState()',
    ),
    (
      'Favorites (Set<String>) — ValueNotifier',
      'Shared',
      'Dipakai di Home, Courses, Profile, dan Detail.',
      'ValueNotifier',
    ),
    (
      'Quiz score & course filter',
      'Shared',
      'Quiz score tampil di Profile; filter dipakai CourseGridPage.',
      'ValueNotifier',
    ),
    (
      '_favoriteCount di HomeDashboardPageV3',
      'Local (SSOT)',
      'Contoh Single Source of Truth dengan setState + callback.',
      'setState()',
    ),
    (
      'favoriteCounter (ValueNotifier<int>)',
      'Shared',
      'Pola listener sederhana (Tahap 4).',
      'ValueNotifier',
    ),
    (
      'CourseProvider.favorites',
      'Shared',
      'ChangeNotifier yang menyimpan Set<String> + method toggleFavorite().',
      'ChangeNotifier',
    ),
    (
      'Provider terpasang di widget tree',
      'Infrastruktur',
      'ChangeNotifierProvider membungkus MaterialApp.',
      'provider',
    ),
    (
      'Akses provider via context',
      'Infrastruktur',
      'watch untuk listen + rebuild, read untuk aksi, Consumer untuk rebuild terbatas.',
      'provider',
    ),
    (
      'Model Course',
      'Representasi data',
      'Mengubah Map<String, dynamic> menjadi object bertipe.',
      'Course.fromJson',
    ),
    (
      'CourseService',
      'Data access',
      'Membaca asset JSON dan mengembalikan List<Course>.',
      'rootBundle + Course.fromJson',
    ),
    (
      'CourseRepository',
      'Abstraksi data',
      'Kontrak + implementasi yang membungkus CourseService.',
      'abstract + impl',
    ),
    (
      'courses, isLoading, error di CourseProvider',
      'Async state',
      'Satu state holder untuk loading, error, dan data. UI menampilkan ketiganya berdasarkan state.',
      'ChangeNotifier + notifyListeners',
    ),
  ];

  Color _colorFor(String kind) {
    if (kind.startsWith('Shared')) return AppColors.success;
    if (kind.startsWith('Infrastruktur')) return AppColors.primary;
    if (kind.startsWith('Representasi')) return AppColors.warn;
    if (kind.startsWith('Data access')) return AppColors.muted;
    if (kind.startsWith('Abstraksi')) return AppColors.success;
    if (kind.startsWith('Async')) return AppColors.primary;
    if (kind.contains('SSOT')) return AppColors.warn;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.3),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.account_tree_outlined,
            'Klasifikasi State Aplikasi',
            Text('${_items.length} state',
                style: ts(12, color: Colors.black54)),
          ),
          gap(10),
          hint(
              'Local = cukup setState di widget sendiri. Shared = dipakai banyak widget/screen.'),
          gap(10),
          for (var i = 0; i < _items.length; i++) ...[
            _row(_items[i]),
            if (i < _items.length - 1) const Divider(height: 16),
          ],
        ]),
      );

  Widget _row((String, String, String, String) item) {
    final (name, kind, reason, tool) = item;
    final c = _colorFor(kind);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: c.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(kind, style: ts(10, w: FontWeight.bold, color: c)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(name,
              style: ts(13, w: FontWeight.w600, color: Colors.black)),
        ),
      ]),
      const SizedBox(height: 4),
      Text(reason, style: ts(11, color: Colors.black54, height: 1.4)),
      const SizedBox(height: 4),
      Text('Dikelola dengan: $tool',
          style: ts(11, italic: FontStyle.italic, color: AppColors.muted)),
    ]);
  }
}

// ===== KARTU STATUS PROVIDER =====
class ProviderStatusCard extends StatelessWidget {
  const ProviderStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CourseProvider>();
    return AppCard(
      borderColor: AppColors.primary.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        cardHeader(
          Icons.hub_outlined,
          'Provider Terpasang',
          Text('Tahap 6', style: ts(12, color: Colors.black54)),
          color: AppColors.primary,
        ),
        gap(10),
        _row(Icons.check_circle, 'Status', 'ChangeNotifierProvider aktif',
            color: AppColors.success),
        _row(Icons.inventory_2_outlined, 'Package', 'provider: ^6.1.2'),
        _row(Icons.account_tree_outlined, 'Tipe',
            'ChangeNotifierProvider<CourseProvider>'),
        _row(Icons.place_outlined, 'Lokasi',
            'Membungkus MaterialApp di MyApp'),
        _row(Icons.star_outline, 'Favorite via provider',
            '${provider.favoriteCount}'),
        gap(10),
        hint(
            'Kartu ini memakai context.read<CourseProvider>() untuk mengambil instance. read() tidak memicu rebuild, cocok untuk data status yang tidak perlu di-update terus-menerus.'),
      ]),
    );
  }

  Widget _row(IconData icon, String label, String value,
          {Color color = Colors.black87}) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(label, style: ts(12, color: Colors.black54)),
          const Spacer(),
          Flexible(
            child: Text(value,
                textAlign: TextAlign.right,
                overflow: TextOverflow.ellipsis,
                style: ts(12, w: FontWeight.w600, color: color)),
          ),
        ]),
      );
}

class CourseModelDemoCard extends StatelessWidget {
  const CourseModelDemoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.warn.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.data_object,
          'Model Course',
          Text('Tahap 8', style: ts(12, color: Colors.black54)),
          color: AppColors.warn,
        ),
        gap(10),
        hint(
            'Data JSON diubah menjadi object Course lewat Course.fromJson(). Data diambil melalui CourseService.'),
        gap(12),
        FutureBuilder<List<Course>>(
          future: courseService.loadCourses(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError || snap.data == null || snap.data!.isEmpty) {
              return Text('Gagal memuat data: ${snap.error}',
                  style: const TextStyle(color: Colors.red));
            }
            final course = snap.data!.first;
            return _coursePreview(course);
          },
        ),
      ]),
    );
  }

  Widget _coursePreview(Course course) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.school_outlined,
                size: 20, color: AppColors.primary),
            const SizedBox(width: 6),
            Expanded(
              child: Text(course.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: ts(14, w: FontWeight.bold, color: Colors.black)),
            ),
            StatusHelper.badge(course.status),
          ]),
          gap(6),
          Text(course.summary, style: ts(12, color: Colors.black54)),
          gap(8),
          _row('Code (String)', course.code),
          _row('Title (String)', course.title),
          _row('Credits (int)', '${course.credits}'),
          _row('Status (String)', course.status),
          _row('Dosen (String)', course.dosen),
          gap(6),
          Row(children: [
            const Icon(Icons.check_circle_outline,
                size: 14, color: AppColors.success),
            const SizedBox(width: 6),
            Text('isDone: ${course.isDone}',
                style: ts(11, color: Colors.black87)),
            const SizedBox(width: 12),
            Text('progress: ${(course.progress * 100).round()}%',
                style: ts(11, color: Colors.black87)),
          ]),
        ]),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(children: [
          Expanded(
            flex: 4,
            child: Text(label, style: ts(11, color: Colors.black54)),
          ),
          Expanded(
            flex: 6,
            child: Text(value,
                overflow: TextOverflow.ellipsis,
                style: ts(11, w: FontWeight.w600, color: Colors.black87)),
          ),
        ]),
      );
}

class CourseServiceDemoCard extends StatefulWidget {
  const CourseServiceDemoCard({super.key});

  @override
  State<CourseServiceDemoCard> createState() => _CourseServiceDemoCardState();
}

class _CourseServiceDemoCardState extends State<CourseServiceDemoCard> {
  late Future<List<Course>> _future;

  @override
  void initState() {
    super.initState();
    _future = courseService.loadCourses();
  }

  void _reload() {
    setState(() {
      _future = courseService.loadCourses();
    });
    showMsg(context, 'Memuat ulang data dari service...',
        color: AppColors.primary);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.muted.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.cloud_download_outlined,
          'CourseService',
          Text('Tahap 9', style: ts(12, color: Colors.black54)),
          color: AppColors.muted,
        ),
        gap(10),
        hint(
            'UI memanggil courseService.loadCourses() dan menerima List<Course>. Path asset JSON dan parsing tersembunyi di dalam service.'),
        gap(12),
        FutureBuilder<List<Course>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return _loadingTile();
            }
            if (snap.hasError) {
              return _errorTile('${snap.error}');
            }
            final courses = snap.data ?? const <Course>[];
            return _successTile(courses);
          },
        ),
        gap(10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Muat Ulang'),
              style: outlined(AppColors.muted, pad: 10),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _loadingTile() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text('Memuat data dari service...',
              style: ts(12, color: Colors.black87)),
        ]),
      );

  Widget _errorTile(String message) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Error: $message',
                style: ts(12, color: Colors.red.shade700)),
          ),
        ]),
      );

  Widget _successTile(List<Course> courses) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_circle, size: 18, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Sukses: ${courses.length} course diterima',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
            const Spacer(),
            hint('List<Course>'),
          ]),
          gap(10),
          for (final c in courses.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.school_outlined,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${c.code} — ${c.title} '
                      '(${c.credits} SKS)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(11, color: Colors.black87)),
                ),
              ]),
            ),
        ]),
      );
}

class CourseRepositoryDemoCard extends StatefulWidget {
  const CourseRepositoryDemoCard({super.key});

  @override
  State<CourseRepositoryDemoCard> createState() =>
      _CourseRepositoryDemoCardState();
}

class _CourseRepositoryDemoCardState extends State<CourseRepositoryDemoCard> {
  late Future<List<Course>> _future;

  @override
  void initState() {
    super.initState();
    _future = courseRepository.getCourses();
  }

  void _reload() {
    setState(() {
      _future = courseRepository.getCourses();
    });
    showMsg(context, 'Memuat ulang data dari repository...',
        color: AppColors.success);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.success.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.storage_outlined,
          'CourseRepository',
          Text('Tahap 10', style: ts(12, color: Colors.black54)),
        ),
        gap(10),
        hint(
            'UI memanggil courseRepository.getCourses(). Repository membungkus service; UI tidak tahu implementasi konkretnya.'),
        gap(12),
        FutureBuilder<List<Course>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return _loadingTile();
            }
            if (snap.hasError) {
              return _errorTile('${snap.error}');
            }
            final courses = snap.data ?? const <Course>[];
            return _successTile(courses);
          },
        ),
        gap(10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _reload,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Muat Ulang'),
              style: outlined(AppColors.success, pad: 10),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _loadingTile() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text('Memuat data dari repository...',
              style: ts(12, color: Colors.black87)),
        ]),
      );

  Widget _errorTile(String message) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
        ),
        child: Row(children: [
          const Icon(Icons.error_outline, size: 18, color: Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text('Error: $message',
                style: ts(12, color: Colors.red.shade700)),
          ),
        ]),
      );

  Widget _successTile(List<Course> courses) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_circle, size: 18, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Repository sukses: ${courses.length} course',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
            const Spacer(),
            hint('via repository'),
          ]),
          gap(10),
          for (final c in courses.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.storage_outlined,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${c.code} — ${c.title} '
                      '(${c.credits} SKS)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(11, color: Colors.black87)),
                ),
              ]),
            ),
        ]),
      );
}

class AsyncCoursesCard extends StatefulWidget {
  const AsyncCoursesCard({super.key});

  @override
  State<AsyncCoursesCard> createState() => _AsyncCoursesCardState();
}

class _AsyncCoursesCardState extends State<AsyncCoursesCard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<CourseProvider>();
      if (!provider.hasLoaded && !provider.isLoading) {
        provider.loadCourses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.primary.withValues(alpha: 0.6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.sync_problem_outlined,
          'Provider Async State',
          Text('Tahap 11', style: ts(12, color: Colors.black54)),
          color: AppColors.primary,
        ),
        gap(10),
        hint(
            'Provider mengelola isLoading, error, dan courses. UI menampilkan tiga kondisi tanpa FutureBuilder.'),
        gap(12),
        _body(provider),
        gap(10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: provider.isLoading
                  ? null
                  : () {
                      context.read<CourseProvider>().refresh();
                    },
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh (via provider)'),
              style: outlined(AppColors.primary, pad: 10),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _body(CourseProvider provider) {
    if (provider.isLoading) {
      return _loadingTile();
    }
    if (provider.error != null) {
      return _errorTile(provider.error!);
    }
    if (!provider.hasLoaded) {
      return _initialTile();
    }
    return _successTile(provider.courses);
  }

  Widget _initialTile() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.hourglass_empty, size: 18, color: AppColors.muted),
          const SizedBox(width: 10),
          Text('Initial: belum ada data dimuat.',
              style: ts(12, color: Colors.black87)),
        ]),
      );

  Widget _loadingTile() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          const SizedBox(width: 10),
          Text('Loading: memuat data dari provider...',
              style: ts(12, color: Colors.black87)),
        ]),
      );

  Widget _errorTile(String message) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.errorSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.error_outline, size: 18, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Error dari provider',
                  style: ts(12, w: FontWeight.bold, color: Colors.red.shade700)),
            ),
          ]),
          gap(6),
          Text(message, style: ts(11, color: Colors.red.shade700)),
        ]),
      );

  Widget _successTile(List<Course> courses) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.check_circle, size: 18, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Success: ${courses.length} course',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
            const Spacer(),
            hint('via provider'),
          ]),
          gap(10),
          for (final c in courses.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(children: [
                const Icon(Icons.school_outlined,
                    size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                Expanded(
                  child: Text('${c.code} — ${c.title} '
                      '(${c.credits} SKS)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: ts(11, color: Colors.black87)),
                ),
              ]),
            ),
        ]),
      );
}

class AsyncStateIndicatorCard extends StatelessWidget {
  const AsyncStateIndicatorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseProvider>(
      builder: (context, provider, child) {
        final label = provider.asyncStateLabel;
        final color = _colorFor(label);
        final icon = _iconFor(label);
        return AppCard(
          borderColor: color.withValues(alpha: 0.5),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(children: [
                Icon(icon, size: 12, color: color),
                const SizedBox(width: 6),
                Text(label.toUpperCase(),
                    style: ts(10, w: FontWeight.bold, color: color)),
              ]),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _descriptionFor(label),
                style: ts(12, color: Colors.black87),
              ),
            ),
            hint('Tahap 11'),
          ]),
        );
      },
    );
  }

  Color _colorFor(String label) {
    switch (label) {
      case 'loading':
        return AppColors.primary;
      case 'success':
        return AppColors.success;
      case 'error':
        return Colors.red.shade700;
      default:
        return AppColors.muted;
    }
  }

  IconData _iconFor(String label) {
    switch (label) {
      case 'loading':
        return Icons.hourglass_top;
      case 'success':
        return Icons.check_circle;
      case 'error':
        return Icons.error_outline;
      default:
        return Icons.circle_outlined;
    }
  }

  String _descriptionFor(String label) {
    switch (label) {
      case 'loading':
        return 'Provider sedang memuat data dari repository.';
      case 'success':
        return 'Data course berhasil dimuat dan siap ditampilkan.';
      case 'error':
        return 'Terjadi error saat memuat data. Coba Refresh.';
      default:
        return 'Belum ada pemuatan data. Panggil loadCourses().';
    }
  }
}

class AsyncStateComparisonCard extends StatelessWidget {
  const AsyncStateComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.sync_problem_outlined,
            'FutureBuilder vs Provider Async State',
            Text('Tahap 11', style: ts(12, color: Colors.black54)),
            color: AppColors.primary,
          ),
          gap(10),
          _row('Pengelola state', 'FutureBuilder (di widget)',
              'CourseProvider (di luar widget)'),
          _row('Kapan load dipanggil', 'Setiap build bisa trigger',
              'Sekali di initState / refresh()'),
          _row('Loading', 'connectionState.waiting', 'isLoading == true'),
          _row('Error', 'snapshot.hasError', 'error != null'),
          _row('Success', 'snapshot.data', 'courses.isNotEmpty / hasLoaded'),
          _row('Retry', 'Bikin Future baru', 'provider.refresh()'),
          _row('Dipakai lintas screen', 'Sulit (perlu widget sendiri)',
              'Ya (watch provider)'),
          gap(6),
          hint(
              'Kesimpulan: provider memusatkan async state sehingga loading/error/success dikelola sekali, bisa di-retry, dan bisa diakses lintas screen.'),
        ]),
      );

  Widget _row(String label, String before, String after) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('FutureBuilder: $before',
                  style: ts(11, color: AppColors.warn, height: 1.3)),
            ),
            Expanded(
              child: Text('Provider: $after',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}

class CourseRepositoryComparisonCard extends StatelessWidget {
  const CourseRepositoryComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.success.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.storage_outlined,
            'CourseService vs CourseRepository',
            Text('Tahap 10', style: ts(12, color: Colors.black54)),
          ),
          gap(10),
          _row('Peran', 'Detail teknis data', 'Kontrak sumber data'),
          _row('Tahu asset/JSON?', 'Ya', 'Tidak'),
          _row('Bisa diganti?', 'Hanya isinya', 'Ya, via interface'),
          _row('Bisa di-mock?', 'Sulit', 'Ya (FakeCourseRepository)'),
          _row('Dipakai oleh', 'Repository', 'Provider / UI'),
          _row('Contoh perubahan', 'Ganti path JSON', 'Ganti service apa pun'),
          gap(6),
          hint(
              'Kesimpulan: service tahu cara membaca data; repository menyediakan kontrak agar layer atas tidak bergantung pada implementasi konkret.'),
        ]),
      );

  Widget _row(String label, String serviceSide, String repoSide) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('Service: $serviceSide',
                  style: ts(11, color: AppColors.muted, height: 1.3)),
            ),
            Expanded(
              child: Text('Repo: $repoSide',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}

class CourseModelComparisonCard extends StatelessWidget {
  const CourseModelComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.warn.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.data_object,
            'Map vs Model Course',
            Text('Tahap 8', style: ts(12, color: Colors.black54)),
            color: AppColors.warn,
          ),
          gap(10),
          _row('Tipe data', 'Map<String, dynamic>', 'Course (class)'),
          _row('Akses field', "course['title']", 'course.title'),
          _row('Keamanan tipe', 'Runtime (bisa salah ketik)', 'Compile-time'),
          _row('Parsing', 'Manual di UI', 'Course.fromJson()'),
          _row('Helper/logic', 'Sulit (tersebar)',
              'Di dalam class (isDone, progress)'),
          _row('Refactor aman', 'Rentan typo key',
              'Rename field terbantu IDE'),
          gap(6),
          hint(
              'Kesimpulan: model memindahkan representasi data dari Map longgar ke object bertipe.'),
        ]),
      );

  Widget _row(String label, String before, String after) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('Map: $before',
                  style: ts(11, color: AppColors.warn, height: 1.3)),
            ),
            Expanded(
              child: Text('Model: $after',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}

class CourseServiceComparisonCard extends StatelessWidget {
  const CourseServiceComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.muted.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.swap_horiz,
            'UI Baca JSON vs UI Panggil Service',
            Text('Tahap 9', style: ts(12, color: Colors.black54)),
            color: AppColors.muted,
          ),
          gap(10),
          _row('Tahu path file JSON?', 'Ya, di main.dart',
              'Tidak, hanya di service'),
          _row('Melakukan jsonDecode?', 'Ya, di main.dart',
              'Tidak, di service'),
          _row('Casting ke Map/List?', 'Ya, di main.dart',
              'Tidak, dari service'),
          _row('Return type', 'Future<Json>', 'Future<List<Course>>'),
          _row('Ganti sumber data', 'Ubah di main.dart',
              'Ubah di service saja'),
          _row('Test service', 'Tidak bisa lepas dari widget',
              'Bisa, murni Dart + asset'),
          gap(6),
          hint(
              'Kesimpulan: service memisahkan detail teknis data access dari UI.'),
        ]),
      );

  Widget _row(String label, String before, String after) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('Sebelum: $before',
                  style: ts(11, color: AppColors.warn, height: 1.3)),
            ),
            Expanded(
              child: Text('Sesudah: $after',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}

class HomeDashboardPageV3 extends StatefulWidget {
  const HomeDashboardPageV3({super.key});

  @override
  State<HomeDashboardPageV3> createState() => _HomeDashboardPageV3State();
}

class _HomeDashboardPageV3State extends State<HomeDashboardPageV3> {
  int _favoriteCount = 0;

  void _increment() => setState(() => _favoriteCount++);
  void _decrement() {
    if (_favoriteCount == 0) return;
    setState(() => _favoriteCount--);
  }

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.warn.withValues(alpha: 0.35),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.arrow_upward,
          'Lifting State Up (setState)',
          Text('Tahap 3', style: ts(12, color: Colors.black54)),
          color: AppColors.warn,
        ),
        gap(10),
        hint(
            'Parent memiliki _favoriteCount. Tiga child menerima lewat constructor; satu child mengirim aksi lewat callback.'),
        gap(12),
        Row(children: [
          Expanded(
            child: CourseSummaryTileV3(favoriteCount: _favoriteCount),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: FavoriteTogglePanelV3(
              favoriteCount: _favoriteCount,
              onIncrement: _increment,
              onDecrement: _decrement,
            ),
          ),
        ]),
        gap(10),
        DashboardStatusBarV3(favoriteCount: _favoriteCount),
      ]),
    );
  }
}

class CourseSummaryTileV3 extends StatelessWidget {
  final int favoriteCount;

  const CourseSummaryTileV3({super.key, required this.favoriteCount});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.summarize_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Ringkasan',
                style: ts(12, w: FontWeight.bold, color: AppColors.primary)),
          ]),
          gap(6),
          Text('Favorite saat ini:', style: ts(11, color: Colors.black54)),
          Text('$favoriteCount',
              style: ts(22, w: FontWeight.bold, color: AppColors.primary)),
          gap(4),
          hint('read-only dari parent'),
        ]),
      );
}

class FavoriteTogglePanelV3 extends StatelessWidget {
  final int favoriteCount;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const FavoriteTogglePanelV3({
    super.key,
    required this.favoriteCount,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.tune, size: 18, color: AppColors.success),
            const SizedBox(width: 6),
            Text('Kontrol',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
          ]),
          gap(6),
          hint('Nilai dibaca: $favoriteCount'),
          gap(6),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onDecrement,
                style: outlined(AppColors.muted, pad: 8),
                child: const Icon(Icons.remove, size: 16),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: onIncrement,
                style: filled(AppColors.success, pad: 8),
                child: const Icon(Icons.add, size: 16),
              ),
            ),
          ]),
        ]),
      );
}

class DashboardStatusBarV3 extends StatelessWidget {
  final int favoriteCount;

  const DashboardStatusBarV3({super.key, required this.favoriteCount});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Status: $favoriteCount favorite aktif di dashboard',
              style: ts(12, color: Colors.black87),
            ),
          ),
          Text('child ke-3',
              style: ts(10, italic: FontStyle.italic, color: AppColors.muted)),
        ]),
      );
}
class HomeDashboardPageV4 extends StatelessWidget {
  const HomeDashboardPageV4({super.key});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.primary.withValues(alpha: 0.35),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.notifications_active_outlined,
          'ValueNotifier',
          Text('Tahap 4', style: ts(12, color: Colors.black54)),
          color: AppColors.primary,
        ),
        gap(10),
        hint(
            'Nilai disimpan di ValueNotifier<int> global. Tiga child mendengarkan langsung lewat ValueListenableBuilder tanpa constructor nilai.'),
        gap(12),
        Row(children: [
          Expanded(child: CourseSummaryTileV4(counter: favoriteCounter)),
          const SizedBox(width: 10),
          Expanded(child: FavoriteTogglePanelV4(counter: favoriteCounter)),
        ]),
        gap(10),
        DashboardStatusBarV4(counter: favoriteCounter),
      ]),
    );
  }
}

class CourseSummaryTileV4 extends StatelessWidget {
  final ValueNotifier<int> counter;

  const CourseSummaryTileV4({super.key, required this.counter});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.summarize_outlined,
                size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text('Ringkasan',
                style: ts(12, w: FontWeight.bold, color: AppColors.primary)),
          ]),
          gap(6),
          Text('Favorite saat ini:', style: ts(11, color: Colors.black54)),
          ValueListenableBuilder<int>(
            valueListenable: counter,
            builder: (_, value, __) => Text('$value',
                style: ts(22, w: FontWeight.bold, color: AppColors.primary)),
          ),
          gap(4),
          hint('listen langsung'),
        ]),
      );
}

class FavoriteTogglePanelV4 extends StatelessWidget {
  final ValueNotifier<int> counter;

  const FavoriteTogglePanelV4({super.key, required this.counter});

  void _increment() => counter.value = counter.value + 1;
  void _decrement() {
    if (counter.value == 0) return;
    counter.value = counter.value - 1;
  }

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.successSoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.success.withValues(alpha: 0.25)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.tune, size: 18, color: AppColors.success),
            const SizedBox(width: 6),
            Text('Kontrol',
                style: ts(12, w: FontWeight.bold, color: AppColors.success)),
          ]),
          gap(6),
          ValueListenableBuilder<int>(
            valueListenable: counter,
            builder: (_, value, __) => hint('Nilai dibaca: $value'),
          ),
          gap(6),
          Row(children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _decrement,
                style: outlined(AppColors.muted, pad: 8),
                child: const Icon(Icons.remove, size: 16),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: ElevatedButton(
                onPressed: _increment,
                style: filled(AppColors.success, pad: 8),
                child: const Icon(Icons.add, size: 16),
              ),
            ),
          ]),
        ]),
      );
}

class DashboardStatusBarV4 extends StatelessWidget {
  final ValueNotifier<int> counter;

  const DashboardStatusBarV4({super.key, required this.counter});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          const Icon(Icons.info_outline, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: counter,
              builder: (_, value, __) => Text(
                'Status: $value favorite aktif di dashboard',
                style: ts(12, color: Colors.black87),
              ),
            ),
          ),
          Text('child ke-3',
              style: ts(10, italic: FontStyle.italic, color: AppColors.muted)),
        ]),
      );
}
class ChangeNotifierDemoCard extends StatelessWidget {
  const ChangeNotifierDemoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.primary.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.sync_alt,
          'ChangeNotifier via Provider',
          Text('Tahap 6', style: ts(12, color: Colors.black54)),
          color: AppColors.primary,
        ),
        gap(10),
        hint(
            'Kartu ini memakai context.watch<CourseProvider>() untuk menampilkan jumlah favorite. Setiap notifyListeners() memicu rebuild otomatis.'),
        gap(12),
        _counterRow(provider),
        gap(10),
        _courseToggleList(context, provider),
        gap(10),
        Row(children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.read<CourseProvider>().clearFavorites(),
              icon: const Icon(Icons.clear_all, size: 16),
              label: const Text('Reset'),
              style: outlined(AppColors.muted, pad: 8),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _counterRow(CourseProvider provider) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.star, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Jumlah favorite: ', style: ts(12, color: Colors.black87)),
          Text('${provider.favoriteCount}',
              style: ts(16, w: FontWeight.bold, color: AppColors.primary)),
          const Spacer(),
          hint('via watch'),
        ]),
      );

  Widget _courseToggleList(BuildContext context, CourseProvider provider) =>
      withCourses(
        handleStates: false,
        (_, courses) => Column(children: [
          for (final c in courses.take(4))
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () =>
                    context.read<CourseProvider>().toggleFavorite(c.code),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Row(children: [
                    Icon(
                      provider.isFavorite(c.code)
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 18,
                      color: provider.isFavorite(c.code)
                          ? AppColors.success
                          : AppColors.muted,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('${c.code} — ${c.title}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ts(12, color: Colors.black87)),
                    ),
                  ]),
                ),
              ),
            ),
        ]),
      );
}
class WatchReadConsumerDemoCard extends StatelessWidget {
  const WatchReadConsumerDemoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return AppCard(
      padding: const EdgeInsets.all(16),
      borderColor: AppColors.success.withValues(alpha: 0.5),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        cardHeader(
          Icons.visibility_outlined,
          'watch, read, dan Consumer',
          Text('Tahap 7', style: ts(12, color: Colors.black54)),
        ),
        gap(10),
        hint(
            'Tiga pola dalam satu kartu: watch untuk menampilkan nilai, read untuk aksi tombol, dan Consumer untuk membatasi rebuild ke satu area kecil.'),
        gap(12),
        _sectionLabel(
          'context.watch',
          'Widget ini (seluruh kartu) rebuild setiap provider berubah.',
          color: AppColors.primary,
        ),
        gap(6),
        _counterRow(provider),
        gap(10),
        _sectionLabel(
          'context.read',
          'Tombol di bawah hanya memanggil method, tidak listen. Tidak memicu rebuild tambahan.',
          color: AppColors.warn,
        ),
        gap(6),
        Row(children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                final p = context.read<CourseProvider>();
                final list = p.favorites.toList()..sort();
                if (list.isEmpty) {
                  showMsg(context, 'Belum ada favorite untuk ditampilkan.');
                  return;
                }
                showMsg(
                  context,
                  'Favorite aktif: ${list.length} course',
                  color: AppColors.success,
                );
              },
              icon: const Icon(Icons.info_outline, size: 16),
              label: const Text('Cek Favorite (read)'),
              style: filled(AppColors.warn, pad: 10),
            ),
          ),
        ]),
        gap(14),
        _sectionLabel(
          'Consumer',
          'Hanya tile kecil di bawah yang rebuild, bukan seluruh kartu.',
          color: AppColors.success,
        ),
        gap(6),
        const ConsumerOnlyCounterTile(),
      ]),
    );
  }

  Widget _sectionLabel(String title, String desc, {required Color color}) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(title, style: ts(10, w: FontWeight.bold, color: color)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(desc,
              style: ts(11, color: Colors.black54, height: 1.4)),
        ),
      ]);

  Widget _counterRow(CourseProvider provider) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          const Icon(Icons.star, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('Jumlah favorite: ', style: ts(12, color: Colors.black87)),
          Text('${provider.favoriteCount}',
              style: ts(16, w: FontWeight.bold, color: AppColors.primary)),
          const Spacer(),
          hint('watch'),
        ]),
      );
}

class ConsumerOnlyCounterTile extends StatelessWidget {
  const ConsumerOnlyCounterTile({super.key});

  @override
  Widget build(BuildContext context) => Consumer<CourseProvider>(
        builder: (context, provider, child) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.successSoft,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.35)),
          ),
          child: Row(children: [
            const Icon(Icons.visibility, size: 18, color: AppColors.success),
            const SizedBox(width: 8),
            Text('Consumer — favorite: ',
                style: ts(12, color: Colors.black87)),
            Text('${provider.favoriteCount}',
                style: ts(16, w: FontWeight.bold, color: AppColors.success)),
            const Spacer(),
            hint('rebuild terbatas'),
          ]),
        ),
      );
}

// ===== CATATAN =====
class PropDrillingNoteCard extends StatelessWidget {
  const PropDrillingNoteCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.warn.withValues(alpha: 0.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.warning_amber_outlined,
            'Catatan Prop Drilling',
            Text('Tahap 2', style: ts(12, color: Colors.black54)),
            color: AppColors.warn,
          ),
          gap(10),
          _bullet('State _favoriteCount dimiliki HomeDashboardPage dan harus dikirim ke setiap child lewat constructor.'),
          _bullet('Setiap child yang ingin mengubah nilai harus menerima callback dari parent.'),
          _bullet('Menambah child baru berarti menambah constructor baru — inilah prop drilling.'),
          _bullet('Risiko duplikasi: child yang menyimpan salinan bisa tidak sinkron.'),
        ]),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 6, color: AppColors.warn),
          ),
          Expanded(
            child: Text(text,
                style: ts(12, color: Colors.black87, height: 1.4)),
          ),
        ]),
      );
}

class LiftingStateUpNoteCard extends StatelessWidget {
  const LiftingStateUpNoteCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.success.withValues(alpha: 0.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.arrow_upward,
            'Catatan Lifting State Up',
            Text('Tahap 3', style: ts(12, color: Colors.black54)),
          ),
          gap(10),
          _bullet('State _favoriteCount diangkat ke ancestor terdekat.'),
          _bullet('HomeDashboardPage menjadi Single Source of Truth.'),
          _bullet('Tiga child menerima nilai yang sama lewat constructor.'),
          _bullet('Hanya FavoriteTogglePanel yang menerima callback.'),
        ]),
      );

  Widget _bullet(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(Icons.circle, size: 6, color: AppColors.success),
          ),
          Expanded(
            child: Text(text,
                style: ts(12, color: Colors.black87, height: 1.4)),
          ),
        ]),
      );
}

class ValueNotifierComparisonCard extends StatelessWidget {
  const ValueNotifierComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.compare_arrows,
            'Perbandingan setState vs ValueNotifier',
            Text('Tahap 4', style: ts(12, color: Colors.black54)),
            color: AppColors.primary,
          ),
          gap(10),
          _row('Pemilik state', 'Widget (State class)',
              'ValueNotifier global'),
          _row('Child menerima nilai lewat', 'Constructor',
              'Reference notifier'),
          _row('Child mengubah nilai lewat', 'Callback parent',
              'notifier.value = ...'),
          _row('Rebuild dipicu oleh', 'setState()',
              'notifier.value berubah'),
          _row('Cakupan rebuild', 'Seluruh subtree parent',
              'Hanya ValueListenableBuilder'),
        ]),
      );

  Widget _row(String label, String v3, String v4) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('setState: $v3',
                  style: ts(11, color: AppColors.warn, height: 1.3)),
            ),
            Expanded(
              child: Text('Notifier: $v4',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}

class ChangeNotifierComparisonCard extends StatelessWidget {
  const ChangeNotifierComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.success.withValues(alpha: 0.35),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.sync_alt,
            'Perbandingan ValueNotifier vs ChangeNotifier',
            Text('Tahap 5', style: ts(12, color: Colors.black54)),
          ),
          gap(10),
          _row('Menyimpan', 'Satu nilai', 'Banyak field sekaligus'),
          _row('Method sendiri', 'Tidak bisa', 'Bisa (toggleFavorite)'),
          _row('Notifikasi', 'notifier.value = ...', 'notifyListeners()'),
          _row('Logika terkait', 'Di luar class', 'Di dalam class'),
          _row('Cocok untuk', 'Satu nilai sederhana',
              'State gabungan + logika'),
        ]),
      );

  Widget _row(String label, String v4, String v5) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ts(11, w: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 2),
          Row(children: [
            Expanded(
              child: Text('ValueNotifier: $v4',
                  style: ts(11, color: AppColors.primary, height: 1.3)),
            ),
            Expanded(
              child: Text('ChangeNotifier: $v5',
                  style: ts(11, color: AppColors.success, height: 1.3)),
            ),
          ]),
        ]),
      );
}

class ProviderPatternsComparisonCard extends StatelessWidget {
  const ProviderPatternsComparisonCard({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
        borderColor: AppColors.primary.withValues(alpha: 0.5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          cardHeader(
            Icons.visibility_outlined,
            'Pola Akses Provider',
            Text('Tahap 7', style: ts(12, color: Colors.black54)),
            color: AppColors.primary,
          ),
          gap(10),
          _row(
            'context.watch<T>()',
            'Listen + rebuild widget',
            'Menampilkan nilai di UI',
            AppColors.primary,
          ),
          _row(
            'context.read<T>()',
            'Ambil instance, tanpa listen',
            'Memanggil method / aksi tombol',
            AppColors.warn,
          ),
          _row(
            'Consumer<T>',
            'Listen + rebuild terbatas',
            'Membatasi rebuild ke area kecil',
            AppColors.success,
          ),
          _row(
            'ListenableBuilder',
            'Listen ke Listenable apa pun',
            'Alternatif tanpa Provider',
            AppColors.muted,
          ),
          gap(6),
          hint(
              'Aturan singkat: watch untuk tampilkan, read untuk aksi, Consumer untuk area kecil yang sering berubah. Jangan panggil watch di dalam onPressed.'),
        ]),
      );

  Widget _row(String label, String behavior, String useCase, Color color) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(label,
                  style: ts(10, w: FontWeight.bold, color: color)),
            ),
          ]),
          const SizedBox(height: 4),
          Text(behavior,
              style: ts(11, w: FontWeight.w600, color: Colors.black87)),
          Text(useCase, style: ts(11, color: Colors.black54, height: 1.3)),
        ]),
      );
}

class FavoriteSectionCard extends StatelessWidget {
  const FavoriteSectionCard({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<Set<String>>(
        valueListenable: favorites,
        builder: (context, favs, _) =>
            withCourses(handleStates: false, (_, courses) {
          final favCourses =
              courses.where((c) => favs.contains(c.code)).toList();
          return AppCard(
            borderColor: AppColors.success.withValues(alpha: 0.35),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              cardHeader(
                Icons.star,
                'Course Favorite (ValueNotifier)',
                Text('${favCourses.length}',
                    style:
                        ts(13, w: FontWeight.bold, color: AppColors.success)),
              ),
              gap(10),
              if (favCourses.isEmpty)
                hint('Belum ada course favorite. Tap ikon ⭐ di halaman detail course.')
              else
                for (final c in favCourses) _favItem(context, c),
            ]),
          );
        }),
      );

  Widget _favItem(BuildContext context, Json c) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => go(context, CourseDetailPage(course: c, isFavorite: true)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(children: [
              const Icon(Icons.bookmark, size: 16, color: AppColors.success),
              const SizedBox(width: 8),
              Expanded(
                child: Text(c.title,
                    overflow: TextOverflow.ellipsis,
                    style: ts(13, w: FontWeight.w500, color: Colors.black)),
              ),
              const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
            ]),
          ),
        ),
      );
}

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  int _index = 0;

  static const _pages = <Widget>[
    _HomeTabPage(),
    CourseGridPage(),
    _ProfileTabPage(),
  ];

  static const _dest = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.school_outlined, Icons.school, 'Courses'),
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

class _HomeTabPage extends StatelessWidget {
  const _HomeTabPage();

  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const IdentityCard(),
          gap(),
          const AsyncCoursesCard(),
          gap(),
          const CourseRepositoryDemoCard(),
          gap(),
          const CourseServiceDemoCard(),
          gap(),
          const CourseModelDemoCard(),
          gap(),
          const WatchReadConsumerDemoCard(),
          gap(),
          const ChangeNotifierDemoCard(),
          gap(),
          const HomeDashboardPageV3(),
          gap(),
          const HomeDashboardPageV4(),
          gap(),
          const MiniQuizCard(),
          gap(12),
          const FavoriteSectionCard(),
          gap(),
          sectionTitle('Course Terbaru'),
          gap(8),
          const _RecentCourses(),
        ],
      );
}

class _RecentCourses extends StatelessWidget {
  const _RecentCourses();

  @override
  Widget build(BuildContext context) => withCourses(
        (_, courses) => Column(children: [
          for (final c in courses.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  leading: Icon(StatusHelper.icon(c.status),
                      color: StatusHelper.color(c.status)),
                  title: Text(c.title),
                  subtitle: Text('${c.str('code')} • ${c.str('credits')} SKS'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openCourse(context, c),
                ),
              ),
            ),
        ]),
      );
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;

  const _StatTile(this.icon, this.label, this.value,
      {this.color = AppColors.primary});

  @override
  Widget build(BuildContext context) => Expanded(
        child: AppCard(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: ts(18, w: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, style: ts(12, color: Colors.black54)),
          ]),
        ),
      );
}

class _ProfileTabPage extends StatelessWidget {
  const _ProfileTabPage();

  @override
  Widget build(BuildContext context) => ScrollPage([
        const IdentityCard(
            subtitle: 'Pendidikan Teknik Informatika • Semester 5'),
        gap(),
        ListenableBuilder(
          listenable: Listenable.merge([favorites, quizScore]),
          builder: (_, __) => Row(children: [
            const _StatTile(Icons.book_outlined, 'Topik', '5'),
            const SizedBox(width: 10),
            _StatTile(Icons.star_outline, 'Favorite',
                '${favorites.value.length}',
                color: AppColors.success),
            const SizedBox(width: 10),
            _StatTile(Icons.emoji_events_outlined, 'Quiz',
                quizScore.value?.toString() ?? '-',
                color: AppColors.warn),
          ]),
        ),
        gap(),
        const StateClassificationCard(),
        gap(),
        const AsyncStateIndicatorCard(),
        gap(),
        const ProviderStatusCard(),
        gap(),
        const ProviderPatternsComparisonCard(),
        gap(),
        const AsyncStateComparisonCard(),
        gap(),
        const CourseRepositoryComparisonCard(),
        gap(),
        const CourseServiceComparisonCard(),
        gap(),
        const CourseModelComparisonCard(),
        gap(),
        const PropDrillingNoteCard(),
        gap(),
        const LiftingStateUpNoteCard(),
        gap(),
        const ValueNotifierComparisonCard(),
        gap(),
        const ChangeNotifierComparisonCard(),
        gap(),
        ...section(
          'Informasi Mahasiswa',
          const InfoCard([
            InfoRow(Icons.person_outline, 'Nama', studentName),
            InfoRow(Icons.badge_outlined, 'NIM', studentId),
            InfoRow(Icons.school_outlined, 'Program Studi',
                'Pendidikan Teknik Informatika'),
            InfoRow(Icons.calendar_today_outlined, 'Semester', '5'),
          ], padding: EdgeInsets.all(16)),
        ),
        ...section(
          'About Me',
          AppCard(child: hint('Mahasiswa Pendidikan Teknik Informatika')),
        ),
        ...section(
          'About Application',
          AppCard(
            borderColor: AppColors.primary.withValues(alpha: 0.3),
            child: hint('Course Explorer v2'),
          ),
        ),
        ...section('Daftar Favorite', const FavoriteSectionCard()),
      ]);
}

const _filterOptions = <(String, String, IconData)>[
  ('all', 'Semua', Icons.apps),
  ('done', 'Selesai', Icons.check_circle),
  ('active', 'Berjalan', Icons.play_circle),
  ('planned', 'Belum', Icons.schedule),
  ('favorite', 'Favorite', Icons.star),
];

bool _matchesFilter(String filter, Json c, Set<String> favs) =>
    switch (filter) {
      'done' || 'active' || 'planned' => c.status == filter,
      'favorite' => favs.contains(c.code),
      _ => true,
    };

class CourseGridPage extends StatelessWidget {
  final bool standalone;

  const CourseGridPage({super.key, this.standalone = false});

  @override
  Widget build(BuildContext context) {
    final content = withCourses((data, courses) {
      final s = (data['student'] as Json?) ?? {};
      return Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: IdentityCard(
            name: s['name'] ?? studentName,
            nim: s['nim'] ?? studentId,
            subtitle:
                '${s['program'] ?? 'Mahasiswa'} • Semester ${s['semester'] ?? '-'}',
          ),
        ),
        const _FilterBar(),
        Expanded(
          child: ListenableBuilder(
            listenable: Listenable.merge([favorites, courseFilter]),
            builder: (_, __) {
              final favs = favorites.value;
              final filtered = courses
                  .where((c) => _matchesFilter(courseFilter.value, c, favs))
                  .toList();
              return filtered.isEmpty ? _emptyState() : _grid(filtered, favs);
            },
          ),
        ),
      ]);
    });
    return standalone ? DemoScaffold(body: content) : content;
  }

  Widget _emptyState() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.filter_alt_off, size: 48, color: AppColors.muted),
            gap(10),
            hint('Tidak ada course dengan filter ini.'),
          ]),
        ),
      );

  Widget _grid(List<Json> items, Set<String> favs) => LayoutBuilder(
        builder: (context, c) => GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnsFor(c.maxWidth),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 170,
          ),
          itemCount: items.length,
          itemBuilder: (_, i) => CourseCard(
            course: items[i],
            isFavorite: favs.contains(items[i].code),
            onTap: () => openCourse(context, items[i]),
            onLongPress: () => _confirmRemoveFavorite(context, items[i]),
          ),
        ),
      );
}

class _FilterBar extends StatelessWidget {
  const _FilterBar();

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
        valueListenable: courseFilter,
        builder: (_, active, __) => SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _filterOptions.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final (key, label, icon) = _filterOptions[i];
              final selected = active == key;
              return ChoiceChip(
                selected: selected,
                onSelected: (_) => courseFilter.value = key,
                avatar: Icon(icon,
                    size: 16,
                    color: selected ? Colors.white : AppColors.primary),
                label: Text(label),
                labelStyle: ts(12,
                    w: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black87),
                selectedColor: AppColors.primary,
                backgroundColor: Colors.white,
                side: BorderSide(
                    color: selected ? AppColors.primary : AppColors.border),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              );
            },
          ),
        ),
      );
}

// ===== COURSE CARD =====
class CourseCard extends StatefulWidget {
  final Json course;
  final bool isFavorite;
  final VoidCallback? onTap, onLongPress;

  const CourseCard({
    super.key,
    required this.course,
    this.isFavorite = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  State<CourseCard> createState() => _CourseCardState();
}

class _CourseCardState extends State<CourseCard> {
  bool _showDescription = false;

  void _toggleDescription() =>
      setState(() => _showDescription = !_showDescription);

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final status = course.status;
    final color = StatusHelper.color(status);
    return AppCard(
      padding: const EdgeInsets.all(12),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      borderColor: widget.isFavorite
          ? AppColors.success.withValues(alpha: 0.6)
          : color.withValues(alpha: 0.25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(StatusHelper.icon(status), color: color, size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Text(course.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: ts(14, w: FontWeight.bold, color: Colors.black)),
          ),
          if (widget.isFavorite)
            const Icon(Icons.star, color: AppColors.success, size: 18),
        ]),
        gap(4),
        Text('${course.str('code')} • ${course.str('credits')} SKS',
            style: ts(11, color: Colors.black54)),
        gap(4),
        Expanded(
          child: _showDescription
              ? SingleChildScrollView(
                  child: Text(course.str('description', ''),
                      style: ts(11, color: Colors.black87, height: 1.4)),
                )
              : Text(course.str('description', ''),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: ts(11, color: Colors.black45, height: 1.3)),
        ),
        Row(children: [
          Expanded(
            child: Text('Dosen: ${course.str('dosen')}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    ts(10, color: Colors.black45, italic: FontStyle.italic)),
          ),
          InkWell(
            onTap: _toggleDescription,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Row(children: [
                Text(_showDescription ? 'Tutup' : 'Detail',
                    style: ts(10,
                        w: FontWeight.bold, color: AppColors.primary)),
                Icon(
                  _showDescription
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  size: 14,
                  color: AppColors.primary,
                ),
              ]),
            ),
          ),
          const SizedBox(width: 4),
          StatusHelper.badge(status),
        ]),
      ]),
    );
  }
}

// ===== COURSE DETAIL =====
class CourseDetailPage extends StatefulWidget {
  final Json course;
  final bool isFavorite;

  const CourseDetailPage({super.key, required this.course, this.isFavorite = false});

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  bool _showFullDescription = false;

  @override
  Widget build(BuildContext context) {
    final course = widget.course;
    final status = course.status;
    final color = StatusHelper.color(status);
    final credits = course.str('credits');
    final progress = StatusHelper.progressOf(status);
    final code = course.str('code');
    final desc = course.str('description', 'Tidak ada deskripsi.');

    return DemoScaffold(
      body: ScrollPage([
        AppCard(
          padding: const EdgeInsets.all(16),
          borderColor: color.withValues(alpha: 0.4),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(StatusHelper.icon(status), color: color, size: 28),
              const SizedBox(width: 10),
              Expanded(
                  child: Text(course.title,
                      style: ts(18, w: FontWeight.bold))),
            ]),
            gap(10),
            Row(children: [
              Text('$code • $credits SKS', style: ts(13, color: Colors.black54)),
              const Spacer(),
              StatusHelper.badge(status),
            ]),
            gap(14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.border,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.success),
              ),
            ),
            gap(6),
            Row(children: [
              const Icon(Icons.trending_up, size: 14, color: AppColors.success),
              const SizedBox(width: 6),
              Text('Progress: ${(progress * 100).round()}%',
                  style:
                      ts(12, w: FontWeight.w600, color: AppColors.success)),
            ]),
          ]),
        ),
        gap(),
        ...section(
          'Deskripsi',
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: _showFullDescription
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(desc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: ts(13, height: 1.5)),
                secondChild: Text(desc, style: ts(13, height: 1.5)),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => setState(
                      () => _showFullDescription = !_showFullDescription),
                  icon: Icon(
                    _showFullDescription
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 18,
                  ),
                  label: Text(_showFullDescription
                      ? 'Sembunyikan'
                      : 'Selengkapnya'),
                ),
              ),
            ]),
          ),
        ),
        ...section(
          'Informasi Course',
          InfoCard([
            InfoRow(Icons.tag, 'Kode', code),
            InfoRow(Icons.credit_card, 'SKS', '$credits SKS'),
            InfoRow(Icons.person, 'Dosen', course.str('dosen')),
            InfoRow(Icons.info_outline, 'Status', StatusHelper.label(status)),
          ]),
        ),
        ...section('Identitas Mahasiswa', const IdentityCard()),
        OutlinedButton.icon(
          onPressed: () async {
            await Clipboard.setData(ClipboardData(text: code));
            if (!context.mounted) return;
            showMsg(context, 'Kode course "$code" disalin.');
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Salin Kode Course'),
          style: outlined(AppColors.primary),
        ),
        gap(10),
        ElevatedButton.icon(
          onPressed: () => Navigator.pop(context, !widget.isFavorite),
          icon: Icon(widget.isFavorite ? Icons.star_border : Icons.star, size: 18),
          label: Text(widget.isFavorite
              ? 'Hapus dari Favorite & Kembali'
              : 'Tandai Favorite & Kembali'),
          style: filled(widget.isFavorite ? AppColors.muted : AppColors.success),
        ),
      ]),
    );
  }
}

// ===== APP =====
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

void main() => runApp(const MyApp());