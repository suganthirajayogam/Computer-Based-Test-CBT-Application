import 'package:computer_based_test/database/mcq_result_db.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:computer_based_test/database/accountcreation.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';
 
class ExamResultScreen extends StatefulWidget {
  final int total;
  final int correct;
  final Map<String, dynamic> employee;
  final List<MCQQuestion> questions;
  final List<String> selectedAnswers;
 
  const ExamResultScreen({
    super.key,
    required this.total,
    required this.correct,
    required this.employee,
    required this.questions,
    required this.selectedAnswers,
  });
 
  @override
  State<ExamResultScreen> createState() => _ExamResultScreenState();
}
 
class _ExamResultScreenState extends State<ExamResultScreen> {
  late String percentage;
  late String status;
  late String date;
  late bool isPassed;
 
  @override
  void initState() {
    super.initState();
 
      percentage = ((widget.correct / widget.total) * 100).toStringAsFixed(2);
    isPassed = double.tryParse(percentage) != null &&
        double.parse(percentage) >= 80.0;
    status = isPassed ? "Pass" : "Fail";
    date = DateFormat('yyyy-MM-dd').format(DateTime.now());
 
    _saveResultToDB();
  }
 
  String getOptionText(String label, MCQQuestion q) {
    switch (label) {
      case 'A':
        return q.optionA;
      case 'B':
        return q.optionB;
      case 'C':
        return q.optionC;
      case 'D':
        return q.optionD;
      default:
        return '';
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F9FF),
      appBar: AppBar(
        title: const Text("MCQ Exam Result"),
        backgroundColor: Colors.teal.shade700,
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 700),
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 60, color: Colors.amber),
              const SizedBox(height: 12),
              Text(
                isPassed ? "🎉 Congratulations!" : "Keep Trying!",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: isPassed ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoRow("👤 Employee:", widget.employee['employeeName']),
              _buildInfoRow("🆔 ID:", widget.employee['employeeId']),
              const SizedBox(height: 12),
              _buildInfoRow("📊 Score:", "${widget.correct} / ${widget.total}"),
              _buildInfoRow("📈 Percentage:", "$percentage%"),
              _buildInfoRow(
                "📋 Status:",
                status,
                valueColor: isPassed ? Colors.green : Colors.red,
              ),
              _buildInfoRow("🗓 Date:", date),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home),
                label: const Text("Back to Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  void _saveResultToDB() async {
    final db = ExamResultDatabase.instance;
 
    final empId = widget.employee['employeeId'];
 
    if (empId == null || empId.toString().isEmpty) {
      print('❌ No employee_id found in data!');
      return;
    }
 
    final updateData = {
      'score': widget.correct,
      'percentage': double.parse(percentage),
      'status': status,
      'date': date,
    };
 
    
  }
 
}
 
 