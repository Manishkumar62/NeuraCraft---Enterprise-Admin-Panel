import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../network/token_storage.dart';

import '../../features/auth/data/auth_remote_data_source.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  sl.registerLazySingleton<TokenStorage>(() => TokenStorage());

  sl.registerLazySingleton<DioClient>(
    () => DioClient(sl<TokenStorage>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      sl<DioClient>(),
      sl<TokenStorage>(),
    ),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      sl<AuthRemoteDataSource>(),
    ),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(sl<AuthRepository>()),
  );
}