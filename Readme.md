Tahap 0 : Review Project dan Environment

Project Course Explorer dari Pertemuan 5 sudah berhasil dijalankan tanpa mengalami error. Untuk saat ini, sebagian besar kode masih berada di lib/main.dart, dengan bantuan file quiz_data.dart. NavigationBar dan NavigationRail sudah berfungsi secara responsif. Navigasi ke halaman detail course juga berjalan dengan baik, begitu pula fitur favorite yang masih menggunakan ValueNotifier sebagai penyimpanan state sementara. Identitas mahasiswa, yaitu I Kadek Dwi Bajaskara dengan NIM 2415051068, sudah ditampilkan melalui IdentityCard di beberapa halaman. Selain itu, repository GitHub sudah terhubung dan working tree dalam keadaan bersih. Dengan kondisi tersebut, project siap dilanjutkan ke tahap pembelajaran local state dan shared state.

Tahap 1 : Mengenal Local State dan Shared State

Pada tahap ini, saya mempelajari enam state yang ada pada aplikasi Course Explorer dan membaginya menjadi local state dan shared state. Local state meliputi tab aktif pada MainShellPage, progress Mini Quiz (_index, _score, _selected, _finished), pengaturan buka-tutup deskripsi pada CourseCard, serta expand/collapse deskripsi di CourseDetailPage. State tersebut menggunakan setState() karena hanya diperlukan oleh widget tertentu. Sementara itu, shared state terdiri dari favorites, quizScore, dan courseFilter yang masih menggunakan ValueNotifier karena datanya dibutuhkan di beberapa halaman dan nilainya harus tetap konsisten.

Sebagai bagian dari praktikum, saya menambahkan tombol "Detail/Tutup" pada setiap CourseCard dan tombol "Selengkapnya/Sembunyikan" di halaman detail. Saya juga menambahkan kartu "Klasifikasi State Aplikasi" pada halaman Profile untuk menjelaskan keenam state beserta alasan pengelompokannya. Dari tahap ini, saya memahami bahwa penggunaan Provider tidak selalu diperlukan untuk setiap state. Jika state hanya digunakan secara lokal, setState() sudah cukup dan membuat kode lebih sederhana.

Tahap 2 : Masalah setState() Saat Aplikasi Membesar

Saya membuat HomeDashboardPage sebagai parent yang menyimpan _favoriteCount, lalu meneruskan nilainya ke CourseSummaryTile dan FavoriteTogglePanel melalui constructor. Perubahan nilai dilakukan melalui callback onIncrement dan onDecrement. Dari percobaan ini, saya menemukan bahwa semakin banyak child yang membutuhkan state yang sama, semakin banyak parameter dan callback yang harus ditulis. Hal ini membuat kode lebih rumit, sehingga ValueNotifier atau ChangeNotifier bisa menjadi alternatif untuk mengurangi prop drilling.

Tahap 3 : Lifting State Up dan Single Source of Truth

Pada tahap ini, saya menerapkan lifting state up dengan menjadikan HomeDashboardPage sebagai satu-satunya pemilik _favoriteCount. Nilainya diteruskan ke tiga child, yaitu CourseSummaryTile, FavoriteTogglePanel, dan DashboardStatusBar. Dengan begitu, semua widget menggunakan sumber data yang sama sehingga nilainya tetap konsisten tanpa perlu sinkronisasi manual. Namun, cara ini masih membutuhkan constructor dan callback untuk meneruskan data, sehingga ValueNotifier dan ChangeNotifier bisa menjadi solusi pada tahap berikutnya.

Pada aplikasi saya, Single Source of Truth berarti nilai _favoriteCount hanya hidup di dalam _HomeDashboardPageState. Tidak ada child yang menyimpan salinan nilai ini. Semua widget yang menampilkan atau mengubahnya harus membaca atau memanggil callback ke parent tersebut. Konsekuensinya, tidak mungkin ada dua angka berbeda untuk data yang sama, dan setiap perubahan otomatis tercermin di seluruh child karena semuanya membaca dari sumber yang sama.

Tahap 4 : ValueNotifier dan ValueListenableBuilder

Saya menggunakan ValueNotifier<int> bernama favoriteCounter dan ValueListenableBuilder untuk menampilkan nilainya di tiga child. Tombol + dan − dapat mengubah nilai notifier secara langsung, sehingga widget lain ikut diperbarui tanpa callback dari parent. Kode menjadi lebih ringkas, tetapi notifier masih disimpan secara global. Karena itu, pengelolaannya akan dikembangkan menggunakan ChangeNotifier dan Provider pada tahap berikutnya.

Tahap 5 : ChangeNotifier dan notifyListeners()

Saya membuat CourseProvider dengan ChangeNotifier untuk menyimpan daftar favorite dan mengelolanya melalui method toggleFavorite(). Dengan ListenableBuilder, perubahan favorite langsung memperbarui jumlah dan ikon pada UI. Dibandingkan ValueNotifier, ChangeNotifier lebih fleksibel karena dapat mengelola beberapa state dan method dalam satu class. Namun, instance-nya masih global dan akan dikelola menggunakan Provider pada tahap berikutnya. 
notifyListeners() memberi tahu widget yang mendengarkan bahwa state telah berubah, sehingga UI dapat diperbarui. Jika tidak dipanggil, nilai state tetap berubah, tetapi tampilan tidak otomatis ikut diperbarui.

Tahap 6 : Memasang Provider Pada Widget Tree

Saya menambahkan dependency provider dan membungkus MaterialApp dengan ChangeNotifierProvider agar CourseProvider bisa diakses oleh semua halaman, termasuk halaman yang dibuka melalui navigasi. Saya juga mengubah ChangeNotifierDemoCard agar mengambil provider melalui context.read() dan menambahkan ProviderStatusCard di halaman Profile. Saat provider dihapus, muncul ProviderNotFoundException, yang menunjukkan bahwa widget memang membutuhkan provider tersebut.
Provider diletakkan di atas MaterialApp agar bisa diakses oleh semua halaman, termasuk halaman yang dibuka melalui Navigator.push. Jika provider berada di bawahnya, halaman lain mungkin tidak dapat menemukan provider dan memunculkan ProviderNotFoundException.

Tahap 7 : context.watch(), context.read(), dan Consumer

Saya mencoba context.watch, context.read, dan Consumer untuk mengakses CourseProvider. Dari percobaan ini, saya memahami bahwa watch memperbarui widget saat state berubah, read digunakan untuk memanggil method tanpa listen, sedangkan Consumer membatasi rebuild pada bagian widget tertentu. Saya juga mengamati melalui DevTools bahwa widget yang menggunakan read tidak ikut rebuild ketika favorite berubah.

Tahap 8 : Membuat Model Course

Saya membuat class Course di lib/models/course.dart untuk menampung data mata kuliah, lengkap dengan fromJson, toJson, serta getter seperti isDone dan progress. Saya juga menambahkan kartu demo di halaman Home dan perbandingan penggunaan Map dengan model di halaman Profile. Dengan model ini, tipe data lebih jelas dan parsing JSON tidak perlu dilakukan berulang kali di UI.

Tahap 9 : Service / Data Source

Saya membuat CourseService untuk menangani pembacaan JSON, mulai dari rootBundle.loadString hingga mengubah data menjadi List<Course>. Saya juga menambahkan kartu demo di Home dengan tombol "Muat Ulang" serta perbandingan di Profile. Dari tahap ini, saya memahami bahwa service memisahkan proses pengambilan data dari UI, sehingga jika sumber data berubah menjadi REST API, penyesuaian cukup dilakukan di CourseService.

Tahap 10 : Repository Pattern

Saya membuat CourseRepository sebagai kontrak pengambilan data dan CourseRepositoryImpl sebagai implementasinya yang menggunakan CourseService melalui constructor injection. Saya juga menambahkan kartu demo di Home dan perbandingan service dengan repository di Profile. Dari tahap ini, saya memahami bahwa repository menjadi perantara yang memisahkan UI dari implementasi sumber data, sehingga lebih mudah diuji dan diganti, misalnya dari JSON asset ke HTTP API.

Tahap 11 : Provider untuk Async State

Saya mengembangkan CourseProvider untuk mengelola data course, status loading, dan error menggunakan CourseRepository. Method loadCourses() mengatur proses pemuatan data dan memperbarui UI melalui notifyListeners(). Saya juga menambahkan kartu demo di Home untuk menampilkan loading, data, atau pesan error dengan tombol Retry. Dari tahap ini, saya memahami bahwa async state dapat dikelola secara terpusat dan digunakan di beberapa halaman tanpa perlu membuat FutureBuilder terpisah.

Tahap 12 : Refactor Struktur Folder

Pada tahap ini, saya merapikan struktur folder dengan menerapkan separation of concerns. File main.dart berhasil dipangkas dari 2.967 baris menjadi sekitar 40 baris, sedangkan class lainnya dipindahkan ke folder sesuai tanggung jawabnya. Setelah import diperbaiki, aplikasi tetap berjalan seperti sebelumnya. Saya juga menemukan masih ada dua sumber state favorites, yaitu ValueNotifier lama dan CourseProvider, yang akan disatukan pada tahap berikutnya.

Tahap 13 : 

Pada tahap ini, saya menyatukan state favorites ke CourseProvider sebagai satu-satunya sumber data dan menghapus ValueNotifier lama. Saya juga memperbarui fitur favorite di halaman Courses dan Detail, menambahkan tombol favorite pada CourseCard, serta membuat halaman dan tab Favorites. Hasilnya, perubahan favorite langsung konsisten di seluruh halaman tanpa perlu callback atau prop drilling.

Tahap 14 : Mini Project Integrasi: Course Explorer v2

Pada tahap ini, saya mulai mengembangkan Course Explorer v2 sebagai mini project integrasi dari materi sebelumnya. Pengerjaan dibagi menjadi beberapa bagian, dimulai dari penerapan warna emas dan migrasi data JSON ke model Course pada 14-A dan 14-B. Selanjutnya, saya akan mengembangkan halaman Gallery, memperbarui Home dan Profile, menambahkan fitur Search dan Statistik, serta animasi. Tahap ini akan diakhiri dengan dokumentasi, pengujian, dan commit final.

Tahap 14-A :

Menambahkan warna aksen emas (gold = #FFB300, goldSoft = #FFF4D6) ke AppColors sebagai persiapan untuk aksen visual Course Explorer v2 bertema Undiksha. Warna ini akan dipakai untuk highlight bintang favorite, badge prestasi, dan tombol Demo/Catatan Tahapan. Tidak ada perilaku aplikasi yang berubah; warna lama tetap dipertahankan.

Tahap 14-B :

Saya memigrasikan data dari Json ke model Course pada seluruh screen utama, sehingga field dapat diakses langsung tanpa cast manual. Saya juga memindahkan fungsi openCourse() dan confirmRemoveFavorite() ke file yang sesuai untuk menghindari circular import. Selain itu, aksen favorite diubah menjadi warna emas agar sesuai dengan tema Undiksha, dan screen utama kini mengambil data langsung dari CourseProvider.

Tahap 14-C :

Saya membuat tiga halaman baru, yaitu DemoGalleryPage, NotesGalleryPage, dan AboutPage untuk memisahkan demo, catatan, dan informasi aplikasi. Saya juga memindahkan empat kartu perbandingan ke folder notes/ agar struktur kode lebih terorganisir. Perubahan ini hanya berfokus pada penambahan halaman dan perapian struktur tanpa mengubah perilaku aplikasi.

Tahap 14-D :

Saya merombak halaman Home dan Profile agar lebih rapi dan berfokus pada fitur utama. Home kini menampilkan identitas mahasiswa, statistik course, SKS dan favorite, course terbaru, AsyncCoursesCard, serta MiniQuiz. Sementara itu, Profile berisi informasi mahasiswa, statistik, dan daftar favorite. Kartu demo dan catatan tahapan dipindahkan ke halaman terpisah agar tidak menumpuk. Saya juga menerapkan aksen emas yang dipadukan dengan warna biru dan hijau sesuai tema Undiksha.

Tahap 14-E :

Saya menambahkan fitur search pada tab Courses menggunakan TextEditingController dan setState() karena pencarian termasuk local UI state. Pencarian dapat dilakukan berdasarkan nama atau kode course, serta digunakan bersamaan dengan filter status. Saya juga menambahkan tombol clear dan empty state yang berbeda untuk hasil pencarian atau filter kosong. Fitur lama seperti favorite dan navigasi detail tetap berjalan normal.

Tahap 14-F :

Saya menambahkan animasi fade-in dan slide-up pada elemen Home, animasi membesar pada tombol favorite, serta transisi halus saat deskripsi course dibuka atau ditutup. Semua animasi menggunakan durasi singkat dan Curves.easeOut agar terasa lebih natural.

Saya tetap menggunakan IndexedStack di MainShellPage supaya state setiap tab, seperti search query, tidak hilang saat berpindah tab. Animasi dibuat secukupnya agar aplikasi terasa lebih halus tanpa berlebihan.

Tahap 14- G :

# Course Explorer v2

Aplikasi eksplorasi course yang dibangun sebagai **Mini Project Praktikum Pemrograman Mobile Pertemuan 6**. Menerapkan **State Management** dan **Mobile Application Architecture** bertingkat dengan pola Provider → Repository → Service.


## 🏗️ Arsitektur

Aplikasi menerapkan **separation of concerns** dengan lima layer:

```
   UI (Screens & Widgets)
        │
        ▼
   Provider (CourseProvider)
        │
        ▼
   Repository (CourseRepository)
        │
        ▼
   Service (CourseService)
        │
        ▼
   Data Source (JSON Asset)
```


## 📁 Struktur Folder

```
lib/
├── main.dart                          # Entry point + wiring Provider
├── quiz_data.dart                     # Data soal Mini Quiz
│
├── core/                              # Fondasi: konstanta & helper
│   ├── app_colors.dart                # Palet warna (Undiksha + emas)
│   ├── app_strings.dart               # Identitas & judul aplikasi
│   ├── di.dart                        # Dependency Injection sederhana
│   ├── legacy_globals.dart            # Legacy state (quizScore, courseFilter)
│   └── ui_helpers.dart                # Helper UI (ts, gap, section, dll.)
│
├── models/                            # Model data
│   └── course.dart                    # Class Course + fromJson
│
├── services/                          # Detail teknis data access
│   └── course_service.dart            # Baca JSON, parse, return List<Course>
│
├── repositories/                      # Abstraksi sumber data
│   └── course_repository.dart         # Interface + implementasi
│
├── providers/                         # State management
│   └── course_provider.dart           # ChangeNotifier untuk courses & favorites
│
├── widgets/                           # Widget reusable
│   ├── app_card.dart                  # Kartu umum
│   ├── course_card.dart               # Kartu course (typed Course)
│   ├── demo_scaffold.dart             # Scaffold standar
│   ├── fade_in.dart                   # Animasi fade-in reusable
│   ├── identity_card.dart             # Kartu identitas mahasiswa
│   ├── info_card.dart                 # Kartu info (row-based)
│   ├── mini_quiz_card.dart            # Kartu Mini Quiz
│   ├── scroll_page.dart               # Wrapper untuk SingleChildScrollView
│   └── status_helper.dart             # Helper status (warna, ikon, badge)
│
├── screens/                           # Halaman utama
│   ├── main_shell_page.dart           # Shell dengan 4 tab responsif
│   ├── home_tab_page.dart             # Tab Home
│   ├── course_grid_page.dart          # Tab Courses (dengan search & filter)
│   ├── favorites_page.dart            # Tab Favorites
│   ├── profile_tab_page.dart          # Tab Profile
│   ├── course_detail_page.dart        # Halaman detail course
│   ├── demo_gallery_page.dart         # Gallery kartu demo Tahap 2–11
│   ├── notes_gallery_page.dart        # Gallery catatan perbandingan
│   └── about_page.dart                # Halaman tentang aplikasi
│
├── demos/                             # Kartu demo per tahap
│   ├── tahap_2_3_demo.dart            # Prop drilling & lifting state
│   ├── tahap_4_demo.dart              # ValueNotifier
│   ├── tahap_5_6_7_demo.dart          # ChangeNotifier, Provider, watch/read/Consumer
│   ├── tahap_8_demo.dart              # Model Course
│   ├── tahap_9_demo.dart              # CourseService
│   ├── tahap_10_demo.dart             # CourseRepository
│   └── tahap_11_demo.dart             # Async State
│
└── notes/                             # Kartu catatan perbandingan
    ├── state_classification_card.dart
    ├── prop_drilling_note_card.dart
    ├── lifting_state_up_note_card.dart
    ├── value_notifier_comparison_card.dart
    ├── change_notifier_comparison_card.dart
    ├── provider_status_card.dart
    ├── provider_patterns_comparison_card.dart
    ├── course_model_comparison_card.dart
    ├── course_service_comparison_card.dart
    ├── course_repository_comparison_card.dart
    └── async_state_comparison_card.dart
```

## 🚀 Cara Menjalankan

### syarat

- Flutter SDK **3.13.2** atau lebih baru.
- Dart SDK **3.0.0** atau lebih baru.
- Emulator Android / iOS / Chrome, atau device fisik.

### Langkah

1. **Clone repository:**
   ```bash
   git clone <https://github.com/shiroKaraa/Course-Explorer-v2/blob/main/lib/main.dart#L2967>
   cd course_explorer_v2
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Jalankan aplikasi:**
   ```bash
   flutter run
   ```

### Build untuk Production

```bash
# Android APK
flutter build apk --release

# Web
flutter build web --release

# iOS (hanya di macOS)
flutter build ios --release
```

## 🧪 Pengujian

```bash
# Analisis statis
flutter analyze

# Unit test (kalau ada)
flutter test
```


## 👤 Author

**I Kadek Dwi Bajaskara**  
NIM: 2415051068  
Kelas: PTI 5A  
Program Studi Pendidikan Teknik Informatika  
Universitas Pendidikan Ganesha

CATATAN :
Saya membuat README.md sebagai dokumentasi utama Course Explorer v2 yang berisi deskripsi aplikasi, identitas mahasiswa, fitur, arsitektur, struktur folder, cara menjalankan, riwayat Tahap 0–17, dan teknologi yang digunakan.

Saya juga memeriksa .gitignore agar file sensitif dan build artifacts tidak ikut ter-commit, serta memastikan deskripsi di pubspec.yaml tetap singkat dan sesuai. Dokumentasi ini memudahkan dosen atau asisten memahami proyek sekaligus melihat perkembangan pembelajaran dari setiap tahap.

Tahap 14-H :

Saya menyelesaikan integrasi utama Course Explorer v2 dan membuat commit yang mencakup seluruh perubahan Tahap 14-A sampai 14-G. Perubahan meliputi migrasi ke model Course, penambahan halaman Demo Gallery, Notes Gallery, dan About, perombakan Home & Profile, fitur search, serta animasi halus.

Fitur utama telah diperiksa melalui checklist, termasuk identity, favorites, search, filter, async state, dan navigasi. Tahap 14-H bukan akhir pengembangan, melainkan penutup tahap integrasi awal. Selanjutnya, proyek akan memasuki tahap Debugging untuk memperbaiki bug dan melakukan penyesuaian atau penambahan fitur jika diperlukan, sebelum melanjutkan ke Audit Architecture.

