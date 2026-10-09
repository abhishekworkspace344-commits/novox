import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../models/admin_fee_model.dart';
import '../../services/admin_service.dart';

class AdminFeesScreen extends StatefulWidget {
  const AdminFeesScreen({
    super.key,
  });

  @override
  State<AdminFeesScreen> createState() =>
      _AdminFeesScreenState();
}

class _AdminFeesScreenState
    extends State<AdminFeesScreen> {
  late final AdminService adminService;

  // ============================================================
  // DATA
  // ============================================================

  List<AdminFeeModel> fees = [];
  List<dynamic> feeStructures = [];

  bool loading = true;
  bool paymentLoading = false;
  bool structureLoading = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    adminService = AdminService(
      ApiClient(),
    );

    loadFees();
  }

  // ============================================================
  // LOAD DATA
  // ============================================================

  Future<void> loadFees() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final results = await Future.wait([
        adminService.getPendingFees(),
        adminService.getFeeStructures(),
      ]);

      if (!mounted) return;

      final pendingData =
          results[0] as List<AdminFeeModel>;

      final structureData =
          results[1] as List<dynamic>;

      setState(() {
        fees = pendingData;
        feeStructures = structureData;
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
            "Failed to load fee data: $e",
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  double get totalCollected {
    return fees.fold(
      0.0,
      (sum, fee) => sum + fee.paidAmount,
    );
  }

  double get totalPending {
    return fees.fold(
      0.0,
      (sum, fee) => sum + fee.pendingAmount,
    );
  }

  double get totalFee {
    return fees.fold(
      0.0,
      (sum, fee) => sum + fee.totalAmount,
    );
  }

  int get paidStudents {
    return fees.where(
      (fee) => fee.pendingAmount <= 0,
    ).length;
  }

  int get partialStudents {
    return fees.where(
      (fee) =>
          fee.paidAmount > 0 &&
          fee.pendingAmount > 0,
    ).length;
  }

  int get pendingStudents {
    return fees.where(
      (fee) =>
          fee.paidAmount <= 0 &&
          fee.pendingAmount > 0,
    ).length;
  }

  // ============================================================
  // CREATE FEE STRUCTURE
  // ============================================================

  void showFeeStructureDialog() {
    final courseController =
        TextEditingController();

    final feeTypeController =
        TextEditingController();

    final amountController =
        TextEditingController();

    final descriptionController =
        TextEditingController();

    showDialog(
      context: context,
      barrierDismissible:
          !structureLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                "Create Fee Structure",
              ),

              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      inputField(
                        courseController,
                        "Course",
                        Icons.school_rounded,
                      ),

                      inputField(
                        feeTypeController,
                        "Fee Type",
                        Icons.category_rounded,
                      ),

                      inputField(
                        amountController,
                        "Total Amount",
                        Icons.currency_rupee_rounded,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      inputField(
                        descriptionController,
                        "Description",
                        Icons.description_rounded,
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed:
                      structureLoading
                          ? null
                          : () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                  child:
                      const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed:
                      structureLoading
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
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Create Structure",
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // CREATE FEE STRUCTURE API
  // ============================================================

  Future<void> createFeeStructure(
    BuildContext dialogContext,
    String course,
    String feeType,
    String amountText,
    String description,
    void Function(
      void Function(),
    ) setDialogState,
  ) async {
    final amount =
        double.tryParse(
      amountText.trim(),
    );

    if (course.trim().isEmpty) {
      showMessage(
        "Please enter course name",
      );
      return;
    }

    if (feeType.trim().isEmpty) {
      showMessage(
        "Please enter fee type",
      );
      return;
    }

    if (amount == null ||
        amount <= 0) {
      showMessage(
        "Please enter a valid amount",
      );
      return;
    }

    setDialogState(() {
      structureLoading = true;
    });

    try {
      await adminService.createFeeStructure(
        {
          "course": course.trim(),
          "fee_type": feeType.trim(),
          "total_amount": amount,
          "description":
              description.trim().isEmpty
                  ? null
                  : description.trim(),
        },
      );

      if (!dialogContext.mounted) {
        return;
      }

      Navigator.pop(
        dialogContext,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Fee structure created successfully",
          ),
          backgroundColor:
              Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      await loadFees();
    } catch (e) {
      setDialogState(() {
        structureLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to create fee structure: $e",
          ),
          backgroundColor:
              Colors.red,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // RECORD PAYMENT
  // ============================================================

  void showPaymentDialog(
    AdminFeeModel fee,
  ) {
    final amountController =
        TextEditingController();

    final transactionController =
        TextEditingController();

    String paymentMethod = "CASH";

    showDialog(
      context: context,
      barrierDismissible:
          !paymentLoading,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: const Text(
                "Record Fee Payment",
              ),

              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Container(
                        padding:
                            const EdgeInsets.all(
                          14,
                        ),
                        margin:
                            const EdgeInsets.only(
                          bottom: 16,
                        ),
                        decoration:
                            BoxDecoration(
                          color: Colors.blue
                              .withOpacity(
                            0.08,
                          ),
                          borderRadius:
                              BorderRadius.circular(
                            12,
                          ),
                        ),
                        child: Column(
                          children: [
                            paymentInfo(
                              "Total Fee",
                              fee.totalAmount,
                            ),
                            paymentInfo(
                              "Amount Paid",
                              fee.paidAmount,
                            ),
                            paymentInfo(
                              "Pending Amount",
                              fee.pendingAmount,
                            ),
                          ],
                        ),
                      ),

                      inputField(
                        amountController,
                        "Payment Amount",
                        Icons.currency_rupee_rounded,
                        keyboardType:
                            const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),

                      const SizedBox(
                        height: 4,
                      ),

                      DropdownButtonFormField<
                          String>(
                        initialValue:
                            paymentMethod,
                        decoration:
                            const InputDecoration(
                          labelText:
                              "Payment Method",
                          prefixIcon:
                              Icon(
                            Icons.payment_rounded,
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "CASH",
                            child:
                                Text("Cash"),
                          ),
                          DropdownMenuItem(
                            value: "ONLINE",
                            child: Text(
                              "Online / UPI",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "CHEQUE",
                            child:
                                Text("Cheque"),
                          ),
                          DropdownMenuItem(
                            value:
                                "BANK_TRANSFER",
                            child: Text(
                              "Bank Transfer",
                            ),
                          ),
                          DropdownMenuItem(
                            value: "CARD",
                            child:
                                Text("Card"),
                          ),
                        ],
                        onChanged:
                            (value) {
                          if (value ==
                              null) {
                            return;
                          }

                          setDialogState(() {
                            paymentMethod =
                                value;
                          });
                        },
                      ),

                      const SizedBox(
                        height: 12,
                      ),

                      inputField(
                        transactionController,
                        "Transaction / Reference ID",
                        Icons.receipt_long_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed:
                      paymentLoading
                          ? null
                          : () {
                              Navigator.pop(
                                dialogContext,
                              );
                            },
                  child:
                      const Text("Cancel"),
                ),

                ElevatedButton(
                  onPressed:
                      paymentLoading
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
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Confirm Payment",
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ============================================================
  // PAYMENT API
  // ============================================================

  Future<void> recordPayment(
    BuildContext dialogContext,
    AdminFeeModel fee,
    String amountText,
    String paymentMethod,
    String transactionId,
    void Function(
      void Function(),
    ) setDialogState,
  ) async {
    final amount =
        double.tryParse(
      amountText.trim(),
    );

    if (amount == null ||
        amount <= 0) {
      showMessage(
        "Please enter a valid payment amount",
      );
      return;
    }

    if (amount >
        fee.pendingAmount) {
      showMessage(
        "Payment cannot exceed pending amount of ₹${fee.pendingAmount.toStringAsFixed(2)}",
      );
      return;
    }

    setDialogState(() {
      paymentLoading = true;
    });

    try {
      await adminService.recordPayment(
        {
          "student_fee_id": fee.id,
          "student_id": fee.studentId,
          "amount": amount,
          "payment_method":
              paymentMethod,
          "transaction_id":
              transactionId.trim().isEmpty
                  ? null
                  : transactionId.trim(),
        },
      );

      if (!dialogContext.mounted) {
        return;
      }

      Navigator.pop(
        dialogContext,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Payment recorded successfully",
          ),
          backgroundColor:
              Colors.green,
          behavior:
              SnackBarBehavior.floating,
        ),
      );

      await loadFees();
    } catch (e) {
      setDialogState(() {
        paymentLoading = false;
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Payment failed: $e",
          ),
          backgroundColor:
              Colors.red,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ============================================================
  // FEE STRUCTURE CARD
  // ============================================================

  Widget feeStructureCard(
    dynamic structure,
  ) {
    final data =
        Map<String, dynamic>.from(
      structure as Map,
    );

    final course =
        data["course"]?.toString() ??
            "-";

    final feeType =
        data["fee_type"]?.toString() ??
            "-";

    final amount =
        toDouble(
      data["total_amount"],
    );

    final description =
        data["description"]?.toString() ??
            "";

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 10,
      ),
      elevation: 1,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          15,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration:
                  BoxDecoration(
                color: Colors.blue
                    .withOpacity(
                  0.10,
                ),
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Icon(
                Icons
                    .account_balance_wallet_rounded,
                color: Colors.blue,
              ),
            ),

            const SizedBox(
              width: 13,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    feeType,
                    style:
                        const TextStyle(
                      fontSize: 16,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(
                    height: 4,
                  ),

                  Text(
                    "Course: $course",
                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 12,
                    ),
                  ),

                  if (description
                      .isNotEmpty)
                    Padding(
                      padding:
                          const EdgeInsets
                              .only(
                        top: 3,
                      ),
                      child: Text(
                        description,
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                          fontSize:
                              11,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(
              width: 10,
            ),

            Text(
              "₹${amount.toStringAsFixed(2)}",
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STUDENT FEE CARD
  // ============================================================

  Widget feeCard(
    AdminFeeModel fee,
  ) {
    final bool isPaid =
        fee.pendingAmount <= 0;

    final bool isPartial =
        fee.paidAmount > 0 &&
        fee.pendingAmount > 0;

    final Color statusColor =
        isPaid
            ? Colors.green
            : isPartial
                ? Colors.orange
                : Colors.red;

    final String status =
        isPaid
            ? "PAID"
            : isPartial
                ? "PARTIALLY PAID"
                : "PENDING";

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 1.5,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          16,
        ),
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(
          16,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor:
                      Colors.blue
                          .withOpacity(
                    0.10,
                  ),
                  child:
                      const Icon(
                    Icons.person,
                    color:
                        Colors.blue,
                  ),
                ),

                const SizedBox(
                  width: 12,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        "Student #${fee.studentId}",
                        style:
                            const TextStyle(
                          fontSize: 16,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        "Fee ID: ${fee.id}",
                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration:
                      BoxDecoration(
                    color: statusColor
                        .withOpacity(
                      0.10,
                    ),
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    status,
                    style:
                        TextStyle(
                      color:
                          statusColor,
                      fontWeight:
                          FontWeight
                              .bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(
              height: 28,
            ),

            Row(
              children: [
                Expanded(
                  child: amountColumn(
                    "Total Fee",
                    fee.totalAmount,
                    Colors.blue,
                  ),
                ),

                Expanded(
                  child: amountColumn(
                    "Amount Paid",
                    fee.paidAmount,
                    Colors.green,
                  ),
                ),

                Expanded(
                  child: amountColumn(
                    "Pending",
                    fee.pendingAmount,
                    Colors.red,
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 15,
            ),

            paymentProgress(
              fee.totalAmount,
              fee.paidAmount,
            ),

            if (fee.pendingAmount >
                0) ...[
              const SizedBox(
                height: 14,
              ),

              SizedBox(
                width:
                    double.infinity,
                child:
                    ElevatedButton.icon(
                  onPressed:
                      paymentLoading
                          ? null
                          : () {
                              showPaymentDialog(
                                fee,
                              );
                            },
                  icon:
                      const Icon(
                    Icons
                        .payments_rounded,
                    size: 18,
                  ),
                  label:
                      const Text(
                    "COLLECT PAYMENT",
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // AMOUNT COLUMN
  // ============================================================

  Widget amountColumn(
    String title,
    double amount,
    Color color,
  ) {
    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        Text(
          title,
          style:
              const TextStyle(
            color: Colors.grey,
            fontSize: 11,
          ),
        ),

        const SizedBox(
          height: 5,
        ),

        Text(
          "₹${amount.toStringAsFixed(2)}",
          style:
              TextStyle(
            color: color,
            fontWeight:
                FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT PROGRESS
  // ============================================================

  Widget paymentProgress(
    double total,
    double paid,
  ) {
    double progress = 0;

    if (total > 0) {
      progress = paid / total;
    }

    progress =
        progress.clamp(
      0.0,
      1.0,
    );

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment
              .start,
      children: [
        Row(
          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
          children: [
            const Text(
              "Payment Progress",
              style:
                  TextStyle(
                color:
                    Colors.grey,
                fontSize: 11,
              ),
            ),

            Text(
              "${(progress * 100).toStringAsFixed(0)}%",
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 6,
        ),

        ClipRRect(
          borderRadius:
              BorderRadius.circular(
            10,
          ),
          child:
              LinearProgressIndicator(
            value: progress,
            minHeight: 7,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget summaryCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(
          15,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            16,
          ),
          border: Border.all(
            color:
                Colors.grey.shade200,
          ),
          boxShadow: const [
            BoxShadow(
              color:
                  Color(0x08000000),
              blurRadius: 8,
              offset:
                  Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration:
                  BoxDecoration(
                color: color
                    .withOpacity(
                  0.10,
                ),
                borderRadius:
                    BorderRadius
                        .circular(
                  10,
                ),
              ),
              child:
                  Icon(
                icon,
                color: color,
                size: 21,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(
              title,
              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize: 11,
              ),
            ),

            const SizedBox(
              height: 4,
            ),

            Text(
              "₹${amount.toStringAsFixed(2)}",
              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STATUS CARD
  // ============================================================

  Widget statusCard({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding:
            const EdgeInsets.all(
          12,
        ),
        decoration:
            BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(
            14,
          ),
          border: Border.all(
            color:
                Colors.grey.shade200,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 25,
            ),

            const SizedBox(
              height: 5,
            ),

            Text(
              count.toString(),
              style:
                  TextStyle(
                color: color,
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            Text(
              title,
              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget inputField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 12,
      ),
      child: TextField(
        controller: controller,
        keyboardType:
            keyboardType,
        maxLines: maxLines,
        decoration:
            InputDecoration(
          labelText: label,
          prefixIcon:
              Icon(icon),
          border:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              12,
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT INFO
  // ============================================================

  Widget paymentInfo(
    String label,
    double amount,
  ) {
    return Padding(
      padding:
          const EdgeInsets
              .symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,
        children: [
          Text(label),

          Text(
            "₹${amount.toStringAsFixed(2)}",
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(
    String title, {
    String? subtitle,
  }) {
    return Padding(
      padding:
          const EdgeInsets.only(
        top: 20,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment
                .start,
        children: [
          Text(
            title,
            style:
                const TextStyle(
              fontSize: 19,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          if (subtitle !=
              null) ...[
            const SizedBox(
              height: 3,
            ),

            Text(
              subtitle,
              style:
                  const TextStyle(
                color:
                    Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // DOUBLE CONVERSION
  // ============================================================

  double toDouble(
    dynamic value,
  ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value.toString(),
        ) ??
        0;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void showMessage(
    String message,
  ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior
                .floating,
      ),
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
          "Fees & Collections",
        ),
        actions: [
          IconButton(
            tooltip:
                "Refresh",
            onPressed:
                loading
                    ? null
                    : loadFees,
            icon:
                const Icon(
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
          : RefreshIndicator(
              onRefresh:
                  loadFees,
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.all(
                  14,
                ),
                children: [
                  // ==================================================
                  // COLLECTION SUMMARY
                  // ==================================================

                  sectionTitle(
                    "Collection Summary",
                    subtitle:
                        "Overall student fee collection",
                  ),

                  LayoutBuilder(
                    builder:
                        (
                      context,
                      constraints,
                    ) {
                      final width =
                          constraints
                              .maxWidth;

                      if (width <
                          600) {
                        return Column(
                          children: [
                            Row(
                              children: [
                                summaryCard(
                                  title:
                                      "Collected Revenue",
                                  amount:
                                      totalCollected,
                                  icon:
                                      Icons.check_circle_outline,
                                  color:
                                      Colors.green,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                summaryCard(
                                  title:
                                      "Outstanding Balance",
                                  amount:
                                      totalPending,
                                  icon:
                                      Icons.pending_actions,
                                  color:
                                      Colors.red,
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Row(
                              children: [
                                summaryCard(
                                  title:
                                      "Total Fee",
                                  amount:
                                      totalFee,
                                  icon:
                                      Icons.account_balance_wallet_outlined,
                                  color:
                                      Colors.blue,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                summaryCard(
                                  title:
                                      "Pending Students",
                                  amount:
                                      pendingStudents.toDouble(),
                                  icon:
                                      Icons.people_outline,
                                  color:
                                      Colors.orange,
                                ),
                              ],
                            ),
                          ],
                        );
                      }

                      return Row(
                        children: [
                          summaryCard(
                            title:
                                "Collected Revenue",
                            amount:
                                totalCollected,
                            icon:
                                Icons.check_circle_outline,
                            color:
                                Colors.green,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          summaryCard(
                            title:
                                "Outstanding Balance",
                            amount:
                                totalPending,
                            icon:
                                Icons.pending_actions,
                            color:
                                Colors.red,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          summaryCard(
                            title:
                                "Total Fee",
                            amount:
                                totalFee,
                            icon:
                                Icons.account_balance_wallet_outlined,
                            color:
                                Colors.blue,
                          ),

                          const SizedBox(
                            width: 10,
                          ),

                          summaryCard(
                            title:
                                "Pending Students",
                            amount:
                                pendingStudents.toDouble(),
                            icon:
                                Icons.people_outline,
                            color:
                                Colors.orange,
                          ),
                        ],
                      );
                    },
                  ),

                  // ==================================================
                  // CREATE BUTTON
                  // ==================================================

                  const SizedBox(
                    height: 18,
                  ),

                  SizedBox(
                    width:
                        double.infinity,
                    height: 48,
                    child:
                        ElevatedButton.icon(
                      onPressed:
                          structureLoading
                              ? null
                              : showFeeStructureDialog,
                      icon:
                          const Icon(
                        Icons.add,
                      ),
                      label:
                          const Text(
                        "CREATE FEE STRUCTURE",
                      ),
                    ),
                  ),

                  // ==================================================
                  // PAYMENT STATUS
                  // ==================================================

                  sectionTitle(
                    "Payment Status",
                  ),

                  Row(
                    children: [
                      statusCard(
                        title:
                            "Paid",
                        count:
                            paidStudents,
                        color:
                            Colors.green,
                        icon:
                            Icons.check_circle,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      statusCard(
                        title:
                            "Partially Paid",
                        count:
                            partialStudents,
                        color:
                            Colors.orange,
                        icon:
                            Icons.timelapse,
                      ),

                      const SizedBox(
                        width: 8,
                      ),

                      statusCard(
                        title:
                            "Pending",
                        count:
                            pendingStudents,
                        color:
                            Colors.red,
                        icon:
                            Icons.pending,
                      ),
                    ],
                  ),

                  // ==================================================
                  // CREATED FEE STRUCTURES
                  // ==================================================

                  sectionTitle(
                    "Created Fee Structures",
                    subtitle:
                        "Fee structures created by Admin",
                  ),

                  if (feeStructures
                      .isEmpty)
                    emptyBox(
                      icon:
                          Icons
                              .account_balance_wallet_outlined,
                      message:
                          "No fee structures have been created yet.",
                    )
                  else
                    ...feeStructures
                        .where(
                          (item) =>
                              item is Map,
                        )
                        .map(
                          feeStructureCard,
                        ),

                  // ==================================================
                  // STUDENT COLLECTION
                  // ==================================================

                  sectionTitle(
                    "Student Fee Collection",
                    subtitle:
                        "Total fee, amount paid and pending amount",
                  ),

                  if (fees.isEmpty)
                    emptyBox(
                      icon:
                          Icons
                              .receipt_long_outlined,
                      message:
                          "No student fee records found.",
                    )
                  else
                    ...fees.map(
                      feeCard,
                    ),

                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
    );
  }

  // ============================================================
  // EMPTY BOX
  // ============================================================

  Widget emptyBox({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width:
          double.infinity,
      padding:
          const EdgeInsets.all(
        28,
      ),
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          16,
        ),
        border: Border.all(
          color:
              Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 46,
            color:
                Colors.grey,
          ),

          const SizedBox(
            height: 10,
          ),

          Text(
            message,
            textAlign:
                TextAlign.center,
            style:
                const TextStyle(
              color:
                  Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}