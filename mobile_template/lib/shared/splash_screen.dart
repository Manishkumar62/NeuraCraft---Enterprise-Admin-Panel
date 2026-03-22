import 'package:flutter/material.dart';

import '../shared/widgets/app_loader.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLoader(
      message: "Initializing NeuraCraft...",
      fullscreen: true,
    );
  }
}
