import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../services/report_service.dart';

class AdminLateEntryReportScreen extends StatefulWidget {
  const AdminLateEntryReportScreen({
    super.key,
  });

  @override
  State<AdminLateEntryReportScreen> createState() =>
      _AdminLateEntryReportScreenState();
}

class _AdminLateEntryReportScreenState
    extends State<AdminLateEntryReportScreen> {
  // ============================================================
  // SERVICE
  // ============================================================

  late final ReportService reportService;

  // ============================================================
  // DATA
  // ============================================================

  List<dynamic> records = [];

  DateTime? startDate;
  DateTime? endDate;

  // ============================================================
  // STATE
  // ============================================================

  bool loading = false;

  @override
  void initState() {
    super.initState();

    reportService = ReportService(
      ApiClient(),
    );

    loadReport();
  }

  // ============================================================
  // DATE FORMAT
  // ============================================================

  String formatDate(
    DateTime date,
  ) {
    return "${date.year.toString().padLeft(4, '0')}-"
        "${date.month.toString().padLeft(2, '0')}-"
        "${date.day.toString().padLeft(2, '0')}";
  }

  // ============================================================
  // LOAD REPORT
  // ============================================================

  Future<void> loadReport() async {
    if (!mounted) return;

    setState(() {
      loading = true;
    });

    try {
      final data =
          await reportService.getLateEntryReport(
        startDate: startDate == null
            ? null
            : formatDate(startDate!),
        endDate: endDate == null
            ? null
            : formatDate(endDate!),
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

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load late-entry report: $e",
          ),
        ),
      );
    }
  }

  // ============================================================
  // START DATE
  // ============================================================

  Future<void> selectStartDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      startDate = selected;
    });

    await loadReport();
  }

  // ============================================================
  // END DATE
  // ============================================================

  Future<void> selectEndDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate:
          endDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected == null) return;

    setState(() {
      endDate = selected;
    });

    await loadReport();
  }

  // ============================================================
  // CLEAR FILTERS
  // ============================================================

  Future<void> clearFilters() async {
    setState(() {
      startDate = null;
      endDate = null;
    });

    await loadReport();
  }

  // ============================================================
  // DISPLAY DATE
  // ============================================================

  String displayDate(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return "-";
    }

    final date =
        DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  // ============================================================
  // DISPLAY TIME
  // ============================================================

  String displayTime(
    String? value,
  ) {
    if (value == null ||
        value.isEmpty) {
      return "-";
    }

    final date =
        DateTime.tryParse(value);

    if (date == null) {
      return value;
    }

    return "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  // ============================================================
  // LATE CARD
  // ============================================================

  Widget lateCard(
    Map<String, dynamic> item,
  ) {
    final name =
        item["user_name"]?.toString() ??
            "-";

    final date =
        item["attendance_date"]?.toString();

    final checkIn =
        item["check_in"]?.toString();

    final arrivalStatus =
        item["arrival_status"]
                ?.toString() ??
            "LATE";

    final distance =
        item["check_in_distance"];

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 2,
      child: Padding(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------
            // HEADER
            // --------------------------------------------------

            Row(
              children: [
                const CircleAvatar(
                  child: Icon(
                    Icons.access_time,
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
                        name,
                        style:
                            const TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 3,
                      ),

                      Text(
                        displayDate(date),
                        style: TextStyle(
                          color: Colors
                              .grey
                              .shade600,
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
                    color:
                        Colors.orange
                            .shade100,
                    borderRadius:
                        BorderRadius
                            .circular(
                      20,
                    ),
                  ),
                  child: Text(
                    arrivalStatus
                        .replaceAll(
                      "_",
                      " ",
                    ),
                    style: TextStyle(
                      color:
                          Colors.orange
                              .shade800,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(
              height: 28,
            ),

            // --------------------------------------------------
            // CHECK-IN
            // --------------------------------------------------

            _infoRow(
              Icons.login,
              "Check-in",
              displayTime(checkIn),
            ),

            // --------------------------------------------------
            // DISTANCE
            // --------------------------------------------------

            if (distance != null)
              _infoRow(
                Icons.location_on,
                "Campus Distance",
                "${distance.toString()} m",
              ),

            // --------------------------------------------------
            // DATE
            // --------------------------------------------------

            _infoRow(
              Icons.calendar_month,
              "Date",
              displayDate(date),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION ROW
  // ============================================================

  Widget _infoRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color:
                AppColors.textMuted,
          ),

          const SizedBox(
            width: 10,
          ),

          Text(
            "$title: ",
            style:
                const TextStyle(
              fontWeight:
                  FontWeight.w500,
            ),
          ),

          Expanded(
            child: Text(
              value,
              style:
                  const TextStyle(
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
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
    final hasFilters =
        startDate != null ||
            endDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Late Entry Report",
        ),

        actions: [
          if (hasFilters)
            IconButton(
              tooltip:
                  "Clear Filters",
              icon: const Icon(
                Icons.filter_alt_off,
              ),
              onPressed:
                  clearFilters,
            ),

          IconButton(
            tooltip: "Refresh",
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed:
                loadReport,
          ),
        ],
      ),

      body: Column(
        children: [
          // ====================================================
          // DATE FILTERS
          // ====================================================

          Padding(
            padding:
                const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        selectStartDate,
                    icon:
                        const Icon(
                      Icons.calendar_month,
                    ),
                    label: Text(
                      startDate == null
                          ? "Start Date"
                          : formatDate(
                              startDate!,
                            ),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 8,
                ),

                Expanded(
                  child:
                      OutlinedButton.icon(
                    onPressed:
                        selectEndDate,
                    icon:
                        const Icon(
                      Icons.calendar_month,
                    ),
                    label: Text(
                      endDate == null
                          ? "End Date"
                          : formatDate(
                              endDate!,
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ====================================================
          // LOADING
          // ====================================================

          if (loading)
            const LinearProgressIndicator(),

          // ====================================================
          // RECORDS
          // ====================================================

          Expanded(
            child: records.isEmpty &&
                    !loading
                ? RefreshIndicator(
                    onRefresh:
                        loadReport,
                    child: ListView(
                      physics:
                          const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(
                          height: 180,
                        ),
                        Center(
                          child: Text(
                            "No late entries found",
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh:
                        loadReport,
                    child:
                        ListView.builder(
                      padding:
                          const EdgeInsets
                              .all(12),
                      itemCount:
                          records.length,
                      itemBuilder:
                          (context, index) {
                        return lateCard(
                          Map<String,
                              dynamic>.from(
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
