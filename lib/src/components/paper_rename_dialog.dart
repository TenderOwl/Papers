import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PaperRenameDialog extends StatefulWidget {
  const PaperRenameDialog(
      {super.key, required this.title, required this.onChange});

  final String title;
  final void Function(String title) onChange;

  @override
  State<PaperRenameDialog> createState() => _PaperRenameDialogState();
}

class _PaperRenameDialogState extends State<PaperRenameDialog> {
  final titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16),
      title: const Text('Rename paper'),
      children: [
        TextField(
          controller: titleController,
          autofocus: true,
          onSubmitted: (value) => submit(),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => submit(),
                child: const Text('Rename'),
              )
            ],
          ),
        )
      ],
    );
  }

  void submit() {
    widget.onChange(titleController.text);
    context.pop();
  }
}
