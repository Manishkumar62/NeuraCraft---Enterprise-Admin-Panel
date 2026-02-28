import 'package:equatable/equatable.dart';

class AppModule extends Equatable {
  final int id;
  final String moduleName;
  final String icon;
  final String path;
  final int order;
  final List<String> permissions;
  final List<AppModule> children;

  const AppModule({
    required this.id,
    required this.moduleName,
    required this.icon,
    required this.path,
    required this.order,
    required this.permissions,
    required this.children,
  });

  factory AppModule.fromJson(Map<String, dynamic> json) {
    return AppModule(
      id: json["id"],
      moduleName: json["module_name"],
      icon: json["icon"],
      path: json["path"],
      order: json["order"],
      permissions: List<String>.from(json["permissions"]),
      children: json["children"] != null
          ? (json["children"] as List)
              .map((e) => AppModule.fromJson(e))
              .toList()
          : [],
    );
  }

  @override
  List<Object?> get props =>
      [id, moduleName, path, permissions, children];
}