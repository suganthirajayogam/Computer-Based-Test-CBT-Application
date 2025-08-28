import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';
import 'exam_mcq_event.dart';
import 'exam_mcq_state.dart';

class ExamMCQBloc extends Bloc<ExamMCQEvent, ExamMCQState> {
  final List<MCQQuestion> _questions = [];
  final Map<int, String> _selectedAnswers = {};
  int _currentIndex = 1;

  ExamMCQBloc() : super(ExamInitial()) {
    on<LoadMCQQuestions>(_onLoadQuestions);
    on<SelectAnswer>(_onSelectAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<JumpToQuestion>(_onJumpToQuestion);
    on<SubmitExam>(_onSubmitExam);
  }

  void _onLoadQuestions(LoadMCQQuestions event, Emitter emit) {
    _questions.clear();
    _questions.addAll(event.questions);
    _selectedAnswers.clear();
    _currentIndex = 1;

    if (_questions.isEmpty) {
      emit(ExamError("No questions available."));
    } else {
      emit(_buildState());
    }
  }

  void _onSelectAnswer(SelectAnswer event, Emitter emit) {
    _selectedAnswers[_currentIndex - 1] = event.selectedOption;
    emit(_buildState());
  }

  void _onNextQuestion(NextQuestion event, Emitter emit) {
    if (_currentIndex < _questions.length) _currentIndex++;
    emit(_buildState());
  }

  void _onPreviousQuestion(PreviousQuestion event, Emitter emit) {
    if (_currentIndex > 1) _currentIndex--;
    emit(_buildState());
  }

  void _onJumpToQuestion(JumpToQuestion event, Emitter emit) {
    _currentIndex = event.index; // ✅ Removed +1 here
    emit(_buildState());
  }

  void _onSubmitExam(SubmitExam event, Emitter emit) {
    emit(ExamCompleted(Map.from(_selectedAnswers)));
  }

  ExamLoaded _buildState() {
    return ExamLoaded(
      _questions[_currentIndex - 1],
      _currentIndex,
      _questions.length,
      Map.from(_selectedAnswers),
    );
  }
}
