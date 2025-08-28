import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:computer_based_test/database/accountcreation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p; // ✅ Use alias

class EmpImageUploadScreen extends StatefulWidget {
  const EmpImageUploadScreen({super.key});

  @override
  State<EmpImageUploadScreen> createState() => _EmpImageUploadScreenState();
}

class _EmpImageUploadScreenState extends State<EmpImageUploadScreen> {
  File? _selectedImage;
  String? _empId;

  // Picking image from gallery
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final fileName = pickedFile.name;
      final idMatch = RegExp(r'(\d+)').firstMatch(fileName);

      if (idMatch != null) {
        final extractedId = idMatch.group(1)!;
        setState(() {
          _empId = extractedId;
          _selectedImage = File(pickedFile.path);
        });
      } else {
        _showPopup("Invalid Image", "Filename must contain employee ID (e.g., 1.jpg)");
      }
    }
  }

  // Save image to internal app folder: Emp_Images
  Future<void> _saveImage() async {
    if (_selectedImage == null || _empId == null) {
      _showPopup("No Image", "Please select a valid image first.");
      return;
    }

    try {
      final appDocDir = await getApplicationDocumentsDirectory();
      final imageDir = Directory(p.join(appDocDir.path, 'Emp_Images'));

      if (!await imageDir.exists()) {
        await imageDir.create(recursive: true);
      }

      final fileName = '$_empId.jpg';
      final newPath = p.join(imageDir.path, fileName);
      await _selectedImage!.copy(newPath);

      // ✅ Save relative path only
      final relativePath = 'Emp_Images/$fileName';

      final updated = await AccountCreationDB.instance.updateEmpByEmployeeId(_empId!, {
        'image_path': relativePath,
      });

      if (updated > 0) {
        _showPopup("✅ Image Saved", "Image linked to employee ID: $_empId");
      } else {
        _showPopup("❌ Save Failed", "Image saved, but employee ID $_empId not found in DB.");
      }

      setState(() {
        _selectedImage = null;
        _empId = null;
      });
    } catch (e) {
      _showPopup("Error", "Unexpected error: $e");
    }
  }

  void _showPopup(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emp_Images Upload'),
        backgroundColor: Colors.orange.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.image),
              label: const Text("Choose Image"),
            ),
            const SizedBox(height: 16),
            if (_selectedImage != null) ...[
              Text("Detected emp_id: $_empId"),
              const SizedBox(height: 12),
              Image.file(_selectedImage!, height: 200),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saveImage,
                icon: const Icon(Icons.save),
                label: const Text("Save Image"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
