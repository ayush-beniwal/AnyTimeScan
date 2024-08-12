import 'package:cad_scanner/providers/user_places.dart';
import 'package:cad_scanner/screens/add_project.dart';
import 'package:cad_scanner/widgets/main_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:cad_scanner/model/project.dart';

class Home extends ConsumerWidget {
  Home({super.key, required this.firstCamera, required this.loadedProjects});
  final CameraDescription firstCamera;
  final List<Project> loadedProjects;

  @override
  Widget build(context, WidgetRef ref) {
    final userProjects = ref.watch(userProjectProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Projects',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (ctx) => AddProjectScreen(),
                ));
              },
              icon: const Icon(Icons.add)),
        ],
      ),
      body: MainList(
        project_list: [...userProjects],
        firstCamera: firstCamera,
      ),
    );
  }
}
