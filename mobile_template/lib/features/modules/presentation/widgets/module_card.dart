import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/permission_service.dart';
import '../../domain/entities/module_entity.dart';
import '../bloc/module_bloc.dart';
import '../bloc/module_event.dart';

class ModuleCard extends StatelessWidget {
  final ModuleEntity module;
  final PermissionService permissionService;
  final int level;
  final bool isExpanded;
  final VoidCallback? onToggleExpand;

  const ModuleCard({
    super.key,
    required this.module,
    required this.permissionService,
    this.level = 0,
    this.isExpanded = false,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final canEdit = permissionService.canEdit('/modules');
    final canDelete = permissionService.canDelete('/modules');
    final hasChildren = module.children.isNotEmpty;
    DismissDirection direction = DismissDirection.none;

    if (canEdit && canDelete) {
      direction = DismissDirection.horizontal;
    } else if (canEdit) {
      direction = DismissDirection.startToEnd;
    } else if (canDelete) {
      direction = DismissDirection.endToStart;
    }

    return Padding(
      padding: EdgeInsets.only(left: level * 18.0),
      child: Dismissible(
        key: ValueKey('module-${module.id}'),
        direction: direction,
        background: canEdit
            ? Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(left: 20),
                color: Colors.blue,
                child: const Icon(Icons.edit, color: Colors.white),
              )
            : canDelete
                ? Container(color: Colors.transparent)
                : null,
        secondaryBackground: canDelete
            ? Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                color: Colors.red,
                child: const Icon(Icons.delete, color: Colors.white),
              )
            : null,
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd && canEdit) {
            context.push('/modules/edit/${module.id}');
            return false;
          }

          if (direction == DismissDirection.endToStart && canDelete) {
            _confirmDelete(context, module.id, module.name);
            return false;
          }

          return false;
        },
        child: GestureDetector(
          onTap: canEdit ? () => context.push('/modules/edit/${module.id}') : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasChildren)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(
                        isExpanded ? Icons.expand_more : Icons.chevron_right,
                      ),
                      onPressed: onToggleExpand,
                    ),
                  )
                else
                  const SizedBox(width: 2),
                CircleAvatar(
                  radius: 24,
                  child: Icon(
                    hasChildren ? Icons.folder_outlined : _mapIconData(module.icon),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              module.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: module.isActive
                                  ? Colors.green.withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              module.isActive ? "Active" : "Inactive",
                              style: TextStyle(
                                color: module.isActive ? Colors.green : Colors.red,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        module.path,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Icon: ${module.icon}  |  Order: ${module.order}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildPlatformChip(
                            label: 'Web',
                            enabled: module.availableOnWeb,
                            activeColor: Colors.blue,
                          ),
                          _buildPlatformChip(
                            label: 'Mobile',
                            enabled: module.availableOnMobile,
                            activeColor: Colors.orange,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Module"),
        content: Text('Are you sure you want to delete "$name"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<ModuleBloc>().add(DeleteModuleEvent(id));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  Widget _buildPlatformChip({
    required String label,
    required bool enabled,
    required Color activeColor,
  }) {
    final backgroundColor = enabled
        ? activeColor.withOpacity(0.15)
        : Colors.grey.withOpacity(0.12);
    final foregroundColor = enabled ? activeColor : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foregroundColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _mapIconData(String iconName) {
    switch (iconName) {
      case 'dashboard':
        return Icons.dashboard;
      case 'users':
        return Icons.people;
      case 'user':
        return Icons.person;
      case 'shield':
        return Icons.security;
      case 'building':
        return Icons.apartment;
      case 'modules':
        return Icons.view_module;
      case 'chart':
        return Icons.bar_chart;
      case 'document':
        return Icons.description;
      case 'settings':
        return Icons.settings;
      case 'folder':
        return Icons.folder;
      default:
        return Icons.circle;
    }
  }
}
