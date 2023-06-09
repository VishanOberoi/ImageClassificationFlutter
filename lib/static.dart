import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';

// class StaticPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Capture/Upload Image'),
//       ),
//       body: Center(
//         child: Text('This is the Static Page'),
//       ),
//     );
//   }
// }

class StaticPage extends StatefulWidget {
  StaticPage({Key? key}) : super(key: key);
  @override
  _StaticPageState createState() => _StaticPageState();
}

class _StaticPageState extends State<StaticPage> {
  late ImagePicker imagePicker;
  File? _image;
  String result = '';

  //TODO declare ImageLabeler
  dynamic imageLabeler;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    //TODO initialize labeler
    createLabeler();
  }

  @override
  void dispose() {
    super.dispose();
    imageLabeler.close();
  }

  //TODO capture image using camera
  _imgFromCamera() async {
    XFile? pickedFile = await imagePicker.pickImage(source: ImageSource.camera);
    _image = File(pickedFile!.path);
    setState(() {
      _image;
      doImageLabeling();
    });
  }

  //TODO choose image using gallery
  _imgFromGallery() async {
    XFile? pickedFile =
    await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        doImageLabeling();
      });
    }
  }

  Future<String> _getModel(String assetPath) async {
    if (Platform.isAndroid) {
      return 'flutter_assets/$assetPath';
    }
    final path = '${(await getApplicationSupportDirectory()).path}/$assetPath';
    await Directory(dirname(path)).create(recursive: true);
    final file = File(path);
    if (!await file.exists()) {
      final byteData = await rootBundle.load(assetPath);
      await file.writeAsBytes(byteData.buffer
          .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    }
    return file.path;
  }

  //TODO image labeling code here
  // doImageLabeling() async {
  //   result = "";
  //   final inputImage = InputImage.fromFile(_image!);
  //   final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
  //   for (ImageLabel label in labels) {
  //     final String text = label.label;
  //     final int index = label.index;
  //     final double confidence = label.confidence;
  //     result += "$text   ${confidence.toStringAsFixed(2)}\n";
  //   }
  //   setState(() {
  //     result;
  //   });
  // }
  doImageLabeling() async {
    result = "";
    final inputImage = InputImage.fromFile(_image!);
    final List<ImageLabel> labels = await imageLabeler.processImage(inputImage);
    if (labels.isEmpty) {
      result = "No labels found";
    } else {
      for (ImageLabel label in labels) {
        final String text = label.label;
        final int index = label.index;
        final double confidence = label.confidence;
        result += "$text   ${confidence.toStringAsFixed(2)}\n";
      }
    }
    setState(() {
      result;
    });
  }
  createLabeler() async {
    final modelPath = await _getModel('assets/ml/efficientnet.tflite');
    final options = LocalLabelerOptions(modelPath: modelPath);
    imageLabeler = ImageLabeler(options : options);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage('images/matrix.png'), fit: BoxFit.cover),
        ),
        child: Scaffold(
          body:  SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(
                  width: 100,
                ),
                Container(
                  margin: const EdgeInsets.only(top: 100),
                  child: Stack(children: <Widget>[
                    Stack(children: <Widget>[
                      Center(
                        child: Image.asset(
                          'images/frame2.jpg',
                          height: 510,
                          width: 500,
                        ),
                      ),
                    ]),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: Colors.transparent,
                            shadowColor: Colors.transparent),
                        onPressed: _imgFromGallery,
                        onLongPress: _imgFromCamera,
                        child: Container(
                          margin: const EdgeInsets.only(top: 8),
                          child: _image != null
                              ? Image.file(
                            _image!,
                            width: 335,
                            height: 495,
                            fit: BoxFit.fill,
                          )
                              : Container(
                            width: 340,
                            height: 330,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.black,
                              size: 100,
                            ),
                          ),
                        ),
                      ),

                    ),
                  ]),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  child: Text(
                    result,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }
}