import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/legacy_globals.dart';
import '../core/ui_helpers.dart';
import '../quiz_data.dart';
import 'app_card.dart';

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