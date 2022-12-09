import 'package:isar/isar.dart';

part 'book.g.dart';

@collection
class Book {
  Id? id = Isar.autoIncrement;
  String? title;
  String description;
  bool encrypted = false;

  late DateTime createdAt = DateTime.now();
  late DateTime updatedAt;

  Book({required this.description, this.id, this.title});
}
