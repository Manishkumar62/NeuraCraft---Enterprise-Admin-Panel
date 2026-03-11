import '../../domain/entities/department_entity.dart';

class DepartmentModel extends DepartmentEntity {
  DepartmentModel({
    required super.id,
    required super.name,
    required super.code,
    super.description,
    required super.isActive,
  });

  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      isActive: json['is_active'],
    );
  }
}