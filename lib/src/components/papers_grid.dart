import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icon.dart';

import '../models/paper.dart';
import 'paper_tile.dart';

class PapersGrid extends StatefulWidget {
  const PapersGrid({
    super.key,
    this.papers,
    this.onPaperTap,
    this.onDeletePaper,
  });

  final List<Paper>? papers;
  final void Function(int paperId)? onPaperTap;
  final void Function(int paperId)? onDeletePaper;

  @override
  State<PapersGrid> createState() => _PapersGridState();
}

class _PapersGridState extends State<PapersGrid> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: widget.papers != null
            ? Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.papers!
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
                              ContextMenuButtonConfig("Delete", onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Delete Paper?'),
                                    content: const Text(
                                      'Paper will be deleted permanently.\nThis action cannot be undone.',
                                    ),
                                    icon: LineIcon.trash(size: 36),
                                    iconColor:
                                        Theme.of(context).colorScheme.error,
                                    actions: [
                                      TextButton(
                                        onPressed: context.pop,
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.pop();
                                          if (widget.onDeletePaper != null) {
                                            widget.onDeletePaper!(paper.id);
                                          }
                                        },
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                          child: PaperTile(
                            paper: paper,
                            onTap: widget.onPaperTap,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              )
            : const Center(child: CircularProgressIndicator.adaptive()),
      ),
    );
  }
}
