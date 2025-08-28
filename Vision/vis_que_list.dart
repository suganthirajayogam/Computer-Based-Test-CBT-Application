import 'package:flutter/material.dart';
import 'package:computer_based_test/Vision/vis_ques_edit.dart';
import 'package:computer_based_test/database/vision_question.db.dart';
import 'package:computer_based_test/models/vis_ques_model.dart';

class VisionQuestionListScreen extends StatelessWidget {
  final String module;

  const VisionQuestionListScreen({required this.module, super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<VisionQuestionModel>>(
      future: VisionQuestionDB.instance.getQuestionsByModule(module),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else {
          final questions = snapshot.data ?? [];

          return Scaffold(
            appBar: AppBar(
              title: Text(
                "Questions for $module",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: const Color(0xFF0D47A1), // Indigo dark
              foregroundColor: Colors.white,
              elevation: 4,
            ),
            body: questions.isEmpty
                ? const Center(
                    child: Text(
                      "No questions found.",
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: questions.length,
                    itemBuilder: (context, index) {
                      final question = questions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.2)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  Colors.orange.shade400,
                                  Colors.deepOrange.shade600
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          title: Text(
                            question.questionText ?? "No question text",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: "Edit Question",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => VisionQuestionEdit(
                                    question: question,
                                    moduleName: module,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
          );
        }
      },
    );
  }
}
