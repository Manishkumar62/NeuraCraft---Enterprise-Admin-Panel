import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/session/session_manager.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../shared/navigation/main_shell.dart';

GoRouter createRouter() {
  final session = getIt<SessionManager>();

  return GoRouter(
    initialLocation: "/",

    // 🔥 THIS makes router reactive to login/logout
    refreshListenable: session,

    redirect: (context, state) {
      final isLoggedIn = session.isAuthenticated;
      final isLoggingIn = state.matchedLocation == "/login";

      if (!isLoggedIn && !isLoggingIn) {
        return "/login";
      }

      if (isLoggedIn && isLoggingIn) {
        return "/";
      }

      return null;
    },

    routes: [
      /// 🔐 LOGIN
      GoRoute(path: "/login", builder: (context, state) => const LoginPage()),

      /// 🏠 MAIN SHELL
      GoRoute(path: "/", builder: (context, state) => const MainShell()),

      /// 🔥 DYNAMIC MODULE ROUTES
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
