// lib/blocs/auth/auth_state.dart

import 'package:equatable/equatable.dart';
import 'package:computer_based_test/models/employee.dart'; // To hold logged-in employee info - IMPORTANT: Ensure this path is correct and file exists!
import 'package:meta/meta.dart'; // Import for @immutable annotation

// Base class for all Auth states
@immutable // Added @immutable annotation to ensure state objects are immutable
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

// Initial state: User is not authenticated, showing login/register form
class AuthInitial extends AuthState {
  const AuthInitial();
}

// State when an authentication process (login/register/dummy admin creation) is ongoing
class AuthLoading extends AuthState {
  final String message; // Optional message, e.g., "Logging in..."

  const AuthLoading({this.message = 'Processing...'});

  @override
  List<Object> get props => [message];
}

// State when authentication is successful
class AuthSuccess extends AuthState {
  final Employee employee; // The logged-in/registered employee details
  final String message;    // Success message

  const AuthSuccess({required this.employee, this.message = 'Success!'});

  @override
  List<Object> get props => [employee, message];
}

// State when authentication fails (e.g., wrong credentials, employee ID exists)
class AuthFailure extends AuthState {
  final String message; // Error message to display

  const AuthFailure({required this.message});

  @override
  List<Object> get props => [message];
}
