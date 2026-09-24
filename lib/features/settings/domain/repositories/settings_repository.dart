import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<Either<Failure, UserSettings>> loadSettings();
  Future<Either<Failure, void>> saveSettings(UserSettings settings);
}
