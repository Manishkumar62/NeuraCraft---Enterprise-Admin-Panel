import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(const NeuraCraftApp());
}

class NeuraCraftApp extends StatelessWidget {
  const NeuraCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isAuthenticated = state is AuthAuthenticated;

          final router = createRouter(isAuthenticated);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}