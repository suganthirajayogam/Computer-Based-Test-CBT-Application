import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:computer_based_test/database/LOGIN_db.dart';

import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      await Future.delayed(const Duration(milliseconds: 500)); // simulate small delay

      // Check employee exists in DB
      final employee = await DatabaseHelper.instance.getEmployeeByEmployeeId(event.empId);

      if (employee != null) {
        emit(LoginSuccess());
      } else {
        emit(LoginFailure("Invalid Employee ID"));
      }
    });
  }
}
