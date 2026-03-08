import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/role_entity.dart';
import '../bloc/role_bloc.dart';
import '../bloc/role_event.dart';
import '../bloc/role_state.dart';

class RoleFormPage extends StatefulWidget {
  final int? roleId;

  const RoleFormPage({super.key, this.roleId});

  bool get isEdit => roleId != null;

  @override
  State<RoleFormPage> createState() => _RoleFormPageState();
}

class _RoleFormPageState extends State<RoleFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      context.read<RoleBloc>().add(LoadRoleById(widget.roleId!));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _displayName {
    return _nameController.text.isEmpty ? "New Role" : _nameController.text;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Role" : "Create Role"),
      ),

      bottomNavigationBar: _buildBottomBar(isEdit),

      body: BlocListener<RoleBloc, RoleState>(
        listener: (context, state) {
          if (state is SingleRoleLoaded) {
            _fillForm(state.role);
          }

          if (state is RoleError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }

          if (state is RoleLoaded) {
            Navigator.pop(context);
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

                  _buildSectionTitle("Role Info"),

                  _buildCard([
                    _buildField(_nameController, "Role Name"),

                    const SizedBox(height: 12),

                    _buildField(
                      _descriptionController,
                      "Description",
                      maxLines: 3,
                    ),
                  ]),

                  if (isEdit) ...[
                    const SizedBox(height: 18),

                    _buildCard([
                      SwitchListTile(
                        title: const Text("Active"),
                        value: _isActive,
                        onChanged: (v) => setState(() => _isActive = v),
                      ),
                    ]),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials =
        _displayName.isEmpty ? "R" : _displayName.trim()[0].toUpperCase();

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor:
                Theme.of(context).colorScheme.primary.withOpacity(0.15),
            child: Text(
              initials,
              style:
                  const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),

          const SizedBox(height: 10),

          Text(
            _displayName,
            style:
                const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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

  Widget _buildField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: (v) {
        if (label == "Role Name" && (v == null || v.isEmpty)) {
          return "Role name required";
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildBottomBar(bool isEdit) {
    return BlocBuilder<RoleBloc, RoleState>(
      builder: (context, state) {
        final loading = state is RoleLoading;

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
                      isEdit ? "Update Role" : "Create Role",
                      style: const TextStyle(fontSize: 15),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _fillForm(RoleEntity role) {
    _nameController.text = role.name;
    _descriptionController.text = role.description ?? "";
    _isActive = role.isActive;

    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "name": _nameController.text,
      "description": _descriptionController.text,
      "is_active": _isActive,
    };

    if (widget.isEdit) {
      context.read<RoleBloc>().add(UpdateRoleEvent(widget.roleId!, data));
    } else {
      context.read<RoleBloc>().add(CreateRoleEvent(data));
    }
  }
}