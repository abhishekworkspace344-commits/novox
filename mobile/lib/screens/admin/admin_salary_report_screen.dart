import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../services/report_service.dart';

class AdminSalaryReportScreen extends StatefulWidget {
  const AdminSalaryReportScreen({
    super.key,
  });

  @override
  State<AdminSalaryReportScreen> createState() =>
      _AdminSalaryReportScreenState();
}

class _AdminSalaryReportScreenState
    extends State<AdminSalaryReportScreen> {

  late final ReportService reportService;

  List<dynamic> records = [];

  bool loading = false;

  int selectedYear = DateTime.now().year;
  int? selectedMonth;

  @override
  void initState() {
    super.initState();

    reportService = ReportService(
      ApiClient(),
    );

    loadReport();
  }

  Future<void> loadReport() async {
    setState(() {
      loading = true;
    });

    try {
      final data =
          await reportService.getSalaryReport(
        month: selectedMonth,
        year: selectedYear,
      );

      if (!mounted) return;

      setState(() {
        records = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load salary report: $e",
          ),
        ),
      );
    }
  }

  String monthName(int month) {
    const months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December",
    ];

    return months[month - 1];
  }

  Widget salaryCard(
    Map<String, dynamic> item,
  ) {
    final staffName =
        item["staff_name"]?.toString() ?? "-";

    final month =
        item["month"] ?? 0;

    final year =
        item["year"] ?? 0;

    final basic =
        item["basic_salary"] ?? 0;

    final allowance =
        item["allowance"] ?? 0;

    final deduction =
        item["deduction"] ?? 0;

    final net =
        item["net_salary"] ?? 0;

    final status =
        item["status"]?.toString() ?? "-";

    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),

      child: Padding(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                const CircleAvatar(
                  child: Icon(
                    Icons.person,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      Text(
                        staffName,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        "${monthName(month)} $year",
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  status,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            Row(
              children: [

                Expanded(
                  child: _amount(
                    "Basic",
                    basic,
                  ),
                ),

                Expanded(
                  child: _amount(
                    "Allowance",
                    allowance,
                  ),
                ),

                Expanded(
                  child: _amount(
                    "Deduction",
                    deduction,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(12),

              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(10),
              ),

              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "Net Salary",
                    style: TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  Text(
                    "₹ $net",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _amount(
    String title,
    dynamic amount,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          "₹ $amount",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Salary Report",
        ),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(12),

            child: Row(
              children: [

                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: selectedMonth,

                    decoration:
                        const InputDecoration(
                      labelText: "Month",
                      border:
                          OutlineInputBorder(),
                    ),

                    items: [
                      const DropdownMenuItem<int>(
                        value: null,
                        child: Text(
                          "All Months",
                        ),
                      ),

                      ...List.generate(
                        12,
                        (index) {
                          final month =
                              index + 1;

                          return DropdownMenuItem<int>(
                            value: month,
                            child: Text(
                              monthName(month),
                            ),
                          );
                        },
                      ),
                    ],

                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                      });

                      loadReport();
                    },
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: selectedYear,

                    decoration:
                        const InputDecoration(
                      labelText: "Year",
                      border:
                          OutlineInputBorder(),
                    ),

                    items: List.generate(
                      7,
                      (index) {
                        final year =
                            DateTime.now().year -
                                index;

                        return DropdownMenuItem<int>(
                          value: year,
                          child: Text(
                            year.toString(),
                          ),
                        );
                      },
                    ),

                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedYear = value;
                      });

                      loadReport();
                    },
                  ),
                ),
              ],
            ),
          ),

          if (loading)
            const LinearProgressIndicator(),

          Expanded(
            child: records.isEmpty && !loading
                ? const Center(
                    child: Text(
                      "No salary records found",
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: loadReport,

                    child: ListView.builder(
                      padding:
                          const EdgeInsets.all(12),

                      itemCount:
                          records.length,

                      itemBuilder:
                          (context, index) {

                        return salaryCard(
                          Map<String, dynamic>.from(
                            records[index],
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
