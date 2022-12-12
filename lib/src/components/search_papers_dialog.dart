import 'package:easy_debounce/easy_debounce.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:papers/src/models/paper.dart';

import '../services/papers_service.dart';

class SearchPaperDialog extends StatefulWidget {
  const SearchPaperDialog({super.key, this.initialValue});

  final String? initialValue;

  @override
  State<SearchPaperDialog> createState() => _SearchPaperDialogState();
}

class _SearchPaperDialogState extends State<SearchPaperDialog> {
  PapersService papersService = Get.find();

  final searchController = TextEditingController();
  List<Paper> papers = [];

  @override
  void initState() {
    super.initState();

    searchController.text = widget.initialValue ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      contentPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: const Text('Search'),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TextField(
            controller: searchController,
            autofocus: true,
            onChanged: (value) => EasyDebounce.debounce(
              'search-debouncer',
              const Duration(milliseconds: 300),
              () async => await searchForPapers(value),
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              filled: true,
              fillColor: Theme.of(context).colorScheme.primary.withAlpha(20),
              hintText: 'Type Title of text to find…',
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          width: 360,
          child: ListView.builder(
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
              return ListTile(
                title: Text(paper.title!),
                leading: const Icon(Icons.description_rounded),
                dense: true,
                onTap: () => context.goNamed(
                  'paperPage',
                  params: {'paperId': paper.id.toString()},
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future searchForPapers(String value) async {
    final papers = await papersService.search(value);
    setState(() {
      this.papers = papers;
    });
  }
}
