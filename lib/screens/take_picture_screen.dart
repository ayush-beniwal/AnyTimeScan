import 'package:path_provider/path_provider.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';

class TakePictureScreen extends StatefulWidget {
  const TakePictureScreen({
    super.key,
    required this.camera,
    required this.title,
  });
  final String title;
  final CameraDescription camera;

  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  int _imageCount = 1;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.ultraHigh,
    );

    _initializeControllerFuture = _controller.initialize();
    _initializeControllerFuture.then((_) {
      _controller.setFlashMode(FlashMode.off);
      _controller.setFocusMode(FocusMode.locked);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _takePicturesRegularly() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      if (_imageCount <= 100) {
        try {
          final String folderName = widget.title;
          await _initializeControllerFuture;
          final image = await _controller.takePicture();
          final File newImage = File(image.path);
          Directory? appDocumentsDir = await getExternalStorageDirectory();
          appDocumentsDir ??= await getApplicationDocumentsDirectory();
          String appDocPath = appDocumentsDir.path;
          String folderPath = '$appDocPath/$folderName/Images';
          Directory folderDir = Directory(folderPath);
          if (!folderDir.existsSync()) {
            folderDir.createSync(recursive: true);
          }

          // ignore: unused_local_variable
          final File storedImage =
              await newImage.copy('$folderPath/$_imageCount.png');

          setState(() {
            _imageCount++;
          });
        } catch (e) {
          print(e);
        }
      } else {
        _timer.cancel();
        Navigator.pop(context);
      }
    });}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${_imageCount - 1} images taken'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _takePicturesRegularly,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
