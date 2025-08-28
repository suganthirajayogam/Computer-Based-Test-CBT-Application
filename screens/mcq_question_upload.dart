import 'package:flutter/material.dart';
import 'package:computer_based_test/database/modules_db.dart';
import 'package:computer_based_test/screens/mcq_load_question.dart';
import 'package:computer_based_test/screens/question_editor_screen.dart';

class MCQDashboardPage extends StatefulWidget {
  const MCQDashboardPage({super.key});

  @override
  State<MCQDashboardPage> createState() => _MCQDashboardPageState();
}

class _MCQDashboardPageState extends State<MCQDashboardPage> {
  List<String> dynamicModules = [];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    final modules = await ModuleDatabase.instance.getModules();
    setState(() {
      dynamicModules = modules;
    });
  }

  Future<void> _addModuleDialog() async {
    String newModule = '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Module'),
        content: TextField(
          decoration: const InputDecoration(labelText: 'Module Name'),
          onChanged: (value) => newModule = value.trim(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newModule.isNotEmpty) {
                await ModuleDatabase.instance.insertModule(newModule);
                await _loadModules();
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteModuleDialog() async {
    List<String> selected = [];
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Modules'),
        content: StatefulBuilder(
          builder: (context, setStateSB) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: dynamicModules.map((module) {
                  return CheckboxListTile(
                    title: Text(module),
                    value: selected.contains(module),
                    onChanged: (val) {
                      setStateSB(() {
                        if (val == true) {
                          selected.add(module);
                        } else {
                          selected.remove(module);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              for (var module in selected) {
                await ModuleDatabase.instance.deleteModule(module);
              }
              await _loadModules();
              Navigator.pop(context);
            },
            child: const Text('Delete Selected'),
          ),
        ],
      ),
    );
  }

  void _onWrite(String module) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => QuestionEditorScreen(subject: module)),
    );
  }

  void _onView(String module) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MCQScreen(subject: module)),
    );
  }

  Widget _buildCard({
    required String title,
    required String subtitle,
    required String? imagePath,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                leading: imagePath != null ? Image.asset(imagePath, width: 50) : const Icon(Icons.book),
                title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(subtitle),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _onWrite(title),
                    icon: const Icon(Icons.edit_note),
                    label: const Text("Write"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    onPressed: () => _onView(title),
                    icon: const Icon(Icons.list),
                    label: const Text("View"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 225, 125, 3),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Question Editor Dashboard"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Module',
            onPressed: _addModuleDialog,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Module',
            onPressed: _deleteModuleDialog,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _buildCard(
              title: "Safety",
              subtitle: "Open SAFETY Questions Editor",
              imagePath: "assets/images/safety.jpeg",
            ),
            _buildCard(
              title: "ESD",
              subtitle: "Open ESD Questions Editor",
              imagePath: "assets/images/esd.jpg",
            ),
            _buildCard(
              title: "SMT",
              subtitle: "Open SMT Questions Editor",
              imagePath: "assets/images/smt.png",
            ),
            _buildCard(
              title: "FA",
              subtitle: "Open FA Questions Editor",
              imagePath: "assets/images/fa.png",
            ),
            const Divider(height: 30),
            ...dynamicModules.map((module) => _buildCard(
                  title: module,
                  subtitle: "Open $module Questions Editor",
                  imagePath: null,
                )),
          ],
        ),
      ),
    );
  }
}
