import 'package:flutter/material.dart';

class ScrollPage extends StatelessWidget {
  final List<Widget> children;

  const ScrollPage(this.children, {super.key});

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
            16, 16, 16, 24 + MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
      );
}