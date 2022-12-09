import 'package:go_router/go_router.dart';

import 'pages/documents_page.dart';
import 'pages/editor_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DocumentsPage(),
    ),
    GoRoute(
      path: '/document/:documentId',
      builder: (context, state) =>
          EditorPage(documentId: state.params['documentId']),
    ),
  ],
);
