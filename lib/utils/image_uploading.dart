
import 'dart:io';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image/image.dart' as img;
List<num> laplacianKernel = [
  0,  1,  0,
  1, -4,  1,
  0,  1,  0,
];

Future<bool> isIdNumberInDocument(File imageFile, String enteredNumber) async {
  final inputImage = InputImage.fromFile(imageFile);
  final recognizer = TextRecognizer();
  final result = await recognizer.processImage(inputImage);
  await recognizer.close();
  print(result.text);
  final extractedText = result.text.replaceAll(RegExp(r'\s+'), '');
  print(extractedText);
  final cleanedInput = enteredNumber.replaceAll(RegExp(r'\s+'), '');

  return extractedText.contains(cleanedInput);
}

bool isImageUnderSizeLimit(File imageFile, {int maxKB = 10000}) {
  final bytes = imageFile.lengthSync();
  return bytes <= maxKB * 1024;
}

double computeLaplacianVariance(img.Image image) {
  final grayscale = img.grayscale(image);

  final kernel = [
    [0, -1, 0],
    [-1, 4, -1],
    [0, -1, 0],
  ];

  int width = grayscale.width;
  int height = grayscale.height;

  double sum = 0;
  double sumSquared = 0;
  int pixelCount = 0;

  for (int y = 1; y < height - 1; y++) {
    for (int x = 1; x < width - 1; x++) {
      double result = 0;

      for (int ky = 0; ky < 3; ky++) {
        for (int kx = 0; kx < 3; kx++) {
          final pixel = grayscale.getPixel(x + kx - 1, y + ky - 1);
          final luminance = img.getLuminance(pixel).toDouble();
          result += luminance * kernel[ky][kx];
        }
      }

      sum += result;
      sumSquared += result * result;
      pixelCount++;
    }
  }

  if (pixelCount == 0) return 0;

  double mean = sum / pixelCount;
  double variance = (sumSquared / pixelCount) - (mean * mean);
  return variance;
}

Future<bool> isImageSharpAndFaceVisible(File file, {double threshold = 100}) async {
  try {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) return false;

    final variance = computeLaplacianVariance(image);
    print('Sharpness (variance): $variance');
    final isSharp = variance > threshold;

    if (!isSharp) return false;

    final inputImage = InputImage.fromFile(file);
    final faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        enableContours: false,
        enableClassification: false,
      ),
    );

    final faces = await faceDetector.processImage(inputImage);
    await faceDetector.close();

    final hasFace = faces.isNotEmpty;
    print('Face detected: $hasFace');

    return hasFace;
  } catch (e) {
    print('Error in face detection: $e');
    return false;
  }
}

