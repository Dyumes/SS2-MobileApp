import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

typedef FaceMatch = ({String name, double difference, bool isRecognized});

class FaceRecognitionService {
  Interpreter? _interpreter;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
  );

  Future<void> loadModel() async {
    if (_interpreter != null) return;
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobile_face_net.tflite');
    } catch (e) {
    }
  }

  Future<List<Face>> detectFaces(Uint8List imageBytes) async {
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
    await tempFile.writeAsBytes(imageBytes);

    final inputImage = InputImage.fromFile(tempFile);
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    if (await tempFile.exists()) await tempFile.delete();
    return faces;
  }

  List<dynamic> _imageProcessor(img.Image image, Face face) {
    final rect = face.boundingBox;

    int x = rect.left.clamp(0, image.width).toInt();
    int y = rect.top.clamp(0, image.height).toInt();
    int width = rect.width.clamp(1, image.width - x).toInt();
    int height = rect.height.clamp(1, image.height - y).toInt();

    final img.Image croppedFace = img.copyCrop(
      image,
      x: x,
      y: y,
      width: width,
      height: height,
    );

    final img.Image resizedFace = img.copyResize(croppedFace, width: 112, height: 112);

    var imageAsList = List.generate(
      112,
      (y) => List.generate(
        112,
        (x) {
          final pixel = resizedFace.getPixel(x, y);
          return [
            (pixel.r - 128) / 128,
            (pixel.g - 128) / 128,
            (pixel.b - 128) / 128,
          ];
        },
      ),
    );

    return imageAsList;
  }

  Future<List<double>> recognizeFace(Uint8List rawBytes, Face face) async {
    await loadModel();
    if (_interpreter == null) return [];

    try {
      final img.Image? decodedImage = img.decodeImage(rawBytes);
      if (decodedImage == null) return [];

      List input = _imageProcessor(decodedImage, face);
      input = input.reshape([1, 112, 112, 3]);

      List output = List.generate(1, (index) => List.filled(192, 0.0));

      _interpreter!.run(input, output);

      final List<double> vector = List<double>.from(output[0]);

      return vector;
    } catch (error) {
    }
    return [];
  }

  FaceMatch findFromList(List<double> currentVector, Map<String, List<double>> registeredUsers) {
    if (registeredUsers.isEmpty) {
      return (name: "Unknown", difference: 1.0, isRecognized: false);
    }

    String bestMatchUid = "Unknown";
    double lowestDistance = double.infinity;

    registeredUsers.forEach((uid, knownVector) {
      if (knownVector.length != currentVector.length) {
  
      }

      double sumOfSquares = 0.0;
      for (int i = 0; i < currentVector.length; i++) {
        double diff = currentVector[i] - knownVector[i];
        sumOfSquares += diff * diff;
      }
      double distance = sqrt(sumOfSquares);

      if (distance < lowestDistance) {
        lowestDistance = distance;
        bestMatchUid = uid;
      }
    });
    const double threshold = 0.85;
    final bool isRecognized = lowestDistance <= threshold;

    return (
      name: isRecognized ? bestMatchUid : "Unknown",
      difference: lowestDistance,
      isRecognized: isRecognized,
    );
  }

  void dispose() {
    _interpreter?.close();
    _faceDetector.close();
  }
}