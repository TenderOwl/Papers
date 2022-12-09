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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Rename paper'),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TextField(
            controller: titleController,
            autofocus: true,
            onSubmitted: (value) => submit(),
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary.withAlpha(20),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => submit(),
                child: const Text('Save'),
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
