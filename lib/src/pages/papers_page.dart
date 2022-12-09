import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../components/paper_tile.dart';
import '../models/paper.dart';
import '../services/papers_service.dart';

class PapersPage extends StatefulWidget {
  const PapersPage({super.key});

  @override
  State<PapersPage> createState() => _PapersPageState();
}

class _PapersPageState extends State<PapersPage> {
  PapersService papersService = Get.find();
  List<Paper> papers = [];

  @override
  void initState() {
    super.initState();
    papers = papersService.getAllSync();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    papers = papersService.getAllSync();
  }

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
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: papers
                  .map(
                    (paper) => SizedBox(
                      width: 120,
                      height: 120,
                      child: PaperTile(
                        paper: paper,
                        onTap: (paperId) {
                          print('Go to paper with id $paperId');
                          context.pushNamed('paperPage',
                              params: {'paperId': paperId.toString()});
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('paperPage', params: {'paperId': 'new'});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
