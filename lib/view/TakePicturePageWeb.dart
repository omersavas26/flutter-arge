import 'package:angaryos/helper/LogHelper.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:ui' as ui;

class TakePicturePageWeb extends StatefulWidget {
  TakePicturePageWeb({Key? key});

  @override
  _TakePicturePageWebState createState() => _TakePicturePageWebState();
}

class _TakePicturePageWebState extends State<TakePicturePageWeb> {
  Widget? _webcamWidget;
  html.VideoElement? _webcamVideoElement;
  html.ImageBitmap? _img = null;

  @override
  void initState() {
    super.initState();

    /*_webcamVideoElement = html.VideoElement();

    ui.platformViewRegistry.registerViewFactory(
        'webcamVideoElement', (int viewId) => _webcamVideoElement!);

    _webcamWidget =
        HtmlElementView(key: UniqueKey(), viewType: 'webcamVideoElement');

    html.window.navigator
        .getUserMedia(video: true, audio: false)
        .then((html.MediaStream stream) {
      _webcamVideoElement!.srcObject = stream;

      _webcamVideoElement!.play();
    });*/
  }

  void _takePicture() async {
    try {
      print("çek");

      /*var truck = _webcamVideoElement!.captureStream().getTracks()[0];
      var cap = new html.ImageCapture(truck);

      _img = await cap.grabFrame();
      print(_img!.height);
      print(_img!.width);
      print(_img!.runtimeType);
      print(_img!.toString());*/

      //buradan byte çevirilip select gibi byte olarak atılabilir galiba

      /*cap.takePhoto().then((blob) {
        print("omersavas");
        print(blob.size);
        print(blob.type);
        print(blob.runtimeType);
        print(blob.toString());
        print("omersavas");
      }).catchError((e) {
        print(e);
      });*/
    } catch (e) {
      print("Çekmede hata: " + e.toString());
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
                child: Container(
              width: 750,
              height: 750,
              child: _webcamWidget,
            ))
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _takePicture();
          },
          tooltip: 'foto',
          child: Icon(Icons.camera),
        ),
      );

  @override
  void dispose() {
    super.dispose();
  }
}
