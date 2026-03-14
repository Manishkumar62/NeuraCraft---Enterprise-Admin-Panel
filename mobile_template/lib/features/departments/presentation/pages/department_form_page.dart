import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/department_entity.dart';
import '../bloc/department_bloc.dart';
import '../bloc/department_event.dart';
import '../bloc/department_state.dart';

class DepartmentFormPage extends StatefulWidget {
  final int? departmentId;

  const DepartmentFormPage({super.key, this.departmentId});

  bool get isEdit => departmentId != null;

  @override
  State<DepartmentFormPage> createState() => _DepartmentFormPageState();
}

class _DepartmentFormPageState extends State<DepartmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.isEdit) {
      context.read<DepartmentBloc>().add(
        LoadDepartmentById(widget.departmentId!),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String get _displayName {
    return _nameController.text.isEmpty
        ? "New Department"
        : _nameController.text;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Edit Department" : "Create Department"),
      ),

      bottomNavigationBar: _buildBottomBar(isEdit),

      body: BlocListener<DepartmentBloc, DepartmentState>(
        listener: (context, state) {
          if (state is SingleDepartmentLoaded) {
            _fillForm(state.department);
          }

          if (state is DepartmentError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is DepartmentsLoaded) {
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

                  _buildSectionTitle("Department Info"),

                  _buildCard([
                    _buildField(_nameController, "Department Name"),

                    const SizedBox(height: 12),

                    _buildField(_codeController, "Department Code"),

                    const SizedBox(height: 12),

                    _buildField(
                      _descriptionController,
                      "Description",
                      maxLines: 3,
                    ),
                  ]),

                  const SizedBox(height: 18),

                  _buildCard([
                    SwitchListTile(
                      title: const Text("Active"),
                      value: _isActive,
                      onChanged: (v) {
                        setState(() => _isActive = v);
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
    final initials = _displayName.isEmpty
        ? "D"
        : _displayName.trim()[0].toUpperCase();

    return Center(
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.15),
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (v) {
        if ((label == "Department Name" || label == "Department Code") &&
            (v == null || v.isEmpty)) {
          return "$label required";
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildBottomBar(bool isEdit) {
    return BlocBuilder<DepartmentBloc, DepartmentState>(
      builder: (context, state) {
        final loading = state is DepartmentLoading;

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
                      isEdit ? "Update Department" : "Create Department",
                      style: const TextStyle(fontSize: 15),
                    ),
            ),
          ),
        );
      },
    );
  }

  void _fillForm(DepartmentEntity dept) {
    _nameController.text = dept.name;
    _codeController.text = dept.code;
    _descriptionController.text = dept.description ?? "";
    _isActive = dept.isActive;

    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "name": _nameController.text,
      "code": _codeController.text,
      "description": _descriptionController.text,
      "is_active": _isActive,
    };

    if (widget.isEdit) {
      context.read<DepartmentBloc>().add(
        UpdateDepartmentEvent(widget.departmentId!, data),
      );
    } else {
      context.read<DepartmentBloc>().add(CreateDepartmentEvent(data));
    }
  }
}
