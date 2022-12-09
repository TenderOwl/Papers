import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../components/paper_rename_dialog.dart';
import '../models/paper.dart';
import '../services/papers_service.dart';

class PaperPage extends StatefulWidget {
  const PaperPage({super.key, this.paperId});

  final String? paperId;

  @override
  State<PaperPage> createState() => _PaperPageState();
}

class _PaperPageState extends State<PaperPage> {
  PapersService papersService = Get.find();

  final controller = quill.QuillController.basic();
  Paper? paper;

  @override
  void initState() {
    super.initState();

    if (widget.paperId != null && widget.paperId != 'new') {
      paper = papersService.getSync(int.tryParse(widget.paperId!)!);
      if (paper != null) {
        controller.document =
            quill.Document.fromJson(jsonDecode(paper!.content));
      }
    } else {
      paper = Paper(bookId: 0, content: '{}');
    }
  }

  void closePaper() {
    if (paper == null) return;

    paper!.content = jsonEncode(controller.document.toDelta().toJson());
    papersService.putSync(paper!);

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: showRenameDialog,
          child: Text(paper?.title == null ? 'Paper' : paper!.title!),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: IconButton(
            onPressed: () {
              closePaper();
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        actions: [
          IconButton(
            onPressed: sharePaper,
            icon: const Icon(Icons.share_outlined),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: quill.QuillToolbar.basic(
                  controller: controller,
                  toolbarIconAlignment: WrapAlignment.spaceBetween,
                  showAlignmentButtons: false,
                  showDirection: false,
                  showFontFamily: false,
                  showFontSize: false,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: quill.QuillEditor.basic(
                  controller: controller,
                  readOnly: false, // true for view only mode
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void showRenameDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return PaperRenameDialog(
          title: paper?.title ?? '',
          onChange: (title) => setState(() {
            if (paper != null) {
              paper!.title = title;
            }
          }),
        );
      },
    );
  }

  void sharePaper() {
    final filename = '${paper?.title ?? 'Paper'}.html';
    final plainText = controller.document.toPlainText();
    final bytes = Uint8List.fromList(utf8.encode(plainText));

    Share.shareXFiles(
      [
        XFile.fromData(
          bytes,
          name: filename,
          mimeType: 'text/plain',
          path: filename,
        )
      ],
      text: filename,
      subject: filename,
    );
  }
}
