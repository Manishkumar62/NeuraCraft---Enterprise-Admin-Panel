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

import '../../features/users/data/datasources/user_remote_datasource.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/get_users.dart';
import '../../features/users/presentation/bloc/user_bloc.dart';
import '../../features/users/domain/usecases/create_user.dart';
import '../../features/users/domain/usecases/delete_user.dart';
import '../../features/users/domain/usecases/get_user_by_id.dart';
import '../../features/users/domain/usecases/update_user.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  getIt.registerLazySingleton<DioClient>(
    () => DioClient(getIt<TokenStorage>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>(), getIt<TokenStorage>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  getIt.registerFactory<AuthBloc>(() => AuthBloc(getIt<AuthRepository>()));

  getIt.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(getIt<DashboardRemoteDataSource>()),
  );

  getIt.registerLazySingleton<GetDashboardStats>(
    () => GetDashboardStats(getIt<DashboardRepository>()),
  );

  // USERS
  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(getIt()),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton(() => GetUsers(getIt()));
  getIt.registerLazySingleton(() => GetUserById(getIt()));
  getIt.registerLazySingleton(() => CreateUser(getIt()));
  getIt.registerLazySingleton(() => UpdateUser(getIt()));
  getIt.registerLazySingleton(() => DeleteUser(getIt()));

  getIt.registerFactory(
    () => UserBloc(
      getUsers: getIt(),
      getUserById: getIt(),
      createUser: getIt(),
      updateUser: getIt(),
      deleteUser: getIt(),
      permissionService: getIt(),
    ),
  );
}
