import 'package:flutter/material.dart';
import 'package:computer_based_test/database/mcq_question_db.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';
 
class TestPage extends StatelessWidget {
  const TestPage({super.key});
 
  @override
  Widget build(BuildContext context) {
    final data =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final empName = data['employeeName'];
    final empId = data['employeeId'];
    final module = data['module']; // ✅ Already selected module
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Page'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, $empName',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // ✅ Fetch questions for the selected module
                  List<MCQQuestion> questions = await MCQQuestionDatabase
                      .instance
                      .getQuestionsBySubject(module);
 
                  Navigator.pushNamed(
                    context,
                    '/examquiz',
                    arguments: {
                      'subject': module,
                      'employee': {
                        'employeeId': empId,
                        'employeeName': empName,
                        'module': module,
                      },
                      'questions': questions,
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                ),
                child: const Text('Proceed'),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
 
 