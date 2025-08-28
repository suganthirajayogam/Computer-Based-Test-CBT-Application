import 'dart:io';
import 'package:flutter/material.dart';
import 'package:computer_based_test/database/modules_db.dart';
import 'package:computer_based_test/models/account_screen_model.dart';
import 'package:computer_based_test/database/accountcreation.dart';
import 'package:computer_based_test/screens/c_view_add_emp_db.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:collection/collection.dart';
 
class AdminEmpEntryScreen extends StatefulWidget {
  const AdminEmpEntryScreen({super.key});
 
  @override
  State<AdminEmpEntryScreen> createState() => _AdminEmpEntryScreenState();
}
 
class _AdminEmpEntryScreenState extends State<AdminEmpEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _empIdController = TextEditingController();
  final _empNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _deptController = TextEditingController();
 
  List<String> modules = ['Select Module'];
 
  @override
  void initState() {
    super.initState();
    loadModules();
  }
 
  /// Ensure Emp_Images folder exists
  Future<Directory> _getImagesDir() async {
    final dir = Directory(p.join(Directory.current.path, 'CBT', 'Emp_Images'));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }
 
  /// Save a single employee
  void _saveData() async {
    if (_formKey.currentState!.validate()) {
      final newEmployee = EmployeeModel(
        empId: _empIdController.text.trim(),
        empName: _empNameController.text.trim(),
        mobileNo: _mobileController.text.trim(),
        department: _deptController.text.trim(),
      );
 
      try {
        final imagesDir = await _getImagesDir();
        final result = await AccountCreationDB.instance
            .insertEmp(newEmployee.toMap(), imagesDir);
 
        if (result == 0) {
          _showPopup(
            'Duplicate Entry',
            'Employee ID "${newEmployee.empId}" already exists.',
          );
        } else {
          _showPopup('Success', 'Employee added successfully!');
          _empIdController.clear();
          _empNameController.clear();
          _mobileController.clear();
          _deptController.clear();
        }
      } catch (e) {
        _showPopup('Error', 'Failed to save: $e');
      }
    }
  }
 
  /// Download sample CSV
  Future<void> _downloadSampleCSV() async {
    try {
      final directory =
          await getDownloadsDirectory() ?? Directory.current;
      final path = '${directory.path}/sample_employee_data.csv';
      final file = File(path);
 
      final sampleData = 'employee_id,employee_name,department,mobile_no\n';
      await file.writeAsString(sampleData);
 
      _showPopup('Downloaded', 'Sample CSV saved to:\n$path');
    } catch (e) {
      _showPopup('Error', 'Failed to download CSV: $e');
    }
  }
 
  /// Import CSV and insert employees
  /// Import CSV and insert employees
Future<void> _importCSVAndInsert() async {
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );
 
    if (result == null || result.files.single.path == null) return;
 
    final filePath = result.files.single.path!;
    final file = File(filePath);
    final csvContent = await file.readAsString();
 
    List<List<dynamic>> rows;
    try {
      rows = const CsvToListConverter().convert(csvContent, eol: '\n');
    } catch (e) {
      _showPopup('Error', 'Failed to parse CSV: $e');
      return;
    }
 
    if (rows.isEmpty) {
      _showPopup('Error', 'CSV file is empty.');
      return;
    }
 
    final headers = rows.first.map((e) => e.toString().trim()).toList();
    final expectedHeaders = [
      'employee_id',
      'employee_name',
      'department',
      'mobile_no',
      'image_path'
    ];
 
    if (headers.length != expectedHeaders.length ||
        !const ListEquality().equals(headers, expectedHeaders)) {
      _showPopup(
        'Invalid CSV Format',
        'Please use the correct format:\n${expectedHeaders.join(', ')}',
      );
      return;
    }
 
    int successCount = 0;
    List<String> duplicates = [];
    final imagesDir = await _getImagesDir();
 
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 4) continue;
 
      final data = {
        'employee_id': row[0].toString().trim(),
        'employee_name': row[1].toString().trim(),
        'department': row[2].toString().trim(),
        'mobile_no': row[3].toString().trim(),
        'image_path': row.length > 4 ? row[4].toString().trim() : null,
      };
 
      final insertResult =
          await AccountCreationDB.instance.insertEmp(data, imagesDir);
 
      if (insertResult == 0) {
        final empId = data['employee_id'] ?? '';
        if (empId.isNotEmpty) duplicates.add(empId);
      } else {
        successCount++;
      }
    }
 
    _showPopup(
      'Import Summary',
      '✅ Inserted: $successCount\n'
      '⚠️ Duplicates Skipped: ${duplicates.length}'
      '${duplicates.isNotEmpty ? '\nDuplicate IDs: ${duplicates.join(', ')}' : ''}',
    );
  } catch (e) {
    _showPopup('Error', 'Failed to import CSV: $e');
  }
}
 
  /// Upload image for employee
  Future<void> _uploadImageFromPicker() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      if (result == null || result.files.single.path == null) return;
 
      final filePath = result.files.single.path!;
      final file = File(filePath);
      final empId = p.basenameWithoutExtension(file.path).trim();
 
      if (empId.isEmpty) {
        _showDialog("Error", "Employee ID could not be extracted from image name.");
        return;
      }
 
      final dir = await _getImagesDir();
      final destImagePath = p.join(dir.path, '$empId.jpg');
 
      await file.copy(destImagePath);
      final relativePath = p.join('CBT', 'Emp_Images', '$empId.jpg');
 
      final data = {'image_path': relativePath};
      final updated =
          await AccountCreationDB.instance.updateEmpByEmployeeId(empId, data);
 
      if (updated > 0) {
        _showDialog("Success", "Image uploaded and linked to employee ID $empId.");
      } else {
        _showDialog("Error", "Employee ID $empId not found in the database.");
      }
    } catch (e) {
      _showDialog("Exception", "Error uploading image: $e");
    }
  }
 
  /// Show popup dialog
  void _showPopup(String title, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );
  }
 
  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
 
  Future<void> loadModules() async {
    try {
      final dbModules = await ModuleDatabase.instance.getModules();
      setState(() {
        modules = ['Modules', ...dbModules];
      });
    } catch (e) {
      print('❌ Failed to fetch modules: $e');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    Widget buildTextField(
      TextEditingController controller,
      String label,
      String hint, {
      TextInputType keyboardType = TextInputType.text,
    }) {
      return TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 14),
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 12, color: Colors.grey),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      );
    }
 
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Add Employee'),
        backgroundColor: const Color.fromARGB(253, 233, 141, 21),
        actions: [
          IconButton(
            icon: const Icon(Icons.image_outlined, color: Colors.white),
            tooltip: 'Upload Emp_Images',
            onPressed: _uploadImageFromPicker,
          ),
          IconButton(
            icon: const Icon(Icons.table_chart, color: Colors.white),
            tooltip: 'View Employees',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ViewEmployeeDatabaseScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            tooltip: 'Download Sample CSV',
            onPressed: _downloadSampleCSV,
          ),
          IconButton(
            icon: const Icon(Icons.upload_file, color: Colors.white),
            tooltip: 'Import CSV File',
            onPressed: _importCSVAndInsert,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              buildTextField(_empIdController, 'Employee ID', 'Eg. 1234'),
              const SizedBox(height: 12),
              buildTextField(_empNameController, 'Employee Name', 'Eg. John Doe'),
              const SizedBox(height: 12),
              buildTextField(_mobileController, 'Mobile No', 'Eg. 9876543210',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 12),
              buildTextField(_deptController, 'Department', 'Eg. HR'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text(
                  'Save Employee',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
 
 