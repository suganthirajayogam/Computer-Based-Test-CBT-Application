import 'package:flutter/material.dart';
import 'package:computer_based_test/database/mcq_question_db.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';
import 'package:computer_based_test/screens/question_editor_screen.dart';

class MCQScreen extends StatefulWidget {
  final String subject;
  const MCQScreen({super.key, required this.subject});

  @override
  State<MCQScreen> createState() => _MCQScreenState();
}

class _MCQScreenState extends State<MCQScreen> {
  List<MCQQuestion> _questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await MCQQuestionDatabase.instance.getQuestionsBySubject(widget.subject);
    setState(() {
      _questions = questions;
    });
  }

  Future<void> _deleteQuestion(int id) async {
    await MCQQuestionDatabase.instance.deleteQuestion(id);
    await _loadQuestions();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Question deleted")),
    );
  }

  void _editQuestion(MCQQuestion question) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuestionEditorScreen(
          subject: widget.subject,
          editingQuestion: question,
        ),
      ),
    );
    if (result == true) {
      _loadQuestions();
    }
  }

  Widget _buildQuestionCard(MCQQuestion q) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(q.question, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...[
              {'key': 'A', 'text': q.optionA},
              {'key': 'B', 'text': q.optionB},
              {'key': 'C', 'text': q.optionC},
              {'key': 'D', 'text': q.optionD},
            ].map((opt) {
              final isCorrect = q.correctAnswer == opt['key'];
              return ListTile(
                dense: true,
                title: Text('${opt['key']}. ${opt['text']}'),
                trailing: isCorrect ? const Icon(Icons.check, color: Colors.green) : null,
              );
            }),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () => _editQuestion(q),
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  label: const Text("Edit"),
                ),
                TextButton.icon(
                  onPressed: () => _deleteQuestion(q.id!),
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text("Delete"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.subject} Questions"),
        backgroundColor: Colors.purple.shade400,
      ),
      body: _questions.isEmpty
          ? const Center(child: Text("No questions found"))
          : ListView.builder(
              itemCount: _questions.length,
              itemBuilder: (_, index) {
                return _buildQuestionCard(_questions[index]);
              },
            ),
    );
  }
}
