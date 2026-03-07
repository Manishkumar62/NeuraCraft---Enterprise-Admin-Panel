import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user_entity.dart';
import '../../presentation/bloc/user_bloc.dart';
import '../../presentation/bloc/user_event.dart';
import '../../presentation/bloc/user_state.dart';

class UserFormPage extends StatefulWidget {
  final int? userId;

  const UserFormPage({super.key, this.userId});

  bool get isEdit => userId != null;

  @override
  State<UserFormPage> createState() => _UserFormPageState();
}

class _UserFormPageState extends State<UserFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _employeeIdController = TextEditingController();

  bool _isActive = true;

  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _departments = [];

  List<int> _selectedRoles = [];
  int? _selectedDepartment;

  bool _loadingDropdowns = false;

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    final bloc = context.read<UserBloc>();

    if (widget.isEdit) {
      bloc.add(LoadUserById(widget.userId!));
    }

    bloc.add(LoadRoles());
    bloc.add(LoadDepartments());
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _employeeIdController.dispose();
    super.dispose();
  }

  String get _displayName {
    final name = "${_firstNameController.text} ${_lastNameController.text}"
        .trim();
    return name.isEmpty ? _usernameController.text : name;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.isEdit;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? "Edit User" : "Create User")),

      bottomNavigationBar: _buildBottomBar(isEdit),

      body: BlocListener<UserBloc, UserState>(
        listener: (context, state) {
          if (state is SingleUserLoaded) {
            _fillForm(state.user);
          }

          if (state is UserError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is RolesLoaded) {
            setState(() {
              _roles = state.roles;
            });
          }

          if (state is DepartmentsLoaded) {
            setState(() {
              _departments = state.departments;
            });
          }

          if (state is UserListLoaded) {
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

                  _buildSectionTitle("Account"),

                  _buildCard([
                    _buildField(_usernameController, "Username"),
                    const SizedBox(height: 12),
                    _buildField(
                      _emailController,
                      "Email",
                      keyboard: TextInputType.emailAddress,
                    ),
                    if (!isEdit) ...[
                      const SizedBox(height: 12),
                      _buildField(
                        _passwordController,
                        "Password",
                        obscure: true,
                      ),
                    ],
                  ]),

                  const SizedBox(height: 18),

                  _buildSectionTitle("Personal"),

                  _buildCard([
                    _buildField(_firstNameController, "First Name"),
                    const SizedBox(height: 12),
                    _buildField(_lastNameController, "Last Name"),
                    const SizedBox(height: 12),
                    _buildField(_phoneController, "Phone"),
                  ]),

                  const SizedBox(height: 18),

                  _buildSectionTitle("Organization"),

                  _buildCard([
                    _buildField(_employeeIdController, "Employee ID"),
                    const SizedBox(height: 12),
                    _buildDepartmentDropdown(),
                    const SizedBox(height: 12),
                    _buildRolesSelector(),
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 30,
          child: Text(
            _displayName.isEmpty ? "U" : _displayName[0].toUpperCase(),
            style: const TextStyle(fontSize: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _displayName.isEmpty ? "New User" : _displayName,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (_emailController.text.isNotEmpty)
          Text(
            _emailController.text,
            style: TextStyle(color: Colors.grey.shade600),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(blurRadius: 10, color: Colors.black.withOpacity(0.05)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 12,
        ),
      ),
      validator: (v) {
        if (label == "Username" && (v == null || v.isEmpty)) {
          return "Username required";
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDepartmentDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedDepartment,
      decoration: const InputDecoration(labelText: "Department"),
      items: _departments.map<DropdownMenuItem<int>>((dept) {
        return DropdownMenuItem<int>(
          value: dept['id'] as int,
          child: Text(dept['name']),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDepartment = value;
        });
      },
    );
  }

  Widget _buildRolesSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _openRolesSelector,
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: "Roles",
              border: OutlineInputBorder(),
            ),
            child: Text(
              _selectedRoles.isEmpty
                  ? "Select roles"
                  : "${_selectedRoles.length} role(s) selected",
            ),
          ),
        ),

        if (_selectedRoles.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: _selectedRoles.map((id) {
              final role = _roles.firstWhere((r) => r['id'] == id);
              return Chip(label: Text(role['name']));
            }).toList(),
          ),
        ],
      ],
    );
  }

  void _openRolesSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          children: _roles.map((role) {
            final int id = role['id'] as int;

            return CheckboxListTile(
              title: Text(role['name']),
              value: _selectedRoles.contains(id),
              onChanged: (v) {
                setState(() {
                  if (v == true) {
                    _selectedRoles.add(id);
                  } else {
                    _selectedRoles.remove(id);
                  }
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBottomBar(bool isEdit) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final loading = state is UserLoading;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ElevatedButton(
            onPressed: loading ? null : _submit,
            child: loading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isEdit ? "Update User" : "Create User"),
          ),
        );
      },
    );
  }

  void _fillForm(UserEntity user) {
    _usernameController.text = user.username;
    _emailController.text = user.email;
    _firstNameController.text = user.firstName ?? '';
    _lastNameController.text = user.lastName ?? '';
    _phoneController.text = user.phone ?? '';
    _employeeIdController.text = user.employeeId ?? '';

    _selectedDepartment = user.departmentId;

    _selectedRoles = user.roleIds ?? [];

    _isActive = user.isActive;

    setState(() {});
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      "username": _usernameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "first_name": _firstNameController.text,
      "last_name": _lastNameController.text,
      "phone": _phoneController.text,
      "employee_id": _employeeIdController.text,
      "role_ids": _selectedRoles,
      "department_id": _selectedDepartment,
      "is_active": _isActive,
    };

    if (widget.isEdit) {
      context.read<UserBloc>().add(UpdateUserEvent(widget.userId!, data));
    } else {
      context.read<UserBloc>().add(CreateUserEvent(data));
    }
  }
}
