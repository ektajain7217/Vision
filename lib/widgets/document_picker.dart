import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../utils/theme.dart';

class DocumentPicker extends StatelessWidget {
  final Function(File) onDocumentSelected;

  const DocumentPicker({
    Key? key,
    required this.onDocumentSelected,
  }) : super(key: key);

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      onDocumentSelected(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pickDocument,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Icon(
          Icons.attach_file,
          color: AppTheme.primaryColor,
          size: 24,
        ),
      ),
    );
  }
}