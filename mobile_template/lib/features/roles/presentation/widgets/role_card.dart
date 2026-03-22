import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/permission_service.dart';
import '../../domain/entities/role_entity.dart';
import '../bloc/role_bloc.dart';
import '../bloc/role_event.dart';

class RoleCard extends StatelessWidget {
  final RoleEntity role;
  final PermissionService permissionService;

  const RoleCard({
    super.key,
    required this.role,
    required this.permissionService,
  });

  @override
  Widget build(BuildContext context) {
    final canEdit = permissionService.canEdit('/roles');
    final canDelete = permissionService.canDelete('/roles');
    DismissDirection direction = DismissDirection.none;
    final canAssign = permissionService.hasPermission(
      '/roles',
      'assign_permissions',
    );

    if (canEdit && canDelete) {
      direction = DismissDirection.horizontal;
    } else if (canEdit) {
      direction = DismissDirection.startToEnd;
    } else if (canDelete) {
      direction = DismissDirection.endToStart;
    }

    return Dismissible(
      key: ValueKey(role.id),

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
          context.push('/roles/edit/${role.id}');
          return false;
        }

        if (direction == DismissDirection.endToStart && canDelete) {
          _confirmDelete(context, role.id);
          return false;
        }

        return false;
      },

      child: GestureDetector(
        onTap: canEdit
            ? () {
                context.push('/roles/edit/${role.id}');
              }
            : null,
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
            children: [
              /// Avatar
              CircleAvatar(radius: 24, child: Text(role.name[0].toUpperCase())),

              const SizedBox(width: 15),

              /// Role Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name + status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            role.name,
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
                            color: role.isActive
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            role.isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              color: role.isActive ? Colors.green : Colors.red,
                              fontSize: 11,
                            ),
                          ),
                        ),

                        if (canAssign)
                          IconButton(
                            icon: const Icon(
                              Icons.key,
                              size: 18,
                              color: Colors.orange,
                            ),
                            tooltip: "Manage Permissions",
                            onPressed: () {
                              context.push('/roles/${role.id}/permissions');
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      role.departmentName ?? "No department",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Role"),
        content: const Text("Are you sure you want to delete this role?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<RoleBloc>().add(DeleteRoleEvent(id));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
