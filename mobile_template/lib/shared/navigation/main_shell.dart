import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/session/session_manager.dart';
import '../../core/di/injection.dart';
import '../../core/services/permission_service.dart';

import '../../features/menu/domain/models/module_model.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_event.dart';

import '../../features/dashboard/domain/usecases/get_dashboard_stats.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../features/dashboard/presentation/bloc/dashboard_event.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

import '../../features/users/presentation/bloc/user_bloc.dart';
import '../../features/users/presentation/bloc/user_event.dart' as user_event;
import '../../features/users/presentation/pages/user_list_page.dart';

import '../../features/roles/presentation/bloc/role_bloc.dart';
import '../../features/roles/presentation/bloc/role_event.dart' as role_event;
import '../../features/roles/presentation/pages/role_list_page.dart';

import '../../features/departments/presentation/bloc/department_bloc.dart';
import '../../features/departments/presentation/bloc/department_event.dart' as department_event;
import '../../features/departments/presentation/pages/department_list_page.dart';

import '../../features/modules/presentation/bloc/module_bloc.dart';
import '../../features/modules/presentation/bloc/module_event.dart' as module_event;
import '../../features/modules/presentation/pages/module_list_page.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  late final ScrollController _scrollController;
  final Map<String, Widget> _loadedPages = {};
  bool _showLeftArrow = false;
  bool _showRightArrow = false;

  void _updateArrowVisibility() {
    if (!_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;

    if (!mounted) return;

    setState(() {
      _showLeftArrow = current > 5;
      _showRightArrow = maxScroll > 5 && current < maxScroll - 5;
    });
  }

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(_updateArrowVisibility);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateArrowVisibility();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C2128),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(LogoutRequested());
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  void openModule(String path) {
    final session = getIt<SessionManager>();

    final index = session.modules.indexWhere((m) => m.path == path);

    if (index != -1) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  Widget _getOrCreatePage(AppModule module, PermissionService permissionService) {
    return _loadedPages.putIfAbsent(
      module.path,
      () => _buildPage(module, permissionService),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = getIt<SessionManager>();

    if (!session.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final modules = session.modules;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            modules[_currentIndex].moduleName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => _confirmLogout(context),
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentIndex,
          children: List.generate(modules.length, (index) {
            final module = modules[index];
            final shouldBuild =
                index == _currentIndex || _loadedPages.containsKey(module.path);

            if (!shouldBuild) {
              return const SizedBox.shrink();
            }

            final permissionService = PermissionService(session.modules);
            return _getOrCreatePage(module, permissionService);
          }),
        ),
        floatingActionButton: _buildFab(modules[_currentIndex]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildStyledScrollableNav(modules),
      ),
    );
  }

  Widget _buildStyledScrollableNav(List<AppModule> modules) {
    return Padding(
      padding: const EdgeInsets.all(14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: Stack(
            children: [
              /// 🔥 Scrollable Nav Items
              LayoutBuilder(
                builder: (context, constraints) {
                  final itemWidth = constraints.maxWidth / 4;

                  return SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(modules.length, (index) {
                        final module = modules[index];
                        final isSelected = _currentIndex == index;

                        return GestureDetector(
                          onTap: () {
                            if (module.children.isNotEmpty) {
                              _showChildren(context, module);
                            } else {
                              setState(() => _currentIndex = index);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            width: itemWidth,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                /// 🔥 Icon with glow effect
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(
                                            0xFF7C3AED,
                                          ).withOpacity(0.15)
                                        : Colors.transparent,
                                  ),
                                  child: Icon(
                                    _mapIconData(module.icon),
                                    size: isSelected ? 22 : 20,
                                    color: isSelected
                                        ? const Color(0xFF7C3AED)
                                        : Colors.grey,
                                  ),
                                ),

                                /// 🔥 Title
                                AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 250),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? const Color(0xFF7C3AED)
                                        : Colors.grey,
                                  ),
                                  child: Text(
                                    module.moduleName,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                /// 🔥 Bottom Indicator Line
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 250),
                                  height: 3,
                                  width: isSelected ? 24 : 0,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF7C3AED),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),

              /// ⬅ LEFT OVERLAY ARROW
              if (modules.length > 4)
                Positioned(
                  left: 6,
                  top: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showLeftArrow ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !_showLeftArrow,
                      child: GestureDetector(
                        onTap: () {
                          _scrollController.animateTo(
                            _scrollController.offset - 140,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: const Icon(
                            Icons.chevron_left,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

              /// ➡ RIGHT OVERLAY ARROW
              if (modules.length > 4)
                Positioned(
                  right: 6,
                  top: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showRightArrow ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !_showRightArrow,
                      child: GestureDetector(
                        onTap: () {
                          _scrollController.animateTo(
                            _scrollController.offset + 140,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: const Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(AppModule module, PermissionService permissionService) {
    switch (module.path) {
      case "/dashboard":
        return BlocProvider(
          create: (_) => DashboardBloc(
            getDashboardStats: getIt<GetDashboardStats>(),
            permissionService: permissionService,
          )..add(LoadDashboard()),
          child: const DashboardPage(),
        );

      case '/users':
        return BlocProvider(
          create: (_) =>
              getIt<UserBloc>(param1: permissionService)..add(user_event.LoadUsers()),
          child: const UserListPage(),
        );

      case '/roles':
        return BlocProvider(
          create: (_) =>
              getIt<RoleBloc>(param1: permissionService)..add(role_event.LoadRoles()),
          child: const RoleListPage(),
        );

      case '/departments':
        return BlocProvider(
          create: (_) =>
              getIt<DepartmentBloc>(param1: permissionService)..add(department_event.LoadDepartments()),
          child: const DepartmentListPage(),
        );

      case '/modules':
        return BlocProvider(
          create: (_) =>
              getIt<ModuleBloc>(param1: permissionService)..add(module_event.LoadModules()),
          child: const ModuleListPage(),
        );

      default:
        return Center(
          child: Text(module.moduleName, style: const TextStyle(fontSize: 22)),
        );
    }
  }

  void _showChildren(BuildContext context, AppModule module) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF161B22),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.all(20),
          child: ListView.builder(
            itemCount: module.children.length,
            itemBuilder: (context, index) {
              final child = module.children[index];

              return Container(
                margin: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  leading: const Icon(Icons.arrow_forward_ios, size: 16),
                  title: Text(child.moduleName),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(child.path);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget? _buildFab(AppModule module) {
    if (!module.permissions.contains("add")) return null;

    switch (module.path) {
      case '/users':
        return FloatingActionButton(
          backgroundColor: const Color(0xFF7C3AED),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () => context.push('/users/add'),
          child: const Icon(Icons.add),
        );

      case '/roles':
        return FloatingActionButton(
          backgroundColor: const Color(0xFF7C3AED),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () => context.push('/roles/add'),
          child: const Icon(Icons.add),
        );

      case '/departments':
        return FloatingActionButton(
          backgroundColor: const Color(0xFF7C3AED),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () => context.push('/departments/add'),
          child: const Icon(Icons.add),
        );

      case '/modules':
        return FloatingActionButton(
          backgroundColor: const Color(0xFF7C3AED),
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          onPressed: () => context.push('/modules/add'),
          child: const Icon(Icons.add),
        );

      default:
        return null;
    }
  }

  IconData _mapIconData(String iconName) {
    switch (iconName) {
      case "dashboard":
        return Icons.dashboard;
      case "user":
        return Icons.people;
      case "shield":
        return Icons.security;
      case "building":
        return Icons.apartment;
      case "modules":
        return Icons.view_module;
      case "document":
        return Icons.description;
      default:
        return Icons.circle;
    }
  }
}
