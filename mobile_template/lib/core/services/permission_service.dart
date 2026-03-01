import '../../features/menu/domain/models/module_model.dart';

class PermissionService {
  final List<AppModule> modules;

  PermissionService(this.modules);

  List<String> _getPermissions(String path) {
    for (final module in modules) {
      if (module.path == path) {
        return module.permissions;
      }

      for (final child in module.children ?? []) {
        if (child.path == path) {
          return child.permissions;
        }
      }
    }

    return [];
  }

  bool hasPermission(String path, String permission) {
    final permissions = _getPermissions(path);
    return permissions.contains(permission);
  }

  bool hasAnyPermission(String path, List<String> permissionsToCheck) {
    final permissions = _getPermissions(path);
    return permissionsToCheck.any((p) => permissions.contains(p));
  }

  bool hasAllPermissions(String path, List<String> permissionsToCheck) {
    final permissions = _getPermissions(path);
    return permissionsToCheck.every((p) => permissions.contains(p));
  }

  bool canView(String path) => hasPermission(path, 'view');
  bool canAdd(String path) => hasPermission(path, 'add');
  bool canEdit(String path) => hasPermission(path, 'edit');
  bool canDelete(String path) => hasPermission(path, 'delete');
}