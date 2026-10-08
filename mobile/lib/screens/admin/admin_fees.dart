import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_theme.dart';
import '../../models/admin_fee_model.dart';
import '../../services/admin_service.dart';
import '../../widgets/status_badge.dart';

class AdminFeesScreen extends StatefulWidget {
  const AdminFeesScreen({
    super.key,
  });

  @override
  State<AdminFeesScreen> createState() => _AdminFeesScreenState();
}

class _AdminFeesScreenState extends State<AdminFeesScreen> {
  late final AdminService adminService;

  List<AdminFeeModel> pendingFees = [];
  bool loading = true;
  bool paymentLoading = false;
  bool structureLoading = false;

  @override
  void initState() {
    super.initState();
    adminService = AdminService(ApiClient());
    loadFees();
  }

  Future<void> loadFees() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });

    try {
      final data = await adminService.getPendingFees();
      if (!mounted) return;
      setState(() {
        pendingFees = data;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load fees: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  double get totalPending {
    return pendingFees.fold(0.0, (sum, fee) => sum + fee.pendingAmount);
  }

  double get totalCollected {
    return pendingFees.fold(0.0, (sum, fee) => sum + fee.paidAmount);
  }

  void showPaymentDialog(AdminFeeModel fee) {
    final amountController = TextEditingController();
    final transactionController = TextEditingController();
    String paymentMethod = "CASH";

    showDialog(
      context: context,
      barrierDismissible: !paymentLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Record Fee Payment"),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Student #${fee.studentId}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                            Text(
                              "Due: ₹${fee.pendingAmount.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppColors.danger,
                              ),
                            ),
                          ],
                        ),
                      ),
                      inputField(
                        amountController,
                        "Amount to Pay (₹)",
                        Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: paymentMethod,
                        decoration: const InputDecoration(
                          labelText: "Payment Method",
                          prefixIcon: Icon(Icons.payment_rounded, color: AppColors.primary),
                        ),
                        items: const [
                          DropdownMenuItem(value: "CASH", child: Text("Cash")),
                          DropdownMenuItem(value: "ONLINE", child: Text("Online / UPI")),
                          DropdownMenuItem(value: "CHEQUE", child: Text("Cheque")),
                          DropdownMenuItem(value: "BANK_TRANSFER", child: Text("Bank Transfer")),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setDialogState(() => paymentMethod = val);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      inputField(
                        transactionController,
                        "Transaction / Ref ID (Optional)",
                        Icons.tag_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: paymentLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: paymentLoading
                      ? null
                      : () async {
                          await recordPayment(
                            dialogContext,
                            fee,
                            amountController.text,
                            paymentMethod,
                            transactionController.text,
                            setDialogState,
                          );
                        },
                  child: paymentLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Confirm Payment"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> recordPayment(
    BuildContext dialogContext,
    AdminFeeModel fee,
    String amountText,
    String paymentMethod,
    String transactionId,
    void Function(void Function()) setDialogState,
  ) async {
    final amount = double.tryParse(amountText.trim());

    if (amount == null || amount <= 0) {
      showMessage("Please enter a valid positive payment amount");
      return;
    }

    if (amount > fee.pendingAmount) {
      showMessage("Amount cannot exceed the pending balance of ₹${fee.pendingAmount.toStringAsFixed(2)}");
      return;
    }

    setDialogState(() {
      paymentLoading = true;
    });

    try {
      await adminService.recordPayment({
        "student_fee_id": fee.id,
        "amount": amount,
        "payment_method": paymentMethod,
        "transaction_id": transactionId.trim().isEmpty ? null : transactionId.trim(),
      });

      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Payment recorded successfully!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadFees();
    } catch (e) {
      setDialogState(() {
        paymentLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to record payment: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void showFeeStructureDialog() {
    final courseController = TextEditingController();
    final feeTypeController = TextEditingController();
    final amountController = TextEditingController();
    final descriptionController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: !structureLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text("Create Fee Structure"),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      inputField(
                        courseController,
                        "Course Name (e.g. MCA, B.Tech)",
                        Icons.school_rounded,
                      ),
                      inputField(
                        feeTypeController,
                        "Fee Type (e.g. Tuition, Exam, Lab)",
                        Icons.category_rounded,
                      ),
                      inputField(
                        amountController,
                        "Total Amount (₹)",
                        Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                      ),
                      inputField(
                        descriptionController,
                        "Description (Optional)",
                        Icons.description_rounded,
                        maxLines: 2,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: structureLoading ? null : () => Navigator.pop(dialogContext),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: structureLoading
                      ? null
                      : () async {
                          await createFeeStructure(
                            dialogContext,
                            courseController.text,
                            feeTypeController.text,
                            amountController.text,
                            descriptionController.text,
                            setDialogState,
                          );
                        },
                  child: structureLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text("Create Structure"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> createFeeStructure(
    BuildContext dialogContext,
    String course,
    String feeType,
    String amountText,
    String description,
    void Function(void Function()) setDialogState,
  ) async {
    final amount = double.tryParse(amountText.trim());

    if (course.trim().isEmpty) {
      showMessage("Please enter course name");
      return;
    }
    if (feeType.trim().isEmpty) {
      showMessage("Please enter fee type");
      return;
    }
    if (amount == null || amount <= 0) {
      showMessage("Please enter a valid amount");
      return;
    }

    setDialogState(() {
      structureLoading = true;
    });

    try {
      await adminService.createFeeStructure({
        "course": course.trim(),
        "fee_type": feeType.trim(),
        "total_amount": amount,
        "description": description.trim().isEmpty ? null : description.trim(),
      });

      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fee structure created successfully!"),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      await loadFees();
    } catch (e) {
      setDialogState(() {
        structureLoading = false;
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to create fee structure: $e"),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        ),
      ),
    );
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

  Widget summaryCard(
    String title,
    double amount,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "₹${amount.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget feeCard(AdminFeeModel fee) {
    final isPaid = fee.pendingAmount <= 0;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primarySoft,
                  child: const Icon(
                    Icons.school_rounded,
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
                        "Student #${fee.studentId}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      StatusBadge(status: fee.status, compact: true),
                    ],
                  ),
                ),
                if (!isPaid)
                  ElevatedButton.icon(
                    onPressed: paymentLoading ? null : () => showPaymentDialog(fee),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    ),
                    icon: const Icon(Icons.payment_rounded, size: 16),
                    label: const Text("Collect", style: TextStyle(fontSize: 13)),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                amountColumn("Total Fee", fee.totalAmount, AppColors.textPrimary),
                amountColumn("Collected", fee.paidAmount, AppColors.success),
                amountColumn("Pending Due", fee.pendingAmount, AppColors.danger),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget amountColumn(String title, double amount, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          "₹${amount.toStringAsFixed(2)}",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 14,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Fees & Collections"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: loading ? null : loadFees,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: "Add Fee Structure",
            onPressed: showFeeStructureDialog,
            icon: const Icon(Icons.add_card_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadFees,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Row(
                    children: [
                      summaryCard(
                        "Collected Revenue",
                        totalCollected,
                        Icons.check_circle_outline_rounded,
                        AppColors.success,
                      ),
                      const SizedBox(width: 12),
                      summaryCard(
                        "Outstanding Balance",
                        totalPending,
                        Icons.pending_actions_rounded,
                        AppColors.danger,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed: structureLoading ? null : showFeeStructureDialog,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        "CREATE FEE STRUCTURE",
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Outstanding Invoices",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (pendingFees.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Center(
                        child: Column(
                          children: const [
                            Icon(
                              Icons.task_alt_rounded,
                              size: 46,
                              color: AppColors.success,
                            ),
                            SizedBox(height: 12),
                            Text(
                              "All student fees are fully settled!",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...pendingFees.map(feeCard),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}