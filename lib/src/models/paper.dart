import 'package:isar/isar.dart';

part 'paper.g.dart';

@collection
class Paper {
  Id id = Isar.autoIncrement;
  int bookId;
  String? title;
  String content;
  bool encrypted = false;

  late DateTime createdAt = DateTime.now();
  late DateTime updatedAt;

  Paper({required this.bookId, required this.content, this.title});
}
