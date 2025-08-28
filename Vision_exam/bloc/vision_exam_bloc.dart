import 'package:flutter_bloc/flutter_bloc.dart';
import 'vision_exam_event.dart';
import 'vision_exam_state.dart';

class VisionExamBloc extends Bloc<VisionExamEvent, VisionExamState> {
  VisionExamBloc() : super(const VisionExamState()) {
    // Load questions and shuffle them before setting the initial state.
    on<LoadVisionQuestions>((event, emit) {
      // Create a mutable copy of the questions list.
      final shuffledQuestions = List.of(event.questions);

      // Shuffle the list of questions randomly.
      shuffledQuestions.shuffle();

      final allReasonsSet = <String>{};
      for (var question in shuffledQuestions) {
        allReasonsSet.addAll(question.allReasons);
      }

      emit(state.copyWith(
        questions: shuffledQuestions, // Use the shuffled list
        empName: event.empName,
        empId: event.empId,
        module: event.module,
        currentIndex: 0,
        selectedAnswers: {},
        selectedReasons: {},
        allReasons: allReasonsSet.toList(),
      ));
    });

    // Handle answer selection
    on<VisionExamAnswerSelected>((event, emit) {
      final updatedAnswers = Map<int, String>.from(state.selectedAnswers)
        ..[event.index] = event.answer;

      if (event.answer == "Good") {
        final updatedReasons = Map<int, List<String>>.from(state.selectedReasons)
          ..remove(event.index);
        emit(state.copyWith(
          selectedAnswers: updatedAnswers,
          selectedReasons: updatedReasons,
        ));
      } else {
        emit(state.copyWith(selectedAnswers: updatedAnswers));
      }
    });

    // Toggle a single reason
    on<VisionExamReasonSelected>((event, emit) {
      final updatedReasons = Map<int, List<String>>.from(state.selectedReasons);
      final currentReasons = updatedReasons[event.index] ?? [];

      if (currentReasons.contains(event.reason)) {
        currentReasons.remove(event.reason);
      } else {
        currentReasons.add(event.reason);
      }

      updatedReasons[event.index] = currentReasons;
      emit(state.copyWith(selectedReasons: updatedReasons));
    });

    // Select full list of reasons (from checkbox list)
    on<VisionExamReasonSelectedList>((event, emit) {
      final updatedReasons = Map<int, List<String>>.from(state.selectedReasons)
        ..[event.index] = event.reasons;

      emit(state.copyWith(selectedReasons: updatedReasons));
    });

    // Navigate to another question
    on<VisionExamQuestionChanged>((event, emit) {
      if (event.newIndex >= 0 && event.newIndex < state.questions.length) {
        emit(state.copyWith(currentIndex: event.newIndex));
      }
    });

    // Submit event handler - MUST be inside constructor
    on<VisionExamSubmitted>((event, emit) {
      print("Vision exam submitted!");
      // Add your submit logic here (save results, navigate, etc)
    });
  }
}

// Your event class should be outside the bloc:
class VisionExamSubmitted extends VisionExamEvent {}

// Placeholder for the necessary state and event classes
// This makes the provided code block self-contained and runnable
abstract class VisionExamEvent {}
class LoadVisionQuestions extends VisionExamEvent {
  final List<dynamic> questions;
  final String empName;
  final String empId;
  final String module;
  LoadVisionQuestions({required this.questions, required this.empName, required this.empId, required this.module});
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
  VisionExamQuestionChanged(int index, {required this.newIndex});
}

class VisionExamState {
  final List<dynamic> questions;
  final String empName;
  final String empId;
  final String module;
  final int currentIndex;
  final Map<int, String> selectedAnswers;
  final Map<int, List<String>> selectedReasons;
  final List<String> allReasons;

  const VisionExamState({
    this.questions = const [],
    this.empName = '',
    this.empId = '',
    this.module = '',
    this.currentIndex = 0,
    this.selectedAnswers = const {},
    this.selectedReasons = const {},
    this.allReasons = const [],
  });

  VisionExamState copyWith({
    List<dynamic>? questions,
    String? empName,
    String? empId,
    String? module,
    int? currentIndex,
    Map<int, String>? selectedAnswers,
    Map<int, List<String>>? selectedReasons,
    List<String>? allReasons,
  }) {
    return VisionExamState(
      questions: questions ?? this.questions,
      empName: empName ?? this.empName,
      empId: empId ?? this.empId,
      module: module ?? this.module,
      currentIndex: currentIndex ?? this.currentIndex,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
      selectedReasons: selectedReasons ?? this.selectedReasons,
      allReasons: allReasons ?? this.allReasons,
    );
  }
}
