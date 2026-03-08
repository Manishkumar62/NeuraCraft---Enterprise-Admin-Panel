import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:neuracraft/shared/navigation/main_shell.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/session/session_manager.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../../../../core/services/permission_service.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_users_widget.dart';
import '../widgets/department_distribution_chart.dart';
import '../widgets/user_growth_chart.dart';

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
    final session = getIt<SessionManager>();

    if (!session.isAuthenticated) {
      return const Center(child: Text("Not authenticated"));
    }

    final permissionService = PermissionService(session.modules);

    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        if (state is DashboardLoading) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: List.generate(
                4,
                (_) => Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            ),
          );
        }

        if (state is DashboardError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    "Something went wrong",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "We couldn't load dashboard data.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text("Retry"),
                    onPressed: () {
                      context.read<DashboardBloc>().add(LoadDashboard());
                    },
                  ),
                ],
              ),
            ),
          );
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
                  /// Stats Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 2;

                      if (constraints.maxWidth > 900) {
                        crossAxisCount = 4;
                      } else if (constraints.maxWidth > 600) {
                        crossAxisCount = 3;
                      }

                      final cards = <Widget>[
                        if (permissionService.hasPermission('/dashboard', 'total_users'))
                          StatCard(
                            title: "Users",
                            value: data.totalUsers.toString(),
                            // subtitle: "Active: ${data.activeUsers}",
                            icon: Icons.people,
                            color: Colors.blue,
                            onTap: () {
                              final shell = context
                                  .findAncestorStateOfType<MainShellState>();
                              shell?.openModule('/users');
                            },
                          ),
                        if (permissionService.hasPermission('/dashboard', 'total_roles'))
                          StatCard(
                            title: "Roles",
                            value: data.totalRoles.toString(),
                            icon: Icons.security,
                            color: Colors.purple,
                          ),
                        if (permissionService.hasPermission('/dashboard', 'total_departments'))
                          StatCard(
                            title: "Departments",
                            value: data.totalDepartments.toString(),
                            icon: Icons.apartment,
                            color: Colors.orange,
                          ),
                        if (permissionService.hasPermission('/dashboard', 'total_modules'))
                          StatCard(
                            title: "Modules",
                            value: data.totalModules.toString(),
                            icon: Icons.extension,
                            color: Colors.green,
                          ),
                      ];

                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          mainAxisExtent:
                              120, // 🔥 fixed height prevents overflow
                        ),
                        itemCount: cards.length,
                        itemBuilder: (context, index) => cards[index],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const UserGrowthChart(),

                  const SizedBox(height: 24),

                  const DepartmentDistributionChart(),
                  const SizedBox(height: 26),
                  if (permissionService.hasPermission('/dashboard', 'recent_users'))
                    RecentUsersWidget(users: data.recentUsers),
                ],
              ),
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}
