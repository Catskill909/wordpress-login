import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final List<String> roles;

  const User({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatarUrl,
    required this.roles,
  });

  @override
  List<Object?> get props => [
        id,
        username,
        email,
        firstName,
        lastName,
        avatarUrl,
        roles,
      ];
}
