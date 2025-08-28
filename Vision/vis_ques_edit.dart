import 'dart:io';
import 'package:flutter/material.dart';
import 'package:computer_based_test/database/vision_question.db.dart';
import 'package:computer_based_test/models/vis_ques_model.dart';
import 'package:file_picker/file_picker.dart';

class VisionQuestionEdit extends StatefulWidget {
  final VisionQuestionModel? question;
  final String moduleName;

  const VisionQuestionEdit({
    Key? key,
    required this.moduleName,
    this.question,
  }) : super(key: key);

  @override
  _VisionQuestionEditState createState() => _VisionQuestionEditState();
}

class _VisionQuestionEditState extends State<VisionQuestionEdit> {
  final _textController = TextEditingController();
  File? selectedMedia;
  String? mediaType;
  String? mediaRelativePath;
  String selectedAnswer = 'Good';
  List<String> reasons = [];
  List<String> selectedReasons = [];

  @override
  void initState() {
    super.initState();

    if (widget.question != null) {
      _textController.text = widget.question!.questionText ?? '';

      final path = widget.question!.imagePath ?? widget.question!.videoPath;
      if (path != null && path.isNotEmpty) {
        mediaRelativePath = path;
        final file = File('${Directory.current.path}/$path');
        if (file.existsSync()) {
          selectedMedia = file;
          mediaType = widget.question!.videoPath != null ? 'video' : 'image';
        }
      }

      selectedAnswer = widget.question!.correctAnswer;
      reasons = List.from(widget.question!.allReasons);

      if (selectedAnswer == 'Not Good') {
        selectedReasons = List.from(widget.question!.reasons);
      }
    } else {
      reasons = ['Alignment Issue', 'Missing Component', 'Wrong Orientation'];
    }
  }

  Future<void> _pickMedia() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4'],
    );

    if (result != null && result.files.single.path != null) {
      final originalPath = result.files.single.path!;
      final file = File(originalPath);
      final extension = result.files.single.extension!;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${result.files.single.name}';

      final appDir = Directory.current;
      final saveDir = Directory('${appDir.path}/Vision_Que_Img');

      if (!saveDir.existsSync()) {
        saveDir.createSync(recursive: true);
      }

      final newPath = '${saveDir.path}/$fileName';
      final savedFile = await file.copy(newPath);

      setState(() {
        selectedMedia = savedFile;
        mediaType = extension == 'mp4' ? 'video' : 'image';
        mediaRelativePath = 'Vision_Que_Img/$fileName';
      });
    }
  }

  Future<void> _updateQuestion() async {
    final updatedData = VisionQuestionModel(
      id: widget.question?.id,
      module: widget.moduleName,
      questionText: _textController.text,
      imagePath: mediaType == 'image' ? mediaRelativePath : null,
      videoPath: mediaType == 'video' ? mediaRelativePath : null,
      correctAnswer: selectedAnswer,
      reasons: selectedAnswer == 'Not Good' ? selectedReasons : [],
      allReasons: reasons,
    );

    int rowsAffected = 0;

    if (widget.question == null) {
      await VisionQuestionDB.instance.insertvisionQuestion(updatedData);
      rowsAffected = 1;
    } else {
      rowsAffected = await VisionQuestionDB.instance.updateVisionQuestion(
        updatedData.id!,
        updatedData.toMap(),
      );
    }

    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(rowsAffected > 0 ? 'Success' : 'No Changes'),
        content: Text(rowsAffected > 0
            ? '✅ Question saved successfully!'
            : '⚠️ No changes were made.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );

    Navigator.pop(context, true);
  }

  Future<void> _deleteQuestion() async {
    if (widget.question != null && widget.question!.id != null) {
      await VisionQuestionDB.instance.deleteVisionQuestion(widget.question!.id!);
      if (!mounted) return;

      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Deleted"),
          content: const Text("🗑 Question has been deleted."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.question == null ? 'Add Question' : 'Edit Question'),
        backgroundColor: Colors.orange,
        actions: [
          if (widget.question != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text("Delete Question"),
                    content: const Text("Are you sure you want to delete this question?"),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
                    ],
                  ),
                );

                if (confirm == true) {
                  await _deleteQuestion();
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          color: const Color.fromARGB(255, 255, 250, 240),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 4,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                "Q. No: ${widget.question?.id ?? "New"}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.attach_file),
                label: const Text('Choose Image or Video'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
              const SizedBox(height: 8),

              if (selectedMedia != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.orangeAccent),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: mediaType == 'image'
                      ? Image.file(selectedMedia!, height: 200)
                      : Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            '📹 Video Selected: ${selectedMedia!.path.split("/").last}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                ),

              const SizedBox(height: 16),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: 'Question Text',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16),

              const Text('Answer:', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Radio<String>(
                    value: 'Good',
                    groupValue: selectedAnswer,
                    onChanged: (value) => setState(() {
                      selectedAnswer = value!;
                      selectedReasons.clear();
                    }),
                  ),
                  const Text('Good'),
                  Radio<String>(
                    value: 'Not Good',
                    groupValue: selectedAnswer,
                    onChanged: (value) => setState(() {
                      selectedAnswer = value!;
                    }),
                  ),
                  const Text('Not Good'),
                ],
              ),

              if (selectedAnswer == 'Not Good') ...[
                const SizedBox(height: 8),
                const Text('Reasons:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...List.generate(reasons.length, (index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: reasons[index],
                          onChanged: (value) => setState(() => reasons[index] = value),
                          decoration: const InputDecoration(hintText: 'Enter reason'),
                        ),
                      ),
                      Checkbox(
                        value: selectedReasons.contains(reasons[index]),
                        onChanged: (checked) {
                          setState(() {
                            final value = reasons[index];
                            if (checked == true && !selectedReasons.contains(value)) {
                              selectedReasons.add(value);
                            } else {
                              selectedReasons.remove(value);
                            }
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () => setState(() {
                          selectedReasons.remove(reasons[index]);
                          reasons.removeAt(index);
                        }),
                      ),
                    ],
                  );
                }),
                TextButton.icon(
                  onPressed: () => setState(() => reasons.add('')),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Reason'),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _updateQuestion,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
