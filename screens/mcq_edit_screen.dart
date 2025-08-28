import 'dart:io';
import 'package:flutter/material.dart';
import 'package:computer_based_test/database/mcq_question_db.dart';
import 'package:computer_based_test/screens/edit_exam_screen.dart';

class MCQPreviewScreen extends StatefulWidget {
  final String subject;

  const MCQPreviewScreen({super.key, required this.subject});

  @override
  State<MCQPreviewScreen> createState() => _MCQPreviewScreenState();
}

class _MCQPreviewScreenState extends State<MCQPreviewScreen> {
  List<Map<String, dynamic>> questions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

 Future<void> _loadQuestions() async {
  final data = await MCQQuestionDatabase.instance.getQuestionsBySubject(widget.subject);
  setState(() {
    questions = data.map((q) => q.toMap()).toList(); // 👈 FIXED HERE
  });
}


  Future<void> _deleteQuestion(int id) async {
    await MCQQuestionDatabase.instance.deleteQuestion(id);
    _loadQuestions();
  }

  void _editQuestion(Map<String, dynamic> question) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditQuestionScreen(
          question: question,
          onUpdated: _loadQuestions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.subject} Preview")),
      body: questions.isEmpty
          ? const Center(child: Text("No questions available"))
          : ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
                return _buildQuestionCard(q);
              },
            ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q) {
    Widget questionContent = q['questionText'].toString().isNotEmpty
        ? Text(q['questionText'])
        : Container();

    if (q['questionImagePath'] != null && q['questionImagePath'].toString().isNotEmpty) {
      questionContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (q['questionText'].toString().isNotEmpty) Text(q['questionText']),
          const SizedBox(height: 8),
          Image.file(File(q['questionImagePath']), height: 150),
        ],
      );
    }

    Widget buildOption(String label) {
      final text = q['option$label'].toString();
      final imagePath = q['option${label}ImagePath'];
      return ListTile(
        leading: imagePath != null && imagePath.toString().isNotEmpty
            ? Image.file(File(imagePath), width: 40, height: 40)
            : null,
        title: Text("$label. $text"),
        trailing: q['correctAnswer'] == label ? const Icon(Icons.check, color: Colors.green) : null,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            questionContent,
            const Divider(),
            buildOption('A'),
            buildOption('B'),
            buildOption('C'),
            buildOption('D'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Confirmation'),
                        content: const Text('Are you sure you want to delete this question?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await _deleteQuestion(q['id']);
                    }
                  },
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _editQuestion(q),
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label: const Text('Edit', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
