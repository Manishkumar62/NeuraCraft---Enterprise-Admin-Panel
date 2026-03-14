import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/permission_service.dart';
import '../../../../core/session/session_manager.dart';
import '../../domain/entities/module_entity.dart';
import '../bloc/module_bloc.dart';
import '../bloc/module_event.dart';
import '../bloc/module_state.dart';
import '../widgets/module_card.dart';

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final VoidCallback? onCreate;
  final bool isSearching;

  const _EmptyView({this.onCreate, this.isSearching = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.grid_view_rounded, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 14),
          Text(
            isSearching ? "No modules found" : "No modules yet",
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Text(
            isSearching
                ? "Try adjusting your search"
                : "Create your first module",
            style: TextStyle(color: Colors.grey.shade600),
          ),
          if (!isSearching && onCreate != null) ...[
            const SizedBox(height: 14),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Create Module"),
              onPressed: onCreate,
            ),
          ],
        ],
      ),
    );
  }
}

class ModuleListPage extends StatefulWidget {
  const ModuleListPage({super.key});

  @override
  State<ModuleListPage> createState() => _ModuleListPageState();
}

class _ModuleListPageState extends State<ModuleListPage> {
  final TextEditingController _searchController = TextEditingController();
  final Set<int> _expanded = {};
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();
    final permissionService = PermissionService(session.modules);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search modules...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = "");
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (value) {
              setState(() {
                _query = value.toLowerCase();
              });
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<ModuleBloc, ModuleState>(
            builder: (context, state) {
              if (state is ModuleLoading) {
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: 6,
                  itemBuilder: (_, __) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(0.05),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 12,
                                  width: 120,
                                  color: Colors.black26,
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  height: 10,
                                  width: 180,
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }

              if (state is ModuleError) {
                return _ErrorView(
                  message: state.message,
                  onRetry: () => context.read<ModuleBloc>().add(LoadModules()),
                );
              }

              if (state is ModuleLoaded) {
                final modules = _filterModules(state.modules);

                if (_query.isNotEmpty) {
                  _syncExpandedForSearch(modules);
                }

                if (modules.isEmpty) {
                  return _EmptyView(
                    isSearching: _query.isNotEmpty,
                    onCreate: permissionService.canAdd('/modules')
                        ? () => context.push('/modules/add')
                        : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ModuleBloc>().add(LoadModules());
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: modules.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildModuleCard(
                          context,
                          modules[index],
                          permissionService,
                        ),
                      );
                    },
                  ),
                );
              }

              return const SizedBox();
            },
          ),
        ),
      ],
    );
  }

  List<ModuleEntity> _filterModules(List<ModuleEntity> modules) {
    if (_query.isEmpty) return modules;

    return modules
        .map(_filterModuleTree)
        .whereType<ModuleEntity>()
        .toList();
  }

  ModuleEntity? _filterModuleTree(ModuleEntity module) {
    final matches = module.name.toLowerCase().contains(_query) ||
        module.path.toLowerCase().contains(_query) ||
        module.icon.toLowerCase().contains(_query);

    final filteredChildren = module.children
        .map(_filterModuleTree)
        .whereType<ModuleEntity>()
        .toList();

    if (!matches && filteredChildren.isEmpty) {
      return null;
    }

    return ModuleEntity(
      id: module.id,
      name: module.name,
      icon: module.icon,
      path: module.path,
      parent: module.parent,
      order: module.order,
      isActive: module.isActive,
      permissions: module.permissions,
      children: filteredChildren,
    );
  }

  void _syncExpandedForSearch(List<ModuleEntity> modules) {
    final allIds = <int>{};

    void collect(List<ModuleEntity> items) {
      for (final item in items) {
        allIds.add(item.id);
        if (item.children.isNotEmpty) {
          collect(item.children);
        }
      }
    }

    collect(modules);
    _expanded
      ..clear()
      ..addAll(allIds);
  }

  Widget _buildModuleCard(
    BuildContext context,
    ModuleEntity module,
    PermissionService permissionService, {
    int level = 0,
  }) {
    final hasChildren = module.children.isNotEmpty;
    final isExpanded = _expanded.contains(module.id);

    return Column(
      children: [
        ModuleCard(
          module: module,
          permissionService: permissionService,
          level: level,
          isExpanded: isExpanded,
          onToggleExpand: hasChildren
              ? () {
                  setState(() {
                    if (isExpanded) {
                      _expanded.remove(module.id);
                    } else {
                      _expanded.add(module.id);
                    }
                  });
                }
              : null,
        ),
          if (hasChildren && isExpanded)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Column(
                children: module.children
                    .map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: _buildModuleCard(
                          context,
                          child,
                          permissionService,
                          level: level + 1,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
      ],
    );
  }
}
