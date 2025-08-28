import 'package:flutter/material.dart';
import 'package:computer_based_test/database/accountcreation.dart';
import 'dart:io';

class ViewEmployeeDatabaseScreen extends StatefulWidget {
  const ViewEmployeeDatabaseScreen({super.key});

  @override
  State<ViewEmployeeDatabaseScreen> createState() =>
      _ViewEmployeeDatabaseScreenState();
}

class _ViewEmployeeDatabaseScreenState
    extends State<ViewEmployeeDatabaseScreen> {
  List<Map<String, dynamic>> _employees = [];
  List<Map<String, dynamic>> _filteredEmployees = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEmployees();
    _searchController.addListener(_searchEmployee); // 🔍 Live search
  }

  @override
  void dispose() {
    _searchController.removeListener(_searchEmployee);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmployees() async {
    try {
      final data = await AccountCreationDB.instance.getAllEmployees();
      setState(() {
        _employees = data;
        _filteredEmployees = data;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching employees: $e");
    }
  }

  void _searchEmployee() {
    final query = _searchController.text.trim();
    setState(() {
      _filteredEmployees = query.isEmpty
          ? _employees
          : _employees
              .where((emp) => emp['employee_id']
                  .toString()
                  .toLowerCase()
                  .contains(query.toLowerCase()))
              .toList();
    });
  }

Future<void> _confirmDelete(
    BuildContext context, String empId, VoidCallback onDeleted) async {
  try {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Confirmation'),
        content: const Text('Are you sure you want to delete this record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Corrected line: Convert empId (int) to a String before passing it.
      final rowsDeleted = await AccountCreationDB.instance.deleteEmp(empId.toString());

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(rowsDeleted > 0 ? 'Success' : 'Failed'),
          content: Text(rowsDeleted > 0
              ? 'Record deleted successfully.'
              : 'Failed to delete the record.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (rowsDeleted > 0) {
        onDeleted(); // Refresh UI after deletion
      }
    }
  } catch (e) {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Error'),
        content: Text('An error occurred while deleting the record:\n$e'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

  void _editEmployee(Map<String, dynamic> emp) {
    final nameController = TextEditingController(text: emp['employee_name']);
    final mobileController = TextEditingController(text: emp['mobile_no']);
    final deptController = TextEditingController(text: emp['department']);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Employee'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: mobileController,
              decoration: const InputDecoration(labelText: 'Mobile No'),
            ),
            TextField(
              controller: deptController,
              decoration: const InputDecoration(labelText: 'Department'),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final db = await AccountCreationDB.instance.database;
              await db.update(
                'emp_db',
                {
                  'employee_name': nameController.text,
                  'mobile_no': mobileController.text,
                  'department': deptController.text,
                },
                where: 'employee_id = ?',
                whereArgs: [emp['employee_id']],
              );
              Navigator.pop(context);
              _fetchEmployees();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Employee Database'),
        backgroundColor: Colors.indigo,
      ),
      body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search by Employee ID',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal, // horizontal scroll for table
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Emp ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Mobile No')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Image')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: List<DataRow>.generate(
                  _filteredEmployees.length,
                  (index) {
                    final emp = _filteredEmployees[index];
                    final imagePath = emp['image_path'];
                    final fullImagePath = imagePath != null
                        ? '${Directory.current.path}/$imagePath'
                        : null;

                    return DataRow(
                      color: MaterialStateProperty.all(
                        index.isEven ? Colors.grey[100] : Colors.white,
                      ),
                      cells: [
                        DataCell(Text(emp['employee_id'].toString())),
                        DataCell(Text(emp['employee_name'] ?? '')),
                        DataCell(Text(emp['mobile_no'] ?? '')),
                        DataCell(Text(emp['department'] ?? '')),
                        DataCell(
                          imagePath != null &&
                                  File(fullImagePath!).existsSync()
                              ? Image.file(
                                  File(fullImagePath),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editEmployee(emp),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _confirmDelete(
                                  context,
                                  emp['employee_id'].toString() ,
                                  () => _fetchEmployees(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
