import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/session/session_manager.dart';
import '../../../../core/services/permission_service.dart';
import '../bloc/user_bloc.dart';
import '../bloc/user_event.dart';
import '../bloc/user_state.dart';
import '../widgets/user_card.dart';

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),

          const SizedBox(height: 14),

          const Text(
            "No users found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 6),

          Text(
            "Create your first user",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class UserListPage extends StatefulWidget {
  const UserListPage({super.key});

  @override
  State<UserListPage> createState() => _UserListPageState();
}

class _UserListPageState extends State<UserListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final permissionService = PermissionService(session.modules);

    return Column(
      children: [
        /// SEARCH BAR
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// USERS HEADER
              // BlocBuilder<UserBloc, UserState>(
              //   builder: (context, state) {
              //     if (state is UserListLoaded) {
              //       return Text(
              //         "Users (${state.users.length})",
              //         style: const TextStyle(
              //           fontSize: 18,
              //           fontWeight: FontWeight.w600,
              //         ),
              //       );
              //     }

              //     return const Text(
              //       "Users",
              //       style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              //     );
              //   },
              // ),

              // const SizedBox(height: 10),

              /// SEARCH BAR
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search users...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _query = value.toLowerCase();
                  });
                },
              ),
            ],
          ),
        ),

        Expanded(
          child: BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              /// LOADING
              if (state is UserLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (_, __) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      height: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.05),
                      ),
                    );
                  },
                );
              }

              /// ERROR
              if (state is UserError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context.read<UserBloc>().add(LoadUsers()),
                );
              }

              /// DATA
              if (state is UserListLoaded) {
                var users = state.users;

                /// LOCAL SEARCH FILTER
                if (_query.isNotEmpty) {
                  users = users.where((user) {
                    final name =
                        "${user.firstName ?? ''} ${user.lastName ?? ''}"
                            .toLowerCase();

                    return name.contains(_query) ||
                        user.email.toLowerCase().contains(_query) ||
                        user.username.toLowerCase().contains(_query);
                  }).toList();
                }

                if (users.isEmpty) {
                  return const _EmptyView();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<UserBloc>().add(LoadUsers());
                  },

                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),

                    itemCount: users.length,

                    separatorBuilder: (_, __) => const SizedBox(height: 12),

                    itemBuilder: (context, index) {
                      final user = users[index];

                      return UserCard(
                        user: user,
                        permissionService: permissionService,
                      );
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }
}
