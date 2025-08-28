import 'package:flutter/material.dart';
import 'package:computer_based_test/widgets/employee_login_test.dart'; // Your login form widget

class EmployeeLoginScreen extends StatelessWidget {
  const EmployeeLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Employee Login"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: EmployeeLoginForm(
              onSubmit: (formData) {
                Navigator.pushNamed(
                  context,
                  '/examquiz',
                  arguments: {
                    'subject': formData['subject'],
                    'employee': formData,
                    'questions': formData['questions'],
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
