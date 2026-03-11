class DepartmentEntity {
  final int id;
  final String name;
  final String code;
  final String? description;
  final bool isActive;

  DepartmentEntity({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.isActive,
  });
}