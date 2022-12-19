import 'dart:convert';
import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:papers/src/components/papers_list.dart';
import 'package:path/path.dart' show basenameWithoutExtension;

import '../components/papers_grid.dart';
import '../actions/dispatcher.dart';
import '../actions/search_for_paper.dart';
import '../components/search_papers_dialog.dart';
import '../models/paper.dart';
import '../services/papers_service.dart';

enum ViewMode { grid, list }

class PapersPage extends StatefulWidget {
  const PapersPage({super.key});

  @override
  State<PapersPage> createState() => _PapersPageState();
}

class _PapersPageState extends State<PapersPage> {
  PapersService papersService = Get.find();
  List<Paper> papers = [];
  ViewMode viewMode = ViewMode.grid;

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyK, control: true):
            SearchForPaperIntent(),
      },
      child: Actions(
        dispatcher: LoggingActionDispatcher(),
        actions: <Type, Action<Intent>>{
          SearchForPaperIntent: SearchForPaperAction(context)
        },
        child: Builder(builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                'Papers',
                style: GoogleFonts.comfortaa(),
              ),
              centerTitle: true,
              elevation: 0,
              leading: Padding(
                padding: EdgeInsets.only(left: Platform.isMacOS ? 82.0 : 12.0),
                child: Tooltip(
                  message: 'Import file',
                  waitDuration: const Duration(milliseconds: 400),
                  child: IconButton(
                    onPressed: onImportMarkdown,
                    icon: LineIcon.fileImport(),
                    splashRadius: 24,
                  ),
                ),
              ),
              leadingWidth: Platform.isMacOS ? 128 : 56,
              actions: [
                buildViewModeButton(),
                Tooltip(
                  message: 'Search for paper',
                  waitDuration: const Duration(milliseconds: 400),
                  child: IconButton(
                    onPressed: Actions.handler<SearchForPaperIntent>(
                      context,
                      const SearchForPaperIntent(),
                    ),
                    icon: LineIcon.search(),
                    splashRadius: 24,
                  ),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: ContextMenuOverlay(
              child: SafeArea(
                child: StreamBuilder<void>(
                  stream: papersService.isar.papers.watchLazy(),
                  builder: (context, snapshot) {
                    return FutureBuilder(
                      future: papersService.getAll(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final papers = snapshot.data;
                          return viewMode == ViewMode.grid
                              ? PapersGrid(
                                  papers: papers,
                                  onPaperTap: onPaperTap,
                                  onDeletePaper: deletePaper,
                                )
                              : PapersList(
                                  papers: papers,
                                  onPaperTap: onPaperTap,
                                  onDeletePaper: deletePaper,
                                );
                        } else {
                          if (snapshot.hasError) {
                            return const SizedBox.shrink();
                          } else {
                            return const Center(
                              child: CircularProgressIndicator.adaptive(),
                            );
                          }
                        }
                      },
                    );
                  },
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                context.pushNamed('paperPage', params: {'paperId': 'new'});
              },
              child: LineIcon.plus(),
            ),
          );
        }),
      ),
    );
  }

  Widget buildViewModeButton() {
    switch (viewMode) {
      case ViewMode.grid:
        return IconButton(
          onPressed: () {
            setState(() {
              viewMode = ViewMode.list;
            });
          },
          splashRadius: 24,
          icon: LineIcon.list(),
        );
      default:
        return IconButton(
          onPressed: () {
            setState(() {
              viewMode = ViewMode.grid;
            });
          },
          splashRadius: 24,
          icon: LineIcon.thLarge(),
        );
    }
  }

  void onPaperTap(int paperId) {
    context.pushNamed(
      'paperPage',
      params: {'paperId': paperId.toString()},
    );
  }

  void deletePaper(int paperId) {
    papersService.delete(paperId);
  }

  void onSearchForPaper() {
    showDialog(
      context: context,
      builder: (context) => const SearchPaperDialog(),
    );
  }

  Future onImportMarkdown() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final file = File(result.files.single.path!);
      final delta = quill.Delta();
      for (var line in await file.readAsLines()) {
        delta.insert('$line\n');
      }

      // final doc = quill.Document.fromDelta(delta);

      final paper = Paper(
        bookId: 0,
        content: jsonEncode(delta.toJson()),
        title: basenameWithoutExtension(result.files.single.path!),
      );

      await papersService.put(paper);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot get that file'),
          ),
        );
      }
    }
  }
}
