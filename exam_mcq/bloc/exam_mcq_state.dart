import 'package:computer_based_test/models/mcq_ques_model.dart';

abstract class ExamMCQState {}

class ExamInitial extends ExamMCQState {}

class ExamLoaded extends ExamMCQState {
  final MCQQuestion question;
  final int currentIndex;
  final int totalQuestions;
  final Map<int, String> selectedAnswers;

  ExamLoaded(
    this.question,
    this.currentIndex,
    this.totalQuestions,
    this.selectedAnswers,
  );
}

class ExamCompleted extends ExamMCQState {
  final Map<int, String> selectedAnswers;

  ExamCompleted(this.selectedAnswers);
}

class ExamError extends ExamMCQState {
  final String message;

  ExamError(this.message);

  
}
