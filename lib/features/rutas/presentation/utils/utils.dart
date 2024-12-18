import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/services.dart';

class Utils {
  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    final codec = await instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    final frameInfo = await codec.getNextFrame();
    final byteData = await frameInfo.image.toByteData(format: ImageByteFormat.png);
    if (byteData == null) {
      throw Exception("Failed to convert image to byte data.");
    }
    
    return byteData.buffer.asUint8List();
  }
}
