import 'package:permission_handler/permission_handler.dart' as ph;

class PermissionUtils {
  PermissionUtils._();

  static Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestMicrophonePermission() async {
    final status = await ph.Permission.microphone.request();
    return status.isGranted;
  }

  static Future<bool> requestGalleryPermission() async {
    final status = await ph.Permission.photos.request();
    return status.isGranted;
  }

  static Future<bool> requestNotificationPermission() async {
    final status = await ph.Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> hasCameraPermission() async {
    return await ph.Permission.camera.isGranted;
  }

  static Future<bool> hasMicrophonePermission() async {
    return await ph.Permission.microphone.isGranted;
  }

  static Future<bool> hasGalleryPermission() async {
    return await ph.Permission.photos.isGranted;
  }

  static Future<bool> openAppSettings() async {
    return await ph.openAppSettings();
  }
}
