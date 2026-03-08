import 'package:flutter/material.dart';

class PermissionChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const PermissionChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: selected
              ? theme.colorScheme.primary
              : Colors.white.withOpacity(0.05),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: selected ? Colors.white : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }
}