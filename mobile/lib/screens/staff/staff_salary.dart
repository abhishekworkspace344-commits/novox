import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../models/salary_model.dart';
import '../../services/salary_service.dart';

class StaffSalaryScreen extends StatefulWidget {
  const StaffSalaryScreen({
    super.key,
  });

  @override
  State<StaffSalaryScreen> createState() =>
      _StaffSalaryScreenState();
}

class _StaffSalaryScreenState
    extends State<StaffSalaryScreen> {
  late final SalaryService salaryService;

  List<SalaryModel> salaries = [];

  bool loading = true;

  @override
  void initState() {
    super.initState();

    salaryService = SalaryService(
      ApiClient(),
    );

    loadSalaries();
  }

  // ============================================================
  // LOAD SALARY
  // ============================================================

  Future<void> loadSalaries() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final result =
          await salaryService.getMySalarySlips();

      if (!mounted) return;

      setState(() {
        salaries = result;
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
            "Unable to load salary: $e",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String monthName(int month) {
    const months = [
      "",
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

    if (month < 1 || month > 12) {
      return "Unknown Month";
    }

    return months[month];
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color statusColor(String status) {
    switch (status.toUpperCase()) {
      case "GENERATED":
      case "PAID":
        return Colors.green;

      case "PENDING":
        return Colors.orange;

      case "CANCELLED":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // SALARY CARD
  // ============================================================

  Widget buildSalaryCard(
    SalaryModel salary,
  ) {
    final color =
        statusColor(salary.status);

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------

            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.10),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons
                        .account_balance_wallet_outlined,
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${monthName(salary.month)} ${salary.year}",
                        style:
                            const TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      const Text(
                        "Monthly Salary Slip",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: Text(
                    salary.status.toUpperCase(),
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            const Divider(),

            const SizedBox(height: 10),

            // ----------------------------------------------------
            // SALARY BREAKDOWN
            // ----------------------------------------------------

            buildSalaryRow(
              "Basic Salary",
              salary.basicSalary,
            ),

            buildSalaryRow(
              "Allowance",
              salary.allowance,
            ),

            buildSalaryRow(
              "Deduction",
              salary.deduction,
              deduction: true,
            ),

            const SizedBox(height: 8),

            const Divider(),

            const SizedBox(height: 8),

            // ----------------------------------------------------
            // NET SALARY
            // ----------------------------------------------------

            Container(
              padding:
                  const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.green
                    .withValues(alpha: 0.08),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons
                        .account_balance_wallet,
                    color: Colors.green,
                  ),

                  const SizedBox(width: 10),

                  const Expanded(
                    child: Text(
                      "Net Salary",
                      style:
                          TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ),

                  Text(
                    formatCurrency(
                      salary.netSalary,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                      color: Colors.green,
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

  // ============================================================
  // SALARY ROW
  // ============================================================

  Widget buildSalaryRow(
    String title,
    double amount, {
    bool deduction = false,
  }) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style:
                  const TextStyle(
                fontSize: 14,
              ),
            ),
          ),

          Text(
            deduction
                ? "- ${formatCurrency(amount)}"
                : formatCurrency(amount),
            style: TextStyle(
              fontSize: 14,
              fontWeight:
                  FontWeight.w600,
              color: deduction
                  ? Colors.red
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CURRENCY
  // ============================================================

  String formatCurrency(
    double amount,
  ) {
    return "₹ ${amount.toStringAsFixed(2)}";
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget buildEmptyState() {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height:
              MediaQuery.of(context)
                      .size
                      .height *
                  0.30,
        ),

        Icon(
          Icons
              .account_balance_wallet_outlined,
          size: 70,
          color: AppColors.textMuted,
        ),

        const SizedBox(height: 16),

        const Center(
          child: Text(
            "No salary slips available",
            style: TextStyle(
              fontSize: 18,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 30,
            ),
            child: Text(
              "Your monthly salary slips will appear here once they are generated.",
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Salary",
        ),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed:
                loadSalaries,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),

      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : salaries.isEmpty
              ? RefreshIndicator(
                  onRefresh:
                      loadSalaries,
                  child:
                      buildEmptyState(),
                )
              : RefreshIndicator(
                  onRefresh:
                      loadSalaries,
                  child: ListView.builder(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding:
                        const EdgeInsets.all(
                      16,
                    ),
                    itemCount:
                        salaries.length,
                    itemBuilder:
                        (context, index) {
                      return buildSalaryCard(
                        salaries[index],
                      );
                    },
                  ),
                ),
    );
  }
}
