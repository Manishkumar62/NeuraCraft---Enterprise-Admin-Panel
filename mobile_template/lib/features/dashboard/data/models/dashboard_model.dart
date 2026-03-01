import '../../domain/entities/dashboard_entity.dart';
import 'recent_user_model.dart';

class DashboardModel {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int totalRoles;
  final int activeRoles;
  final int totalDepartments;
  final int activeDepartments;
  final int totalModules;
  final int activeModules;
  final List<RecentUserModel> recentUsers;

  DashboardModel({
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

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalUsers: json['total_users'],
      activeUsers: json['active_users'],
      inactiveUsers: json['inactive_users'],
      totalRoles: json['total_roles'],
      activeRoles: json['active_roles'],
      totalDepartments: json['total_departments'],
      activeDepartments: json['active_departments'],
      totalModules: json['total_modules'],
      activeModules: json['active_modules'],
      recentUsers: (json['recent_users'] as List)
          .map((e) => RecentUserModel.fromJson(e))
          .toList(),
    );
  }

  DashboardEntity toEntity() {
    return DashboardEntity(
      totalUsers: totalUsers,
      activeUsers: activeUsers,
      inactiveUsers: inactiveUsers,
      totalRoles: totalRoles,
      activeRoles: activeRoles,
      totalDepartments: totalDepartments,
      activeDepartments: activeDepartments,
      totalModules: totalModules,
      activeModules: activeModules,
      recentUsers: recentUsers.map((e) => e.toEntity()).toList(),
    );
  }
}