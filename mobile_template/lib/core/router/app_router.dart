import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../shared/navigation/main_shell.dart';

GoRouter createRouter(bool isAuthenticated) {
  return GoRouter(
    initialLocation: "/login",
    redirect: (context, state) {
      if (!isAuthenticated && state.fullPath != "/login") {
        return "/login";
      }

      if (isAuthenticated && state.fullPath == "/login") {
        return "/";
      }

      return null;
    },
    routes: [
      GoRoute(
        path: "/login",
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: "/",
        builder: (context, state) => const MainShell(),
      ),
    ],
  );
}