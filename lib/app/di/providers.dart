import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:uuid/uuid.dart';

import '../../core/network/network_info.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/history/data/datasources/history_datasource.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/history/presentation/providers/history_provider.dart';
import '../../features/ocr/data/datasources/ocr_datasource.dart';
import '../../features/ocr/data/repositories/ocr_repository_impl.dart';
import '../../features/ocr/presentation/providers/ocr_provider.dart';
import '../../features/scanner/data/datasources/scanner_datasource.dart';
import '../../features/scanner/data/repositories/scanner_repository_impl.dart';
import '../../features/scanner/presentation/providers/scanner_provider.dart';
import '../../features/translation/data/datasources/translation_datasource.dart';
import '../../features/translation/data/repositories/translation_repository_impl.dart';
import '../../features/translation/presentation/providers/translation_provider.dart';

// Core Services
final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl(ref.watch(connectivityProvider)));
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());
final uuidProvider = Provider<Uuid>((ref) => const Uuid());
final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());
final flutterTtsProvider = Provider<FlutterTts>((ref) => FlutterTts());
final speechToTextProvider = Provider<stt.SpeechToText>((ref) => stt.SpeechToText());

// Auth
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(remoteDataSource: ref.watch(authRemoteDataSourceProvider));
});

// Scanner
final scannerRemoteDataSourceProvider = Provider<ScannerRemoteDataSource>((ref) {
  return ScannerRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
    uuid: ref.watch(uuidProvider),
  );
});

final scannerRepositoryProvider = Provider<ScannerRepositoryImpl>((ref) {
  return ScannerRepositoryImpl(
    remoteDataSource: ref.watch(scannerRemoteDataSourceProvider),
    uuid: ref.watch(uuidProvider),
  );
});

// OCR
final ocrRemoteDataSourceProvider = Provider<OcrRemoteDataSource>((ref) {
  return OcrRemoteDataSource(imagePicker: ref.watch(imagePickerProvider));
});

final ocrRepositoryProvider = Provider<OcrRepositoryImpl>((ref) {
  return OcrRepositoryImpl(remoteDataSource: ref.watch(ocrRemoteDataSourceProvider));
});

// Translation
final translationRemoteDataSourceProvider = Provider<TranslationRemoteDataSource>((ref) {
  return TranslationRemoteDataSource(
    flutterTts: ref.watch(flutterTtsProvider),
    speechToText: ref.watch(speechToTextProvider),
  );
});

final translationRepositoryProvider = Provider<TranslationRepositoryImpl>((ref) {
  return TranslationRepositoryImpl(remoteDataSource: ref.watch(translationRemoteDataSourceProvider));
});

// History
final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) {
  return HistoryRemoteDataSource(
    firestore: ref.watch(firestoreProvider),
    firebaseAuth: ref.watch(firebaseAuthProvider),
  );
});

final historyRepositoryProvider = Provider<HistoryRepositoryImpl>((ref) {
  return HistoryRepositoryImpl(remoteDataSource: ref.watch(historyRemoteDataSourceProvider));
});
