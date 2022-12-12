import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/paper_tile.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Papers',
          style: GoogleFonts.comfortaa(),
        ),
        elevation: 0,
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
                            buttonConfigs: [
                              ContextMenuButtonConfig("Export",
                                  onPressed: () {}),
                              ContextMenuButtonConfig("Archive",
                                  onPressed: () {}),
                              ContextMenuButtonConfig("Delete", onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Paper'),
                                    content: const Text(
                                      'Paper will be deleted permanently.\nThis action cannot be undone.',
                                    ),
                                    icon: const Icon(
                                        Icons.delete_forever_outlined),
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
                              print('Go to paper with id $paperId');
                              context.pushNamed('paperPage',
                                  params: {'paperId': paperId.toString()});
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
  }

  void reloadPapers() {
    setState(() {
      papers = papersService.getAllSync();
    });
  }

  void deletePaper(int paperId) {
    papersService.delete(paperId).then((value) => reloadPapers());
  }
}
