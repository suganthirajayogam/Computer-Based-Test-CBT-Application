import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

Future<void> generateEmployeeReport({
  required String imagePath,
  required String empId,
  required String name,
  required String department,
  required String mobile,
  required int score,
  required double percentage,
  required String status,
  required String date,
  required String savePath,
}) async {
  final pdf = pw.Document();
  final image = pw.MemoryImage(File(imagePath).readAsBytesSync());

  final isPassed = status.toLowerCase() == 'passed';

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (context) {
        return pw.Stack(
          children: [
            // Watermark
            pw.Positioned.fill(
              child: pw.Center(
                child: pw.Transform.rotate(
                  angle: -0.5, // Diagonal watermark
                  child: pw.Opacity(
                    opacity: 0.1,
                    child: pw.Text(
                      'Visteon',
                      style: pw.TextStyle(
                        fontSize: 100,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.orange,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Main content with border
            pw.Container(
              width: double.infinity,
              height: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 2),
              ),
              padding: const pw.EdgeInsets.all(20),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  pw.Center(
                    child: pw.Text(
                      'Employee MCQ Test Report',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue,
                        decoration: pw.TextDecoration.underline,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  pw.Center(
                    child: pw.Container(
                      width: 140,
                      height: 160,
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black, width: 1),
                      ),
                      child: pw.Image(image, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(height: 25),
                  buildInfoRow('Employee ID:', empId),
                  buildInfoRow('Name:', name),
                  buildInfoRow('Department:', department),
                  buildInfoRow('Mobile No:', mobile),
                  buildInfoRow('Score:', score.toString()),
                  buildInfoRow('Percentage:', '${percentage.toStringAsFixed(1)}%'),
                  pw.Row(
                    children: [
                      pw.Text('Status: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(
                        status,
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          color: isPassed ? PdfColors.green : PdfColors.red,
                        ),
                      ),
                    ],
                  ),
                  buildInfoRow('Date:', date),
                ],
              ),
            ),
          ],
        );
      },
    ),
  );

  final file = File(savePath);
  await file.writeAsBytes(await pdf.save());
}

pw.Widget buildInfoRow(String label, String value) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 6),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Container(
          width: 120,
          child: pw.Text(
            label,
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        ),
        pw.Expanded(
          child: pw.Text(
            value,
            style: pw.TextStyle(fontWeight: pw.FontWeight.normal),
          ),
        ),
      ],
    ),
  );
}
