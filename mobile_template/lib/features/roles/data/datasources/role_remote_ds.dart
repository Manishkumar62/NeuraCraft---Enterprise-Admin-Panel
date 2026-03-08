import '../../domain/entities/module_permission_entity.dart';

import '../../../../core/network/dio_client.dart';
import '../models/role_model.dart';

class RoleRemoteDataSource {
  final DioClient dioClient;

  RoleRemoteDataSource(this.dioClient);

  Future<List<RoleModel>> getRoles() async {
    final res = await dioClient.dio.get('/roles/');
    return (res.data as List).map((e) => RoleModel.fromJson(e)).toList();
  }

  Future<RoleModel> getRoleById(int id) async {
    final response = await dioClient.dio.get('/roles/$id/');
    return RoleModel.fromJson(response.data);
  }

  Future<RoleModel> createRole(Map<String, dynamic> data) async {
    final response = await dioClient.dio.post('/roles/', data: data);
    return RoleModel.fromJson(response.data);
  }

  Future<RoleModel> updateRole(int id, Map<String, dynamic> data) async {
    final response = await dioClient.dio.put('/roles/$id/', data: data);

    return RoleModel.fromJson(response.data);
  }

  Future<void> deleteRole(int id) async {
    await dioClient.dio.delete('/roles/$id/');
  }

  Future<List<ModulePermissionEntity>> getRolePermissions(int roleId) async {
    final response = await dioClient.dio.get('/roles/$roleId/permissions/');

    final data = response.data as List;

    List<ModulePermissionEntity> parseModules(List modules) {
      return modules.map((m) {
        return ModulePermissionEntity(
          moduleId: m['module_id'],
          moduleName: m['module_name'],
          availablePermissions: (m['available_permissions'] as List)
              .map(
                (p) => PermissionEntity(
                  id: p['id'],
                  codename: p['codename'],
                  label: p['label'],
                  category: p['category'],
                ),
              )
              .toList(),
          grantedPermissions: (m['granted_permissions'] as List)
              .map<String>((e) => e)
              .toList(),
          children: m['children'] != null ? parseModules(m['children']) : [],
        );
      }).toList();
    }

    return parseModules(data);
  }

  Future<void> updateRolePermissions(
    int roleId,
    List<Map<String, dynamic>> permissions,
  ) async {
    await dioClient.dio.post(
      '/roles/$roleId/permissions/',
      data: {"permissions": permissions},
    );
  }
}
