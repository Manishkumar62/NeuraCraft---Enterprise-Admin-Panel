import '../../domain/entities/recent_user_entity.dart';

class RecentUserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final DateTime dateJoined;

  RecentUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.dateJoined,
  });

  factory RecentUserModel.fromJson(Map<String, dynamic> json) {
    return RecentUserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      dateJoined: DateTime.parse(json['date_joined']),
    );
  }

  RecentUserEntity toEntity() {
    return RecentUserEntity(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      dateJoined: dateJoined,
    );
  }
}