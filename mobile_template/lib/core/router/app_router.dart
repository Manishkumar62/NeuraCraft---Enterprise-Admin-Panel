import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/session/session_manager.dart';

import '../../features/auth/presentation/login_page.dart';
import '../../shared/navigation/main_shell.dart';
import '../../shared/splash_screen.dart';

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
