import 'package:flutter/material.dart';
import 'package:computer_based_test/models/Vision_result_model.dart';
import 'package:computer_based_test/models/vis_ques_model.dart';
 
class VisionResultScreen extends StatefulWidget {
  final String empId;
  final String empName;
  final String module;
  final Map<int, String> selectedAnswers;
  final Map<int, List<String>> selectedReasons;
  final List<VisionQuestionModel> questions;
 
  const VisionResultScreen({
    Key? key,
    required this.empId,
    required this.empName,
    required this.module,
    required this.selectedAnswers,
    required this.selectedReasons,
    required this.questions,
  }) : super(key: key);
 
  @override
  State<VisionResultScreen> createState() => _VisionResultScreenState();
}
 
class _VisionResultScreenState extends State<VisionResultScreen> {
  List<VisionExamResultModel> results = [];
  bool isLoading = true;
 
  int total = 0;
  double score = 0;
  double percent = 0;
  String status = '';
 
  @override
  void initState() {
    super.initState();
    _processResults();
  }
 
  Future<void> _processResults() async {
    total = widget.questions.length;
    double totalScore = 0;
 
    results.clear();
 
    for (int i = 0; i < total; i++) {
      final q = widget.questions[i];
      final selectedAnswer = widget.selectedAnswers[i] ?? '';
      final selectedReasonList = widget.selectedReasons[i] ?? [];
 
      final correctReasons = q.reasons;
      double questionScore = 0;
 
      bool isAnswerCorrect = selectedAnswer.toLowerCase().trim() ==
          q.correctAnswer.toLowerCase().trim();
 
      if (isAnswerCorrect) {
        if (selectedAnswer == 'Good') {
          questionScore = 1.0;
        } else if (selectedAnswer == 'Not Good') {
          final matchedReasons = selectedReasonList
              .where((r) => correctReasons.contains(r))
              .toList();
 
          if (matchedReasons.length == correctReasons.length &&
              correctReasons.length == selectedReasonList.length) {
            questionScore = 1.0;
          } else {
            questionScore = 0.5;
          }
        }
      } else {
        questionScore = 0.0;
      }
 
      totalScore += questionScore;
 
      final result = VisionExamResultModel(
        empId: widget.empId,
        empName: widget.empName,
        module: widget.module,
        questionId: q.id ?? 0,
        questionText: q.questionText ?? '',
        correctAnswer: q.correctAnswer,
        selectedAnswer: selectedAnswer,
        selectedReasons: selectedReasonList.join(', '),
      );
 
      results.add(result);
    }
 
    score = totalScore;
    percent = (score / total) * 100;
    status = percent >= 60 ? "Passed" : "Failed";
 
    setState(() {
      isLoading = false;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
 
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vision Exam Result"),
        backgroundColor: Colors.teal.shade300,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: screenWidth > 600 ? 600 : double.infinity,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    color: Colors.teal.shade50,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            "Vision Test Summary",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildInfoRow("👤 Employee", widget.empName),
                          _buildInfoRow("🆔 Employee ID", widget.empId),
                          _buildInfoRow("📘 Module", widget.module),
                          _buildInfoRow("❓ Total Questions", "$total"),
                          _buildInfoRow("✅ Score", "${score.toStringAsFixed(1)} / $total"),
                          _buildInfoRow("📊 Percentage", "${percent.toStringAsFixed(2)}%"),
                          _buildInfoRow(
                            "🏁 Status",
                            status,
                            valueColor:
                                status == "Passed" ? Colors.green : Colors.red,
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.popUntil(context, (route) => route.isFirst);
                            },
                            icon: const Icon(Icons.home),
                            label: const Text("Back to Home"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 14),
                              textStyle: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
 
  Widget _buildInfoRow(String title, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
 