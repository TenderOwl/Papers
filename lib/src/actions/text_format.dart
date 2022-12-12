import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class BoldIntent extends Intent {
  const BoldIntent();
}

class BoldAction extends Action<BoldIntent> {
  BoldAction(this.controller);

  QuillController controller;

  @override
  Object? invoke(BoldIntent intent) {
    print('Gets bold!');
  }
}
