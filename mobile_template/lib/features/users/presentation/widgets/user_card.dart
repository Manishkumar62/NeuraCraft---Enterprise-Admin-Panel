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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(blurRadius: 6, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            child: Text(
              (user.firstName?.isNotEmpty == true
                      ? user.firstName![0]
                      : user.username[0])
                  .toUpperCase(),
            ),
          ),
          const SizedBox(width: 16),

          /// User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${user.firstName ?? ''} ${user.lastName ?? ''}"
                          .trim()
                          .isEmpty
                      ? user.username
                      : "${user.firstName ?? ''} ${user.lastName ?? ''}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(user.email,
                    style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 4),
                Text(
                  user.isActive ? "Active" : "Inactive",
                  style: TextStyle(
                    color: user.isActive ? Colors.green : Colors.red,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          /// Actions
          Row(
            children: [
              if (permissionService.canEdit('/users'))
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    context.push('/users/edit/${user.id}');
                  },
                ),
              if (permissionService.canDelete('/users'))
                IconButton(
                  icon: const Icon(Icons.delete),
                  color: Colors.red,
                  onPressed: () {
                    _confirmDelete(context, user.id);
                  },
                ),
            ],
          ),
        ],
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