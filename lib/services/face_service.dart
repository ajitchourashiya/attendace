// import 'dart:io';
// import 'dart:math';
//
// import 'package:tflite_flutter/tflite_flutter.dart';
// import 'package:image/image.dart' as img;
// import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
//
// class FaceService {
//
//   Interpreter? _interpreter;
//
//   /* LOAD MODEL */
//
//   Future loadModel() async {
//
//     _interpreter =
//     await Interpreter.fromAsset(
//       "assets/models/mobilefacenet.tflite",
//     );
//   }
//
//   /* GENERATE EMBEDDING WITH FACE CROP */
//
//   List<double> generateEmbedding(
//       File imageFile,
//       Face face) {
//
//     img.Image? image =
//     img.decodeImage(
//         imageFile.readAsBytesSync());
//
//     if (image == null) {
//
//       throw Exception(
//           "Cannot decode image");
//     }
//
//     /* FACE BOUNDING BOX */
//
//     final rect =
//         face.boundingBox;
//
//     int x =
//     rect.left.toInt();
//
//     int y =
//     rect.top.toInt();
//
//     int w =
//     rect.width.toInt();
//
//     int h =
//     rect.height.toInt();
//
//     /* FIX BOUNDARY */
//
//     x = max(0, x);
//     y = max(0, y);
//
//     if (x + w > image.width) {
//       w = image.width - x;
//     }
//
//     if (y + h > image.height) {
//       h = image.height - y;
//     }
//
//     /* CROP FACE */
//
//     img.Image cropped =
//     img.copyCrop(
//       image,
//
//       x: x,
//       y: y,
//       width: w,
//       height: h,
//     );
//
//     /* RESIZE */
//
//     img.Image resized =
//     img.copyResize(
//       cropped,
//
//       width: 112,
//       height: 112,
//     );
//
//     /* NORMALIZE */
//
//     var input = List.generate(
//       1,
//           (i) => List.generate(
//         112,
//             (y) => List.generate(
//           112,
//               (x) {
//
//             final pixel =
//             resized.getPixel(x, y);
//
//             return [
//
//               pixel.r / 255.0,
//               pixel.g / 255.0,
//               pixel.b / 255.0
//
//             ];
//           },
//         ),
//       ),
//     );
//
//     var output = List.generate(
//       1,
//           (i) => List.filled(
//           192,
//           0.0),
//     );
//
//     _interpreter!
//         .run(input, output);
//
//     return output[0];
//   }
//
//   /* DISTANCE */
//
//   double compareEmbeddings(
//       List<double> e1,
//       List<double> e2) {
//
//     double sum = 0;
//
//     for (int i = 0;
//     i < e1.length;
//     i++) {
//
//       sum +=
//           pow(
//               e1[i] - e2[i],
//               2);
//     }
//
//     return sqrt(sum);
//   }
// }


import 'dart:io';
import 'package:flutter_litert/flutter_litert.dart';
import 'package:image/image.dart' as img;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FaceService {
  Interpreter? _interpreter;

  Future loadModel() async {
    _interpreter = await Interpreter.fromAsset(
      'assets/models/mobilefacenet.tflite',
    );
  }

  List<double> generateEmbedding(File imageFile, Face face) {
    final image = img.decodeImage(imageFile.readAsBytesSync());

    if (image == null) throw Exception("Image decode failed");

    final rect = face.boundingBox;

    int x = rect.left.toInt();
    int y = rect.top.toInt();
    int w = rect.width.toInt();
    int h = rect.height.toInt();

    final cropped = img.copyCrop(
      image,
      x: x,
      y: y,
      width: w,
      height: h,
    );

    final resized = img.copyResize(cropped, width: 112, height: 112);

    var input = List.generate(
      1,
          (_) => List.generate(
        112,
            (y) => List.generate(112, (x) {
          final pixel = resized.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        }),
      ),
    );

    var output = List.generate(
      1,
          (_) => List.filled(192, 0.0),
    );

    _interpreter!.run(input, output);

    return output[0];
  }
}