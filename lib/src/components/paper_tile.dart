import 'package:flutter/material.dart';

import '../models/paper.dart';

class PaperTile extends StatelessWidget {
  const PaperTile({super.key, required this.paper, this.onTap});

  final Paper paper;
  final void Function(int? bookId)? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: () {
            print('Paper with id ${paper.id} clicked');
            onTap != null ? onTap!(paper.id) : null;
          },
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.book_outlined),
                ),
                Text(
                  paper.content.substring(0, 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
