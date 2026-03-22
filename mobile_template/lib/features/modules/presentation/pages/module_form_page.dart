import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/module_entity.dart';
import '../bloc/module_bloc.dart';
import '../bloc/module_event.dart';
import '../bloc/module_state.dart';
import '../widgets/module_permission_selector.dart';

class ModuleFormPage extends StatefulWidget {
  final int? moduleId;

  const ModuleFormPage({super.key, this.moduleId});

  bool get isEdit => moduleId != null;

  @override
  State<ModuleFormPage> createState() => _ModuleFormPageState();
}

class _ModuleFormPageState extends State<ModuleFormPage> {
  static const List<Map<String, String>> _iconOptions = [
    {'value': 'dashboard', 'label': 'Dashboard'},
    {'value': 'users', 'label': 'Users'},
    {'value': 'user', 'label': 'User'},
    {'value': 'shield', 'label': 'Shield'},
    {'value': 'building', 'label': 'Building'},
    {'value': 'modules', 'label': 'Modules'},
    {'value': 'chart', 'label': 'Chart'},
    {'value': 'document', 'label': 'Document'},
    {'value': 'settings', 'label': 'Settings'},
    {'value': 'folder', 'label': 'Folder'},
  ];

  static const List<ModulePermissionEntity> _presetPermissions = [
    ModulePermissionEntity(codename: 'view', label: 'View', category: 'crud'),
    ModulePermissionEntity(codename: 'add', label: 'Add', category: 'crud'),
    ModulePermissionEntity(codename: 'edit', label: 'Edit', category: 'crud'),
    ModulePermissionEntity(codename: 'delete', label: 'Delete', category: 'crud'),
    ModulePermissionEntity(
      codename: 'export_csv',
      label: 'Export CSV',
      category: 'action',
    ),
    ModulePermissionEntity(
      codename: 'export_pdf',
      label: 'Export PDF',
      category: 'action',
    ),
    ModulePermissionEntity(
      codename: 'export_excel',
      label: 'Export Excel',
      category: 'action',
    ),
    ModulePermissionEntity(codename: 'import', label: 'Import', category: 'action'),
    ModulePermissionEntity(codename: 'print', label: 'Print', category: 'action'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _pathController = TextEditingController();
  final _orderController = TextEditingController(text: "0");

  String? _selectedIcon;
  int? _selectedParentId;
  bool _isActive = true;
  bool _availableOnWeb = true;
  bool _availableOnMobile = true;

  List<ModuleEntity> _parentModules = [];
  List<ModulePermissionEntity> _selectedPermissions = const [
    ModulePermissionEntity(codename: 'view', label: 'View', category: 'crud'),
  ];

  @override
  void initState() {
    super.initState();

    final bloc = context.read<ModuleBloc>();
    bloc.add(LoadModules());

    if (widget.isEdit) {
      bloc.add(LoadModuleById(widget.moduleId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pathController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  String get _displayName {
    final name = _nameController.text.trim();
    return name.isEmpty ? "New Module" : name;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit Module" : "Create Module")),
      bottomNavigationBar: _buildBottomBar(isEdit),
      body: BlocListener<ModuleBloc, ModuleState>(
        listener: (context, state) {
          if (state is ModuleLoaded) {
            setState(() {
              _parentModules = _flattenModules(state.modules)
                  .where((module) => module.id != widget.moduleId)
                  .toList();
            });
          }

          if (state is SingleModuleLoaded) {
            _fillForm(state.module);
          }

          if (state is ModuleError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is ModuleSaved) {
            Navigator.pop(context, true);
          }
        },
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 18),
                  _buildSectionTitle("Module"),
                  _buildCard([
                    _buildTextField(_nameController, "Module Name"),
                    const SizedBox(height: 12),
                    _buildIconDropdown(),
                    const SizedBox(height: 12),
                    _buildTextField(_pathController, "Path"),
                  ]),
                  const SizedBox(height: 18),
                  _buildSectionTitle("Structure"),
                  _buildCard([
                    _buildParentDropdown(),
                    const SizedBox(height: 12),
                    _buildTextField(
                      _orderController,
                      "Order",
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Active"),
                      subtitle: const Text(
                        "Globally enables this module. If off, it stays hidden on every platform.",
                      ),
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Show on web"),
                      subtitle: const Text(
                        "Allow this module to appear in the web app when it is active.",
                      ),
                      value: _availableOnWeb,
                      onChanged: (value) {
                        setState(() => _availableOnWeb = value);
                      },
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text("Show on mobile"),
                      subtitle: const Text(
                        "Allow this module to appear in the mobile app when it is active.",
                      ),
                      value: _availableOnMobile,
                      onChanged: (value) {
                        setState(() => _availableOnMobile = value);
                      },
                    ),
                  ]),
                  const SizedBox(height: 18),
                  _buildSectionTitle("Permissions"),
                  _buildCard([
                    _buildPermissionSummary(),
                    const SizedBox(height: 12),
                    ModulePermissionSelector(
                      title: "Permissions",
                      items: _availablePermissions,
                      selectedPermissions: _selectedPermissions,
                      onChanged: (permissions) {
                        setState(() {
                          _selectedPermissions = permissions;
                        });
                      },
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = _displayName.trim().isEmpty
        ? "M"
        : _displayName.trim()[0].toUpperCase();

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            child: Text(
              initials,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _displayName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (_pathController.text.trim().isNotEmpty)
            Text(
              _pathController.text.trim(),
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 14, 4, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      ),
      validator: (value) {
        if (label == "Module Name" && (value == null || value.trim().isEmpty)) {
          return "Module name required";
        }

        if (label == "Path" && (value == null || value.trim().isEmpty)) {
          return "Path required";
        }

        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildIconDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedIcon,
      decoration: InputDecoration(
        labelText: "Icon",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
      ),
      items: _iconOptions.map((icon) {
        return DropdownMenuItem<String>(
          value: icon['value'],
          child: Text(icon['label']!),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedIcon = value;
        });
      },
      validator: (value) => value == null || value.isEmpty ? "Icon required" : null,
    );
  }

  Widget _buildParentDropdown() {
    return DropdownButtonFormField<int?>(
      value: _selectedParentId,
      decoration: InputDecoration(
        labelText: "Parent Module",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
      ),
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          child: Text("None (Top Level)"),
        ),
        ..._parentModules.map((module) {
          return DropdownMenuItem<int?>(
            value: module.id,
            child: Text(module.name),
          );
        }),
      ],
      onChanged: (value) {
        setState(() {
          _selectedParentId = value;
        });
      },
    );
  }

  Widget _buildPermissionSummary() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        "${_selectedPermissions.length} permission(s) selected",
        style: TextStyle(
          fontSize: 13,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  List<ModulePermissionEntity> get _availablePermissions {
    final customPermissions = _selectedPermissions.where((permission) {
      return !_presetPermissions.any(
        (preset) => preset.codename == permission.codename,
      );
    });

    return [
      ..._presetPermissions,
      ...customPermissions,
    ];
  }

  Widget _buildBottomBar(bool isEdit) {
    return BlocBuilder<ModuleBloc, ModuleState>(
      builder: (context, state) {
        final loading = state is ModuleLoading;

        return SafeArea(
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: loading ? null : _submit,
              child: loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isEdit ? "Update Module" : "Create Module",
                      style: const TextStyle(fontSize: 15),
                    ),
            ),
          ),
        );
      },
    );
  }

  List<ModuleEntity> _flattenModules(List<ModuleEntity> modules) {
    final flattened = <ModuleEntity>[];

    void walk(List<ModuleEntity> items) {
      for (final item in items) {
        flattened.add(item);
        if (item.children.isNotEmpty) {
          walk(item.children);
        }
      }
    }

    walk(modules);
    return flattened;
  }

  void _fillForm(ModuleEntity module) {
    _nameController.text = module.name;
    _pathController.text = module.path;
    _orderController.text = module.order.toString();
    _selectedIcon = module.icon;
    _selectedParentId = module.parent;
    _isActive = module.isActive;
    _availableOnWeb = module.availableOnWeb;
    _availableOnMobile = module.availableOnMobile;
    _selectedPermissions = module.permissions.isNotEmpty
        ? List<ModulePermissionEntity>.from(module.permissions)
        : const [
            ModulePermissionEntity(
              codename: 'view',
              label: 'View',
              category: 'crud',
            ),
          ];
    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPermissions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Select at least one permission")));
      return;
    }

    final data = {
      "name": _nameController.text.trim(),
      "icon": _selectedIcon,
      "path": _pathController.text.trim(),
      "parent": _selectedParentId,
      "order": int.tryParse(_orderController.text.trim()) ?? 0,
      "is_active": _isActive,
      "available_on_web": _availableOnWeb,
      "available_on_mobile": _availableOnMobile,
      "permissions": _selectedPermissions.asMap().entries.map((entry) {
        final permission = entry.value;
        return {
          "id": permission.id,
          "codename": permission.codename,
          "label": permission.label,
          "category": permission.category,
          "order": entry.key + 1,
        };
      }).toList(),
    };

    if (widget.isEdit) {
      context.read<ModuleBloc>().add(UpdateModuleEvent(widget.moduleId!, data));
    } else {
      context.read<ModuleBloc>().add(CreateModuleEvent(data));
    }
  }
}
