
import 'package:flutter/material.dart';
import 'package:computer_based_test/database/mcq_question_db.dart';

class EditQuestionScreen extends StatefulWidget {
  final Map<String, dynamic> question;
  final VoidCallback onUpdated;

  const EditQuestionScreen({super.key, required this.question, required this.onUpdated});

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  late TextEditingController questionText;
  late TextEditingController optionA;
  late TextEditingController optionB;
  late TextEditingController optionC;
  late TextEditingController optionD;
  late TextEditingController correctAnswer;

  @override
  void initState() {
    super.initState();
    questionText = TextEditingController(text: widget.question['questionText']);
    optionA = TextEditingController(text: widget.question['optionA']);
    optionB = TextEditingController(text: widget.question['optionB']);
    optionC = TextEditingController(text: widget.question['optionC']);
    optionD = TextEditingController(text: widget.question['optionD']);
    correctAnswer = TextEditingController(text: widget.question['correctAnswer']);
  }

  @override
  void dispose() {
    questionText.dispose();
    optionA.dispose();
    optionB.dispose();
    optionC.dispose();
    optionD.dispose();
    correctAnswer.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final updated = {
      'id': widget.question['id'],
      'questionText': questionText.text,
      'optionA': optionA.text,
      'optionB': optionB.text,
      'optionC': optionC.text,
      'optionD': optionD.text,
      'correctAnswer': correctAnswer.text,
      'questionImagePath': widget.question['questionImagePath'],
      'optionAImagePath': widget.question['optionAImagePath'],
      'optionBImagePath': widget.question['optionBImagePath'],
      'optionCImagePath': widget.question['optionCImagePath'],
      'optionDImagePath': widget.question['optionDImagePath'],
      'subject': widget.question['subject'],
    };

    await MCQQuestionDatabase.instance.updateQuestion(
  widget.question['id'], // <-- the ID
  updated,               // <-- the updated data map
);

    widget.onUpdated();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Question"), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: questionText, decoration: const InputDecoration(labelText: "Question")),
              const SizedBox(height: 10),
              TextField(controller: optionA, decoration: const InputDecoration(labelText: "Option A")),
              TextField(controller: optionB, decoration: const InputDecoration(labelText: "Option B")),
              TextField(controller: optionC, decoration: const InputDecoration(labelText: "Option C")),
              TextField(controller: optionD, decoration: const InputDecoration(labelText: "Option D")),
              const SizedBox(height: 10),
              TextField(controller: correctAnswer, decoration: const InputDecoration(labelText: "Correct Answer (A/B/C/D)")),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text("Save Changes"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: _save,
              )
            ],
          ),
        ),
      ),
    );
  }
}
