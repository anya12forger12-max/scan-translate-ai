import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource ds;
  SettingsRepositoryImpl({required this.ds});

  @override Future<Either<Failure, UserSettings>> loadSettings() async {
    try { return Right(await ds.loadSettings()); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }

  @override Future<Either<Failure, void>> saveSettings(UserSettings settings) async {
    try { return Right(await ds.saveSettings(settings)); }
    on AppException catch (e) { return Left(mapExceptionToFailure(e)); }
  }
}
