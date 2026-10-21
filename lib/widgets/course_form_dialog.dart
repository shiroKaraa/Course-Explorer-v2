import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/app_colors.dart';
import '../core/ui_helpers.dart';
import '../models/course.dart';
import '../providers/course_provider.dart';

class CourseFormDialog extends StatefulWidget {
  final Course? initialCourse;

  const CourseFormDialog({super.key, this.initialCourse});

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _titleCtrl;
  late final TextEditingController _creditsCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _dosenCtrl;
  late String _status;

  bool get isEditMode => widget.initialCourse != null;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCourse;
    _codeCtrl = TextEditingController(text: c?.code ?? '');
    _titleCtrl = TextEditingController(text: c?.title ?? '');
    _creditsCtrl = TextEditingController(
      text: c == null ? '' : c.credits.toString(),
    );
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _dosenCtrl = TextEditingController(
      text: (c == null || c.dosen == '-') ? '' : c.dosen,
    );
    _status = c?.status ?? 'planned';
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _creditsCtrl.dispose();
    _descCtrl.dispose();
    _dosenCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final course = Course(
      id: widget.initialCourse?.id,
      code: _codeCtrl.text.trim(),
      title: _titleCtrl.text.trim(),
      credits: int.tryParse(_creditsCtrl.text.trim()) ?? 0,
      status: _status,
      description: _descCtrl.text.trim(),
      dosen: _dosenCtrl.text.trim().isEmpty ? '-' : _dosenCtrl.text.trim(),
    );

    final provider = context.read<CourseProvider>();
    final ok = isEditMode
        ? await provider.editCourse(course)
        : await provider.addCourse(course);

    if (!mounted) return;

    Navigator.pop(context, ok);
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = context.watch<CourseProvider>().isSaving;

    return AlertDialog(
      title: Text(isEditMode ? 'Edit Course' : 'Tambah Course'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _codeCtrl,
                readOnly: isEditMode,
                decoration: InputDecoration(
                  labelText: 'Kode (misal: MOB01)',
                  fillColor: isEditMode ? Colors.grey.shade200 : null,
                  filled: isEditMode,
                ),
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
              TextFormField(
                controller: _dosenCtrl,
                decoration: const InputDecoration(
                  labelText: 'Dosen (opsional)',
                ),
              ),
              gap(10),
              TextFormField(
                controller: _descCtrl,
                decoration: const InputDecoration(
                  labelText: 'Deskripsi (opsional)',
                ),
                maxLines: 2,
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
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Simpan'),
        ),
      ],
    );
  }
}