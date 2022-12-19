import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../models/book.dart';

class BooksService {
  Isar isar = Get.find();

  List<Book> getAllSync() {
    return isar.books.where().findAllSync();
  }

  Future<List<Book>> getAll() {
    return isar.books.where().findAll();
  }

  Book? getSync(int bookId) {
    return isar.books.getSync(bookId);
  }

  Future<Book?> get(int bookId) {
    return isar.books.get(bookId);
  }

  int putSync(Book book) {
    book.createdAt = DateTime.now();
    book.updatedAt = DateTime.now();
    return isar.writeTxnSync(() => isar.books.putSync(book));
  }

  Future<int> put(Book book) {
    book.createdAt = DateTime.now();
    book.updatedAt = DateTime.now();
    return isar.writeTxn(() async => await isar.books.put(book));
  }

  void updateSync(Book book) {
    book.updatedAt = DateTime.now();
    return isar.writeTxnSync(() => isar.books.putSync(book));
  }

  bool removeSync(int bookId) {
    return isar.writeTxnSync(() => isar.books.deleteSync(bookId));
  }

  Future<bool> remove(int bookId) {
    return isar.writeTxn(() async => await isar.books.delete(bookId));
  }
}
