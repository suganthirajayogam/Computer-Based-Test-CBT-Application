import 'package:flutter/material.dart';
import 'package:computer_based_test/Vision/vis_que_list.dart';
import 'package:computer_based_test/Vision/vis_ques_upl_page.dart';
import 'package:computer_based_test/database/vision_modules_db.dart';

class VisionUploadScreen extends StatefulWidget {
  const VisionUploadScreen({super.key});

  @override
  State<VisionUploadScreen> createState() => _VisionUploadScreenState();
}

class _VisionUploadScreenState extends State<VisionUploadScreen> {
  List<String> visionModules = ['Select Module'];
  String selectedModule = 'Select Module';

  @override
  void initState() {
    super.initState();
    _loadModulesFromDB();
  }

  Future<void> _loadModulesFromDB() async {
    try {
      final modules = await VisionModuleDB.instance.getModules();
      setState(() {
        visionModules = ['Select Module', ...modules];
        if (!visionModules.contains(selectedModule)) {
          selectedModule = 'Select Module';
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load modules: $e')),
      );
    }
  }

  void _showModuleDialog(BuildContext context, {required bool isDelete}) {
    final TextEditingController controller = TextEditingController();
    String? selectedDeleteModule;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isDelete ? 'Delete Module' : 'Add Module'),
        content: isDelete
            ? DropdownButtonFormField<String>(
                value: visionModules.length > 1 ? visionModules[1] : null,
                items: visionModules
                    .where((m) => m != 'Select Module')
                    .map((module) => DropdownMenuItem(
                          value: module,
                          child: Text(module),
                        ))
                    .toList(),
                onChanged: (value) {
                  selectedDeleteModule = value;
                },
                decoration: const InputDecoration(labelText: 'Select Module'),
              )
            : TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Module Name'),
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = VisionModuleDB.instance;
              try {
                if (isDelete && selectedDeleteModule != null) {
                  await db.deleteModule(selectedDeleteModule!);
                  Navigator.pop(context);

                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Deleted'),
                      content: Text(
                          'Module "$selectedDeleteModule" deleted successfully.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _loadModulesFromDB();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else if (!isDelete && controller.text.trim().isNotEmpty) {
                  final name = controller.text.trim();
                  await db.insertModule(name);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Added module: $name')),
                  );
                  _loadModulesFromDB();
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
            child: Text(isDelete ? 'Delete' : 'Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Question Upload'),
        backgroundColor: Colors.orangeAccent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            tooltip: 'Delete Module',
            onPressed: () => _showModuleDialog(context, isDelete: true),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Module',
            onPressed: () => _showModuleDialog(context, isDelete: false),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...visionModules.where((m) => m != 'Select Module').map((module) {
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade100,
                  child: Text(
                    module[0].toUpperCase(),
                    style: const TextStyle(color: Colors.black),
                  ),
                ),
                title: Text(
                  module,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: const Text('Open Vision Questions Editor'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisionUploadPage(moduleName: module), // ✅ Corrected
      ),
    );
  },
  child: const Text(
  "Write",
  style: TextStyle(color: Colors.white),
),
style: ElevatedButton.styleFrom(
  backgroundColor: const Color.fromARGB(255, 1, 76, 31),
  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8), // Rectangle with slight curve
    ),
),

),

  const SizedBox(width: 8),
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VisionQuestionListScreen(
          module: module,
        ),
      ),
    );
  },
  icon: const Icon(Icons.list, size: 18, color: Colors.white),
  label: const Text(
    'View',
    style: TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: FontWeight.w500,
    ),
  ),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color.fromARGB(255, 216, 119, 39),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    elevation: 3,
  ),
),



                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
