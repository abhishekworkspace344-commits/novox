import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../services/report_service.dart';

import 'admin_attendance_report_screen.dart';
import 'admin_fee_report_screen.dart';
import 'admin_late_entry_report_screen.dart';
import 'admin_salary_report_screen.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({
    super.key,
  });

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  late final ReportService reportService;

  Map<String, dynamic>? summary;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    reportService = ReportService(ApiClient());
    loadSummary();
  }

  Future<void> loadSummary() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });

    try {
      final data = await reportService.getSummary();
      if (!mounted) return;
      setState(() {
        summary = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load reports: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget reportCard(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.3,
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

  Widget reportTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget screen,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => screen),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, color: iconColor, size: 23),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Institutional Analytics"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: loadSummary,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadSummary,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  // Hero Header
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.analytics_rounded,
                            size: 28,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                "Audit & Operations",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                "Live summaries and detailed data exports",
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Executive Summary",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  reportCard(
                    "Total Enrolled Students",
                    "${summary?['total_students'] ?? 0}",
                    Icons.school_rounded,
                    AppColors.primary,
                  ),

                  reportCard(
                    "Faculty & Staff Members",
                    "${summary?['total_staff'] ?? 0}",
                    Icons.groups_rounded,
                    const Color(0xFF0284C7),
                  ),

                  reportCard(
                    "Present On Campus Today",
                    "${summary?['present_today'] ?? 0}",
                    Icons.check_circle_outline_rounded,
                    AppColors.success,
                  ),

                  reportCard(
                    "Late Entry Records Today",
                    "${summary?['late_today'] ?? 0}",
                    Icons.schedule_rounded,
                    AppColors.warning,
                  ),

                  reportCard(
                    "Students with Outstanding Fees",
                    "${summary?['pending_fee_students'] ?? 0}",
                    Icons.pending_actions_rounded,
                    AppColors.danger,
                  ),

                  reportCard(
                    "Total Outstanding Fees",
                    "₹ ${summary?['total_pending_fees'] ?? 0}",
                    Icons.account_balance_wallet_rounded,
                    const Color(0xFFDC2626),
                  ),

                  reportCard(
                    "Total Fees Collected",
                    "₹ ${summary?['total_collected_fees'] ?? 0}",
                    Icons.payments_rounded,
                    AppColors.success,
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    "Detailed Modular Reports",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  reportTile(
                    context: context,
                    icon: Icons.fact_check_rounded,
                    iconColor: AppColors.primary,
                    title: "Attendance Report",
                    subtitle: "Historical attendance logs, filters & PDF export",
                    screen: const AdminAttendanceReportScreen(),
                  ),

                  reportTile(
                    context: context,
                    icon: Icons.schedule_rounded,
                    iconColor: AppColors.warning,
                    title: "Late Entry Analysis",
                    subtitle: "Late arrivals breakdown, user IDs & timestamps",
                    screen: const AdminLateEntryReportScreen(),
                  ),

                  reportTile(
                    context: context,
                    icon: Icons.currency_rupee_rounded,
                    iconColor: const Color(0xFF0D9488),
                    title: "Fee Collections & Dues",
                    subtitle: "Paid receipts, pending amounts & status breakdown",
                    screen: const AdminFeeReportScreen(),
                  ),

                  reportTile(
                    context: context,
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFF7C3AED),
                    title: "Payroll & Salary Register",
                    subtitle: "Monthly disbursements, basic pay & net slips",
                    screen: const AdminSalaryReportScreen(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
