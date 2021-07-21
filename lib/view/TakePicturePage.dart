import 'dart:io';

import 'package:angaryos/helper/LogHelper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TakePicturePage extends StatefulWidget {
  TakePicturePage();

  @override
  _TakePicturePageState createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> {
  CameraController? _cameraController;
  Future<void>? _initializeCameraControllerFuture;
  List<CameraDescription>? _availableCameras;
  int currentCamera = 1;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  void _initializeCamera([CameraDescription? camera]) async {
    if (camera == null) {
      _availableCameras = await availableCameras();
      camera = _availableCameras!.first;
    }

    _cameraController = CameraController(camera, ResolutionPreset.max);
    _initializeCameraControllerFuture = _cameraController!.initialize();

    await _initializeCameraControllerFuture;
    setState(() {});
  }

  void _takePicture(BuildContext context) async {
    try {
      await _initializeCameraControllerFuture;
      XFile file = await _cameraController!.takePicture();
      Navigator.pop(context, File(file.path));
    } catch (e) {
      LogHelper.error(
          "Error in _TakePicturePageState:_takePicture", [e.toString()]);
    }
  }

  void _changeCamera() {
    final lensDirection = _cameraController!.description.lensDirection;
    CameraDescription newDescription;
    if (lensDirection == CameraLensDirection.front) {
      newDescription = _availableCameras!.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.back);
    } else {
      newDescription = _availableCameras!.firstWhere((description) =>
          description.lensDirection == CameraLensDirection.front);
    }

    if (newDescription != null) {
      _initializeCamera(newDescription);
    } else {
      print('Asked camera not available');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: <Widget>[
      FutureBuilder(
        future: _initializeCameraControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_cameraController!);
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      SafeArea(
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  child: Icon(Icons.camera),
                  onPressed: () {
                    _takePicture(context);
                  },
                ),
                FloatingActionButton(
                  backgroundColor: Colors.black,
                  child: Icon(Icons.rotate_left_rounded),
                  onPressed: () {
                    _changeCamera();
                  },
                )
              ],
            ),
          ),
        ),
      )
    ]);
  }

  @override
  void dispose() {
    _cameraController!.dispose();
    super.dispose();
  }
}
