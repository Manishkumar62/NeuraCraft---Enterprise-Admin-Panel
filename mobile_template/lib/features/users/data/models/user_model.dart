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
    super.roleIds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      phone: json['phone'],
      employeeId: json['employee_id'],
      isActive: json['is_active'],

      departmentId: json['department_id'],

      roleIds: (json['role_ids'] as List?)
          ?.map((e) => e as int)
          .toList(),
    );
  }
}