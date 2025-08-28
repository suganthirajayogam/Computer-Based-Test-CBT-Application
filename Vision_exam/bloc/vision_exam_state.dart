import 'package:computer_based_test/models/vis_ques_model.dart';

class VisionExamState {
  final List<VisionQuestionModel> questions;
  final int currentIndex;
  final Map<int, String> selectedAnswers;
  final Map<int, List<String>> selectedReasons;
  final List<String> allReasons; // ✅ NEW
  final String empName;
  final String empId;
  final String module;

  VisionExamState({
    this.questions = const [],
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.selectedReasons = const {},
    this.allReasons = const [], // ✅ NEW
    this.empName = '',
    this.empId = '',
    this.module = '',
  });

  VisionExamState copyWith({
    List<VisionQuestionModel>? questions,
    int? currentIndex,
    Map<int, String>? selectedAnswers,
    Map<int, List<String>>? selectedReasons,
    List<String>? allReasons, // ✅ NEW
    String? empName,
    String? empId,
    String? module,
  }) {
    return VisionExamState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      selectedReasons: selectedReasons ?? this.selectedReasons,
      allReasons: allReasons ?? this.allReasons, // ✅
      empName: empName ?? this.empName,
      empId: empId ?? this.empId,
      module: module ?? this.module,
    );
  }
}
