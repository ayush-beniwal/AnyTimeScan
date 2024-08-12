import 'dart:io';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart' as syspaths;
import 'package:path/path.dart' as path;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cad_scanner/model/project.dart';

class UserProjectNotifier extends StateNotifier<List<Project>> {
  UserProjectNotifier() : super([]) {
    _loadProjectsFromPrefs();
  }
  Future<void> _loadProjectsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final projectData = prefs.getString('projects');
    if (projectData != null) {
      final List<dynamic> decodedData = json.decode(projectData);
      final List<Project> loadedProjects =
          decodedData.map((data) => Project.fromJson(data)).toList();
      state = loadedProjects;
    }
  }

  void addProject(String title, File image) async {
    final appDir = await syspaths.getApplicationDocumentsDirectory();
    final filename = path.basename(image.path);
    // ignore: unused_local_variable
    final copiedImage = await image.copy('${appDir.path}/$filename');
    final newPlace = Project(title: title, image: image);
    state = [newPlace, ...state];
    _saveProjectsToPrefs();
  }

  void _saveProjectsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final projectData = state.map((project) => project.toJson()).toList();
    prefs.setString('projects', json.encode(projectData));
  }

  void setProjectUploaded(String projectName) {
    state.firstWhere((project) => project.title == projectName).isUploaded =
        true;
    _saveProjectsToPrefs();
  }

  bool isProjectUploaded(String projectName) {
    return state
        .any((project) => project.title == projectName && project.isUploaded);
  }

  

  void removeProjectByTitle(String title) {
    state = state.where((project) => project.title != title).toList();
    _saveProjectsToPrefs();
  }
}

final userProjectProvider =
    StateNotifierProvider<UserProjectNotifier, List<Project>>(
  (ref) => UserProjectNotifier(),
);
