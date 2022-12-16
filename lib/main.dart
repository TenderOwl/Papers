import 'dart:io';

import 'package:adwaita/adwaita.dart';
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

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.system);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    if (Platform.isLinux) {
      return ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (_, ThemeMode currentMode, __) {
          return MaterialApp.router(
              theme: AdwaitaThemeData.light(),
              darkTheme: AdwaitaThemeData.dark(),
              debugShowCheckedModeBanner: false,
              routerConfig: router,
              themeMode: currentMode);
        },
      );
    } else {
      return MaterialApp.router(
        title: 'Papers',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // colorSchemeSeed: const Color(0xFF672024),
          colorSchemeSeed: const Color(0xff335763),
          textTheme: GoogleFonts.ibmPlexSansTextTheme(),
        ),
        darkTheme: ThemeData(
          backgroundColor: Colors.black,
          colorSchemeSeed: const Color(0xff335763),
          textTheme: GoogleFonts.ibmPlexSansTextTheme(),
        ),
        themeMode: ThemeMode.dark,
        routerConfig: router,
      );
    }
  }
}

Future initServices() async {
  Isar isar = await Isar.open([BookSchema, PaperSchema]);
  Get.put(isar);
  Get.put(BooksService());
  Get.put(PapersService());
}
