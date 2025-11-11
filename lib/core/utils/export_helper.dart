import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_file/open_file.dart';
import '../../data/models/task_model.dart';
import 'date_formatter.dart';

class ExportHelper {
  // Export tasks to PDF
  static Future<String> exportToPDF(List<TaskModel> tasks) async {
    final pdf = pw.Document();

    // Create PDF pages
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return [
            // Title
            pw.Header(
              level: 0,
              child: pw.Text(
                'Task Report',
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 20),

            // Date
            pw.Text(
              'Generated on: ${DateFormatter.formatDateTime(DateTime.now())}',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 20),

            // Tasks Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(1),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    _buildTableCell('Title', isHeader: true),
                    _buildTableCell('Due Date', isHeader: true),
                    _buildTableCell('Status', isHeader: true),
                    _buildTableCell('Progress', isHeader: true),
                  ],
                ),
                // Data rows
                ...tasks.map((task) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell(task.title),
                      _buildTableCell(DateFormatter.formatDate(task.dueDate)),
                      _buildTableCell(
                        task.isCompleted ? 'Completed' : 'Pending',
                      ),
                      _buildTableCell('${task.progress}%'),
                    ],
                  );
                }).toList(),
              ],
            ),

            pw.SizedBox(height: 20),

            // Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text('Total Tasks: ${tasks.length}'),
                  pw.Text(
                    'Completed: ${tasks.where((t) => t.isCompleted).length}',
                  ),
                  pw.Text(
                    'Pending: ${tasks.where((t) => !t.isCompleted).length}',
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Save PDF
    final output = await getApplicationDocumentsDirectory();
    final file = File(
      '${output.path}/tasks_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  // Helper method to build table cells
  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 12 : 10,
        ),
      ),
    );
  }

  // Export tasks to CSV
  static Future<String> exportToCSV(List<TaskModel> tasks) async {
    List<List<dynamic>> rows = [];

    // Header row
    rows.add([
      'ID',
      'Title',
      'Description',
      'Due Date',
      'Due Time',
      'Status',
      'Repeated',
      'Repeat Type',
      'Progress',
      'Created At',
      'Completed At',
    ]);

    // Data rows
    for (var task in tasks) {
      rows.add([
        task.id ?? '',
        task.title,
        task.description,
        DateFormatter.formatDate(task.dueDate),
        task.dueTime != null ? DateFormatter.formatTime(task.dueTime!) : 'N/A',
        task.isCompleted ? 'Completed' : 'Pending',
        task.isRepeated ? 'Yes' : 'No',
        task.repeatType ?? 'N/A',
        '${task.progress}%',
        DateFormatter.formatDateTime(task.createdAt),
        task.completedAt != null
            ? DateFormatter.formatDateTime(task.completedAt!)
            : 'N/A',
      ]);
    }

    // Convert to CSV
    String csv = const ListToCsvConverter().convert(rows);

    // Save CSV
    final output = await getApplicationDocumentsDirectory();
    final file = File(
      '${output.path}/tasks_${DateTime.now().millisecondsSinceEpoch}.csv',
    );
    await file.writeAsString(csv);

    return file.path;
  }

  // Share file via email or other apps
  static Future<void> shareFile(String filePath, String fileName) async {
    final file = XFile(filePath);
    await Share.shareXFiles(
      [file],
      subject: 'Task Report - $fileName',
      text: 'Please find attached task report.',
    );
  }

  // Open file with default app
  static Future<void> openFile(String filePath) async {
    await OpenFile.open(filePath);
  }

  // Get file size in human-readable format
  static String getFileSize(String filePath) {
    final file = File(filePath);
    final bytes = file.lengthSync();

    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(2)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    }
  }

  // Delete exported file
  static Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  // Get all exported files
  static Future<List<FileSystemEntity>> getExportedFiles() async {
    final output = await getApplicationDocumentsDirectory();
    final directory = Directory(output.path);

    final files = directory
        .listSync()
        .where(
          (file) => file.path.endsWith('.pdf') || file.path.endsWith('.csv'),
        )
        .toList();

    return files;
  }
}
