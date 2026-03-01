import 'package:get_it/get_it.dart';
import '../network/dio_client.dart';
import '../network/token_storage.dart';

import '../../features/auth/data/auth_remote_data_source.dart';
import '../../features/auth/data/auth_repository_impl.dart';
import '../../features/auth/domain/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

import '../../features/dashboard/data/datasources/dashboard_remote_ds.dart';
import '../../features/dashboard/data/repositories/dashboard_repo_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_stats.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<TokenStorage>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(
      getIt<DioClient>(),
      getIt<TokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
    ),
  );

  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      getIt<DashboardRemoteDataSource>(),
    ),
  );

  getIt.registerLazySingleton<GetDashboardStats>(
    () => GetDashboardStats(
      getIt<DashboardRepository>(),
    ),
  );
}