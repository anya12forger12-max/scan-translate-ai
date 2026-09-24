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
import '../../features/ocr/data/datasources/ocr_datasource.dart';
import '../../features/ocr/data/repositories/ocr_repository_impl.dart';
import '../../features/scanner/data/datasources/scanner_datasource.dart';
import '../../features/scanner/data/repositories/scanner_repository_impl.dart';
import '../../features/settings/data/datasources/settings_datasource.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/translation/data/datasources/translation_datasource.dart';
import '../../features/translation/data/repositories/translation_repository_impl.dart';

final connectivityProvider = Provider<Connectivity>((ref) => Connectivity());
final networkInfoProvider = Provider<NetworkInfo>((ref) => NetworkInfoImpl(ref.watch(connectivityProvider)));
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);
final firestoreProvider = Provider<FirebaseFirestore>((ref) => FirebaseFirestore.instance);
final googleSignInProvider = Provider<GoogleSignIn>((ref) => GoogleSignIn());
final uuidProvider = Provider<Uuid>((ref) => const Uuid());
final imagePickerProvider = Provider<ImagePicker>((ref) => ImagePicker());
final flutterTtsProvider = Provider<FlutterTts>((ref) => FlutterTts());
final speechToTextProvider = Provider<stt.SpeechToText>((ref) => stt.SpeechToText());

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) => AuthRemoteDataSource(
  firebaseAuth: ref.watch(firebaseAuthProvider),
  firestore: ref.watch(firestoreProvider),
  googleSignIn: ref.watch(googleSignInProvider),
));
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(
  remoteDataSource: ref.watch(authRemoteDataSourceProvider),
));

final scannerRemoteDataSourceProvider = Provider<ScannerRemoteDataSource>((ref) => ScannerRemoteDataSource(
  firestore: ref.watch(firestoreProvider),
  firebaseAuth: ref.watch(firebaseAuthProvider),
  uuid: ref.watch(uuidProvider),
));
final scannerRepositoryProvider = Provider<ScannerRepositoryImpl>((ref) => ScannerRepositoryImpl(
  ds: ref.watch(scannerRemoteDataSourceProvider),
  uuid: ref.watch(uuidProvider),
));

final ocrRemoteDataSourceProvider = Provider<OcrRemoteDataSource>((ref) => OcrRemoteDataSource(
  picker: ref.watch(imagePickerProvider),
));
final ocrRepositoryProvider = Provider<OcrRepositoryImpl>((ref) => OcrRepositoryImpl(
  ds: ref.watch(ocrRemoteDataSourceProvider),
));

final translationRemoteDataSourceProvider = Provider<TranslationRemoteDataSource>((ref) => TranslationRemoteDataSource(
  flutterTts: ref.watch(flutterTtsProvider),
  speechToText: ref.watch(speechToTextProvider),
));
final translationRepositoryProvider = Provider<TranslationRepositoryImpl>((ref) => TranslationRepositoryImpl(
  ds: ref.watch(translationRemoteDataSourceProvider),
));

final historyRemoteDataSourceProvider = Provider<HistoryRemoteDataSource>((ref) => HistoryRemoteDataSource(
  firestore: ref.watch(firestoreProvider),
  firebaseAuth: ref.watch(firebaseAuthProvider),
));
final historyRepositoryProvider = Provider<HistoryRepositoryImpl>((ref) => HistoryRepositoryImpl(
  ds: ref.watch(historyRemoteDataSourceProvider),
));

final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>((ref) => SettingsLocalDataSource());
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) => SettingsRepositoryImpl(
  ds: ref.watch(settingsLocalDataSourceProvider),
));
