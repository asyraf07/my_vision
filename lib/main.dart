// ignore_for_file: use_build_context_synchronously

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:my_vision/widget/camera_page.dart';

const DEBUG = true;

const TextStyle myTextStyle = TextStyle(
  fontFamily: "sans-serif",
  fontSize: 40,
);

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
      SystemUiOverlay.bottom,
    ]);

    return const MaterialApp(
      title: "My Vision",
      home: Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String url = 'http://0.0.0.0:8080/';

  final myController = TextEditingController();

  Future<List<CameraDescription>> _getCameras() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras;
  }

  void _showCameraPage(BuildContext context) async {
    List<CameraDescription> cameras = await _getCameras();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => CameraPage(
                  url: url,
                  cameras: cameras,
                )));
  }

  void input() {
    setState(() {
      url = "http://${myController.value.text}/predict";
    });
  }

  @override
  void dispose() {
    myController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              children: [
                Text(
                  "Used URL: $url",
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(height: 30),
                TextField(
                  decoration: const InputDecoration(
                      hintText: "Type your URL here, ex: 192.168.0.1"),
                  controller: myController,
                ),
                ElevatedButton(
                    onPressed: () => {input()}, child: const Text("Edit URL")),
                // PredictPage(),
                ElevatedButton(
                    onPressed: () {
                      _showCameraPage(context);
                    },
                    child: const Text("Live Prediction")),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
