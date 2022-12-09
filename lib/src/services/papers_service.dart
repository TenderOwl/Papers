import 'package:get/get.dart';
import 'package:isar/isar.dart';

import '../models/paper.dart';

class PapersService {
  Isar isar = Get.find();

  List<Paper> getAllSync() {
    return isar.papers.where().findAllSync();
  }

  List<Paper> getByBookAllSync(int bookId) {
    return isar.papers.filter().bookIdEqualTo(bookId).findAllSync();
  }

  Paper? getSync(int paperId) {
    return isar.papers.getSync(paperId);
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

  bool removeSync(int paperId) {
    return isar.papers.deleteSync(paperId);
  }
}
