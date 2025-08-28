import 'dart:io';
import 'package:flutter/material.dart';
import 'package:computer_based_test/database/accountcreation.dart';
 
class SettingsScreen extends StatefulWidget {
  final Function(bool) onToggleTheme;
 
  const SettingsScreen({super.key, required this.onToggleTheme});
 
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}
 
class _SettingsScreenState extends State<SettingsScreen> {
  String empName = '';
  String empId = '';
  String? imagePath;
  bool isDark = false;
 
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
 
    if (args != null && args.containsKey('empId')) {
      empId = args['empId'].toString();
      fetchEmployeeDetails(empId);
    }
 
    isDark = Theme.of(context).brightness == Brightness.dark;
  }
 
  Future<void> fetchEmployeeDetails(String id) async {
    try {
      final dbHelper = AccountCreationDB.instance;
final employee = await dbHelper.getEmployeeById(id); // id is already String
      if (employee != null) {
        setState(() {
          empName = employee['employee_name'] ?? '';
          imagePath = employee['image_path'];
        });
      }
    } catch (e) {
      print('Error fetching employee: $e');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            imagePath != null && imagePath!.isNotEmpty
                ? Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.onBackground,
                          width: 2),
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.file(
                        File(imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.error,
                              size: 100, color: Colors.red);
                        },
                      ),
                    ),
                  )
                : const Icon(Icons.person_pin, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              empName.isNotEmpty ? empName : 'Emp Name:',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Emp ID: $empId',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 30),
            const Divider(thickness: 1.2),
            SwitchListTile(
              title: const Text("Dark Mode"),
              value: isDark,
              onChanged: (value) {
                setState(() {
                  isDark = value;
                });
                widget.onToggleTheme(value);
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              onTap: () {
                // TODO: Language setting logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              onTap: () {
                Navigator.pop(context); // or redirect to login
              },
            ),
          ],
        ),
      ),
    );
  }
}
 
 