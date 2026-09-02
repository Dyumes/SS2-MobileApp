import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

class FaceCropUtils {
  static Future<Uint8List?> processAndCropFace(Uint8List imageBytes) async {
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );

    try {
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      final tempDir = Directory.systemTemp;
      final tempFile = File('${tempDir.path}/temp_face_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await tempFile.writeAsBytes(imageBytes);

      final inputImage = InputImage.fromFile(tempFile);
      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (await tempFile.exists()) await tempFile.delete();

      if (faces.isEmpty) {
        throw Exception("No face detected. Please take the photo again.");
      }

      if (faces.length > 1) {
        throw Exception("${faces.length} faces detected. Only one person should be present in the photo.");
      }

      final Face face = faces.first;
      final rect = face.boundingBox;

      const double paddingPercent = 0.15;
      final double padX = rect.width * paddingPercent;
      final double padY = rect.height * paddingPercent;

      int x = (rect.left - padX).clamp(0, originalImage.width.toDouble()).toInt();
      int y = (rect.top - padY).clamp(0, originalImage.height.toDouble()).toInt();
      int width = (rect.width + (2 * padX)).toInt();
      int height = (rect.height + (2 * padY)).toInt();

      if (x + width > originalImage.width) width = originalImage.width - x;
      if (y + height > originalImage.height) height = originalImage.height - y;

      // Crop image
      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: x,
        y: y,
        width: width,
        height: height,
      );

      return Uint8List.fromList(img.encodeJpg(croppedImage, quality: 90));
    } catch (e) {
      debugPrint('Error in processAndCropFace: $e');
      rethrow; 
    } finally {
      await faceDetector.close();
    }
  }
}