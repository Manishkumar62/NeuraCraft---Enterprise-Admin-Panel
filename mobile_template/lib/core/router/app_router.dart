import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:neuracraft/features/roles/presentation/pages/role_permissions_page.dart';

import '../../core/di/injection.dart';
import '../../core/session/session_manager.dart';
import '../../core/services/permission_service.dart';

import '../../shared/navigation/main_shell.dart';
import '../../shared/splash_screen.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../features/users/presentation/pages/user_form_page.dart';
import '../../features/users/presentation/bloc/user_bloc.dart';
import '../../features/users/presentation/bloc/user_event.dart';

import '../../features/roles/presentation/bloc/role_bloc.dart';
import '../../features/roles/presentation/bloc/role_event.dart';
import '../../features/roles/presentation/pages/role_form_page.dart';

GoRouter createRouter() {
  final session = getIt<SessionManager>();

  return GoRouter(
    initialLocation: "/splash",

    // 🔥 THIS makes router reactive to login/logout
    refreshListenable: session,

    redirect: (context, state) {
      final session = getIt<SessionManager>();

      final isLoggedIn = session.isAuthenticated;
      final isBootstrapped = session.isBootstrapped;

      final isSplash = state.matchedLocation == "/splash";
      final isLoggingIn = state.matchedLocation == "/login";

      // ⏳ While bootstrapping → stay on splash
      if (!isBootstrapped) {
        return isSplash ? null : "/splash";
      }

      // ✅ After bootstrap finished

      // If logged in and on splash or login → go to dashboard
      if (isLoggedIn && (isSplash || isLoggingIn)) {
        return "/";
      }

      // If not logged in and not on login → go to login
      if (!isLoggedIn && !isLoggingIn) {
        return "/login";
      }

      return null;
    },

    routes: [
      GoRoute(
        path: "/splash",
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(path: "/login", builder: (context, state) => const LoginPage()),

      GoRoute(path: "/", builder: (context, state) => const MainShell()),

      GoRoute(
        path: "/users/add",
        builder: (context, state) {
          final session = getIt<SessionManager>();
          final permissionService = PermissionService(session.modules);

          return BlocProvider(
            create: (_) => getIt<UserBloc>(param1: permissionService),
            child: const UserFormPage(),
          );
        },
      ),

      GoRoute(
        path: "/users/edit/:id",
        builder: (context, state) {
          final id = int.parse(state.pathParameters["id"]!);

          final session = getIt<SessionManager>();
          final permissionService = PermissionService(session.modules);

          return BlocProvider(
            create: (_) =>
                getIt<UserBloc>(param1: permissionService)
                  ..add(LoadUserById(id)),
            child: UserFormPage(userId: id),
          );
        },
      ),

      GoRoute(
        path: "/roles/add",
        builder: (context, state) {
          final session = getIt<SessionManager>();
          final permissionService = PermissionService(session.modules);

          return BlocProvider(
            create: (_) => getIt<RoleBloc>(param1: permissionService),
            child: const RoleFormPage(),
          );
        },
      ),

      GoRoute(
        path: "/roles/edit/:id",
        builder: (context, state) {
          final id = int.parse(state.pathParameters["id"]!);

          final session = getIt<SessionManager>();
          final permissionService = PermissionService(session.modules);

          return BlocProvider(
            create: (_) =>
                getIt<RoleBloc>(param1: permissionService)
                  ..add(LoadRoleById(id)),
            child: RoleFormPage(roleId: id),
          );
        },
      ),

      GoRoute(
        path: "/roles/:id/permissions",
        builder: (context, state) {
          final id = int.parse(state.pathParameters["id"]!);

          final session = getIt<SessionManager>();
          final permissionService = PermissionService(session.modules);

          return BlocProvider(
            create: (_) =>
                getIt<RoleBloc>(param1: permissionService)
                  ..add(LoadRolePermissions(id)),
            child: RolePermissionsPage(roleId: id),
          );
        },
      ),

      GoRoute(
        path: "/:module",
        builder: (context, state) {
          final moduleName = state.pathParameters["module"] ?? "";

          return _DynamicModuleScreen(title: moduleName);
        },
      ),
    ],
  );
}

/// Temporary dynamic screen until real features are built
class _DynamicModuleScreen extends StatelessWidget {
  final String title;

  const _DynamicModuleScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title.toUpperCase())),
      body: Center(
        child: Text("Screen for /$title", style: const TextStyle(fontSize: 22)),
      ),
    );
  }
}
