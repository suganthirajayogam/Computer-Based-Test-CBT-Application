// Your imports
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:computer_based_test/database/accountcreation.dart';
import 'package:computer_based_test/database/vision_result_db.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
 
class VisionReportPage extends StatefulWidget {
  const VisionReportPage({super.key});
 
  @override
  State<VisionReportPage> createState() => _VisionReportPageState();
}
 
class _VisionReportPageState extends State<VisionReportPage> {
  List<Map<String, dynamic>> _allData = [];
  List<Map<String, dynamic>> _filteredData = [];
  final TextEditingController _searchController = TextEditingController();
 
  @override
  void initState() {
    super.initState();
    _loadData();
  }
 
  Future<void> _loadData() async {
    try {
      final summaryResults = await VisionExamResultDB.instance.getAllSummaryResults();
      final employees = await AccountCreationDB.instance.getAllEmployees();
 
      final employeeMap = {
        for (var e in employees) e['employee_id'].toString().trim(): e,
      };
 
      final mergedData = summaryResults.map((summary) {
        final summaryMap = summary.toMap();
        final empId = summary.empId.toString().trim();
        final empDetails = employeeMap[empId];
 
        // Merge employee details into the summary data
        summaryMap['employee_name'] = empDetails?['employee_name'] ?? 'N/A';
        summaryMap['department'] = empDetails?['department'] ?? 'N/A';
        summaryMap['mobile_no'] = empDetails?['mobile_no'] ?? 'N/A';
        summaryMap['image_path'] = empDetails?['image_path']; // Correctly fetching the image path
        summaryMap['employee_id'] = summary.empId;
       
        return summaryMap;
      }).toList();
 
      setState(() {
        _allData = mergedData;
        _filteredData = mergedData;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading report data')),
        );
      }
    }
  }
 
  void _filterByEmpId(String empId) {
    setState(() {
      _filteredData = _allData
          .where((row) => row['employee_id']
              .toString()
              .toLowerCase()
              .contains(empId.toLowerCase()))
          .toList();
    });
  }
 
  Future<void> _generatePdf(Map<String, dynamic> row) async {
    try {
      final pdf = pw.Document();

      const PdfColor primaryColor = PdfColor.fromInt(0xFF1A237E);
      const PdfColor secondaryColor = PdfColor.fromInt(0xFF3F51B5);
      const PdfColor textColor = PdfColor.fromInt(0xFF333333);
      const PdfColor passColor = PdfColor.fromInt(0xFF4CAF50);
      const PdfColor failColor = PdfColor.fromInt(0xFFF44336);

      // Image handling
      pw.Widget imageWidget;
      final String? imagePath = row['image_path'];
      File? imageFile;

      if (imagePath != null && imagePath.isNotEmpty) {
        imageFile = File(imagePath);
      }

      if (imageFile != null && await imageFile.exists()) {
        final imageBytes = await imageFile.readAsBytes();
        final image = pw.MemoryImage(imageBytes);
        imageWidget = pw.Container(
          height: 120,
          width: 150,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 1),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Image(image, fit: pw.BoxFit.cover),
        );
      } else {
        imageWidget = pw.Container(
          height: 100,
          width: 100,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey, width: 1),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Center(
            child: pw.Text(
              "No Image",
              style: pw.TextStyle(color: PdfColors.grey, fontSize: 12),
            ),
          ),
        );
      }
      
      final isPass = (row['status']?.toString().toLowerCase().trim() == 'passed');

      pdf.addPage(
        pw.Page(
          pageTheme: pw.PageTheme(
            pageFormat: PdfPageFormat.a4,
            margin: pw.EdgeInsets.all(32),
            theme: pw.ThemeData(
              defaultTextStyle: pw.TextStyle(
                font: pw.Font.courier(),
              ),
            ),
          ),
          build: (pw.Context context) {
            return pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: primaryColor, width: 2),
                borderRadius: pw.BorderRadius.circular(10),
                color: PdfColors.white,
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Center(
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'Vision Test Report',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Visteon India Pvt. Ltd.',
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: const PdfColor.fromInt(0xFFFF9800),
                          ),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Divider(thickness: 1, color: secondaryColor),
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        flex: 2,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            _pdfDetailText("Employee ID", row['employee_id'].toString(), textColor),
                            _pdfDetailText("Name", row['employee_name'], textColor),
                            _pdfDetailText("Department", row['department'], textColor),
                            _pdfDetailText("Mobile No", row['mobile_no'], textColor),
                            _pdfDetailText("Module", row['module'], textColor),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.end,
                          children: [
                            pw.Container(
                              width: 100,
                              height: 100,
                              child: imageWidget,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 20),
                  pw.Divider(thickness: 1, color: secondaryColor),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Test Results',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _pdfDetailText("Score", row['score'].toString(), textColor),
                  _pdfDetailText("Percentage", "${double.tryParse(row['percentage'].toString())?.toStringAsFixed(2) ?? '0.00'}%", textColor),
                  pw.Row(
                    children: [
                      pw.Text('Status: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: textColor, fontSize: 14)),
                      pw.Text(
                        row['status'] ?? 'N/A',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: isPass ? passColor : failColor,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 5),
                  _pdfDetailText("Date", row['date'], textColor),
                  pw.SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      );

      final outputDir = await getApplicationDocumentsDirectory();
      final file = File(
        path.join(
          outputDir.path,
          "${row['employee_id']}_${row['module']}_${DateTime.now().microsecondsSinceEpoch}_vision_report.pdf"
              .replaceAll(" ", "_"),
        ),
      );
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('PDF Downloaded'),
            content: Text('✅ PDF downloaded: ${file.path}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('❌ PDF generation error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error generating PDF')),
      );
    }
  }

  // Helper function for PDF text styling
  pw.Widget _pdfDetailText(String label, String value, PdfColor textColor) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.RichText(
        text: pw.TextSpan(
          text: '$label: ',
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
            color: textColor,
            fontSize: 14,
          ),
          children: [
            pw.TextSpan(
              text: value,
              style: pw.TextStyle(
                fontWeight: pw.FontWeight.normal,
                color: textColor,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vision Report Page'),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Search by Employee ID:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _searchController,
              onChanged: _filterByEmpId,
              decoration: const InputDecoration(
                hintText: 'Enter emp_id...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Report Table:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _filteredData.isEmpty
                      ? const Center(child: Text('No data found.'))
                      : DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.indigo.shade100),
                          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
                            (Set<MaterialState> states) {
                              if (states.contains(MaterialState.selected)) {
                                return Colors.indigo.shade50;
                              }
                              return Colors.grey.shade100;
                            },
                          ),
                          columns: const [
                            DataColumn(label: Text('Emp ID', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Image', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Dept', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Module', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Mobile No', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Score', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Percentage', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('PDF', style: TextStyle(fontWeight: FontWeight.bold))),
                          ],
                          rows: _filteredData.map((row) {
                            final isPass = (row['status']?.toString().toLowerCase().trim() == 'passed');
                            final imagePath = row['image_path'];
                            
                            return DataRow(cells: [
                              DataCell(Text(row['employee_id'] ?? '')),
                              DataCell(Text(row['employee_name'] ?? '')),
                              DataCell(
                                imagePath != null
                                    ? FutureBuilder<File?>(
                                        future: AccountCreationDB.instance.getEmployeeImage(imagePath),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState == ConnectionState.done && snapshot.data != null) {
                                            return ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.file(
                                                snapshot.data!,
                                                width: 50,
                                                height: 50,
                                                fit: BoxFit.cover,
                                              ),
                                            );
                                          } else {
                                            return const Icon(Icons.image_not_supported, color: Colors.grey);
                                          }
                                        },
                                      )
                                    : const Icon(Icons.image_not_supported, color: Colors.grey),
                              ),
                              DataCell(Text(row['department'] ?? '')),
                              DataCell(Text(row['module'] ?? '')),
                              DataCell(Text(row['mobile_no'] ?? '')),
                              DataCell(Text('${row['score'] ?? 0}')),
                              DataCell(Text(
                                '${double.tryParse(row['percentage'].toString())?.toStringAsFixed(2) ?? '0.00'}%',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              )),
                              DataCell(
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isPass ? Colors.green.shade100 : Colors.red.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    row['status'] ?? '',
                                    style: TextStyle(
                                      color: isPass ? Colors.green.shade800 : Colors.red.shade800,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(Text(row['date'] ?? '')),
                              DataCell(
                                IconButton(
                                  icon: const Icon(Icons.download, color: Colors.indigo),
                                  onPressed: () => _generatePdf(row),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}