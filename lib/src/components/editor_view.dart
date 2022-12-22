import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:line_icons/line_icon.dart';

import '../actions/dispatcher.dart';
import '../actions/text_format.dart';
import '../models/paper.dart';

class EditorView extends StatefulWidget {
  const EditorView({super.key, this.paper, this.onPaperSwitched});

  final Function(Paper)? onPaperSwitched;
  final Paper? paper;

  @override
  State<EditorView> createState() => _EditorViewState();
}

class _EditorViewState extends State<EditorView> {
  final controller = quill.QuillController.basic();

  @override
  void didUpdateWidget(covariant EditorView oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If there is a callback we need to save document to paper's content
    if (widget.onPaperSwitched != null &&
        widget.paper != null &&
        !controller.document.isEmpty()) {
      Paper paper = widget.paper!;
      // Set default title
      paper.title = paper.title ?? 'Paper';
      // Save content
      paper.content = jsonEncode(controller.document.toDelta());
      widget.onPaperSwitched?.call(paper);
    }

    if (widget.paper != null) {
      controller.document =
          quill.Document.fromJson(jsonDecode(widget.paper!.content));
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.paper == null
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LineIcon.fileAlt(size: 48),
                const Text('No paper selected.'),
              ],
            ),
          )
        : Column(
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
          );
  }
}
