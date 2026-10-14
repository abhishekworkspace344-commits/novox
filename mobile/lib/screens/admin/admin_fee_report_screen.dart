import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../services/report_service.dart';

class AdminFeeReportScreen extends StatefulWidget {
  const AdminFeeReportScreen({
    super.key,
  });

  @override
  State<AdminFeeReportScreen> createState() =>
      _AdminFeeReportScreenState();
}

class _AdminFeeReportScreenState
    extends State<AdminFeeReportScreen> {

  late final ReportService reportService;

  List<dynamic> records = [];

  bool loading = false;

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
          await reportService.getFeeReport();

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
            "Failed to load fee report: $e",
          ),
        ),
      );
    }
  }

  Widget feeCard(
    Map<String, dynamic> item,
  ) {
    final name =
        item["student_name"]?.toString() ?? "-";

    final total =
        item["total_amount"] ?? 0;

    final paid =
        item["paid_amount"] ?? 0;

    final pending =
        item["pending_amount"] ?? 0;

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
                    Icons.school,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.bold,
                    ),
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
                    "Total",
                    total,
                  ),
                ),
                Expanded(
                  child: _amount(
                    "Paid",
                    paid,
                  ),
                ),
                Expanded(
                  child: _amount(
                    "Pending",
                    pending,
                  ),
                ),
              ],
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
            color: AppColors.textMuted,
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
          "Fee Report",
        ),
      ),

      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadReport,

              child: records.isEmpty
                  ? const Center(
                      child: Text(
                        "No fee records found",
                      ),
                    )
                  : ListView.builder(
                      padding:
                          const EdgeInsets.all(12),
                      itemCount: records.length,
                      itemBuilder:
                          (context, index) {
                        return feeCard(
                          Map<String, dynamic>.from(
                            records[index],
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
