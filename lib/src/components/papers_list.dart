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
  final void Function(Paper paper)? onPaperTap;
  final void Function(int paperId)? onDeletePaper;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: papers?.length,
      itemBuilder: (context, index) {
        final paper = papers![index];
        return ListTile(
          dense: true,
          title: Text(
            paper.title ?? "",
            overflow: TextOverflow.ellipsis,
            softWrap: false,
          ),
          onTap: onPaperTap != null ? () => onPaperTap!(paper) : null,
        );
      },
    );
  }
}
