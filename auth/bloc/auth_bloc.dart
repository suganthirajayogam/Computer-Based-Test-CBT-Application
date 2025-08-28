// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:computer_based_test/database/database_helper.dart';
// import 'package:computer_based_test/models/employee.dart';
// import 'auth_event.dart';
// import 'auth_state.dart';

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final DatabaseHelper _databaseHelper;

//   AuthBloc({required DatabaseHelper databaseHelper})
//       : _databaseHelper = databaseHelper,
//         super(const AuthInitial()) {
//     on<LoginRequested>(_onLoginRequested);
//     on<CreateDummyAdmin>(_onCreateDummyAdmin);
//   }

//   // ✅ Modified: No password check, only employeeId and employeeName
//   Future<void> _onLoginRequested(
//     LoginRequested event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthLoading(message: 'Logging in...'));
//     try {
//       final Employee? employee = await _databaseHelper.getEmployeeByEmployeeId(event.employeeId);

//       if (employee == null) {
//         emit(const AuthFailure(message: 'Employee ID not found.'));
//       } else if (employee.employeeName.toLowerCase() != event.employeeName.toLowerCase()) {
//         emit(const AuthFailure(message: 'Incorrect employee name.'));
//       } else {
//         emit(AuthSuccess(employee: employee, message: 'Login successful!'));
//       }
//     } catch (e) {
//       emit(AuthFailure(message: 'Login error: ${e.toString()}'));
//     }
//   }

//   // ✅ Create dummy admin with password still allowed for admin creation only
//   Future<void> _onCreateDummyAdmin(
//     CreateDummyAdmin event,
//     Emitter<AuthState> emit,
//   ) async {
//     emit(const AuthLoading(message: 'Creating dummy admin...'));
//     try {
//       const String adminId = '123';
//       const String adminName = 'jay';
//       const String adminPassword = 'jay@123';

//       final Employee? existing = await _databaseHelper.getEmployeeByEmployeeId(adminId);

//       if (existing == null) {
//         await _databaseHelper.insertEmployee(
//           Employee(
//             employeeId: adminId,
//             employeeName: adminName,
//             employeePassword: adminPassword,
//           ),
//         );
//         emit(AuthSuccess(
//           employee: Employee(
//             employeeId: adminId,
//             employeeName: adminName,
//             employeePassword: adminPassword,
//           ),
//           message: 'Dummy admin created: ID: $adminId, Name: $adminName',
//         ));
//       } else {
//         emit(const AuthFailure(message: 'Dummy admin already exists.'));
//       }
//     } catch (e) {
//       emit(AuthFailure(message: 'Error creating dummy admin: ${e.toString()}'));
//     }
//   }
// }
