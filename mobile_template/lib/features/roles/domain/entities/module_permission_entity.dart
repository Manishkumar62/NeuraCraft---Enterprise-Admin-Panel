class ModulePermissionEntity {
  final int moduleId;
  final String moduleName;
  final bool availableOnWeb;
  final bool availableOnMobile;

  final List<PermissionEntity> availablePermissions;
  final List<String> grantedPermissions;

  final List<ModulePermissionEntity> children;

  ModulePermissionEntity({
    required this.moduleId,
    required this.moduleName,
    this.availableOnWeb = true,
    this.availableOnMobile = true,
    required this.availablePermissions,
    required this.grantedPermissions,
    this.children = const [],
  });
}

class PermissionEntity {
  final int id;
  final String codename;
  final String label;
  final String category;

  PermissionEntity({
    required this.id,
    required this.codename,
    required this.label,
    required this.category,
  });
}
