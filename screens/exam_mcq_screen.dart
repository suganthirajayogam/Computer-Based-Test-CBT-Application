import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:computer_based_test/database/mcq_result_db.dart';
import 'package:computer_based_test/models/exam_result.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';
import 'package:computer_based_test/exam_mcq/bloc/exam_mcq_bloc.dart';
import 'package:computer_based_test/exam_mcq/bloc/exam_mcq_event.dart';
import 'package:computer_based_test/exam_mcq/bloc/exam_mcq_state.dart';
import 'package:computer_based_test/screens/exam_preview_screen.dart';

class ExamMCQScreen extends StatefulWidget {
  final List<MCQQuestion> questions;
  final String subject;
  final Map<String, dynamic> employee;

  const ExamMCQScreen({
    Key? key,
    required this.questions,
    required this.subject,
    required this.employee,
  }) : super(key: key);

  @override
  State<ExamMCQScreen> createState() => _ExamMCQScreenState();
}

class _ExamMCQScreenState extends State<ExamMCQScreen> {
  late List<MCQQuestion> _shuffledQuestions;
  bool _resultShown = false;

  @override
  void initState() {
    super.initState();
    // Shuffle the questions only once when the widget is created
    _shuffledQuestions = List.of(widget.questions)..shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExamMCQBloc()..add(LoadMCQQuestions(_shuffledQuestions)),
      child: Scaffold(
        appBar: AppBar(title: Text("${widget.subject} Exam")),
        body: BlocBuilder<ExamMCQBloc, ExamMCQState>(
          builder: (context, state) {
            if (state is ExamLoaded) {
              final q = state.question;
              final selected = state.selectedAnswers[state.currentIndex - 1];

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // LEFT: Question panel
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: 'Question ',
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                              children: [
                                TextSpan(
                                  text:
                                      '${state.currentIndex} of ${state.totalQuestions}',
                                  style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 220, 3, 3),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Question text
                          if ((q.question ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                q.question ?? '',
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                          // Question image
                          if (q.questionImagePath != null &&
                              q.questionImagePath!.isNotEmpty &&
                              File(q.questionImagePath!).existsSync())
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Image.file(
                                File(q.questionImagePath!),
                                height: 150,
                              ),
                            ),

                          const SizedBox(height: 10),

                          // Options
                          for (var label in ['A', 'B', 'C', 'D'])
                            _buildOption(q, label, selected, context),

                          const Spacer(),

                          // Navigation buttons
                          Wrap(
                            spacing: 10,
                            children: [
                              if (state.currentIndex > 1)
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<ExamMCQBloc>().add(PreviousQuestion());
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.lightBlue,
                                  ),
                                  child: const Text("Previous"),
                                ),
                              if (state.currentIndex == state.totalQuestions) ...[
                                ElevatedButton(
                                  onPressed: () async {
                                    final index = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ExamPreviewScreen(
                                          questions: _shuffledQuestions,
                                          subject: widget.subject,
                                          employee: widget.employee,
                                          selectedAnswers: state.selectedAnswers,
                                        ),
                                      ),
                                    );
                                    if (index != null && index is int) {
                                      context.read<ExamMCQBloc>().add(JumpToQuestion(index));
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                  ),
                                  child: const Text("Revise"),
                                ),
                                ElevatedButton(
                                  onPressed: selected != null
                                      ? () {
                                          context.read<ExamMCQBloc>().add(SubmitExam());
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        const Color.fromARGB(255, 244, 57, 44),
                                  ),
                                  child: const Text("Submit"),
                                ),
                              ] else
                                ElevatedButton(
                                  onPressed: selected != null
                                      ? () {
                                          context.read<ExamMCQBloc>().add(NextQuestion());
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                  ),
                                  child: const Text("Save & Next"),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // RIGHT: Question number panel
                  Container(
                    width: 60,
                    margin:
                        const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: state.totalQuestions,
                      itemBuilder: (context, index) {
                        final isSelected = (index + 1) == state.currentIndex;
                        final isAnswered = state.selectedAnswers[index] != null;

                        return GestureDetector(
                          onTap: () {
                            context.read<ExamMCQBloc>().add(JumpToQuestion(index + 1));
                          },
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.blue
                                  : isAnswered
                                      ? Colors.green
                                      : Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.black),
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
          }
          else if (state is ExamCompleted) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              if (_resultShown) return;
              _resultShown = true;
              int correctCount = 0;
              for (int i = 0; i < _shuffledQuestions.length; i++) {
                if (state.selectedAnswers[i] != null &&
                    state.selectedAnswers[i] == _shuffledQuestions[i].correctAnswer) {
                  correctCount++;
                }
              }
              int totalQuestions = _shuffledQuestions.length;
              int attemptedCount = state.selectedAnswers.values.where((e) => e != null).length;
              int correctAnswers = correctCount;

              // Save individual question results
              for (int i = 0; i < totalQuestions; i++) {
                await ExamResultDatabase.instance.insertResult(
                  ExamResult(
                    empId: widget.employee['employeeId'] ?? '',
                    empName: widget.employee['employeeName'] ?? '',
                    subject: widget.subject,
                    module: widget.employee['module'] ?? '',
                    questionId: _shuffledQuestions[i].id ?? 0,
                    questionText: _shuffledQuestions[i].question ?? '',
                    correctAnswer: _shuffledQuestions[i].correctAnswer ?? '',
                    attempted: state.selectedAnswers[i] ?? '',
                    imagePath: _shuffledQuestions[i].questionImagePath ?? '',
                    totalQuestions: totalQuestions,
                  ),
                );
              }

              int score = correctCount;
              // Calculate percentage as a double for storage in the database
              double percentage = (score / totalQuestions) * 100;

              // Calculate a whole number percentage for display
              // Determine status based on the precise percentage
              String status = percentage >= 80 ? "Pass" : "Fail";
              String date = DateFormat('yyyy-MM-dd').format(DateTime.now());

              // Now insert summary
              await ExamResultDatabase.instance.insertSummary(
                ExamResultSummary(
                  empId: widget.employee['employeeId'] ?? '',
                  empName: widget.employee['employeeName'] ?? '',
                  subject: widget.subject,
                  module: widget.employee['module'] ?? '',
                  totalQuestions: totalQuestions,
                  attempted: attemptedCount,
                  correct: correctCount,
                  score: score,
                  percentage: percentage, // Save the precise double
                  status: status,
                  date: date,
                ),
              );
              print("✅ Exam summary inserted for Employee ID: ${widget.employee['employeeId']}");

              // Show result dialog
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: const BoxDecoration(
                      color: Colors.teal,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        "✅ Test Submitted Successfully!",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.employee['empImagePath'] != null &&
                          File(widget.employee['empImagePath']).existsSync())
                        ClipOval(
                          child: Image.file(
                            File(widget.employee['empImagePath']),
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 10),
                      Text("👤 ${widget.employee['employeeName'] ?? ''}",
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text("Score: $score"),
                      Text("Correct Answers: $correctAnswers / $totalQuestions"),
                      // Use the integer variable directly here
                        Text("Percentage: ${percentage.toStringAsFixed(2)}%"),
                      Text(
                        "Status: $status",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: status == "Pass" ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  actionsAlignment: MainAxisAlignment.center,
                  actions: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text("View Result"),
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushReplacementNamed(
                          context,
                          '/exam_result',
                          arguments: {
                            'employee': widget.employee,
                            'total': totalQuestions,
                            'correct': correctAnswers,
                            'questions': _shuffledQuestions.map((q) => q.toMap()).toList(),
                            'selectedAnswers': state.selectedAnswers,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
            return const Center(child: SizedBox());
          } else if (state is ExamError) {
            return Center(child: Text(state.message));
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    ),
  );
}

  Widget _buildOption(
    MCQQuestion q,
    String label,
    String? selected,
    BuildContext context,
  ) {
    String? optionText;
    String? imagePath;

    switch (label) {
      case 'A':
        optionText = q.optionA;
        imagePath = q.optionAImagePath;
        break;
      case 'B':
        optionText = q.optionB;
        imagePath = q.optionBImagePath;
        break;
      case 'C':
        optionText = q.optionC;
        imagePath = q.optionCImagePath;
        break;
      case 'D':
        optionText = q.optionD;
        imagePath = q.optionDImagePath;
        break;
    }

    return RadioListTile<String>(
      value: label,
      groupValue: selected,
      onChanged: (val) {
        context.read<ExamMCQBloc>().add(SelectAnswer(label));
      },
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$label. ${optionText ?? ''}",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (imagePath != null &&
              imagePath.isNotEmpty &&
              File(imagePath).existsSync())
            Image.file(File(imagePath), height: 80),
        ],
      ),
    );
  }
}