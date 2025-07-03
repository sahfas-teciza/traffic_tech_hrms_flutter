import 'dart:convert';
import 'dart:typed_data';

class Base64ToImage {
  static Uint8List? base64Decoder(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      // print("Error decoding Base64 string: $e");
      return null;
    }
  }
}
