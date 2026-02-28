import '../../features/menu/domain/models/module_model.dart';

class PermissionHelper {
  static bool hasPermission(
    List<AppModule> modules,
    String path,
    String permission,
  ) {
    try {
      final module = modules.firstWhere(
        (m) => m.path == path,
      );

      return module.permissions.contains(permission);
    } catch (_) {
      return false;
    }
  }

  static bool hasModule(
    List<AppModule> modules,
    String path,
  ) {
    return modules.any((m) => m.path == path);
  }
}