class ModulePermissionEntity {
  final int? id;
  final String codename;
  final String label;
  final String category;
  final int? order;

  const ModulePermissionEntity({
    this.id,
    required this.codename,
    required this.label,
    required this.category,
    this.order,
  });
}

class ModuleEntity {
  final int id;
  final String name;
  final String icon;
  final String path;
  final int? parent;
  final int order;
  final bool isActive;
  final List<ModulePermissionEntity> permissions;
  final List<ModuleEntity> children;

  const ModuleEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.path,
    required this.parent,
    required this.order,
    required this.isActive,
    this.permissions = const [],
    this.children = const [],
  });
}
