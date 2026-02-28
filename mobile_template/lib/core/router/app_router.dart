import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../shared/navigation/main_shell.dart';

GoRouter createRouter(bool isAuthenticated) {
  return GoRouter(
    initialLocation: "/",
    redirect: (context, state) {
      final isLoggingIn = state.fullPath == "/login";

      if (!isAuthenticated && !isLoggingIn) {
        return "/login";
      }

      if (isAuthenticated && isLoggingIn) {
        return "/";
      }

      return null;
    },
    routes: [

      /// 🔐 LOGIN
      GoRoute(
        path: "/login",
        builder: (context, state) => const LoginPage(),
      ),

      /// 🏠 MAIN SHELL (Bottom Navigation Root)
      GoRoute(
        path: "/",
        builder: (context, state) => const MainShell(),
      ),

      /// 🔥 DYNAMIC MODULE ROUTES
      GoRoute(
        path: "/:module",
        builder: (context, state) {
          final moduleName = state.pathParameters["module"] ?? "";

          return _DynamicModuleScreen(
            title: moduleName,
          );
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
      appBar: AppBar(
        title: Text(title.toUpperCase()),
      ),
      body: Center(
        child: Text(
          "Screen for /$title",
          style: const TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}