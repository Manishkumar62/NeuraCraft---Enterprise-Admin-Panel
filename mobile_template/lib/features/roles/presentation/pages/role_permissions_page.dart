import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/module_permission_entity.dart';
import '../bloc/role_bloc.dart';
import '../bloc/role_event.dart';
import '../bloc/role_state.dart';

import '../widgets/permission_module_tile.dart';

class RolePermissionsPage extends StatefulWidget {
  final int roleId;

  const RolePermissionsPage({super.key, required this.roleId});

  @override
  State<RolePermissionsPage> createState() => _RolePermissionsPageState();
}

class _RolePermissionsPageState extends State<RolePermissionsPage> {
  final Map<int, Set<String>> selected = {};
  final Map<int, bool> expanded = {};

  final TextEditingController searchController = TextEditingController();

  String query = "";

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Permissions")),

      body: SafeArea(
        child: BlocBuilder<RoleBloc, RoleState>(
          builder: (context, state) {
            if (state is RoleLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is RolePermissionsLoaded) {
              _initializeExpansionState(state.modules);

              final filteredModules = state.modules
                  .where(_matchesModuleOrChildren)
                  .toList();

              return Column(
                children: [
                  /// SEARCH BAR
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Search modules or permissions...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: query.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() => query = "");
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (v) {
                        setState(() {
                          query = v.toLowerCase();
                        });
                      },
                    ),
                  ),

                  /// MODULE LIST
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                      children: _buildModuleSections(filteredModules),
                    ),
                  ),
                ],
              );
            }

            if (state is RoleError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.save),
        label: const Text("Save Permissions"),
        onPressed: _save,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _initializeExpansionState(List<ModulePermissionEntity> modules) {
    if (expanded.isNotEmpty) return;

    for (var index = 0; index < modules.length; index++) {
      _seedExpansion(modules[index], isExpanded: index == 0);
    }
  }

  void _seedExpansion(
    ModulePermissionEntity module, {
    required bool isExpanded,
  }) {
    expanded.putIfAbsent(module.moduleId, () => isExpanded);

    for (final child in module.children) {
      _seedExpansion(child, isExpanded: false);
    }
  }

  List<Widget> _buildModuleSections(
    List<ModulePermissionEntity> modules, {
    int depth = 0,
  }) {
    return modules
        .expand((module) => _buildModuleSection(module, depth: depth))
        .toList();
  }

  List<Widget> _buildModuleSection(
    ModulePermissionEntity module, {
    int depth = 0,
  }) {
    final granted =
        selected[module.moduleId] ?? module.grantedPermissions.toSet();
    final isExpanded = expanded[module.moduleId] ?? false;
    final visibleChildren = module.children
        .where(_matchesModuleOrChildren)
        .toList();

    final widgets = <Widget>[
      Container(
        margin: EdgeInsets.only(left: depth * 16, bottom: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Theme.of(context).colorScheme.surface,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.06),
                            ),
        ),

        child: Column(
          children: [
                              /// MODULE HEADER
            InkWell(
              borderRadius: BorderRadius.circular(14),

              onTap: () {
                setState(() {
                  expanded[module.moduleId] = !isExpanded;
                });
              },

              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  children: [
                    Icon(
                                        isExpanded
                                            ? Icons.expand_less
                                            : Icons.expand_more,
                      size: 18,
                    ),

                    const SizedBox(width: 8),

                    Expanded(
                      child: Text(
                        module.moduleName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                      ),
                    ),

                    Text(
                      "${granted.length}/${module.availablePermissions.length}",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

                              /// MODULE BODY
            if (isExpanded)
              Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                    12,
                                    0,
                                    12,
                                    12,
                                  ),

                child: PermissionModuleTile(
                  module: module,
                  granted: granted,

                  onToggle: (codename) {
                    setState(() {
                      selected.putIfAbsent(
                        module.moduleId,
                                          () =>
                                              module.grantedPermissions.toSet(),
                      );

                                        if (selected[module.moduleId]!.contains(
                                          codename,
                                        )) {
                                          selected[module.moduleId]!.remove(
                                            codename,
                                          );
                      } else {
                                          selected[module.moduleId]!.add(
                                            codename,
                                          );
                      }
                    });
                  },

                  onSelectAll: (values) {
                    setState(() {
                                        selected[module.moduleId] = values
                                            .toSet();
                    });
                  },

                  onSelectCategory: (values) {
                    setState(() {
                                        selected[module.moduleId] = values
                                            .toSet();
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    ];

    if (visibleChildren.isNotEmpty) {
      widgets.add(
        Padding(
          padding: EdgeInsets.only(
            left: (depth * 16) + 16,
            right: 4,
            bottom: 8,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  depth == 0 ? "Child Modules" : "Nested Child Modules",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      widgets.addAll(_buildModuleSections(visibleChildren, depth: depth + 1));
    }

    return widgets;
  }

  bool _matchesModuleOrChildren(ModulePermissionEntity module) {
    if (query.isEmpty) return true;

    final matchesSelf =
        module.moduleName.toLowerCase().contains(query) ||
        module.availablePermissions.any(
          (permission) =>
              permission.label.toLowerCase().contains(query) ||
              permission.codename.toLowerCase().contains(query),
        );

    if (matchesSelf) {
      return true;
    }

    return module.children.any(_matchesModuleOrChildren);
  }

  void _save() {
    final payload = selected.entries.map((e) {
      return {"module_id": e.key, "granted": e.value.toList()};
    }).toList();

    context.read<RoleBloc>().add(
      UpdateRolePermissionsEvent(widget.roleId, payload),
    );
  }
}
