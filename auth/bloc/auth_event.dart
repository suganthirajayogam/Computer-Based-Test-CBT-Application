// lib/blocs/auth/auth_event.dart

import 'package:equatable/equatable.dart';

// Base class for all Auth events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

// Event for when a user attempts to log in
class LoginRequested extends AuthEvent {
  final String employeeId;
  final String employeeName;
  final String password;

  const LoginRequested({
    required this.employeeId,
    required this.employeeName,
    required this.password,
  });

  @override
  List<Object> get props => [employeeId, employeeName, password];
}

// Event to trigger the creation of a dummy admin (for testing/initial setup)
class CreateDummyAdmin extends AuthEvent {
  const CreateDummyAdmin();
}

// Note: RegisterRequested event and its handlers are kept out based on previous requests.
