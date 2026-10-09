// ===== DATA MINI QUIZ =====

const List<Map<String, dynamic>> quizQuestions = [
  {
    'q': 'Apa bahasa pemrograman yang digunakan Flutter?',
    'options': ['Java', 'Dart', 'Python'],
    'answer': 'Dart',
  },
  {
    'q': 'Widget dasar untuk menampilkan teks di Flutter?',
    'options': ['Text', 'Label', 'Span'],
    'answer': 'Text',
  },
  {
    'q': 'Widget untuk membaca asset lokal seperti JSON?',
    'options': ['rootBundle', 'fileSystem', 'http'],
    'answer': 'rootBundle',
  },
  {
    'q': 'Widget yang membangun UI dari Future?',
    'options': ['FutureBuilder', 'StreamReader', 'AsyncWidget'],
    'answer': 'FutureBuilder',
  },
  {
    'q': 'Method untuk menginisialisasi Future di StatefulWidget?',
    'options': ['initState()', 'build()', 'dispose()'],
    'answer': 'initState()',
  },
  {
    'q': 'Widget yang digunakan untuk membuat daftar yang dapat di-scroll?',
    'options': ['ListView', 'TextView', 'ColumnView'],
    'answer': 'ListView',
  },
  {
    'q': 'Widget yang digunakan untuk membuat tata letak secara vertikal?',
    'options': ['Row', 'Column', 'Stack'],
    'answer': 'Column',
  },
  {
    'q': 'Widget yang digunakan untuk menyusun beberapa widget secara horizontal?',
    'options': ['Row', 'Column', 'Stack'],
    'answer': 'Row',
  },
  {
    'q': 'Widget utama yang biasanya digunakan sebagai struktur dasar sebuah halaman Flutter?',
    'options': ['Scaffold', 'Container', 'MaterialApp'],
    'answer': 'Scaffold',
  },
  {
    'q': 'Widget yang digunakan untuk menampilkan gambar dari asset?',
    'options': ['Image.asset', 'Picture.local', 'AssetImageView'],
    'answer': 'Image.asset',
  },
  {
    'q': 'File yang biasanya digunakan untuk mendeklarasikan asset pada project Flutter?',
    'options': ['pubspec.yaml', 'asset.yaml', 'flutter.json'],
    'answer': 'pubspec.yaml',
  },
  {
    'q': 'Tipe data Dart yang digunakan untuk menyimpan teks?',
    'options': ['String', 'Text', 'Char'],
    'answer': 'String',
  },
  {
    'q': 'Tipe data Dart yang digunakan untuk menyimpan bilangan bulat?',
    'options': ['Double', 'int', 'IntegerValue'],
    'answer': 'int',
  },
  {
    'q': 'Tipe data Dart yang digunakan untuk nilai benar atau salah?',
    'options': ['Boolean', 'bool', 'Check'],
    'answer': 'bool',
  },
  {
    'q': 'Keyword Dart untuk membuat variabel yang nilainya tidak dapat diubah?',
    'options': ['final', 'fixed', 'constant'],
    'answer': 'final',
  },
  {
    'q': 'Keyword Dart untuk membuat nilai compile-time constant?',
    'options': ['static', 'const', 'constant'],
    'answer': 'const',
  },
  {
    'q': 'Widget Flutter yang dapat menyimpan dan mengubah state disebut?',
    'options': ['StatefulWidget', 'StaticWidget', 'DataWidget'],
    'answer': 'StatefulWidget',
  },
  {
    'q': 'Widget Flutter yang tidak memiliki state yang dapat berubah disebut?',
    'options': ['StateWidget', 'StatelessWidget', 'ImmutableState'],
    'answer': 'StatelessWidget',
  },
  {
    'q': 'Method yang digunakan untuk membangun tampilan widget di Flutter?',
    'options': ['render()', 'build()', 'createUI()'],
    'answer': 'build()',
  },
  {
    'q': 'Format data yang digunakan pada student_data.json?',
    'options': ['XML', 'JSON', 'CSV'],
    'answer': 'JSON',
  },

  {
    'q': 'Widget yang membaca ukuran layar, orientasi, dan padding sistem secara global?',
    'options': ['MediaQuery', 'LayoutBuilder', 'Container'],
    'answer': 'MediaQuery',
  },
  {
    'q': 'Widget yang membaca constraints dari parent untuk menentukan layout lokal?',
    'options': ['MediaQuery', 'LayoutBuilder', 'InheritedWidget'],
    'answer': 'LayoutBuilder',
  },
  {
    'q': 'Berapa breakpoint "compact" pada worksheet Pertemuan 5?',
    'options': ['Lebar < 600 px', 'Lebar < 720 px', 'Lebar < 840 px'],
    'answer': 'Lebar < 600 px',
  },
  {
    'q': 'Berapa breakpoint "medium" pada worksheet Pertemuan 5?',
    'options': ['400 – 599 px', '600 – 839 px', '840 – 1024 px'],
    'answer': '600 – 839 px',
  },
  {
    'q': 'Berapa breakpoint "expanded" pada worksheet Pertemuan 5?',
    'options': ['≥ 600 px', '≥ 720 px', '≥ 840 px'],
    'answer': '≥ 840 px',
  },
  {
    'q': 'Widget yang mengisi sisa ruang di dalam Row atau Column secara proporsional?',
    'options': ['Expanded', 'Padding', 'Align'],
    'answer': 'Expanded',
  },
  {
    'q': 'Widget yang memberi ruang lebih longgar tetapi tidak selalu memenuhi sisa ruang?',
    'options': ['Flexible', 'Expanded', 'SizedBox'],
    'answer': 'Flexible',
  },
  {
    'q': 'Widget yang memindahkan child ke baris berikutnya ketika ruang tidak cukup?',
    'options': ['Row', 'Wrap', 'Stack'],
    'answer': 'Wrap',
  },
  {
    'q': 'Error yang muncul ketika child meminta ruang lebih besar dari constraints parent?',
    'options': ['RenderFlex overflowed', 'NullPointerException', 'FormatException'],
    'answer': 'RenderFlex overflowed',
  },
  {
    'q': 'Widget scroll yang cocok untuk konten statis yang lebih tinggi dari layar?',
    'options': ['ListView', 'SingleChildScrollView', 'PageView'],
    'answer': 'SingleChildScrollView',
  },

  {
    'q': 'Method untuk membuka halaman baru dengan menambahkan route di atas stack?',
    'options': ['Navigator.push()', 'Navigator.pop()', 'Navigator.replace()'],
    'answer': 'Navigator.push()',
  },
  {
    'q': 'Method untuk kembali ke halaman sebelumnya dengan menghapus route teratas?',
    'options': ['Navigator.push()', 'Navigator.pop()', 'Navigator.remove()'],
    'answer': 'Navigator.pop()',
  },
  {
    'q': 'Cara mengirim data hasil dari halaman detail ke halaman sebelumnya?',
    'options': [
      'Navigator.pop(context, result)',
      'Navigator.push(context, result)',
      'Navigator.setResult(result)',
    ],
    'answer': 'Navigator.pop(context, result)',
  },
  {
    'q': 'Widget navigasi utama yang cocok untuk layar compact/medium?',
    'options': ['NavigationRail', 'NavigationBar', 'Drawer'],
    'answer': 'NavigationBar',
  },
  {
    'q': 'Widget navigasi utama yang cocok untuk layar expanded (≥ 840 px)?',
    'options': ['NavigationRail', 'NavigationBar', 'BottomNavigationBar'],
    'answer': 'NavigationRail',
  },

  {
    'q': 'Widget yang memberi efek ripple Material saat ditekan?',
    'options': ['GestureDetector', 'InkWell', 'Listener'],
    'answer': 'InkWell',
  },
  {
    'q': 'Widget yang mendeteksi gesture umum (tap, long press, drag) tanpa ripple Material?',
    'options': ['InkWell', 'GestureDetector', 'ElevatedButton'],
    'answer': 'GestureDetector',
  },
  {
    'q': 'Widget yang digunakan untuk membungkus form dan memvalidasi semua field sekaligus?',
    'options': ['Form', 'TextField', 'Validator'],
    'answer': 'Form',
  },
  {
    'q': 'Cara memicu validasi semua field pada Form?',
    'options': [
      '_formKey.currentState!.validate()',
      '_formKey.validateAll()',
      'Form.of(context).check()',
    ],
    'answer': '_formKey.currentState!.validate()',
  },
  {
    'q': 'Feedback singkat yang muncul di bawah layar dan tidak memblokir UI?',
    'options': ['SnackBar', 'AlertDialog', 'Tooltip'],
    'answer': 'SnackBar',
  },
  {
    'q': 'Feedback yang memblokir UI sampai user memilih aksi?',
    'options': ['SnackBar', 'AlertDialog', 'Banner'],
    'answer': 'AlertDialog',
  },
  {
    'q': 'Widget yang menampilkan indikator loading berputar?',
    'options': ['CircularProgressIndicator', 'LinearProgressIndicator', 'LoadingSpinner'],
    'answer': 'CircularProgressIndicator',
  },
];