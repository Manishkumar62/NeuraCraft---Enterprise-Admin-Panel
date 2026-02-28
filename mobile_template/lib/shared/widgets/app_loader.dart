import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  const AppLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(),
            SizedBox(height: 24),
            Text(
              "Setting up your workspace...",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}