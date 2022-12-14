import 'package:flutter/material.dart';
import 'package:line_icons/line_icon.dart';

import '../models/book.dart';

class BookTile extends StatelessWidget {
  const BookTile({super.key, required this.book, this.onTap});

  final Book book;
  final void Function(int? bookId)? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap == null ? onTap!(book.id) : null,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: LineIcon.book(),
              ),
              Text(book.title),
            ],
          ),
        ),
      ),
    );
  }
}
