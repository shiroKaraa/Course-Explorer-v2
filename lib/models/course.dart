class Course {
  final int? id; // TAMBAHAN: Nullable karena data lokal (asset JSON) belum tentu punya ID
  final String code;
  final String title;
  final int credits;
  final String status;
  final String description;
  final String dosen;

  const Course({
    this.id,
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
    this.description = '',
    this.dosen = '-',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    // Karena JSONPlaceholder tidak punya field 'code', kita buat tiruannya dari ID.
    // Jika ada field 'code' (misal dari API dosen), gunakan itu.
    final rawId = json['id'];
    final id = rawId is int ? rawId : int.tryParse(rawId?.toString() ?? '');
    
    final code = json['code'] as String? ?? 'POST-${id ?? 'X'}';

    return Course(
      id: id,
      code: code,
      title: (json['title'] ?? 'Tanpa Judul') as String,
      // JSONPlaceholder tidak punya 'credits', kita beri default 2
      credits: _asInt(json['credits'] ?? 2), 
      // JSONPlaceholder tidak punya 'status', kita beri default 'planned'
      status: (json['status'] ?? 'planned') as String,
      // JSONPlaceholder punya 'body', kita map ke 'description'
      description: (json['description'] ?? json['body'] ?? '') as String,
      dosen: (json['dosen'] ?? '-') as String,
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'credits': credits,
        'status': status,
        'description': description,
        'dosen': dosen,
      };

  bool get isDone => status == 'done';
  bool get isActive => status == 'active';

  double get progress {
    switch (status) {
      case 'done':
        return 1.0;
      case 'active':
        return 0.5;
      default:
        return 0.0;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'done':
        return 'Selesai';
      case 'active':
        return 'Berjalan';
      default:
        return 'Belum';
    }
  }

  String get summary => '$code • $credits SKS';
}