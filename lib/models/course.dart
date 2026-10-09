class Course {
  final String code;
  final String title;
  final int credits;
  final String status;
  final String description;
  final String dosen;

  const Course({
    required this.code,
    required this.title,
    required this.credits,
    required this.status,
    this.description = '',
    this.dosen = '-',
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      code: (json['code'] ?? '') as String,
      title: (json['title'] ?? 'Tanpa Judul') as String,
      credits: _asInt(json['credits']),
      status: (json['status'] ?? 'planned') as String,
      description: (json['description'] ?? '') as String,
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