import 'package:flutter/material.dart';

import '../components/search_papers_dialog.dart';

class SearchForPaperIntent extends Intent {
  const SearchForPaperIntent();
}

class SearchForPaperAction extends Action<SearchForPaperIntent> {
  SearchForPaperAction(this.context);

  BuildContext context;

  @override
  Object? invoke(SearchForPaperIntent intent) {
    showDialog(
      context: context,
      builder: (builder) => const SearchPaperDialog(),
    );
    return null;
  }
}
