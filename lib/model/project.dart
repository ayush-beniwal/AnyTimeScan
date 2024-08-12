import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class Project {
  Project({required this.title, required this.image, this.isUploaded = false})
      : id = uuid.v4();
  final String id;
  final String title;
  final File image;
  bool isUploaded;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'imagePath': image.path, // Store the file path instead of the File object
      'isUploaded': isUploaded,
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      title: json['title'],
      image: File(json['imagePath']), // Convert the file path back to File
      isUploaded: json['isUploaded'] ?? false,
    );
  }
  factory Project.fromFile(String title, File image) {
    return Project(
      title: title,
      image: image,
    );
  }
}
