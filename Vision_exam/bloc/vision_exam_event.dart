import 'package:computer_based_test/models/vis_ques_model.dart';

abstract class VisionExamEvent {}

class LoadVisionQuestions extends VisionExamEvent {
  final List<VisionQuestionModel> questions;
  final String empName;
  final String empId;
  final String module;

  LoadVisionQuestions({
    required this.questions,
    required this.empName,
    required this.empId,
    required this.module,
  });
}

class VisionExamAnswerSelected extends VisionExamEvent {
  final int index;
  final String answer;

  VisionExamAnswerSelected({required this.index, required this.answer});
}

class VisionExamReasonSelected extends VisionExamEvent {
  final int index;
  final String reason;

  VisionExamReasonSelected({required this.index, required this.reason});
}

class VisionExamReasonSelectedList extends VisionExamEvent {
  final int index;
  final List<String> reasons;

  VisionExamReasonSelectedList({required this.index, required this.reasons});
}

class VisionExamQuestionChanged extends VisionExamEvent {
  final int newIndex;

  VisionExamQuestionChanged(this.newIndex);
}

