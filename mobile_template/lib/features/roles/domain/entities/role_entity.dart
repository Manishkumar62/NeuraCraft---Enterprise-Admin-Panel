class RoleEntity {
  final int id;
  final String name;
  final String? description;
  final int? departmentId;
  final String? departmentName;
  final bool isActive;

  RoleEntity({
    required this.id,
    required this.name,
    this.description,
    this.departmentId,
    this.departmentName,
    required this.isActive,
  });
}