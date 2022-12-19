import 'package:flutter/material.dart';

import '../models/paper.dart';

class PapersList extends StatelessWidget {
  const PapersList({
    super.key,
    this.papers,
    this.onPaperTap,
    this.onDeletePaper,
  });

  final List<Paper>? papers;
  final void Function(int paperId)? onPaperTap;
  final void Function(int paperId)? onDeletePaper;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: papers?.length,
      itemBuilder: (context, index) {
        final paper = papers![index];
        return ListTile(
          title: Text(paper.title ?? ""),
          onTap: onPaperTap != null ? () => onPaperTap!(paper.id) : null,
        );
      },
    );
  }
}
