import 'dart:convert';
import 'dart:io';

import 'package:delta_to_html/delta_to_html.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:line_icons/line_icon.dart';
import 'package:papers/src/actions/text_format.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart' show PdfPageFormat;

import '../actions/dispatcher.dart';
import '../components/paper_rename_dialog.dart';
import '../models/paper.dart';
import '../services/papers_service.dart';

extension GlobalKeyExtension on GlobalKey {
  Rect? get globalPaintBounds {
    final renderObject = currentContext?.findRenderObject();
    final translation = renderObject?.getTransformTo(null).getTranslation();
    if (translation != null && renderObject?.paintBounds != null) {
      final offset = Offset(translation.x, translation.y);
      return renderObject!.paintBounds.shift(offset);
    } else {
      return null;
    }
  }
}

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

  final shareButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    if (widget.paperId != null && widget.paperId != 'new') {
      paper = papersService.getSync(int.tryParse(widget.paperId!)!);

      // Load initial content
      if (paper != null) {
        controller.document =
            quill.Document.fromJson(jsonDecode(paper!.content));
      }
    } else {
      paper = Paper(bookId: 0, content: '{}');
    }
  }

  void closePaper() {
    // Check if we have paper and edited text is not empty.
    if (paper != null && !controller.document.isEmpty()) {
      // Set default title
      paper!.title = paper?.title ?? 'Paper';
      // Save content
      paper!.content = jsonEncode(controller.document.toDelta());
      papersService.putSync(paper!);
    }

    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: const {
        SingleActivator(LogicalKeyboardKey.keyB, control: true): BoldIntent()
      },
      child: Scaffold(
        appBar: AppBar(
          title: GestureDetector(
            onTap: showRenameDialog,
            child: Text(paper?.title == null ? 'Paper' : paper!.title!),
          ),
          centerTitle: true,
          leading: Padding(
            padding: EdgeInsets.only(left: Platform.isMacOS ? 96.0 : 12.0),
            child: IconButton(
              onPressed: () {
                closePaper();
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/');
                }
              },
              icon: LineIcon.arrowLeft(),
              splashRadius: 24,
            ),
          ),
          leadingWidth: Platform.isMacOS ? 128 : 56,
          actions: [
            Tooltip(
              message: 'Print paper',
              waitDuration: const Duration(milliseconds: 400),
              child: IconButton(
                onPressed: printPaper,
                icon: LineIcon.print(),
                splashRadius: 24,
              ),
            ),
            IconButton(
              key: shareButtonKey,
              onPressed: sharePaper,
              icon: LineIcon.share(),
              splashRadius: 24,
            ),
            Tooltip(
              message: 'Download paper to computer',
              waitDuration: const Duration(milliseconds: 400),
              child: IconButton(
                onPressed: sharePaper,
                icon: LineIcon.download(),
                splashRadius: 24,
              ),
            ),
            const SizedBox(width: 12),
          ],
          elevation: 1,
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
                    showColorButton: false,
                    showBackgroundColorButton: false,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Actions(
                    dispatcher: LoggingActionDispatcher(),
                    actions: <Type, Action<Intent>>{
                      BoldIntent: BoldAction(controller),
                    },
                    child: quill.QuillEditor(
                      controller: controller,
                      autoFocus: true,
                      focusNode: FocusNode(),
                      scrollController: ScrollController(),
                      scrollable: true,
                      padding: const EdgeInsets.all(12),
                      expands: true,
                      readOnly: false,
                      maxContentWidth: 900,
                    ),
                  ),
                ),
              )
            ],
          ),
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
    final filename = '${paper?.title ?? 'Paper'}.md';
    final plainText = controller.document.toPlainText();

    if (Platform.isLinux || Platform.isWindows) {
      Share.share(plainText, subject: filename);
      return;
    }

    final bytes = Uint8List.fromList(utf8.encode(plainText));

    Share.shareXFiles([
      XFile.fromData(
        bytes,
        name: filename,
        mimeType: 'text/plain',
        path: filename,
      )
    ],
        text: filename,
        subject: filename,
        sharePositionOrigin: shareButtonKey.globalPaintBounds);
  }

  Future printPaper() async {
    final delta = controller.document.toDelta();
    final html = DeltaToHTML.encodeJson(delta.toJson());
    final pdf =
        await Printing.convertHtml(html: html, format: PdfPageFormat.a4);

    await Printing.layoutPdf(
        onLayout: (format) => pdf, name: paper?.title ?? 'Paper');
  }
}
