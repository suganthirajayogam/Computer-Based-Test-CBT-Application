import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:computer_based_test/database/mcq_question_db.dart';
import 'package:computer_based_test/models/mcq_ques_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';

class QuestionEditorScreen extends StatefulWidget {
  final String subject;
  final MCQQuestion? editingQuestion;

  const QuestionEditorScreen({
    super.key,
    required this.subject,
    this.editingQuestion,
  });

  @override
  State<QuestionEditorScreen> createState() => _QuestionEditorScreenState();
}

class _QuestionEditorScreenState extends State<QuestionEditorScreen> {
  final _questionTextController = TextEditingController();
  File? _questionImage;
  final Map<String, TextEditingController> _optionTextControllers = {
    'A': TextEditingController(),
    'B': TextEditingController(),
    'C': TextEditingController(),
    'D': TextEditingController(),
  };
  final Map<String, File?> _optionImages = {
    'A': null,
    'B': null,
    'C': null,
    'D': null,
  };
  String? _correctAnswer;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.editingQuestion != null) {
      final q = widget.editingQuestion!;
      _questionTextController.text = q.question;
      if (q.questionImagePath != null) _questionImage = File(q.questionImagePath!);
      _optionTextControllers['A']!.text = q.optionA ?? '';
      _optionTextControllers['B']!.text = q.optionB ?? '';
      _optionTextControllers['C']!.text = q.optionC ?? '';
      _optionTextControllers['D']!.text = q.optionD ?? '';
      if (q.optionAImagePath != null) _optionImages['A'] = File(q.optionAImagePath!);
      if (q.optionBImagePath != null) _optionImages['B'] = File(q.optionBImagePath!);
      if (q.optionCImagePath != null) _optionImages['C'] = File(q.optionCImagePath!);
      if (q.optionDImagePath != null) _optionImages['D'] = File(q.optionDImagePath!);
      _correctAnswer = q.correctAnswer;
    }
  }

Future<File> _saveFileLocally(File file) async {
  final baseDir = Directory.current;
  final imagesDir = Directory(join(baseDir.path, 'CBT','MCQ_que_Img'));

  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }

  final fileName = '${DateTime.now().millisecondsSinceEpoch}_${basename(file.path)}';
  final newPath = join(imagesDir.path, fileName);
  final copiedFile = await file.copy(newPath);

  // ✅ return only relative path instead of full
  return File(join('CBT','MCQ_que_Img', fileName));
}



  Future<void> _pickImage(String forWhat) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final savedFile = await _saveFileLocally(File(pickedFile.path));
      setState(() {
        if (forWhat == 'question') {
          _questionImage = savedFile;
        } else {
          _optionImages[forWhat] = savedFile;
        }
      });
    }
  }

  void _clearAllFields() {
    setState(() {
      _questionTextController.clear();
      _questionImage = null;
      for (var controller in _optionTextControllers.values) {
        controller.clear();
      }
      _optionImages.updateAll((key, value) => null);
      _correctAnswer = null;
    });
  }

  void _showPopup(String message, {bool closeAfter = false}) {
  showDialog(
    context: this.context, // ✅ use 'this.context' to ensure correct BuildContext
    builder: (context) => AlertDialog(
      title: const Text("✅"),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            if (closeAfter) Navigator.of(this.context).pop(true);
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}


  Future<void> _saveQuestion() async {
    if ((_questionTextController.text.isEmpty && _questionImage == null) ||
        _correctAnswer == null ||
        (_optionTextControllers[_correctAnswer!]!.text.isEmpty &&
            _optionImages[_correctAnswer!] == null)) {
      _showPopup("Please fill question, options and correct answer");
      return;
    }

    final data = {
      'subject': widget.subject,
      'questionText': _questionTextController.text,
      'questionImagePath': _questionImage?.path,
      'optionA': _optionTextControllers['A']!.text,
      'optionAImagePath': _optionImages['A']?.path,
      'optionB': _optionTextControllers['B']!.text,
      'optionBImagePath': _optionImages['B']?.path,
      'optionC': _optionTextControllers['C']!.text,
      'optionCImagePath': _optionImages['C']?.path,
      'optionD': _optionTextControllers['D']!.text,
      'optionDImagePath': _optionImages['D']?.path,
      'correctAnswer': _correctAnswer,
    };

    try {
      if (widget.editingQuestion != null && widget.editingQuestion!.id != null) {
        await MCQQuestionDatabase.instance.updateQuestion(
          widget.editingQuestion!.id!,
          data,
        );
        _showPopup("Question updated successfully", closeAfter: true);
      } else {
        await MCQQuestionDatabase.instance.insertQuestion(data);
        _showPopup("Question saved successfully");
        _clearAllFields(); // ✅ Clear after saving
      }
    } catch (e) {
      _showPopup("Error: $e");
    }
  }

  Widget _buildOptionRow(String optionKey) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _optionTextControllers[optionKey],
            decoration: InputDecoration(
              labelText: "Option $optionKey",
              border: const OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          children: [
            _optionImages[optionKey] != null
                ? Image.file(_optionImages[optionKey]!, width: 50, height: 50)
                : Container(width: 50, height: 50, color: Colors.grey[300]),
            IconButton(
              icon: const Icon(Icons.image),
              onPressed: () => _pickImage(optionKey),
            ),
          ],
        ),
        Radio<String>(
          value: optionKey,
          groupValue: _correctAnswer,
          onChanged: (val) {
            setState(() {
              _correctAnswer = val;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.editingQuestion != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Question" : "Add Question"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Question (text or image):", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _questionTextController,
              maxLines: null,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "Enter question",
              ),
            ),
            const SizedBox(height: 8),
            _questionImage != null
                ? Image.file(_questionImage!, height: 150)
                : Container(height: 150, color: Colors.grey[300]),
            TextButton.icon(
              onPressed: () => _pickImage('question'),
              icon: const Icon(Icons.image),
              label: const Text("Pick Question Image"),
            ),
            const Divider(height: 30),
            const Text("Options:", style: TextStyle(fontWeight: FontWeight.bold)),
            ...['A', 'B', 'C', 'D'].map(_buildOptionRow).toList(),
            const SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saveQuestion,
                  icon: const Icon(Icons.save),
                  label: Text(isEditing ? "Update" : "Save"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.cancel),
                  label: const Text("Cancel"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
