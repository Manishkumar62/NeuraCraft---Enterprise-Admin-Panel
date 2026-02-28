import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  late final ScrollController _scrollController;
  bool _showLeftArrow = false;
  bool _showRightArrow = false;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();

    _scrollController.addListener(() {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;

      setState(() {
        _showLeftArrow = current > 5;
        _showRightArrow = current < maxScroll - 5;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AuthBloc>().state;

    if (state is! AuthAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final modules = state.modules;

    return SafeArea(
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: modules.map((m) => _buildPage(m)).toList(),
        ),
        floatingActionButton: _buildFab(modules[_currentIndex]),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildStyledScrollableNav(modules),
      ),
    );
  }

  Widget _buildStyledScrollableNav(List<AppModule> modules) {
    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 8),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: SizedBox(
          height: 65,
          child: Stack(
            children: [
              /// 🔥 SCROLLABLE NAV
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

                        return InkWell(
                          onTap: () {
                            if (module.children.isNotEmpty) {
                              _showChildren(context, module);
                            } else {
                              setState(() => _currentIndex = index);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: itemWidth,
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF7C3AED).withOpacity(0.15)
                                  : Colors.transparent,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _mapIconData(module.icon),
                                  size: 20,
                                  color: isSelected
                                      ? const Color(0xFF7C3AED)
                                      : Colors.grey,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  module.moduleName,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isSelected
                                        ? const Color(0xFF7C3AED)
                                        : Colors.grey,
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
                  left: 4,
                  top: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showLeftArrow ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !_showLeftArrow,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _scrollController.animateTo(
                              _scrollController.offset - 120,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
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
                  right: 4,
                  top: 0,
                  bottom: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: _showRightArrow ? 1 : 0,
                    child: IgnorePointer(
                      ignoring: !_showRightArrow,
                      child: Center(
                        child: GestureDetector(
                          onTap: () {
                            _scrollController.animateTo(
                              _scrollController.offset + 120,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
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

  Widget _buildPage(AppModule module) {
    if (module.children.isEmpty) {
      return Center(
        child: Text(module.moduleName, style: const TextStyle(fontSize: 22)),
      );
    }

    return const SizedBox.shrink();
  }

  void _showChildren(BuildContext context, AppModule module) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF161B22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: module.children.length,
            itemBuilder: (context, index) {
              final child = module.children[index];

              return Card(
                child: ListTile(
                  leading: const Icon(Icons.arrow_forward),
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
    if (module.children.isEmpty && module.permissions.contains("add")) {
      return FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      );
    }
    return null;
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
