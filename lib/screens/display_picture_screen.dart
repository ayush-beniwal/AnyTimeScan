import 'dart:async';
import 'dart:io';
import 'package:cad_scanner/screens/display_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:cad_scanner/providers/user_places.dart';
import 'package:cloudinary/cloudinary.dart';

class DisplayPictureScreen extends ConsumerWidget {
  final String show;
  final String previewImagepath;
  ValueNotifier<double> uploadProgress = ValueNotifier<double>(0.0);

  DisplayPictureScreen(
      {super.key, required this.show, required this.previewImagepath});
 
  void _deleteProject(
      BuildContext context, String projectName, WidgetRef ref) async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleting $projectName...'),
        duration: const Duration(days: 1),
      ),
    );
    try {
      final List<String> imagePaths = await _getImagesInFolder();
      for (final imagePath in imagePaths) {
        File image = File(imagePath);
        String filename = image.path.split('/').last.split('.').first;

        final deleteImagesResponse = await cloudinary.destroy(
            "files/$show/$filename",
            resourceType: CloudinaryResourceType.image);
        if (deleteImagesResponse.isResultOk) {
          print('deleted Image wohooo');
        }
      }
      Directory? appDocumentsDir = await getExternalStorageDirectory();
      appDocumentsDir ??= await getApplicationDocumentsDirectory();
      String folderPath = '${appDocumentsDir.path}/$projectName';
      Directory folderDir = Directory(folderPath);
      if (folderDir.existsSync()) {
        folderDir.deleteSync(recursive: true);

        ref
            .read(userProjectProvider.notifier)
            .removeProjectByTitle(projectName);

        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project $projectName deleted successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Project $projectName not found'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete project: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _uploadImagesToCloudinary(BuildContext context, WidgetRef ref) async {
    final bool isUploaded =
        ref.watch(userProjectProvider.notifier).isProjectUploaded(show);
    final List<String> imagePaths = await _getImagesInFolder();
    if (!isUploaded) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uploading Images to Cloudinary...'),
          duration: Duration(seconds: 2),
        ),
      );
      try {
        int totalImages = imagePaths.length;
        int uploadedImages = 0;
        for (final imagePath in imagePaths) {
          File image = File(imagePath);
          String filename = image.path.split('/').last.split('.').first;
          // ScaffoldMessenger.of(context).hideCurrentSnackBar();
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(
          //     content: Text('Uploading Image $filename...'),
          //     duration: Duration(seconds: 5),
          //   ),
          // );
          final response = await cloudinary.unsignedUpload(
              file: imagePath,
              uploadPreset: 'cadscannerd',
              fileBytes: image.readAsBytesSync(),
              resourceType: CloudinaryResourceType.image,
              folder: 'files/$show',
              fileName: filename,
              progressCallback: (count, total) {
                print('Uploading image from file with progress: $count/$total');
                uploadProgress.value =
                    (uploadedImages + count / total) / totalImages;
              });

          if (response.isSuccessful) {
            uploadedImages++;
            ref.read(userProjectProvider.notifier).setProjectUploaded(show);
            print('Get your image from with ${response.secureUrl}');
          } else {
            int? x = response.statusCode;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(x.toString()),
                duration: Duration(seconds: 2),
              ),
            );
          }
        }
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Images uploaded to Cloudinary successfully'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Upload each image to Cloudinary
      catch (e) {
        // Show an error message if the upload fails
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to upload images to Cloudinary: $e'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      uploadProgress.value = 1;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Project is already uploaded'),
          duration: Duration(seconds: 2),
        ),
      );
    }
    try {
      final deleteResponse = await cloudinary.destroy("ProjectNames/sample.txt",
          resourceType: CloudinaryResourceType.raw);
      if (deleteResponse.isSuccessful) {
        final textContent = '$show and ${imagePaths.length}';
        final textFileName = '$show.txt';
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/$textFileName');
        await tempFile.writeAsString(textContent);
        final textResponse = await cloudinary.unsignedUpload(
          file: tempFile.path,
          uploadPreset: 'cadscannerd',
          folder: 'ProjectNames', // Separate folder for text files
          fileName: 'sample.txt',
          resourceType: CloudinaryResourceType.raw,
        );
        if (textResponse.isSuccessful) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project Updated on Cloud'),
              duration: Duration(seconds: 2),
            ),
          );
          print('Get your image from with ${textResponse.secureUrl}');
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to upload txt to Cloudinary: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _uploadImagesToCloudinary(context, ref);
        },
        child: const Icon(Icons.upload),
      ),
      appBar: AppBar(
        title: Text('$show'),
        actions: [
          IconButton(
              onPressed: () => _deleteProject(context, show, ref),
              icon: const Icon(Icons.delete))
        ],
      ),
      bottomSheet: ValueListenableBuilder<double>(
        valueListenable: uploadProgress,
        builder: (context, value, child) {
          return LinearProgressIndicator(value: value);
        },
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<String>>(
          future: _getImagesInFolder(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else {
              List<String>? imagePaths = snapshot.data;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.file(
                            File(previewImagepath),
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      width: 2,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withOpacity(0.5))),
                              alignment: Alignment.center,
                              height: 150,
                              width: 200,
                              child: TextButton.icon(
                                onPressed: () {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(const SnackBar(
                                    content: Text(
                                        'Showing Generated Model'),
                                    duration: Duration(seconds: 2),
                                  ));
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => DisplayModel()),
                                  );
                                },
                                icon: const Icon(Icons.get_app_sharp),
                                label: const Text('No Model Generated'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      crossAxisSpacing: 4.0,
                      mainAxisSpacing: 4.0,
                    ),
                    itemCount: imagePaths!.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () {
                          _showImagePreview(context, imagePaths[index]);
                        },
                        child: Image.file(
                          File(imagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }

  void _showImagePreview(BuildContext context, String imagePath) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: Image.file(File(imagePath)),
        );
      },
    );
  }

  Future<List<String>> _getImagesInFolder() async {
    Directory? appDocumentsDir = await getExternalStorageDirectory();
    appDocumentsDir ??= await getApplicationDocumentsDirectory();
    String folderPath = '${appDocumentsDir.path}/$show/Images';
    Directory folderDir = Directory(folderPath);
    List<String> imagePaths = [];
    if (folderDir.existsSync()) {
      List<FileSystemEntity> files = folderDir.listSync();
      for (FileSystemEntity file in files) {
        if (file is File) {
          imagePaths.add(file.path);
        }
      }
    }
    return imagePaths;
  }
}
