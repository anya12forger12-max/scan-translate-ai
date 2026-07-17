import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

class SecurityUtils {
  SecurityUtils._();

  static String hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static bool isReleaseMode() {
    return kReleaseMode;
  }

  static bool isRunningOnEmulator() {
    if (!Platform.isAndroid) return false;
    try {
      final result = Process.runSync(
        'getprop',
        ['ro.kernel.qemu'],
      );
      return result.stdout.toString().trim() == '1';
    } catch (_) {
      return false;
    }
  }

  static bool isDeviceRooted() {
    if (!Platform.isAndroid) return false;
    try {
      final paths = [
        '/system/app/Superuser.apk',
        '/sbin/su',
        '/system/bin/su',
        '/system/xbin/su',
        '/data/local/xbin/su',
        '/data/local/bin/su',
        '/system/sd/xbin/su',
        '/system/bin/failsafe/su',
        '/data/local/su',
        '/su/bin/su',
      ];
      for (final path in paths) {
        if (File(path).existsSync()) return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
