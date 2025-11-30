import 'package:equatable/equatable.dart';

/// Model representing authentication credentials
class AuthCredentials extends Equatable {
  final String email;
  final String password;
  final String? name;
  final String? mobileNumber;

  const AuthCredentials({
    required this.email,
    required this.password,
    this.name,
    this.mobileNumber,
  });

  @override
  List<Object?> get props => [email, password, name, mobileNumber];
}
