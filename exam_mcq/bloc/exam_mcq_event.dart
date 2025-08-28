import 'package:computer_based_test/models/mcq_ques_model.dart';

abstract class ExamMCQEvent {}

class LoadMCQQuestions extends ExamMCQEvent {
  final List<MCQQuestion> questions;
  LoadMCQQuestions(this.questions);
}

class SelectAnswer extends ExamMCQEvent {
  final String selectedOption;
  SelectAnswer(this.selectedOption);
}

class NextQuestion extends ExamMCQEvent {}

class PreviousQuestion extends ExamMCQEvent {}

class SubmitExam extends ExamMCQEvent {}

class JumpToQuestion extends ExamMCQEvent {
  final int index;
  JumpToQuestion(this.index);
}
