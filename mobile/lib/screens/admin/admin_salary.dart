import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_error.dart';
import '../../core/theme/app_theme.dart';
import '../../models/admin_salary_model.dart';
import '../../models/staff_admin_model.dart';
import '../../services/admin_service.dart';

class AdminSalaryScreen extends StatefulWidget {
  final StaffAdminModel staff;

  const AdminSalaryScreen({
    super.key,
    required this.staff,
  });

  @override
  State<AdminSalaryScreen> createState() => _AdminSalaryScreenState();
}

class _AdminSalaryScreenState extends State<AdminSalaryScreen> {
  late final AdminService adminService;

  List<AdminSalaryModel> salaryStructures = [];
  bool loading = true;
  bool saving = false;
  bool generatingSlip = false;

  @override
  void initState() {
    super.initState();
    adminService = AdminService(ApiClient());
    loadSalary();
  }

  Future<void> loadSalary() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });

    try {
      final data = await adminService.getStaffSalary(widget.staff.id);
      if (!mounted) return;
      setState(() {
        salaryStructures = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load salary: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> showSalaryDialog() async {
    final basicController = TextEditingController();
    final allowanceController = TextEditingController();
    final deductionController = TextEditingController();
    final effectiveDateController = TextEditingController(
      text: formatDate(DateTime.now()),
    );

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Configure Salary Structure"),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      salaryField(
                        controller: basicController,
                        label: "Basic Monthly Salary (₹)",
                        icon: Icons.account_balance_wallet_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      salaryField(
                        controller: allowanceController,
                        label: "Monthly Allowances (₹)",
                        icon: Icons.add_circle_outline_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      salaryField(
                        controller: deductionController,
                        label: "Monthly Deductions (₹)",
                        icon: Icons.remove_circle_outline_rounded,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                      salaryField(
                        controller: effectiveDateController,
                        label: "Effective Date (YYYY-MM-DD)",
                        icon: Icons.calendar_today_rounded,
                        readOnly: true,
                        onTap: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (selected != null) {
                            effectiveDateController.text = formatDate(selected);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: saving ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: saving
                      ? null
                      : () async {
                          await saveSalary(
                            dialogContext,
                            basicController.text,
                            allowanceController.text,
                            deductionController.text,
                            effectiveDateController.text,
                            setDialogState,
                          );
                        },
                  child: saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Save Structure"),
                ),
              ],
            );
          },
        );
      },
    );

    basicController.dispose();
    allowanceController.dispose();
    deductionController.dispose();
    effectiveDateController.dispose();
  }

  Future<void> saveSalary(
    BuildContext dialogContext,
    String basicText,
    String allowanceText,
    String deductionText,
    String effectiveDate,
    void Function(void Function()) setDialogState,
  ) async {
    final basic = double.tryParse(basicText.trim());
    final allowance = double.tryParse(allowanceText.trim()) ?? 0.0;
    final deduction = double.tryParse(deductionText.trim()) ?? 0.0;

    if (basic == null || basic <= 0) {
      showMessage("Please enter a valid basic salary");
      return;
    }

    setDialogState(() {
      saving = true;
    });

    final data = {
      "staff_id": widget.staff.id,
      "basic_salary": basic,
      "allowance": allowance,
      "deduction": deduction,
      "effective_from": effectiveDate.trim().isEmpty ? null : effectiveDate.trim(),
    };

    try {
      await adminService.createSalaryStructure(data);

      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Salary structure saved successfully"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadSalary();
    } catch (e) {
      setDialogState(() {
        saving = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save salary: ${ApiError.message(e)}"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> generateSlip() async {
    if (generatingSlip) return;

    final now = DateTime.now();
    int selectedMonth = now.month;
    int selectedYear = now.year;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Generate Salary Slip"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Generate slip for ${widget.staff.name}",
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedMonth,
                    decoration: const InputDecoration(
                      labelText: "Month",
                      prefixIcon: Icon(Icons.calendar_month, color: AppColors.primary),
                    ),
                    items: List.generate(12, (index) {
                      final m = index + 1;
                      return DropdownMenuItem(
                        value: m,
                        child: Text(monthName(m)),
                      );
                    }),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedMonth = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedYear,
                    decoration: const InputDecoration(
                      labelText: "Year",
                      prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
                    ),
                    items: [now.year - 1, now.year, now.year + 1].map((y) {
                      return DropdownMenuItem(
                        value: y,
                        child: Text(y.toString()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedYear = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: const Text("Generate Slip"),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirm != true) return;

    setState(() {
      generatingSlip = true;
    });

    try {
      await adminService.generateSalarySlip(
        widget.staff.id,
        selectedMonth,
        selectedYear,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Salary slip generated successfully!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadSalary();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to generate salary slip: ${ApiError.message(e)}"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          generatingSlip = false;
        });
      }
    }
  }

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
    return (month >= 1 && month <= 12) ? months[month] : "Month $month";
  }

  Widget salaryField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget buildStaffHeader() {
    final firstLetter = widget.staff.name.isNotEmpty
        ? widget.staff.name[0].toUpperCase()
        : "S";

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 20,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.staff.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.staff.designation,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Code: ${widget.staff.employeeCode}",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCurrentSalary() {
    final salary = salaryStructures.first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Current Active Structure",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          salaryRow("Basic Pay", salary.basicSalary),
          salaryRow("Allowances", salary.allowance),
          salaryRow("Deductions", salary.deduction),
          const Divider(height: 24),
          // Net Salary Highlight Box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Net Take-Home Salary",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                    fontSize: 14,
                  ),
                ),
                Text(
                  "₹${salary.netSalary.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget salaryRow(String title, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            "₹${amount.toStringAsFixed(2)}",
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSalaryCard(AdminSalaryModel salary) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primarySoft,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.payments_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Net Salary: ₹${salary.netSalary.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Basic: ₹${salary.basicSalary.toStringAsFixed(0)}  •  Allow: ₹${salary.allowance.toStringAsFixed(0)}  •  Ded: ₹${salary.deduction.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Center(
        child: Column(
          children: const [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 48,
              color: AppColors.textMuted,
            ),
            SizedBox(height: 12),
            Text(
              "No Active Salary Structure",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4),
            Text(
              "Tap 'Configure Salary' to set up monthly compensation.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Salary Management"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            icon: const Icon(Icons.refresh),
            onPressed: loadSalary,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: showSalaryDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.payments_rounded),
        label: const Text("Configure Salary"),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadSalary,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  buildStaffHeader(),
                  const SizedBox(height: 18),
                  if (salaryStructures.isNotEmpty)
                    buildCurrentSalary()
                  else
                    buildEmptyState(),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: salaryStructures.isEmpty || generatingSlip
                          ? null
                          : generateSlip,
                      icon: generatingSlip
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.receipt_long_rounded),
                      label: Text(
                        generatingSlip
                            ? "Generating..."
                            : "Generate Monthly Salary Slip",
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Salary History",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (salaryStructures.isEmpty)
                    const Text(
                      "No historical compensation records.",
                      style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    )
                  else
                    ...salaryStructures.map(buildSalaryCard),
                  const SizedBox(height: 80),
                ],
              ),
            ),
    );
  }
}
