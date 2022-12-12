import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
              actions: [
                Tooltip(
                  message: 'Search for paper',
                  waitDuration: const Duration(milliseconds: 400),
                  child: IconButton(
                    onPressed: Actions.handler<SearchForPaperIntent>(
                      context,
                      const SearchForPaperIntent(),
                    ),
                    icon: const Icon(Icons.search_rounded),
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
                                          icon: const Icon(
                                            Icons.delete_forever_outlined,
                                            size: 36,
                                          ),
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
              child: const Icon(Icons.add),
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
}
