import 'dart:io';

import 'package:cad_scanner/providers/user_places.dart';
import 'package:cad_scanner/widgets/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class AddProjectScreen extends ConsumerStatefulWidget {
  AddProjectScreen({super.key});
  @override
  ConsumerState<AddProjectScreen> createState() {
    return _AddProjectScreenState();
  }
}

class _AddProjectScreenState extends ConsumerState<AddProjectScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;
  void _saveProject() async {
    final enteredText = _titleController.text;
    if (enteredText.isEmpty || _selectedImage == null) {
      return;
    }
    
    ref
        .read(userProjectProvider.notifier)
        .addProject(enteredText, _selectedImage!);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  bool isTitleEmpty() {
    return _titleController.text.isEmpty;
  }

  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new project'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              child: ImagePick(
                title: _titleController.text,
                onPickImage: (image) {
                  _selectedImage = image;
                },
              ),
            ),
            const SizedBox(height: 10),
            const SizedBox(height: 16),
            ElevatedButton.icon(
                onPressed: _saveProject,
                icon: const Icon(Icons.add),
                label: const Text('Initialize Project'))
          ],
        ),
      ),
    );
  }
}
