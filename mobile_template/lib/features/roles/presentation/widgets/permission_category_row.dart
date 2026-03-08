import 'package:flutter/material.dart';
import '../../domain/entities/module_permission_entity.dart';
import 'permission_chip.dart';

class PermissionCategoryRow extends StatelessWidget {
  final List<PermissionEntity> permissions;
  final Set<String> granted;

  final Function(String codename) onToggle;
  final Function(List<String>) onSelectCategory;

  const PermissionCategoryRow({
    super.key,
    required this.permissions,
    required this.granted,
    required this.onToggle,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {

    /// group by category
    final Map<String, List<PermissionEntity>> grouped = {};

    for (final p in permissions) {
      grouped.putIfAbsent(p.category ?? "other", () => []).add(p);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: grouped.entries.map((entry) {

        final category = entry.key;
        final perms = entry.value;

        final categoryGranted =
            perms.where((p) => granted.contains(p.codename)).length;

        return Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// Category Button
              GestureDetector(
                onTap: () {
                  final codes = perms.map((p) => p.codename).toList();
                  onSelectCategory(codes);
                },
                child: Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.white.withOpacity(0.05),
                  ),
                  child: Text(
                    category.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 6),

              /// Permission Chips
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: perms.map((p) {
                    final isGranted = granted.contains(p.codename);

                    return PermissionChip(
                      label: p.label,
                      selected: isGranted,
                      onTap: () => onToggle(p.codename),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}