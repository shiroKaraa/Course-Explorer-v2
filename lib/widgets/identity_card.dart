import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_strings.dart';
import '../core/ui_helpers.dart';
import 'app_card.dart';

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