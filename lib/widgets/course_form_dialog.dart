import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormDialog extends StatefulWidget {
  const CourseFormDialog({super.key});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _codeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _creditsCtrl = TextEditingController();
  String _status = 'planned';

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _creditsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final course = Course(
      code: _codeCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      credits: int.tryParse(_creditsCtrl.text.trim()) ?? 0,
      status: _status,
    );

    final provider = context.read<CourseProvider>();
    final ok = await provider.addCourse(course);

    if (!mounted) return;

    if (ok) {
      Navigator.pop(context, true);   // ← return true ke pemanggil
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal: ${provider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CourseProvider>().isSaving;

    return AlertDialog(
      title: const Text('Tambah Course'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeCtrl,
                decoration: const InputDecoration(labelText: 'Kode (misal: MOB01)'),
                validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              gap(10),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Nama Course'),
                validator: (v) => v!.trim().isEmpty ? 'Wajib diisi' : null,
              ),
              gap(10),
              TextFormField(
                controller: _creditsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'SKS'),
                validator: (v) {
                  if (v!.trim().isEmpty) return 'Wajib diisi';
                  final n = int.tryParse(v.trim());
                  if (n == null || n <= 0) return 'Harus angka positif';
                  return null;
                },
              ),
              gap(10),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(labelText: 'Status'),
                items: const [
                  DropdownMenuItem(value: 'planned', child: Text('Belum')),
                  DropdownMenuItem(value: 'active', child: Text('Berjalan')),
                  DropdownMenuItem(value: 'done', child: Text('Selesai')),
                ],
                onChanged: (val) => setState(() => _status = val!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving ? null : () => Navigator.pop(context, false),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: isSaving ? null : _submit,
          style: filled(AppColors.primary, pad: 10),
          child: isSaving
              ? const SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}