import 'package:flutter/material.dart';
import 'package:computer_based_test/database/admin_db_log.dart';
import 'package:computer_based_test/models/admin_log.dart';
import 'package:computer_based_test/screens/main_dashboard.dart';
 
class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});
 
  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}
 
class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
 
  bool _obscurePassword = true;
 
  @override
  void initState() {
    super.initState();
    _createDefaultAdmin();
  }
 
  Future<void> _createDefaultAdmin() async {
    final existing = await AdminDatabase.instance.getAdminByUsername("admin");
    if (existing == null) {
      await AdminDatabase.instance.insertAdmin(Admin(
        username: "admin",
        password: "admin123",
      ));
    }
  }
 
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final username = usernameController.text.trim();
      final password = passwordController.text.trim();
 
      final admin = await AdminDatabase.instance.getAdminByUsername(username);
 
      if (admin != null && admin.password == password) {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Success"),
            content: const Text("Login Successful."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  Future.delayed(const Duration(milliseconds: 100), () {
                    if (!mounted) return;
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const MainDashboard()),
                    );
                  });
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      } else {
        if (!mounted) return;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Login Failed"),
            content: const Text("Invalid credentials."),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.of(context, rootNavigator: true).pop(),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      }
    }
  }
 
  void _showCreateAdminDialog() {
    final supervisorController = TextEditingController();
    final newAdminController = TextEditingController();
    final newPasswordController = TextEditingController();
 
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Create Admin Account"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: supervisorController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Enter Super admin Password"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newAdminController,
                decoration: const InputDecoration(
                    labelText: " Enter new Admin Username"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                    labelText: "Enter new Admin Password"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (supervisorController.text.trim() == "Visteon123") {
                  final newAdmin = Admin(
                    username: newAdminController.text.trim(),
                    password: newPasswordController.text.trim(),
                  );
                  await AdminDatabase.instance.insertAdmin(newAdmin);
 
                  if (!mounted) return;
                  Navigator.of(dialogContext).pop();
 
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Success"),
                      content:
                          const Text("Admin account created successfully."),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                } else {
                  if (!mounted) return;
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text("Error"),
                      content: const Text("Invalid super admin password."),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.of(context, rootNavigator: true).pop(),
                          child: const Text("OK"),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text("Create"),
            ),
          ],
        );
      },
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Admin Login")),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Enter password' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _handleLogin,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _showCreateAdminDialog,
                  child: const Text("Create Admin Account"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
 