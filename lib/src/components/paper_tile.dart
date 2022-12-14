import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

import '../models/paper.dart';

class PaperTile extends StatelessWidget {
  const PaperTile({super.key, required this.paper, this.onTap});

  final Paper paper;
  final void Function(int? bookId)? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          print('Paper with id ${paper.id} clicked');
          onTap != null ? onTap!(paper.id) : null;
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineIcon.bookOpen(size: 32),
              ),
              Flexible(
                child: Text(
                  paper.title ?? paper.content.substring(0, 10),
                  // overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
