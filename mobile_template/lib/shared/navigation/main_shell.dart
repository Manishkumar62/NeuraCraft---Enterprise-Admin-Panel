import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/menu/domain/models/module_model.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final modules = state.modules;

    // Define core modules for bottom nav
    final corePaths = [
      "/dashboard",
      "/users",
      "/roles",
      "/departments",
    ];

    final coreModules = modules
        .where((m) => corePaths.contains(m.path))
        .toList();

    final extraModules = modules
        .where((m) => !corePaths.contains(m.path))
        .toList();

    final navItems = <BottomNavigationBarItem>[];
    final pages = <Widget>[];

    for (final module in coreModules) {
      navItems.add(
        BottomNavigationBarItem(
          icon: _mapIcon(module.icon),
          label: module.moduleName,
        ),
      );

      pages.add(_ModulePlaceholderScreen(module: module));
    }

    // Add "More" if extra modules exist
    if (extraModules.isNotEmpty) {
      navItems.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.more_horiz),
          label: "More",
        ),
      );

      pages.add(_MoreScreen(modules: extraModules));
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      floatingActionButton: _buildFab(state, coreModules),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomNav(navItems),
    );
  }

  Widget _buildBottomNav(List<BottomNavigationBarItem> items) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          selectedItemColor: const Color(0xFF7C3AED),
          unselectedItemColor: Colors.grey,
          items: items,
        ),
      ),
    );
  }

  Widget? _buildFab(
    AuthAuthenticated state,
    List<AppModule> coreModules,
  ) {
    if (_currentIndex >= coreModules.length) return null;

    final currentModule = coreModules[_currentIndex];

    if (currentModule.permissions.contains("add")) {
      return FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to add screen
        },
        child: const Icon(Icons.add),
      );
    }

    return null;
  }

  Icon _mapIcon(String iconName) {
    switch (iconName) {
      case "dashboard":
        return const Icon(Icons.dashboard);
      case "user":
        return const Icon(Icons.people);
      case "shield":
        return const Icon(Icons.security);
      case "building":
        return const Icon(Icons.apartment);
      case "modules":
        return const Icon(Icons.view_module);
      case "document":
        return const Icon(Icons.description);
      default:
        return const Icon(Icons.circle);
    }
  }
}

class _ModulePlaceholderScreen extends StatelessWidget {
  final AppModule module;

  const _ModulePlaceholderScreen({required this.module});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        module.moduleName,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }
}

class _MoreScreen extends StatelessWidget {
  final List<AppModule> modules;

  const _MoreScreen({required this.modules});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: modules.length,
      itemBuilder: (context, index) {
        final module = modules[index];
        return Card(
          child: ListTile(
            leading: const Icon(Icons.arrow_forward),
            title: Text(module.moduleName),
            onTap: () {
              // TODO: Navigate to module screen
            },
          ),
        );
      },
    );
  }
}