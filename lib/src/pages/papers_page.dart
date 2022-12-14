import 'dart:convert' show LineSplitter, jsonEncode, utf8;
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
import 'package:path/path.dart' show basenameWithoutExtension;

import '../actions/dispatcher.dart';
import '../actions/search_for_paper.dart';
import '../components/paper_tile.dart';
import '../components/search_papers_dialog.dart';
import '../models/paper.dart';
import '../services/papers_service.dart';

class PapersPage extends StatefulWidget {
  const PapersPage({super.key});

  @override
  State<PapersPage> createState() => _PapersPageState();
}

class _PapersPageState extends State<PapersPage> {
  PapersService papersService = Get.find();
  List<Paper> papers = [];

  @override
  void initState() {
    super.initState();
    reloadPapers();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    reloadPapers();
  }

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
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: papers
                          .map(
                            (paper) => SizedBox(
                              width: 120,
                              height: 120,
                              child: ContextMenuRegion(
                                contextMenu: GenericContextMenu(
                                  injectDividers: true,
                                  buttonConfigs: [
                                    ContextMenuButtonConfig("Export",
                                        onPressed: () {}),
                                    ContextMenuButtonConfig("Archive",
                                        onPressed: () {}),
                                    ContextMenuButtonConfig("Delete",
                                        onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text('Delete Paper?'),
                                          content: const Text(
                                            'Paper will be deleted permanently.\nThis action cannot be undone.',
                                          ),
                                          icon: LineIcon.trash(size: 36),
                                          iconColor: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          actions: [
                                            TextButton(
                                              child: const Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                            TextButton(
                                              child: const Text('Delete'),
                                              onPressed: () {
                                                deletePaper(paper.id);
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    }),
                                  ],
                                ),
                                child: PaperTile(
                                  paper: paper,
                                  onTap: (paperId) {
                                    context.pushNamed(
                                      'paperPage',
                                      params: {'paperId': paperId.toString()},
                                    );
                                  },
                                ),
                              ),
                            ),
                          )
                          .toList(),
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

  void reloadPapers() {
    setState(() {
      papers = papersService.getAllSync();
    });
  }

  void deletePaper(int paperId) {
    papersService.delete(paperId).then((value) => reloadPapers());
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

      reloadPapers();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot get that file'),
          ),
        );
      }
    }
  }
}
