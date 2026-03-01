class RecentUserEntity {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateJoined;

  RecentUserEntity({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateJoined,
  });
}