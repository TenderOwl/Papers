import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Papers',
          style: GoogleFonts.comfortaa(),
        ),
      ),
      body: SafeArea(
        child: Text('Papers'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('Paper created');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
