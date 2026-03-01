import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../../core/services/permission_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_users_widget.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;

    if (authState is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: Text("Not authenticated")));
    }

    final permissionService = PermissionService(authState.modules);

    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DashboardError) {
            return Center(child: Text(state.message));
          }

          if (state is DashboardLoaded) {
            final data = state.data;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<DashboardBloc>().add(RefreshDashboard());
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.4,
                      children: [
                        if (permissionService.canView('/users'))
                          StatCard(
                            title: "Users",
                            value: data.totalUsers.toString(),
                            subtitle: "Active: ${data.activeUsers}",
                          ),

                        if (permissionService.canView('/roles'))
                          StatCard(
                            title: "Roles",
                            value: data.totalRoles.toString(),
                          ),

                        if (permissionService.canView('/departments'))
                          StatCard(
                            title: "Departments",
                            value: data.totalDepartments.toString(),
                          ),

                        if (permissionService.canView('/modules'))
                          StatCard(
                            title: "Modules",
                            value: data.totalModules.toString(),
                          ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    if (permissionService.canView('/users'))
                      RecentUsersWidget(users: data.recentUsers),
                  ],
                ),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
