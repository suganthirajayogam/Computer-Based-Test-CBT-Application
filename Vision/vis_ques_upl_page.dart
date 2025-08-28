import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:computer_based_test/database/vision_question.db.dart';
import 'package:computer_based_test/models/vis_ques_model.dart';

class VisionUploadPage extends StatefulWidget {
  final String moduleName;
  const VisionUploadPage({Key? key, required this.moduleName}) : super(key: key);

  @override
  State<VisionUploadPage> createState() => _VisionUploadPageState();
}

class _VisionUploadPageState extends State<VisionUploadPage> {
  File? selectedMedia;
  String? mediaType;
  String? answer;
  final _textController = TextEditingController();
  final _reasonController = TextEditingController();
  Set<String> selectedReasons = {};

  List<String> reasons = [];


  Future<void> pickMedia() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'mp4'],
    );

    if (result != null) {
      final originalPath = result.files.single.path!;
      final file = File(originalPath);
      final extension = result.files.single.extension!;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${timestamp}_${result.files.single.name}';

      final appDir = Directory.current; // desktop path
      final saveDir = Directory('${appDir.path}/CBT/Vision_Que_Img');

      if (!saveDir.existsSync()) {
        saveDir.createSync(recursive: true);
      }

      final newPath = '${saveDir.path}/$fileName';
      final savedFile = await file.copy(newPath);

      setState(() {
        selectedMedia = savedFile;
        mediaType = extension == 'mp4' ? 'video' : 'image';
      });
    }
  }


  void addNewReason() {
    final newReason = _reasonController.text.trim();
    if (newReason.isNotEmpty && !reasons.contains(newReason)) {
      setState(() {
        reasons.add(newReason);
        selectedReasons.add(newReason);
        _reasonController.clear();
      });

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Reason Added'),
          content: Text('Reason "$newReason" has been added.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: const Text('Reason already exists or is empty.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  void removeReason(String reasonToRemove) {
    setState(() {
      reasons.remove(reasonToRemove);
      selectedReasons.remove(reasonToRemove);
    });
  }

  void saveQuestion() async {
    if ((selectedMedia == null && _textController.text.isEmpty) || answer == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Missing Fields'),
          content: const Text("Please provide a question and answer."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    final newQuestion = VisionQuestionModel(
      module: widget.moduleName,
      questionText: _textController.text,
      // FIX: Correcting the image and video path string concatenation
      imagePath: mediaType == 'image' ? selectedMedia != null ? 'CBT/Vision_Que_Img/${selectedMedia!.path.split('/').last}' : null : null,
      videoPath: mediaType == 'video' ? selectedMedia != null ? 'CBT/Vision_Que_Img/${selectedMedia!.path.split('/').last}' : null : null,
      correctAnswer: answer!,
      reasons: answer == 'Not Good' ? selectedReasons.toList() : [],
      allReasons: reasons,
    );


    try {
      await VisionQuestionDB.instance.insertvisionQuestion(newQuestion);

      print('Saved: ${newQuestion.questionText}, ${newQuestion.correctAnswer}, ${newQuestion.reasons}');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: const Text("Question saved successfully."),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );

      setState(() {
        _textController.clear();
        selectedMedia = null;
        mediaType = null;
        answer = null;
        selectedReasons.clear();
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text("Error saving question: $e"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vision Upload Page"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Module: ${widget.moduleName}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Question Text (Optional)",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.text_fields),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: pickMedia,
              icon: const Icon(Icons.upload_file),
              label: const Text("Pick Image or Video (Optional)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 12),
            if (selectedMedia != null && mediaType == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(selectedMedia!, height: 160),
              ),
            if (selectedMedia != null && mediaType == 'video')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "Video selected",
                  style: TextStyle(color: Colors.orange),
                ),
              ),
            const SizedBox(height: 20),
            const Text("Select Answer:", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                ChoiceChip(
                  label: const Text("Good"),
                  selected: answer == "Good",
                  onSelected: (selected) => setState(() => answer = "Good"),
                  selectedColor: Colors.green.shade300,
                ),
                ChoiceChip(
                  label: const Text("Not Good"),
                  selected: answer == "Not Good",
                  onSelected: (selected) => setState(() => answer = "Not Good"),
                  selectedColor: Colors.red.shade300,
                ),
              ],
            ),
            if (answer == "Not Good") ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F8F8),
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add Reason", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _reasonController,
                            decoration: InputDecoration(
                              hintText: "Type reason",
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: addNewReason,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.deepOrangeAccent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                    if (reasons.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text("Select Reasons:", style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Column(
                        children: reasons.map((r) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedReasons.contains(r)
                                    ? Colors.green.shade50
                                    : Colors.grey.shade100,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CheckboxListTile(
                                title: Text(r),
                                value: selectedReasons.contains(r),
                                onChanged: (selected) {
                                  setState(() {
                                    if (selected == true) {
                                      selectedReasons.add(r);
                                    } else {
                                      selectedReasons.remove(r);
                                    }
                                  });
                                },
                                controlAffinity: ListTileControlAffinity.leading,
                                secondary: IconButton(
                                  icon: const Icon(Icons.close, color: Colors.redAccent),
                                  onPressed: () => removeReason(r),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ]
                  ],
                ),
              ),
            ],
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: saveQuestion,
              icon: const Icon(Icons.save),
              label: const Text("Save Question"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
