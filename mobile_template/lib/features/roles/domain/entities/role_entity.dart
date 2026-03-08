class RoleEntity {
  final int id;
  final String name;
  final String? description;
  final String? departmentName;
  final bool isActive;

  RoleEntity({
    required this.id,
    required this.name,
    this.description,
    this.departmentName,
    required this.isActive,
  });
}