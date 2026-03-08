import '../../domain/entities/role_entity.dart';

class RoleModel extends RoleEntity {
  RoleModel({
    required super.id,
    required super.name,
    super.description,
    super.departmentName,
    required super.isActive,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      departmentName: json['department_name'],
      isActive: json['is_active'],
    );
  }
}