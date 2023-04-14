import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as Img;
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:async/async.dart';

class ScanningScreen extends StatefulWidget {
  @override
  _ScanningScreenState createState() => _ScanningScreenState();
}

class _ScanningScreenState extends State<ScanningScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  List<String> _numberRows = ['', '', '', '', '', ''];

  @override
  void initState() {
    super.initState();
    WidgetsFlutterBinding.ensureInitialized();
    _initializeControllerFuture = initCameraController();
  }

  Future<void> initCameraController() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.ultraHigh,
    );
    await _controller.initialize();
  }

  List<CameraDescription> get cameras => cameras;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _processImage(Img.Image image) {
    // Process the image to get 6 rows of numbers
    setState(() {
      // Update the state with the 6 rows of numbers
      _numberRows = [];
    });
  }

  Future<void> _takePicture() async {
    try {
      await _initializeControllerFuture;

      final Directory extDir = await getTemporaryDirectory();
      final String dirPath = '${extDir.path}/Pictures/flutter_test';
      await Directory(dirPath).create(recursive: true);
      final String filePath =
          '$dirPath/${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
      await _controller.takePicture();
      final Img.Image image =
          Img.decodeImage(File(filePath).readAsBytesSync())!;
      _processImage(image);
    } catch (e) {
      print(e);
    }
  }

  void _searchNumbers(DateTime drawDate, int drawPeriod) async {
    final formattedDrawDate = drawDate.toString().split(', ')[1];

    final querySnapshot = await FirebaseFirestore.instance
        .collection('vietlott_655_result')
        .where('draw_date', isEqualTo: formattedDrawDate)
        .where('draw_period', isEqualTo: drawPeriod)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final winningNumbers = [
        querySnapshot.docs[0]['number_1'],
        querySnapshot.docs[0]['number_2'],
        querySnapshot.docs[0]['number_3'],
        querySnapshot.docs[0]['number_4'],
        querySnapshot.docs[0]['number_5'],
        querySnapshot.docs[0]['number_6'],
        querySnapshot.docs[0]['special_number']
      ];

      // TODO: Implement the algorithm to compare the winning numbers with the scanned numbers
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('No matching draw result found.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('OK'),
              )
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dò số 6/55'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  _takePicture();
                },
                child: Text('Chụp ảnh'),
              ),
              ElevatedButton(
                onPressed: () {
                  _searchNumbers(DateTime.now(), 1);
                },
                child: Text('Dò số'),
              ),
            ],
          ),
          // Expanded(
          //   child: GridView.builder(
          //     gridDelegate:
          //         SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 6),
          //     itemBuilder: (context, index) {
          //       final row = index ~/ 6;
          //       final col = index % 6;
          //       return Text(_numberRows[row].split(' ')[col]);
          //     },
          //     itemCount: 36,
          //   ),
          // ),
        ],
      ),
    );
  }
}
