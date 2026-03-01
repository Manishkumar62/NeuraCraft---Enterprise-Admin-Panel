import 'package:flutter/material.dart';
import '../../domain/entities/recent_user_entity.dart';

class RecentUsersWidget extends StatelessWidget {
  final List<RecentUserEntity> users;

  const RecentUsersWidget({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Recent Users",
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        ...users.map((user) => ListTile(
          title: Text("${user.firstName} ${user.lastName}"),
          subtitle: Text(user.email),
          trailing: Text(user.username),
        )),
      ],
    );
  }
}