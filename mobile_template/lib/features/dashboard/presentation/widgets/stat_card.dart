import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.labelMedium),
            const Spacer(),
            Text(value,
                style: Theme.of(context).textTheme.headlineMedium),
            if (subtitle != null)
              Text(subtitle!,
                  style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}