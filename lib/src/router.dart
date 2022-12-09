import 'package:go_router/go_router.dart';

import 'pages/papers_page.dart';
import 'pages/paper_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'papersPage',
      builder: (context, state) => const PapersPage(),
    ),
    // GoRoute(
    //   path: '/books/:bookId/papers',
    //   name: 'papersPage',
    //   builder: (context, state) =>
    //       const BookPage(bookId: state.params['bookId']),
    // ),
    GoRoute(
      path: '/papers/:paperId',
      name: 'paperPage',
      builder: (context, state) => PaperPage(paperId: state.params['paperId']),
    ),
  ],
);
