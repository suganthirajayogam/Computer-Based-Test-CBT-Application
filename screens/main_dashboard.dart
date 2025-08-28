import 'package:flutter/material.dart';
import 'package:computer_based_test/Vision/Vision_qu_upl_scre.dart';
import 'package:computer_based_test/screens/c_account_creation_emp.dart';
import 'package:computer_based_test/screens/mcq_question_upload.dart';

class MainDashboard extends StatelessWidget {
  const MainDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> titles = [
      'Reports',
      'MCQ Question Upload',
      'VISION  Question Upload',
      'EMP Database'
    ];
    final List<Color> colors = [
      Colors.purpleAccent,
      Colors.teal,
      Colors.orange,
      Colors.pinkAccent,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("VISTEON APP"),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(titles.length, (index) {
              return GestureDetector(
                onTap: () {
                  if (titles[index] == "VISION  Question Upload") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const VisionUploadScreen(),
                      ),
                    );
                  } else if (titles[index] == "MCQ Question Upload") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MCQDashboardPage(),
                      ),
                    );
                  } else if (titles[index] == "Reports") {
                    Navigator.pushNamed(context, '/screen_report');
                    
                  } else if (titles[index] == "EMP Database") {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AdminEmpEntryScreen(),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors[index].withOpacity(0.85),
                        colors[index],
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: colors[index].withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(3, 6),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      titles[index],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
