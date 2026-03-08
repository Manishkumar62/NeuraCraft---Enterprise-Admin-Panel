import 'package:flutter/material.dart';
import '../../domain/entities/module_permission_entity.dart';
import 'permission_category_row.dart';

class PermissionModuleTile extends StatelessWidget {
  final ModulePermissionEntity module;
  final Set<String> granted;

  final Function(String codename) onToggle;
  final Function(List<String>) onSelectAll;
  final Function(List<String>) onSelectCategory;

  const PermissionModuleTile({
    super.key,
    required this.module,
    required this.granted,
    required this.onToggle,
    required this.onSelectAll,
    required this.onSelectCategory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final allPermissions =
        module.availablePermissions.map((p) => p.codename).toList();

    final allGranted = granted.length == allPermissions.length;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: theme.colorScheme.surface,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// HEADER
          Row(
            children: [

              /// Module Icon
              Container(
                height: 32,
                width: 32,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: theme.colorScheme.primary.withOpacity(0.15),
                ),
                child: Icon(
                  Icons.grid_view_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(width: 10),

              /// Name
              Expanded(
                child: Text(
                  module.moduleName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),

              /// Counter
              Text(
                "${granted.length}/${allPermissions.length}",
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(width: 6),

              /// Select All
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  if (allGranted) {
                    onSelectAll([]);
                  } else {
                    onSelectAll(allPermissions);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: allGranted
                        ? theme.colorScheme.primary
                        : Colors.white.withOpacity(0.05),
                  ),
                  child: Text(
                    "All",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: allGranted
                          ? Colors.white
                          : Colors.grey.shade400,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// PERMISSION CATEGORIES
          PermissionCategoryRow(
            permissions: module.availablePermissions,
            granted: granted,
            onToggle: onToggle,
            onSelectCategory: onSelectCategory,
          ),
        ],
      ),
    );
  }
}