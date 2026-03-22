import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/permission_service.dart';
import '../../domain/entities/department_entity.dart';
import '../bloc/department_bloc.dart';
import '../bloc/department_event.dart';

class DepartmentCard extends StatelessWidget {
  final DepartmentEntity department;
  final PermissionService permissionService;

  const DepartmentCard({
    super.key,
    required this.department,
    required this.permissionService,
  });

  @override
  Widget build(BuildContext context) {
    final canEdit = permissionService.canEdit('/departments');
    final canDelete = permissionService.canDelete('/departments');
    DismissDirection direction = DismissDirection.none;

    if (canEdit && canDelete) {
      direction = DismissDirection.horizontal;
    } else if (canEdit) {
      direction = DismissDirection.startToEnd;
    } else if (canDelete) {
      direction = DismissDirection.endToStart;
    }

    return Dismissible(
      key: ValueKey(department.id),

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
          context.push('/departments/edit/${department.id}');
          return false;
        }

        if (direction == DismissDirection.endToStart && canDelete) {
          _confirmDelete(context, department.id);
          return false;
        }

        return false;
      },

      child: GestureDetector(
        onTap: canEdit
            ? () {
                context.push('/departments/edit/${department.id}');
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
              CircleAvatar(radius: 24, child: Text(department.name[0].toUpperCase())),

              const SizedBox(width: 15),

              /// Department Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Name + status
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            department.name,
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
                            color: department.isActive
                                ? Colors.green.withOpacity(0.15)
                                : Colors.red.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            department.isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              color: department.isActive ? Colors.green : Colors.red,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      department.code,
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
        title: const Text("Delete Department"),
        content: const Text("Are you sure you want to delete this department?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<DepartmentBloc>().add(DeleteDepartmentEvent(id));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
