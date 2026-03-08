import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.firstName,
    super.lastName,
    super.phone,
    super.employeeId,
    required super.isActive,
    super.departmentId,
    required super.roleIds,
    required super.roleNames,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final roles = (json['roles'] as List?) ?? [];

    final roleIds =
        roles.map((role) => role['id'] as int).toList();

    final roleNames =
        roles.map((role) => role['name'] as String).toList();

    final department = json['department'];


    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      employeeId: json['employee_id'],
      isActive: json['is_active'],
      departmentId: department != null ? department['id'] : null,
      roleIds: roleIds,
      roleNames: roleNames,
    );
  }
}