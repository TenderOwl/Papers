import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../models/book.dart';

class BooksService {
  Isar isar = Get.find();

  List<Book> getAllSync() {
    return isar.books.where().findAllSync();
  }

  Book? getSync(int bookId) {
    return isar.books.getSync(bookId);
  }

  int putSync(Book book) {
    book.createdAt = DateTime.now();
    book.updatedAt = DateTime.now();
    return isar.writeTxnSync(() => isar.books.putSync(book));
  }

  void updateSync(Book book) {
    book.updatedAt = DateTime.now();
    return isar.writeTxnSync(() => isar.books.putSync(book));
  }

  bool removeSync(int bookId) {
    return isar.books.deleteSync(bookId);
  }
}
