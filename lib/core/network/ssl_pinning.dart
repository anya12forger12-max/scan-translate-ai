import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class SslPinningConfig {
  SslPinningConfig._();

  static const List<String> pinnedCertificates = [];

  static Future<http.Client> createHttpClient() async {
    final client = http.Client();
    if (!kReleaseMode) return client;

    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return false;
      };

    return http.IOClient(httpClient);
  }
}
