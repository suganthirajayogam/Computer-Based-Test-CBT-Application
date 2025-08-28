import 'package:equatable/equatable.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String empId;

  const LoginSubmitted({required this.empId});

  @override
  List<Object> get props => [empId];
}
