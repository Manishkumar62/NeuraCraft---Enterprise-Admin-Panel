import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../shared/widgets/chip_multi_selector.dart';
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
  bool _showPassword = false;

  List<Map<String, dynamic>> _roles = [];
  List<Map<String, dynamic>> _departments = [];

  List<int> _selectedRoles = [];
  int? _selectedDepartment;

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
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
    final initials = _displayName.isEmpty
        ? "U"
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
            _displayName.isEmpty ? "New User" : _displayName,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),

          if (_emailController.text.isNotEmpty)
            Text(
              _emailController.text,
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

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool obscure = false,
    TextInputType keyboard = TextInputType.text,
  }) {
    final isPassword = label == "Password";

    return TextFormField(
      controller: controller,
      obscureText: isPassword ? !_showPassword : obscure,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        isDense: true,
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 12,
        ),

        /// 👁 Eye button
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              )
            : null,
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
      decoration: InputDecoration(
        labelText: "Department",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.02),
      ),
      items: _departments.map<DropdownMenuItem<int>>((dept) {
        return DropdownMenuItem<int>(
          value: dept['id'],
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
    return ChipMultiSelector(
      title: "Roles",
      items: _roles,
      selectedIds: _selectedRoles,
      onChanged: (ids) {
        setState(() {
          _selectedRoles = ids;
        });
      },
    );
  }

  Widget _buildBottomBar(bool isEdit) {
    return BlocBuilder<UserBloc, UserState>(
      builder: (context, state) {
        final loading = state is UserLoading;

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
                      isEdit ? "Update User" : "Create User",
                      style: const TextStyle(fontSize: 15),
                    ),
            ),
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
