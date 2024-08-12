import 'dart:async';
import 'dart:convert';
import 'package:cad_scanner/model/project.dart';
import 'package:cad_scanner/screens/home.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final colorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: const Color.fromARGB(255, 102, 6, 247),
  background: const Color.fromARGB(255, 56, 49, 66),
);

final theme = ThemeData().copyWith(
  scaffoldBackgroundColor: colorScheme.background,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.ubuntuCondensedTextTheme().copyWith(
    titleSmall: GoogleFonts.ubuntuCondensed(fontWeight: FontWeight.bold),
    titleMedium: GoogleFonts.ubuntuCondensed(fontWeight: FontWeight.bold),
    titleLarge: GoogleFonts.ubuntuCondensed(fontWeight: FontWeight.bold),
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  final List<Project> loadedProjects = await _loadProjectsFromPrefs();

  runApp(
    ProviderScope(
      child: MaterialApp(
        theme: ThemeData.dark(),
        home: Home(
          firstCamera: firstCamera,
          loadedProjects: loadedProjects,
        ),
      ),
    ),
  );
}

Future<List<Project>> _loadProjectsFromPrefs() async {
  final prefs = await SharedPreferences.getInstance();
  final projectData = prefs.getString('projects');
  if (projectData != null) {
    final List<dynamic> decodedData = json.decode(projectData);
    return decodedData.map((data) => Project.fromJson(data)).toList();
  }
  return [];
}
