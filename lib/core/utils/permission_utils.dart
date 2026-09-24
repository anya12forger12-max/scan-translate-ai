import 'package:permission_handler/permission_handler.dart';
class PermissionUtils {
  PermissionUtils._();
  static Future<bool> requestCamera() async => (await Permission.camera.request()).isGranted;
  static Future<bool> requestMicrophone() async => (await Permission.microphone.request()).isGranted;
  static Future<bool> requestGallery() async => (await Permission.photos.request()).isGranted;
  static Future<bool> hasCamera() async => await Permission.camera.isGranted;
  static Future<bool> hasMicrophone() async => await Permission.microphone.isGranted;
}
