import 'package:flutter/material.dart';
import '../../domain/entities/recent_user_entity.dart';

class RecentUsersWidget extends StatelessWidget {
  final List<RecentUserEntity> users;

  const RecentUsersWidget({super.key, required this.users});

  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Header
        Row(
          children: [
            Text(
              "Recent Users",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
          ],
        ),

        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Column(
            children: users.map((user) {
              final initials =
                  "${user.firstName.isNotEmpty ? user.firstName[0] : ''}"
                  "${user.lastName.isNotEmpty ? user.lastName[0] : ''}";

              return ListTile(
                leading: CircleAvatar(child: Text(initials.toUpperCase())),
                title: Text("${user.firstName} ${user.lastName}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    const SizedBox(height: 2),
                    Text(
                      "Joined ${_formatDate(user.dateJoined)}",
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                )
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
