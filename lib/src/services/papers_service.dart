import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../models/paper.dart';

class PapersService {
  Isar isar = Get.find();

  List<Paper> getAllSync() {
    return isar.papers.where().findAllSync();
  }

  Future<List<Paper>> getAll() async {
    return await isar.papers.where().findAll();
  }

  List<Paper> getByBookAllSync(int bookId) {
    return isar.papers.filter().bookIdEqualTo(bookId).findAllSync();
  }

  Future<List<Paper>> getByBookAll(int bookId) async {
    return await isar.papers.filter().bookIdEqualTo(bookId).findAll();
  }

  Paper? getSync(int paperId) {
    return isar.papers.getSync(paperId);
  }

  Future<Paper?> get(int paperId) async {
    return await isar.papers.get(paperId);
  }

  Future<int> put(Paper paper) async {
    paper.updatedAt = DateTime.now();
    return isar.writeTxn(() async => await isar.papers.put(paper));
  }

  int putSync(Paper paper) {
    paper.updatedAt = DateTime.now();
    return isar.writeTxnSync(() => isar.papers.putSync(paper));
  }

  int putInBookSync(Paper paper, int bookId) {
    paper.createdAt = DateTime.now();
    paper.updatedAt = DateTime.now();
    paper.bookId = bookId;
    return isar.writeTxnSync(() => isar.papers.putSync(paper));
  }

  void updateSync(Paper paper) {
    paper.updatedAt = DateTime.now();
    return isar.writeTxnSync(() => isar.papers.putSync(paper));
  }

  bool deleteSync(int paperId) {
    return isar.writeTxnSync(() => isar.papers.deleteSync(paperId));
  }

  Future<bool> delete(int paperId) async {
    return isar.writeTxn(() async => await isar.papers.delete(paperId));
  }

  Future<List<Paper>> search(String value) async {
    return isar.papers
        .filter()
        .titleContains(value, caseSensitive: false)
        .or()
        .contentContains(value, caseSensitive: false)
        .findAll();
  }
}
