import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/permission_service.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';

class UserCard extends StatelessWidget {
  final UserEntity user;
  final PermissionService permissionService;

  const UserCard({
    super.key,
    required this.user,
    required this.permissionService,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(user.id),

      // swipe right → edit
      direction: permissionService.canDelete('/users')
          ? DismissDirection.endToStart
          : DismissDirection.none,

      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),

      confirmDismiss: (direction) async {
        _confirmDelete(context, user.id);
        return false;
      },

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
            CircleAvatar(
              radius: 24,
              child: Text(
                (user.firstName?.isNotEmpty == true
                        ? user.firstName![0]
                        : user.username[0])
                    .toUpperCase(),
              ),
            ),

            const SizedBox(width: 15),

            /// User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Name + status
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          "${user.firstName ?? ''} ${user.lastName ?? ''}"
                                  .trim()
                                  .isEmpty
                              ? user.username
                              : "${user.firstName ?? ''} ${user.lastName ?? ''}",
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
                          color: user.isActive
                              ? Colors.green.withOpacity(0.15)
                              : Colors.red.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          user.isActive ? "Active" : "Inactive",
                          style: TextStyle(
                            color: user.isActive ? Colors.green : Colors.red,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  /// Email
                  Text(
                    user.email,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),

                  const SizedBox(height: 5),

                  /// Actions
                  Row(
                    children: [
                      if (permissionService.canEdit('/users'))
                        TextButton.icon(
                          onPressed: () {
                            context.push('/users/edit/${user.id}');
                          },
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text("Edit"),
                        ),

                      if (permissionService.canDelete('/users'))
                        TextButton.icon(
                          onPressed: () {
                            _confirmDelete(context, user.id);
                          },
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text("Delete"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete User"),
        content: const Text("Are you sure you want to delete this user?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              context.read<UserBloc>().add(DeleteUserEvent(id));
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
