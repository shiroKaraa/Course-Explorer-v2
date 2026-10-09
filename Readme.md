Tahap 0 : Setup

Project Worksheet Pertemuan 5 ini merupakan lanjutan dari project Worksheet Pertemuan 4. Saya menggunakan file main.dart dari pertemuan sebelumnya sebagai dasar, lalu mengembangkannya secara bertahap mengikuti tahapan pada Worksheet 5 (Tahap 1–17) untuk menerapkan konsep responsive layout, navigation, dan user interaction. Struktur project, data JSON, dan identitas mahasiswa (Nama & NIM) tetap dipertahankan.

Tahap 1 : Mengamati Masalah Layout yang Tidak Responsif

Dari percobaan ini saya menemukan bahwa penggunaan width: 500 membuat tampilan mengalami overflow saat dijalankan di layar HP yang lebih kecil. Setelah width diganti menjadi double.infinity, Container bisa mengikuti ruang yang tersedia sehingga tampilan menjadi lebih rapi. Jadi, ukuran yang terlalu tetap kurang cocok digunakan untuk tampilan yang harus menyesuaikan berbagai ukuran layar.

Tahap 2 : MediaQuery: Membaca Karakteristik Layar

Pada tahap ini saya mencoba menggunakan MediaQuery untuk melihat ukuran dan orientasi layar. Hasilnya, nilai width dan height berubah ketika emulator diputar dari portrait ke landscape. Saya juga mencoba kondisi width < 600 untuk membedakan tampilan Compact dan Wide. Dari sini saya jadi memahami bahwa ukuran layar bisa digunakan sebagai acuan untuk mengatur tampilan aplikasi agar menyesuaikan device.

Tahap 3 : LayoutBuilder dan Breakpoint

Pada tahap ini saya mencoba menggunakan LayoutBuilder untuk menyesuaikan tampilan berdasarkan lebar ruang yang tersedia. Hasilnya, layout dapat berubah dari Compact, Medium, sampai Expanded ketika ukuran window diperbesar. Saya juga melihat bahwa LayoutBuilder berbeda dengan MediaQuery, karena LayoutBuilder lebih fokus pada ruang yang tersedia untuk widget tersebut, bukan hanya ukuran layar secara keseluruhan.

Tahap 4 : Expanded, Flexible, dan Wrap

Pada tahap ini saya mencoba menggunakan Expanded dengan nilai flex yang berbeda. Hasilnya, ruang yang tersedia terbagi sesuai perbandingan flex, sehingga flex: 2 mendapatkan ruang dua kali lebih besar dari flex: 1. Saya juga mencoba Wrap untuk menampilkan beberapa Chip. Saat ukuran layar diperkecil, Chip otomatis berpindah ke baris berikutnya sehingga tidak terjadi overflow. Dari percobaan ini saya memahami bahwa Expanded berguna untuk membagi ruang, sedangkan Wrap cocok digunakan ketika jumlah item bisa bertambah atau ruang yang tersedia terbatas.

Tahap 5 : GridView Responsif

Pada tahap ini saya mencoba membuat tampilan daftar course menggunakan GridView. Jumlah kolom dibuat menyesuaikan lebar layar, sehingga pada layar yang kecil tampil 1 kolom, sedangkan saat window diperbesar menjadi 2 atau 3 kolom. Saya juga menyesuaikan ukuran kartu agar teks tetap nyaman dibaca. Dari percobaan ini saya melihat bahwa penggunaan jumlah kolom yang dinamis membuat tampilan grid lebih fleksibel dan tidak mudah mengalami overflow ketika ukuran layar berubah.

Tahap 6 : Scrollable Content dan Keyboard

Pada tahap ini saya mencoba membuat form profil dengan beberapa TextField. Saat scroll belum digunakan, bagian bawah form tidak terlihat karena tinggi konten melebihi layar dan muncul overflow. Setelah menggunakan SingleChildScrollView, seluruh isi form dapat digeser dan ditampilkan dengan baik. Saya juga menemukan bahwa keyboard dapat menutupi field yang berada di bagian bawah, sehingga perlu menambahkan padding berdasarkan viewInsets.bottom. Dari percobaan ini saya memahami bahwa scroll cukup penting untuk form yang memiliki banyak input, terutama saat digunakan pada layar HP.

Tahap 6.5 (DEBUG) : Refactoring/Penyederhanaan Kode dan Perbaikan Beberapa BUG

Sebelum masuk Tahap 7, saya melakukan refactoring pada main.dart untuk merapikan kode dan memperbaiki beberapa bug: (1) home: diubah dari ProfileFormPage ke HomePage agar menu Tahap 1–6 dapat diakses; (2) childAspectRatio pada GridView diganti mainAxisExtent agar tidak overflow; (3) teks hint di Tahap 4 bagian C disesuaikan. Duplikasi seperti header identitas, AppBar, kartu course, dan layout breakpoint digabung menjadi widget reusable. DashboardPage dan GreetingCard dinonaktifkan sementara karena tidak dipakai di tahap 1–6. Sedangkan MiniQuizCard dan quiz_data.dart sengaja dinonaktifkan sementara dan akan digunakan kembali pada Tahap 15 (Mini Project Integrasi). Hasilnya, file main.dart menyusut dari ~1.800 baris menjadi ~680 baris dengan struktur yang lebih bersih.

Tahap 7 : Navigator.push() dan Navigator.pop()

Pada tahap ini saya mencoba membuat perpindahan halaman dari HomePage ke DetailPage menggunakan Navigator.push(). Setelah masuk ke DetailPage, tombol back pada AppBar otomatis muncul karena halaman tersebut berada di atas HomePage. Saya juga mencoba tombol "Kembali" menggunakan Navigator.pop(), dan hasilnya sama-sama kembali ke halaman sebelumnya. Dari percobaan ini saya lebih memahami bahwa navigasi Flutter bekerja seperti stack, yaitu push untuk menambahkan halaman dan pop untuk kembali atau menghapus halaman teratas.

Tahap 8 : Passing Data dari List ke Detail Page

Pada tahap ini saya mencoba membuat halaman detail course yang datanya dikirim dari halaman daftar course. Saat salah satu kartu ditekan, data course dikirim melalui constructor ke CourseDetailPage. Hasilnya, satu halaman detail bisa digunakan untuk semua course tanpa perlu membuat halaman baru untuk setiap course. Saya juga menggunakan InkWell agar kartu bisa ditekan dan memberikan efek ripple. Dari percobaan ini saya memahami bahwa data dapat dikirim antar halaman melalui constructor dan membuat kode menjadi lebih sederhana karena halaman detail dapat digunakan kembali.

Tahap 9 : Returning Data dari Screen

Pada tahap ini saya mencoba mengirimkan hasil dari CourseDetailPage kembali ke halaman sebelumnya. Saat tombol Favorite ditekan, halaman detail mengirim nilai true menggunakan Navigator.pop(), kemudian halaman course menerima nilai tersebut melalui await Navigator.push(). Setelah itu, course yang dipilih ditambahkan ke daftar favorite dan muncul SnackBar sebagai tanda bahwa data berhasil diterima. Jika hanya menekan tombol back biasa, tidak ada perubahan karena tidak ada nilai yang dikirim. Dari percobaan ini saya memahami bahwa halaman Flutter tidak hanya bisa menerima data saat dibuka, tetapi juga bisa mengirim hasil kembali ke halaman sebelumnya.

Tahap 10 : NavigationBar / BottomNavigationBar

Pada Tahap 10, saya menemukan masalah ketika CourseGridPage dipakai di dalam MainShellPage: muncul dua AppBar bertumpuk karena CourseGridPage selalu membawa DemoScaffold (dengan AppBar sendiri) padahal shell sudah menyediakan AppBar. Solusinya adalah menambahkan parameter standalone pada CourseGridPage: ketika standalone: true, halaman dibungkus DemoScaffold (untuk dipanggil dari menu Home via Navigator.push); ketika standalone: false (default), hanya konten grid-nya yang ditampilkan (untuk tab Courses di dalam shell). Pola ini adalah configuration parameter yang umum dipakai agar satu widget dapat beradaptasi di beberapa konteks tanpa duplikasi kode.

Tahap 11 : Adaptive Navigation: NavigationBar vs NavigationRail

Pada tahap ini saya mencoba membuat navigasi yang dapat menyesuaikan ukuran layar. Saat ukuran window masih kecil, navigasi ditampilkan di bagian bawah menggunakan NavigationBar. Ketika window diperbesar sampai 840px atau lebih, navigasi berubah menjadi NavigationRail di sebelah kiri. Saya juga menggunakan satu list _destinations untuk kedua jenis navigasi agar tidak perlu menulis data yang sama dua kali. Saat ukuran window diubah, tab yang sedang aktif tetap sama dan data di dalam tab juga tidak hilang. Dari percobaan ini saya memahami bahwa tampilan navigasi bisa dibuat berbeda sesuai ukuran layar tanpa harus mengubah fungsi navigasinya.

Tahap 12 : Button, InkWell, dan GestureDetector

Pada tahap ini saya mencoba beberapa cara untuk menangani interaksi pengguna, yaitu InkWell, GestureDetector, dan beberapa button Material. Saya melihat bahwa InkWell memiliki efek ripple ketika ditekan, sedangkan GestureDetector hanya mendeteksi gesture tanpa efek tersebut. Saya juga mencoba ElevatedButton, OutlinedButton, dan TextButton yang memiliki tampilan berbeda sesuai penggunaannya. Setiap tombol saya beri SnackBar sebagai feedback setelah ditekan. Dari percobaan ini saya memahami bahwa setiap widget memiliki fungsi interaksi yang berbeda dan setState dapat digunakan ketika interaksi tersebut perlu mengubah tampilan.

Tahap 13 : Form Input dan Validasi

Pada tahap ini saya mencoba membuat form feedback dengan beberapa TextFormField dan menambahkan validasi pada setiap field. Saya mengatur agar pesan error baru muncul setelah tombol Submit ditekan, sehingga sebelum melakukan submit tampilan form tetap lebih bersih. Setelah ada field yang diperbaiki, pesan error akan hilang secara otomatis. Saya juga mencoba validate() untuk memeriksa semua field sekaligus. Jika masih ada field yang salah, data tidak diproses dan muncul SnackBar sebagai pemberitahuan. Setelah semua field valid, data yang dimasukkan dapat ditampilkan sebagai preview. Dari percobaan ini saya memahami bahwa validasi form penting untuk memastikan data yang diproses sudah sesuai.

Tahap 14 : SnackBar, Dialog, dan Loading Feedback

Pada tahap ini saya mencoba membuat beberapa jenis feedback untuk pengguna, yaitu SnackBar, AlertDialog, dan loading menggunakan CircularProgressIndicator. Saya melihat bahwa SnackBar cocok untuk memberikan informasi singkat karena tidak mengganggu aktivitas pengguna. AlertDialog digunakan ketika pengguna perlu memilih atau mengonfirmasi suatu tindakan, sedangkan loading digunakan ketika aplikasi sedang menjalankan proses dan pengguna perlu menunggu. Saya juga mencoba penggunaan ScaffoldMessenger untuk menampilkan SnackBar dan mounted setelah proses await. Dari percobaan ini saya memahami bahwa feedback pada aplikasi perlu disesuaikan dengan kondisi dan jenis informasi yang ingin disampaikan kepada pengguna.

Tahap 14.5 (DEBUG) : Refactoring + Perbaikan BUG

Sebelum Tahap 15, Pada tahap 14.5 (DEBUG) saya melakukan refactoring main.dart untuk menyiapkan shared state favorite (via ValueNotifier<Set<String>>), memperbaiki ripple InkWell yang tertutup warna putih di dalam AppCard (via Material(type: MaterialType.transparency)), dan menjaga state tab saat layout berubah compact↔expanded (satu Scaffold + ValueKey('content')). Saya juga menambahkan PopScope(canPop: false) pada dialog loading agar tombol back Android tidak menutupnya lebih awal. Duplikasi seperti header identitas, kartu, style button, dan baris info digabung menjadi helper (go, showMsg, filled, outlined, ScrollPage, InfoRow, RuleRow, ruleCard). Hasilnya main.dart menyusut dari ~2500 menjadi ~1650 baris, dan fondasi untuk Tahap 15 (Mini Project Integrasi) sudah siap.

Tahap 15: Mini Project

Pada Tahap 15 saya menyelesaikan Mini Project Integrasi berupa aplikasi Responsive Course Explorer yang menggabungkan konsep dari Tahap 1–14. Aplikasi memiliki 3 tab utama, yaitu Home, Courses, dan Profile. Navigasinya dibuat responsif, menggunakan NavigationBar pada layar kecil dan NavigationRail pada layar lebar.

Pada tab Home terdapat IdentityCard, Mini Quiz, daftar Favorite, dan menu untuk mengakses Tahap 1–14. Pada tab Courses saya menambahkan filter berdasarkan status course dan Favorite. Saya juga menambahkan fitur long-press pada course untuk menghapus Favorite melalui dialog konfirmasi.

Pada halaman detail course terdapat informasi course, progress berdasarkan status, tombol untuk menyalin kode course, dan fitur tambah atau hapus Favorite. Sedangkan pada Profile terdapat informasi mahasiswa, statistik, About Me, About Application, dan daftar Favorite.

Untuk state yang digunakan bersama beberapa bagian aplikasi, saya menggunakan ValueNotifier seperti favorites, quizScore, dan courseFilter. Dengan cara ini, perubahan data Favorite, nilai Quiz, dan filter dapat langsung diperbarui pada bagian aplikasi yang membutuhkan. Warna utama aplikasi tetap menggunakan biru dengan aksen hijau. Seluruh fitur dari Tahap 1–14 juga masih dapat diakses melalui menu di Home, dan project tetap menggunakan package yang sama tanpa menambahkan package baru.

Struktur Aplikasi Responsive Course Explorer

Responsive Course Explorer
│
├── MaterialApp
│   └── MainShellPage
│       ├── LayoutBuilder
│       │   ├── Layar kecil/sedang
│       │   │   ├── NavigationBar
│       │   │   └── IndexedStack
│       │   │
│       │   └── Layar lebar
│       │       ├── NavigationRail
│       │       └── IndexedStack
│       │
│       └── Menu:
│           ├── Home
│           ├── Courses
│           └── Profile
│
├── Home
│   ├── Identitas Mahasiswa
│   ├── Mini Quiz
│   ├── Daftar Course Favorite
│   └── Menu Tahap 1–14
│
├── Courses
│   ├── Identitas Mahasiswa
│   ├── Filter Course
│   │   ├── Semua
│   │   ├── Selesai
│   │   ├── Berjalan
│   │   ├── Belum
│   │   └── Favorite
│   │
│   └── Grid Course
│       ├── 1 kolom → layar kecil
│       ├── 2 kolom → layar sedang
│       └── 3 kolom → layar lebar
│           │
│           └── CourseCard
│               ├── Tap → Detail Course
│               └── Long Press → Favorite
│
├── Profile
│   ├── Identitas Mahasiswa
│   ├── Statistik
│   ├── Informasi Mahasiswa
│   ├── About Me
│   ├── About Application
│   └── Daftar Favorite
│
└── Halaman Detail
    ├── CourseDetailPage
    │   ├── Informasi Course
    │   ├── Progress
    │   ├── Deskripsi
    │   ├── Identitas Mahasiswa
    │   ├── Salin Kode Course
    │   └── Tambah/Hapus Favorite
    │
    └── DetailPage
        ├── Identitas Mahasiswa
        └── Tombol Kembali
```

Struktur Direktori Project

responsive_course_explorer/
│
├── lib/
│   ├── main.dart                     ← file utama (semua kode Tahap 1–15)
│   └── quiz_data.dart                ← data soal Mini Quiz (terpisah)
│
├── assets/
│   ├── data/
│   │   └── student_data.json         ← data mahasiswa + courses (dari Worksheet Pertemuan 4)
│   └── images/
│       └── profile.jpg               ← foto profil mahasiswa
│
├── android/                          ← folder bawaan Flutter
├── ios/
├── web/
├── linux/
├── macos/
├── windows/
│
├── test/                             ← (opsional) unit test
├── pubspec.yaml                      ← konfigurasi dependency + asset
├── pubspec.lock
├── analysis_options.yaml
├── .gitignore
└── README.md

Data Mini Quiz. Pada tahap ini saya tetap menggunakan 20 soal lama yang membahas materi umum Flutter dan Dart. Kemudian saya menambahkan 22 soal baru yang disesuaikan dengan materi Worksheet Pertemuan 5.

Soal tambahan tersebut terdiri dari 10 soal tentang Responsive Layout, 5 soal tentang Navigation, dan 7 soal tentang User Interaction. Materinya mencakup MediaQuery, LayoutBuilder, breakpoint, Expanded, Flexible, Wrap, SingleChildScrollView, Navigator.push/pop, NavigationBar, NavigationRail, InkWell, GestureDetector, validasi form, SnackBar, AlertDialog, dan CircularProgressIndicator.

Dengan penambahan tersebut, jumlah soal Mini Quiz menjadi 42 soal. Format data tetap menggunakan {q, options, answer} agar masih sesuai dengan struktur yang dibaca oleh MiniQuizCard.

Tahap 16 : Debugging Challenge

Pada Tahap 16 saya mengerjakan empat kasus debugging, yaitu RenderFlex overflow, unbounded height, keyboard overflow, dan navigasi ganda. Setiap kasus dibuat dalam versi BUG dan FIXED yang dapat dipilih melalui switch di AppBar, sehingga perbedaan antara error dan perbaikannya bisa dilihat langsung.

Pada Kasus A, Text yang terlalu panjang di dalam Row menyebabkan RenderFlex overflowed. Setelah Text dibungkus dengan Expanded, lebar Text menyesuaikan sisa ruang yang tersedia sehingga teks dapat turun ke baris berikutnya.

Pada Kasus B, ListView yang langsung berada di dalam Column menyebabkan error Vertical viewport was given unbounded height karena ListView tidak mendapatkan batas tinggi yang jelas. Solusinya adalah menggunakan Expanded agar ListView mengisi ruang yang tersedia. Saya juga menemukan beberapa error lanjutan seperti RenderBox was not laid out dan Cannot hit test a render box that has never been laid out, sehingga layar sempat tidak bisa menerima sentuhan. Untuk kebutuhan demo, saya menggunakan IgnorePointer agar switch tetap dapat digunakan.

Pada Kasus C, form yang berada di bagian bawah layar mengalami overflow ketika keyboard muncul karena tinggi area body menjadi lebih kecil. Solusinya menggunakan SingleChildScrollView sehingga halaman dapat digeser dan field yang sedang digunakan tetap dapat terlihat.

Pada Kasus D, menekan tombol beberapa kali dapat menyebabkan Navigator.push() dipanggil berkali-kali sehingga halaman tujuan menumpuk. Saya mengatasinya dengan flag _busy dan menonaktifkan tombol selama proses navigasi berlangsung. Pola ini juga dapat digunakan pada tombol submit atau proses lain agar tidak terjadi aksi ganda.

Dari tahap ini saya memahami bahwa banyak masalah layout Flutter berkaitan dengan constraint, yaitu bagaimana ukuran diberikan dari parent ke child. Sedangkan untuk mencegah aksi yang dilakukan berkali-kali, diperlukan pengaturan state agar proses hanya dapat berjalan satu kali pada waktu yang sama.

Tahap 17 : Checkpoint Git dan Pengumpulan

Saya menginisialisasi repository GitHub sejak Tahap 1 dan melakukan commit + push setiap tahap, sehingga riwayat Git tersusun rapi dari Tahap 1 hingga Tahap 17 (17 commit) dengan pesan bermakna yang mencerminkan progres praktikum. Commit terakhir 313ba72 di branch main menjadi checkpoint final praktikum.

echo "2415051068 - I Kadek Dwi Bajaskara"
2415051068 - I Kadek Dwi Bajaskara

**Responsive Course Explorer**
Worksheet Pertemuan 5 — Responsive Layout, Navigation & User Interaction.

**Nama:** I Kadek Dwi Bajaskara  
**NIM:** 2415051068  
**Kelas:** PTI 5A  
**Tanggal:** 29 September 2026

## Fitur
- Responsive layout (MediaQuery, LayoutBuilder, breakpoint)
- Navigation (push/pop, passing data, adaptive shell)
- User interaction (InkWell, GestureDetector, Form, SnackBar, Dialog, Loading)
- Mini Project Integrasi: Responsive Course Explorer
- Debugging Challenge (4 kasus)

## Cara Jalankan
```bash
flutter pub get
flutter run