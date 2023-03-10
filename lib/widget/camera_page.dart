import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:my_vision/object/YoloV5Response.dart';
import 'package:my_vision/widget/bounding_boxes.dart';

class CameraPage extends StatefulWidget {
  final String url;
  final List<CameraDescription>? cameras;

  const CameraPage({super.key, required this.url, this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _cameraController;
  List<YoloV5Response> _data = [];

  bool _isPredicting = true;    // Default predicting behavior

  Future _initCamera(CameraDescription cameraDescription) async {
    _cameraController = CameraController(
        cameraDescription, ResolutionPreset.max,
        enableAudio: false);

    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) return;
        setState(() {});
      });
    } on CameraException catch (e) {
      debugPrint("Camera Error: $e");
    }
  }

  void _togglePrediction() {
    setState(() {
      _isPredicting = !_isPredicting;
    });
  }

  Future<void> _predict() async {
    if (_cameraController.value.isTakingPicture) return;

    try {
      XFile file = await _cameraController.takePicture();
      File image = File(file.path);

      // Check if image is taken
      if (image == null) {
        print("Image is null!");
        return;
      }

      Dio dio = Dio();
      String url = widget.url;

      FormData formData = FormData.fromMap({
        "image": await MultipartFile.fromFile(image.path),
        "width": MediaQuery.of(context).size.width,
        "height": MediaQuery.of(context).size.height,
      });

      dio.options.headers["Content-type"] = "multipart/form-data";

      final response = await dio.post(url, data: formData);

      List<YoloV5Response> predictions = [];
      for (Map<String, dynamic> item in response.data) {
        YoloV5Response prediction = YoloV5Response.fromJson(item);
        predictions.add(prediction);
      }

      setState(() {
        _data = predictions;
      });
    } on CameraException catch (e) {
      print("ERROR: $e");
    } finally {
      _printData();

      // If still predicting, then predict the next image
      if (_isPredicting) {
        Timer.run(() {
          _predict();
        });
      } else {
        setState(() {
          _data = [];
        });
      }
    }
  }

  void _printData() {
    print("===================================================");
    print(_data.length);
    for (var i = 0; i < _data.length; i++) {
      print(_data[i].toString());
    }
    print("===================================================");
  }

  List<Widget> _generateBoundingBoxes() {
    List<BoundingBox> boundingBoxes = [];

    for (YoloV5Response data in _data) {
      BoundingBox boundingBox = BoundingBox(
          xmax: data.xmax!,
          xmin: data.xmin!,
          ymax: data.ymax!,
          ymin: data.ymin!,
          name: data.name!,
          confidence: data.confidence!);
      boundingBoxes.add(boundingBox);
    }

    return boundingBoxes;
  }

  @override
  void initState() {
    super.initState();
    _initCamera(widget.cameras![0]);
    _predict();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          _cameraController.value.isInitialized
              ? SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: AspectRatio(
                    aspectRatio: _cameraController.value.aspectRatio,
                    child: CameraPreview(_cameraController),
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
          Stack(
            children: _generateBoundingBoxes(),
          ),
          ElevatedButton(
              onPressed: () => {_togglePrediction(), _predict()},
              child: Text("Toggle Detection"))
        ],
      )),
    );
  }
}
