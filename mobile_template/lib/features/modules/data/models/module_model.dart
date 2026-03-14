import '../../domain/entities/module_entity.dart';

class ModulePermissionModel extends ModulePermissionEntity {
  const ModulePermissionModel({
    super.id,
    required super.codename,
    required super.label,
    required super.category,
    super.order,
  });

  factory ModulePermissionModel.fromJson(Map<String, dynamic> json) {
    return ModulePermissionModel(
      id: json['id'],
      codename: json['codename'] ?? '',
      label: json['label'] ?? '',
      category: json['category'] ?? 'action',
      order: json['order'],
    );
  }
}

class ModuleModel extends ModuleEntity {
  const ModuleModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.path,
    required super.parent,
    required super.order,
    required super.isActive,
    super.permissions,
    super.children,
  });

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'] ?? '',
      path: json['path'],
      parent: json['parent'],
      order: json['order'] ?? 0,
      isActive: json['is_active'] ?? true,
      permissions: (json['permissions'] as List?)
              ?.map((e) => ModulePermissionModel.fromJson(e))
              .toList() ??
          [],
      children: (json['children'] as List?)
              ?.map((e) => ModuleModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
