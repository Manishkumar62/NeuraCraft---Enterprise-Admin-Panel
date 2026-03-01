import 'recent_user_entity.dart';

class DashboardEntity {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int totalRoles;
  final int activeRoles;
  final int totalDepartments;
  final int activeDepartments;
  final int totalModules;
  final int activeModules;
  final List<RecentUserEntity> recentUsers;

  DashboardEntity({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.totalRoles,
    required this.activeRoles,
    required this.totalDepartments,
    required this.activeDepartments,
    required this.totalModules,
    required this.activeModules,
    required this.recentUsers,
  });
}