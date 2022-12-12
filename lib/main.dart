import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isar/isar.dart';
import 'package:papers/src/models/book.dart';
import 'package:papers/src/models/paper.dart';
import 'package:papers/src/services/books_service.dart';
import 'package:papers/src/services/papers_service.dart';

import 'src/router.dart';

void main() async {
  await initServices();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Papers',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorSchemeSeed: const Color(0xFF672024),
        colorSchemeSeed: const Color(0xff335763),
        textTheme: GoogleFonts.ibmPlexSansTextTheme(),
      ),
      routerConfig: router,
    );
  }
}

Future initServices() async {
  Isar isar = await Isar.open([BookSchema, PaperSchema]);
  Get.put(isar);
  Get.put(BooksService());
  Get.put(PapersService());
}
