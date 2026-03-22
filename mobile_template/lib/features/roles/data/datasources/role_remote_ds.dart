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

  Future<List<Map<String, dynamic>>> getDepartments() async {
    final response = await dioClient.dio.get('/departments/');

    return List<Map<String, dynamic>>.from(response.data);
  }

  Future<List<ModulePermissionEntity>> getRolePermissions(int roleId) async {
    final response = await dioClient.dio.get('/roles/$roleId/permissions/');

    final data = List<Map<String, dynamic>>.from(response.data as List);

    List<ModulePermissionEntity> parseModules(List<Map<String, dynamic>> modules) {
      return modules.map((m) {
        return ModulePermissionEntity(
          moduleId: m['module_id'] as int,
          moduleName: m['module_name'] as String,
          availableOnWeb: m['available_on_web'] as bool? ?? true,
          availableOnMobile: m['available_on_mobile'] as bool? ?? true,
          availablePermissions: List<Map<String, dynamic>>.from(
                m['available_permissions'] as List,
              )
              .map(
                (p) => PermissionEntity(
                  id: p['id'] as int,
                  codename: p['codename'] as String,
                  label: p['label'] as String,
                  category: p['category'] as String,
                ),
              )
              .toList(),
          grantedPermissions: List<String>.from(m['granted_permissions'] as List),
          children: m['children'] != null
              ? parseModules(
                  List<Map<String, dynamic>>.from(m['children'] as List),
                )
              : [],
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
