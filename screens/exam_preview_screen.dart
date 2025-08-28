import 'package:flutter/material.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';

class ExamPreviewScreen extends StatelessWidget {
  final List<MCQQuestion> questions;
  final Map<int, String> selectedAnswers;
  final String subject;
  final Map<String, dynamic> employee;

  const ExamPreviewScreen({
    super.key,
    required this.questions,
    required this.selectedAnswers,
    required this.subject,
    required this.employee,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Answers")),
      body: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (_, index) {
          final q = questions[index];
          final selected = selectedAnswers[index];

          return Card(
            margin: const EdgeInsets.all(10),
            child: ListTile(
              title: Text("Q${index + 1}: ${q.question}"),
              subtitle: Text("Selected: ${selected ?? 'Not Answered'}"),
              trailing: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, index); // 👈 Return index to go to that question
                },
                child: const Text("Change"),
              ),
            ),
          );
        },
      ),
    );
  }
}
