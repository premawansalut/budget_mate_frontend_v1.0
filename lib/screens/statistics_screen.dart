import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../services/api_service.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  bool showPieChart = false;

  List<Map<String, dynamic>> incomeData = [];
  List<Map<String, dynamic>> expenseData = [];
  List<Map<String, dynamic>> loanData = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    fetchStatistics();
  }

  Future<void> fetchStatistics() async {
    setState(() {
      isLoading = true;
      incomeData = [];
      expenseData = [];
      loanData = [];
    });

    try {
      final year = selectedDate.year;
      final month = selectedDate.month;
      final res = await ApiService.getStatistics(year, month);

      if (res.isNotEmpty && res['categories'] != null) {
        final parsed = (res['categories'] as List)
            .map<Map<String, dynamic>>((e) => {
          'category': e['category'],
          'total': double.tryParse(e['total'].toString()) ?? 0.0,
        })
            .toList();

        setState(() {
          incomeData = parsed;
          expenseData = parsed;
          loanData = parsed;
        });
      }
    } catch (e) {
      debugPrint('statistics fetch error: $e');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> pickMonthYear() async {
    int y = selectedDate.year;
    int m = selectedDate.month;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModal) => SizedBox(
          height: 340,
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Select Month & Year',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 20),
              DropdownButton<int>(
                value: m,
                items: List.generate(
                  12,
                      (i) => DropdownMenuItem(
                    value: i + 1,
                    child: Text(DateFormat.MMMM().format(DateTime(0, i + 1))),
                  ),
                ),
                onChanged: (v) => setModal(() => m = v ?? m),
              ),
              const SizedBox(height: 10),
              DropdownButton<int>(
                value: y,
                items: List.generate(
                  10,
                      (i) {
                    final yy = DateTime.now().year - 5 + i;
                    return DropdownMenuItem(value: yy, child: Text('$yy'));
                  },
                ),
                onChanged: (v) => setModal(() => y = v ?? y),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  setState(() => selectedDate = DateTime(y, m));
                  Navigator.pop(context);
                  await fetchStatistics();
                },
                child: const Text('Apply',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _catColor(String c) {
    switch (c.toLowerCase()) {
      case 'salary':
        return Colors.greenAccent;
      case 'invest':
        return Colors.blueAccent;
      case 'business':
        return Colors.orangeAccent;
      case 'interest':
        return Colors.purpleAccent;
      case 'extra income':
        return Colors.cyanAccent;
      case 'other':
        return Colors.amberAccent;
      default:
        return Colors.grey;
    }
  }

  IconData _catIcon(String c) {
    switch (c.toLowerCase()) {
      case 'salary':
        return Icons.payments_rounded;
      case 'invest':
        return Icons.trending_up_rounded;
      case 'business':
        return Icons.store_rounded;
      case 'interest':
        return Icons.star_rounded;
      case 'extra income':
        return Icons.savings_rounded;
      case 'other':
        return Icons.category_rounded;
      default:
        return Icons.circle;
    }
  }

  Key _chartKey(List<Map<String, dynamic>> data, String type) {
    final sum = data.fold<double>(0, (s, e) => s + (e['total'] as double));
    return ValueKey('$type-${selectedDate.year}-${selectedDate.month}-$sum');
  }

  Widget _barChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('No data available'));
    return BarChart(
      BarChartData(
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              getTitlesWidget: (v, meta) {
                if (v < 0 || v >= data.length) return const SizedBox.shrink();
                return Text(
                  data[v.toInt()]['category'],
                  style: const TextStyle(fontSize: 12),
                );
              },
            ),
          ),
        ),
        barGroups: List.generate(data.length, (i) {
          final it = data[i];
          return BarChartGroupData(x: i, barRods: [
            BarChartRodData(
              toY: it['total'],
              color: _catColor(it['category']),
              width: 22,
              borderRadius: BorderRadius.circular(6),
            ),
          ]);
        }),
      ),
    );
  }

  Widget _pieChart(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('No data available'));
    return PieChart(
      PieChartData(
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 40,
        sections: data.map((it) {
          final color = _catColor(it['category']);
          return PieChartSectionData(
            color: color,
            value: it['total'],
            title:
            "${it['category']}\n${NumberFormat('#,##0.0').format(it['total'])}",
            radius: 70,
            titleStyle: const TextStyle(
                fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white),
          );
        }).toList(),
      ),
    );
  }

  // Export as PDF
  // Future<void> exportAsPDF(List<Map<String, dynamic>> data, String title, String currency) async {
  //   final pdf = pw.Document();
  //   final total = data.fold<double>(0, (s, e) => s + (e['total'] as double));
  //
  //   pdf.addPage(
  //     pw.MultiPage(
  //       build: (_) => [
  //         pw.Center(
  //             child: pw.Text('$title Report',
  //                 style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold))),
  //         pw.SizedBox(height: 15),
  //         pw.Table.fromTextArray(
  //           headers: ['Category', 'Amount ($currency)'],
  //           data: data
  //               .map((e) => [
  //             e['category'],
  //             NumberFormat('#,##0.00').format(e['total'])
  //           ])
  //               .toList(),
  //         ),
  //         pw.SizedBox(height: 10),
  //         pw.Align(
  //           alignment: pw.Alignment.centerRight,
  //           child: pw.Text(
  //               'Total: $currency ${NumberFormat('#,##0.00').format(total)}',
  //               style: pw.TextStyle(fontSize: 16)),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   final dir = await getApplicationDocumentsDirectory();
  //   final file = File("${dir.path}/$title-${DateFormat('yyyyMM').format(selectedDate)}.pdf");
  //   await file.writeAsBytes(await pdf.save());
  //   await OpenFilex.open(file.path);
  // }

  // Future<void> exportAsPDF(
  //     List<Map<String, dynamic>> data,
  //     String title,
  //     String currency,
  //     ) async {
  //   // Load a Unicode-capable font so € and other symbols render correctly
  //   final fontData = await rootBundle.load('lib/assets/fonts/NotoSans-Regular.ttf');
  //   final ttf = pw.Font.ttf(fontData);
  //
  //   final pdf = pw.Document(
  //     theme: pw.ThemeData.withFont(
  //       base: ttf,
  //       bold: ttf,
  //       italic: ttf,
  //       boldItalic: ttf,
  //     ),
  //   );
  //
  //   final total = data.fold<double>(0, (s, e) => s + (e['total'] as double));
  //
  //   pdf.addPage(
  //     pw.MultiPage(
  //       build: (_) => [
  //         pw.Center(
  //           child: pw.Text(
  //             '$title Report',
  //             style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
  //           ),
  //         ),
  //         pw.SizedBox(height: 15),
  //         pw.Table.fromTextArray(
  //           headers: ['Category', 'Amount ($currency)'],
  //           headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
  //           data: data
  //               .map((e) => [
  //             e['category'],
  //             NumberFormat('#,##0.00').format(e['total']),
  //           ])
  //               .toList(),
  //         ),
  //         pw.SizedBox(height: 10),
  //         pw.Align(
  //           alignment: pw.Alignment.centerRight,
  //           child: pw.Text(
  //             'Total: $currency ${NumberFormat('#,##0.00').format(total)}',
  //             style: const pw.TextStyle(fontSize: 16),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  //
  //   final dir = await getApplicationDocumentsDirectory();
  //   final file = File(
  //     "${dir.path}/$title-${DateFormat('yyyyMM').format(selectedDate)}.pdf",
  //   );
  //   await file.writeAsBytes(await pdf.save());
  //   await OpenFilex.open(file.path);
  // }


  Future<void> exportAsPDF(
      List<Map<String, dynamic>> data,
      String title,
      String currency,
      ) async {
    final fontData = await rootBundle.load('lib/assets/fonts/NotoSans-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);
    final logo = await rootBundle.load('lib/assets/icons/logo.png');

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: ttf,
        bold: ttf,
        italic: ttf,
        boldItalic: ttf,
      ),
    );

    final total = data.fold<double>(0, (s, e) => s + (e['total'] as double));

    pdf.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          margin: const pw.EdgeInsets.all(32),
        ),
        build: (context) => [
          // ✅ Header with Logo + Title
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Row(
                children: [
                  pw.Container(
                    width: 40,
                    height: 40,
                    child: pw.Image(pw.MemoryImage(logo.buffer.asUint8List())),
                  ),
                  pw.SizedBox(width: 12),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Budget Mate',
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.deepPurple,
                        ),
                      ),
                      pw.Text(
                        'Monthly $title Report',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.Text(
                DateFormat('MMMM yyyy').format(selectedDate),
                style: const pw.TextStyle(fontSize: 12),
              ),
            ],
          ),
          pw.Divider(thickness: 1, color: PdfColors.grey600),
          pw.SizedBox(height: 15),

          // ✅ Summary Table
          pw.Table.fromTextArray(
            headers: ['Category', 'Amount ($currency)'],
            headerDecoration: const pw.BoxDecoration(color: PdfColors.deepPurple),
            headerStyle: pw.TextStyle(
                color: PdfColors.white, fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 11),
            cellHeight: 22,
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.3),
            data: data
                .map((e) => [
              e['category'],
              NumberFormat('#,##0.00').format(e['total'])
            ])
                .toList(),
          ),

          pw.SizedBox(height: 12),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text(
                'Total: $currency ${NumberFormat('#,##0.00').format(total)}',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.green800,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 20),

          // ✅ Footer
          pw.Divider(thickness: 1),
          pw.Center(
            child: pw.Text(
              'Generated by Budget Mate',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
            ),
          ),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        "${dir.path}/$title-${DateFormat('yyyyMM').format(selectedDate)}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }


  // Export as Excel
  Future<void> exportAsExcel(List<Map<String, dynamic>> data, String title, String currency) async {
    final excel = Excel.createExcel();
    final sheet = excel[title];
    sheet.appendRow(['Category', 'Amount ($currency)']);
    for (var e in data) {
      sheet.appendRow([e['category'], e['total']]);
    }
    final dir = await getApplicationDocumentsDirectory();
    final file = File("${dir.path}/$title-${DateFormat('yyyyMM').format(selectedDate)}.xlsx");
    await file.writeAsBytes(excel.encode()!);
    await OpenFilex.open(file.path);
  }

  // ✅ Download options bottom sheet
  void showDownloadOptions(List<Map<String, dynamic>> data, String tabTitle, String currency) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                title: const Text('Download as PDF'),
                onTap: () {
                  Navigator.pop(context);
                  exportAsPDF(data, tabTitle, currency);
                },
              ),
              ListTile(
                leading: const Icon(Icons.table_chart, color: Colors.green),
                title: const Text('Download as Excel'),
                onTap: () {
                  Navigator.pop(context);
                  exportAsExcel(data, tabTitle, currency);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _summary(List<Map<String, dynamic>> data, String currency) {
    final total = data.fold<double>(0, (s, e) => s + (e['total'] as double));
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          ...data.map((it) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(children: [
                    Icon(_catIcon(it['category']),
                        color: _catColor(it['category']), size: 22),
                    const SizedBox(width: 8),
                    Text(it['category'],
                        style: TextStyle(
                            color:
                            Theme.of(context).textTheme.bodyLarge?.color ??
                                Colors.white)),
                  ]),
                  Text(
                    "$currency ${NumberFormat('#,##0.00').format(it['total'])}",
                    style: TextStyle(
                        color: _catColor(it['category']),
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }),
          const Divider(color: Colors.white24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total',
                  style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
              Text(
                "$currency ${NumberFormat('#,##0.00').format(total)}",
                style: const TextStyle(
                    color: Colors.greenAccent, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tabContent(List<Map<String, dynamic>> data, String currency, String type) {
    if (isLoading) return const Center(child: CircularProgressIndicator());
    final chart = showPieChart
        ? SizedBox(key: _chartKey(data, 'pie-$type'), height: 300, child: _pieChart(data))
        : SizedBox(key: _chartKey(data, 'bar-$type'), height: 300, child: _barChart(data));
    return SingleChildScrollView(
      child: Column(
        children: [
          AnimatedSwitcher(duration: const Duration(milliseconds: 200), child: chart),
          _summary(data, currency),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final currency = settings.currency;
    final monthLabel = DateFormat('MMMM yyyy').format(selectedDate);
    final tabTitles = ["Income", "Expense", "Loan"];

    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics - $monthLabel'),
        actions: [
          IconButton(
              icon: const Icon(Icons.download_rounded),
              tooltip: 'Download',
              onPressed: () {
                final currentTab = _tabController.index;
                final data = [incomeData, expenseData, loanData][currentTab];
                showDownloadOptions(data, tabTitles[currentTab], currency);
              }),
          IconButton(
              icon: Icon(showPieChart ? Icons.bar_chart_rounded : Icons.pie_chart),
              onPressed: () => setState(() => showPieChart = !showPieChart)),
          IconButton(icon: const Icon(Icons.calendar_today), onPressed: pickMonthYear),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Theme.of(context).colorScheme.secondary,
          tabs: const [
            Tab(text: 'Income'),
            Tab(text: 'Expense'),
            Tab(text: 'Loan'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _tabContent(incomeData, currency, 'income'),
          _tabContent(expenseData, currency, 'expense'),
          _tabContent(loanData, currency, 'loan'),
        ],
      ),
    );
  }
}
