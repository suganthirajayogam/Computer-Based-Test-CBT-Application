import 'package:flutter/material.dart';
import 'package:computer_based_test/screens/exam_mcq_screen.dart';

class ExamQuizLoader extends StatelessWidget {
  const ExamQuizLoader({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    return ExamMCQScreen(
      subject: args['subject'],
      employee: args['employee'],
      questions: const [], // or pass if you already have questions
    );
  }
}
