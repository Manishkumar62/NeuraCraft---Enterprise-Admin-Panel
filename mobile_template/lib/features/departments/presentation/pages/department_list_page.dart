import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/session/session_manager.dart';
import '../bloc/department_bloc.dart';
import '../bloc/department_state.dart';
import '../bloc/department_event.dart';
import '../widgets/department_card.dart';

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
  final VoidCallback? onCreate;

  const _EmptyView({this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          const Text(
            "No departments found",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            "Create your first department",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Create Department"),
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class DepartmentListPage extends StatefulWidget {
  const DepartmentListPage({super.key});

  @override
  State<DepartmentListPage> createState() => _DepartmentListPageState();
}

class _DepartmentListPageState extends State<DepartmentListPage> {
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
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search departments...",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = "");
                          },
                        )
                      : null,
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
          child: BlocBuilder<DepartmentBloc, DepartmentState>(
            builder: (context, state) {
              if (state is DepartmentLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: 6,
                  itemBuilder: (_, __) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Colors.black26,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 12,
                                  width: 120,
                                  color: Colors.black26,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 10,
                                  width: 180,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              if (state is DepartmentError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context.read<DepartmentBloc>().add(LoadDepartments()),
                );
              }

              if (state is DepartmentsLoaded) {
                var departments = state.departments;

                /// LOCAL SEARCH FILTER
                if (_query.isNotEmpty) {
                  departments = departments.where((department) {
                    final name = department.name.toLowerCase();

                    return name.contains(_query);
                  }).toList();
                }

                if (departments.isEmpty) {
                  return _EmptyView(onCreate: () => context.push('/departments/add'));
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<DepartmentBloc>().add(LoadDepartments());
                  },

                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                    itemCount: departments.length,
                    itemBuilder: (context, index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: DepartmentCard(
                          department: departments[index],
                          permissionService: permissionService,
                        ),
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
