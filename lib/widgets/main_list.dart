import 'package:cad_scanner/screens/take_picture_screen.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cad_scanner/model/project.dart';
import 'package:cad_scanner/screens/display_picture_screen.dart';

import 'dart:io';
import 'package:path_provider/path_provider.dart';

class MainList extends StatefulWidget {
  const MainList(
      {required this.project_list, super.key, required this.firstCamera});
  final CameraDescription firstCamera;
  final List<Project> project_list;

  @override
  State<MainList> createState() => _MainListState();
}

class _MainListState extends State<MainList> {
  @override
  Widget build(BuildContext context) {
    return widget.project_list.isEmpty
        ? Center(
            child: Text(
            'No Projects Yet',
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(color: Theme.of(context).colorScheme.onBackground),
          ))
        : ListView.builder(
            itemBuilder: (ctx, index) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 0, 20),
                child: ListTile(
                  onTap: () async {
                    bool flag = true;
                    final name = widget.project_list[index].title;
                    Directory? appDocumentsDir =
                        await getExternalStorageDirectory();
                    appDocumentsDir ??=
                        await getApplicationDocumentsDirectory();
                    String appDocPath = appDocumentsDir.path;
                    String folderPath = '$appDocPath/$name/Images';
                    Directory folderDir = Directory(folderPath);
                    if (folderDir.existsSync()) {
                      flag = false;
                    }

                    if (flag) {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (ctx) => TakePictureScreen(
                          camera: widget.firstCamera,
                          title: widget.project_list[index].title,
                        ),
                      ));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (ctx) => DisplayPictureScreen(
                              previewImagepath:
                                  widget.project_list[index].image.path,
                              show: widget.project_list[index].title)));
                    }
                  },
                  leading: CircleAvatar(
                      radius: 40,
                      backgroundImage:
                          FileImage(widget.project_list[index].image)),
                  title: Text(
                    widget.project_list[index].title,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: Theme.of(context).colorScheme.onBackground),
                  ),
                  trailing: const Icon(Icons.play_arrow),
                ),
              );
            },
            itemCount: widget.project_list.length,
          );
  }
}
