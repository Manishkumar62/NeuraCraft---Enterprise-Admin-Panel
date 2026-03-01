import 'dart:ui';
import 'package:flutter/material.dart';

class AppLoader extends StatelessWidget {
  final String message;
  final bool fullscreen;

  const AppLoader({
    super.key,
    this.message = "Setting up your workspace...",
    this.fullscreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final loaderContent = Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 28,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 40,
                  width: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (!fullscreen) return loaderContent;

    return Scaffold(
      backgroundColor: const Color(0xFF0F1115),
      body: loaderContent,
    );
  }
}