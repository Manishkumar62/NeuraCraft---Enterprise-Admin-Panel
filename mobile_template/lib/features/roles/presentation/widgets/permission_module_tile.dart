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
    final platformBadge = _getPlatformBadge();

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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.moduleName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: platformBadge.backgroundColor,
                      ),
                      child: Text(
                        platformBadge.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: platformBadge.foregroundColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

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

  ({
    String label,
    Color backgroundColor,
    Color foregroundColor,
  }) _getPlatformBadge() {
    if (module.availableOnWeb && module.availableOnMobile) {
      return (
        label: 'Web + Mobile',
        backgroundColor: Colors.green.withOpacity(0.15),
        foregroundColor: Colors.green,
      );
    }

    if (module.availableOnWeb) {
      return (
        label: 'Web Only',
        backgroundColor: Colors.blue.withOpacity(0.15),
        foregroundColor: Colors.blue,
      );
    }

    if (module.availableOnMobile) {
      return (
        label: 'Mobile Only',
        backgroundColor: Colors.orange.withOpacity(0.15),
        foregroundColor: Colors.orange,
      );
    }

    return (
      label: 'Hidden',
      backgroundColor: Colors.grey.withOpacity(0.15),
      foregroundColor: Colors.grey,
    );
  }
}
