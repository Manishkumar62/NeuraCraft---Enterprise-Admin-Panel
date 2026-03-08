class UserEntity {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? employeeId;
  final bool isActive;

  final int? departmentId;
  final List<int> roleIds;
  final List<String> roleNames;

  UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    this.employeeId,
    required this.isActive,
    this.departmentId,
    required this.roleIds,
    required this.roleNames,
  });
}