import 'package:get_it/get_it.dart';
import 'package:neuracraft/features/roles/domain/usecases/get_departments.dart';
import '../services/permission_service.dart';

import '../network/dio_client.dart';
import '../network/token_storage.dart';
import '../session/session_manager.dart';

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
import '../../features/users/domain/usecases/get_departments.dart';
import '../../features/users/domain/usecases/get_roles.dart';

import '../../features/roles/data/datasources/role_remote_ds.dart';
import '../../features/roles/data/repositories/role_repository_impl.dart';
import '../../features/roles/domain/repositories/role_repository.dart';
import '../../features/roles/domain/usecases/get_roles.dart';
import '../../features/roles/domain/usecases/get_role_by_id.dart';
import '../../features/roles/domain/usecases/create_role.dart';
import '../../features/roles/domain/usecases/update_role.dart';
import '../../features/roles/domain/usecases/delete_role.dart';
import '../../features/roles/domain/usecases/get_role_permissions.dart';
import '../../features/roles/domain/usecases/update_role_permissions.dart';
import '../../features/roles/presentation/bloc/role_bloc.dart';

import '../../features/departments/data/datasources/department_remote_ds.dart';
import '../../features/departments/data/repositories/department_repository_impl.dart';
import '../../features/departments/domain/repositories/department_repository.dart';
import '../../features/departments/domain/usecases/get_departments.dart';
import '../../features/departments/domain/usecases/get_department_by_id.dart';
import '../../features/departments/domain/usecases/create_department.dart';
import '../../features/departments/domain/usecases/update_department.dart';
import '../../features/departments/domain/usecases/delete_department.dart';
import '../../features/departments/presentation/bloc/department_bloc.dart';

import '../../features/modules/data/datasources/module_remote_ds.dart';
import '../../features/modules/data/repositories/module_repository_impl.dart';
import '../../features/modules/domain/repositories/module_repository.dart';
import '../../features/modules/domain/usecases/get_modules.dart';
import '../../features/modules/domain/usecases/get_module_by_id.dart';
import '../../features/modules/domain/usecases/create_module.dart';
import '../../features/modules/domain/usecases/update_module.dart';
import '../../features/modules/domain/usecases/delete_module.dart';
import '../../features/modules/presentation/bloc/module_bloc.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  getIt.registerLazySingleton<TokenStorage>(() => TokenStorage());

  getIt.registerLazySingleton<SessionManager>(() => SessionManager());

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
  getIt.registerLazySingleton(() => GetRolesForUser(getIt()));
  getIt.registerLazySingleton(() => GetDepartments(getIt()));

  getIt.registerFactoryParam<UserBloc, PermissionService, void>(
    (permissionService, _) => UserBloc(
      getUsers: getIt(),
      getUserById: getIt(),
      createUser: getIt(),
      updateUser: getIt(),
      deleteUser: getIt(),
      getRoles: getIt<GetRolesForUser>(),
      getDepartments: getIt(),
      permissionService: permissionService,
    ),
  );

  // ROLES
  getIt.registerLazySingleton<RoleRemoteDataSource>(
    () => RoleRemoteDataSource(getIt()),
  );

  getIt.registerLazySingleton<RoleRepository>(
    () => RoleRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton(() => GetAllRoles(getIt()));
  getIt.registerLazySingleton(() => GetRoleById(getIt()));
  getIt.registerLazySingleton(() => CreateRole(getIt()));
  getIt.registerLazySingleton(() => UpdateRole(getIt()));
  getIt.registerLazySingleton(() => DeleteRole(getIt()));
  getIt.registerLazySingleton(() => GetDepartmentsForRole(getIt()));
  getIt.registerLazySingleton(() => GetRolePermissions(getIt()));
  getIt.registerLazySingleton(() => UpdateRolePermissions(getIt()));

  getIt.registerFactoryParam<RoleBloc, PermissionService, void>(
    (permissionService, _) => RoleBloc(
      getRoles: getIt<GetAllRoles>(),
      getRoleById: getIt(),
      createRole: getIt(),
      updateRole: getIt(),
      deleteRole: getIt(),
      getDepartments: getIt<GetDepartmentsForRole>(),
      getRolePermissions: getIt(),
      updateRolePermissions: getIt(),
      permissionService: permissionService,
    ),
  );

  // DEPARTMENTS
  getIt.registerLazySingleton<DepartmentRemoteDataSource>(
    () => DepartmentRemoteDataSource(getIt()),
  );

  getIt.registerLazySingleton<DepartmentRepository>(
    () => DepartmentRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton(() => GetDepartmentsforDepart(getIt()));
  getIt.registerLazySingleton(() => GetDepartmentById(getIt()));
  getIt.registerLazySingleton(() => CreateDepartment(getIt()));
  getIt.registerLazySingleton(() => UpdateDepartment(getIt()));
  getIt.registerLazySingleton(() => DeleteDepartment(getIt()));

  getIt.registerFactoryParam<DepartmentBloc, PermissionService, void>(
    (permissionService, _) => DepartmentBloc(
      getDepartments: getIt<GetDepartmentsforDepart>(),
      getDepartmentById: getIt<GetDepartmentById>(),
      createDepartment: getIt<CreateDepartment>(),
      updateDepartment: getIt<UpdateDepartment>(),
      deleteDepartment: getIt<DeleteDepartment>(),
      permissionService: permissionService,
    ),
  );

  // MODULES
  getIt.registerLazySingleton<ModuleRemoteDataSource>(
    () => ModuleRemoteDataSource(getIt()),
  );

  getIt.registerLazySingleton<ModuleRepository>(
    () => ModuleRepositoryImpl(getIt()),
  );

  getIt.registerLazySingleton(() => GetModules(getIt()));
  getIt.registerLazySingleton(() => GetModuleById(getIt()));
  getIt.registerLazySingleton(() => CreateModule(getIt()));
  getIt.registerLazySingleton(() => UpdateModule(getIt()));
  getIt.registerLazySingleton(() => DeleteModule(getIt()));

  getIt.registerFactoryParam<ModuleBloc, PermissionService, void>(
    (permissionService, _) => ModuleBloc(
      getModules: getIt<GetModules>(),
      getModuleById: getIt<GetModuleById>(),
      createModule: getIt<CreateModule>(),
      updateModule: getIt<UpdateModule>(),
      deleteModule: getIt<DeleteModule>(),
      permissionService: permissionService,
    ),
  );

}
