import 'dart:convert';
import 'dart:io';

import 'package:context_menus/context_menus.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:line_icons/line_icon.dart';
import 'package:path/path.dart' show basenameWithoutExtension;

import '../components/papers_grid.dart';
import '../components/papers_list.dart';
import '../actions/dispatcher.dart';
import '../actions/search_for_paper.dart';
import '../components/search_papers_dialog.dart';
import '../models/paper.dart';
import '../services/papers_service.dart';

enum ViewMode { grid, list }

class PapersPage extends StatefulWidget {
  const PapersPage({super.key, this.bookId = 0});

  final int bookId;

  @override
  State<PapersPage> createState() => _PapersPageState();
}

class _PapersPageState extends State<PapersPage> {
  PapersService papersService = Get.find();
  List<Paper> papers = [];
  ViewMode viewMode = ViewMode.grid;
  bool dragging = false;

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
            body: DropTarget(
              onDragEntered: (details) => setState(() {
                dragging = true;
              }),
              onDragExited: (details) => setState(() {
                dragging = false;
              }),
              onDragDone: (details) {
                dragging = false;
                for (var file in details.files) {
                  importFile(file.path);
                }
                setState(() {});
              },
              child: Container(
                width: double.maxFinite,
                height: double.maxFinite,
                child: ContextMenuOverlay(
                  child: SafeArea(
                    child: StreamBuilder<void>(
                      stream: papersService.isar.papers.watchLazy(),
                      builder: (context, snapshot) {
                        return FutureBuilder(
                          future: papersService.getAll(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              final papers = snapshot.data;
                              return Stack(
                                children: [
                                  viewMode == ViewMode.grid
                                      ? PapersGrid(
                                          papers: papers,
                                          onPaperTap: onPaperTap,
                                          onDeletePaper: deletePaper,
                                        )
                                      : PapersList(
                                          papers: papers,
                                          onPaperTap: onPaperTap,
                                          onDeletePaper: deletePaper,
                                        ),
                                  if (dragging)
                                    Container(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withAlpha(30),
                                      child: const Center(
                                        child:
                                            Text('Drop files here to import'),
                                      ),
                                    ),
                                ],
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
    FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['txt', 'md', 'rst']);

    if (result == null) return;

    for (var file in result.files) {
      importFile(file.path!);
    }
  }

  Future importFile(String path) async {
    print('importFile  $path');
    try {
      final file = File(path);
      if (!await file.exists()) return;

      final delta = quill.Delta();
      for (var line in await file.readAsLines()) {
        delta.insert('$line\n');
      }

      // final doc = quill.Document.fromDelta(delta);

      final paper = Paper(
        bookId: widget.bookId,
        content: jsonEncode(delta.toJson()),
        title: basenameWithoutExtension(file.path),
      );

      await papersService.put(paper);
    } catch (e) {
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
