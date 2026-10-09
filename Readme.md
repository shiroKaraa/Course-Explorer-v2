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