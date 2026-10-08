import 'package:flutter/material.dart';

import '../../core/network/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../models/attendance_model.dart';
import '../../models/staff_model.dart';
import '../../services/attendance_service.dart';
import '../../services/staff_service.dart';
import '../../widgets/status_badge.dart';

import 'staff_attendance.dart';
import 'staff_profile.dart';
import 'staff_salary.dart';

class StaffDashboard extends StatefulWidget {
  const StaffDashboard({
    super.key,
  });

  @override
  State<StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<StaffDashboard> {
  late final StaffService staffService;
  late final AttendanceService attendanceService;

  StaffModel? staff;
  AttendanceModel? todayAttendance;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    final apiClient = ApiClient();
    staffService = StaffService(apiClient);
    attendanceService = AttendanceService(apiClient);
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    if (!mounted) return;
    setState(() {
      loading = true;
    });

    try {
      final profile = await staffService.getProfile();
      final attendance = await attendanceService.getToday();

      if (!mounted) return;
      setState(() {
        staff = profile;
        todayAttendance = attendance;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      showMessage("Failed to load dashboard: $e");
    }
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

  Future<void> handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to sign out of NOVOX Staff?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await SecureStorage.clear();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  void openAttendance() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StaffAttendanceScreen(),
      ),
    );
  }

  void openSalary() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StaffSalaryScreen(),
      ),
    );
  }

  void openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const StaffProfileScreen(),
      ),
    );
  }

  Widget buildHeader() {
    final name = staff?.name ?? "Staff Member";
    final designation = staff?.designation ?? "Faculty";
    final employeeCode = staff?.employeeCode ?? "NOVOX-STF";
    final department = staff?.department ?? "";

    final firstLetter = name.isNotEmpty ? name[0].toUpperCase() : "S";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.heroGradient,
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
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Text(
              firstLetter,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        employeeCode,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  department.isNotEmpty ? "$designation • $department" : designation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTodayAttendance() {
    final status = todayAttendance?.attendanceStatus ?? "NOT_MARKED";

    return Container(
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
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
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primarySoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Today's Attendance",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              StatusBadge(status: status),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              buildAttendanceInfo(
                "Check-in",
                todayAttendance?.checkIn ?? "-",
                Icons.login_rounded,
                AppColors.primary,
              ),
              buildAttendanceInfo(
                "Checkout",
                todayAttendance?.checkout ?? "-",
                Icons.logout_rounded,
                const Color(0xFF0284C7),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              buildAttendanceInfo(
                "Break Time",
                "${todayAttendance?.totalBreakMinutes ?? 0} min",
                Icons.coffee_rounded,
                AppColors.warning,
              ),
              buildAttendanceInfo(
                "Working Time",
                todayAttendance?.totalWorkMinutes != null
                    ? "${todayAttendance!.totalWorkMinutes} min"
                    : "-",
                Icons.schedule_rounded,
                AppColors.success,
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: openAttendance,
              icon: const Icon(Icons.history_rounded, size: 18),
              label: const Text("View Attendance History"),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAttendanceInfo(
    String title,
    String value,
    IconData icon,
    Color iconColor,
  ) {
    return Expanded(
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              size: 18,
              color: iconColor,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cardBorder,
          width: 1,
        ),
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
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: iconColor.withValues(alpha: 0.10),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("NOVOX Staff"),
        actions: [
          IconButton(
            tooltip: "Refresh",
            onPressed: loadDashboard,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: "Logout",
            icon: const Icon(Icons.logout_rounded),
            color: AppColors.danger,
            onPressed: handleLogout,
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: loadDashboard,
              color: AppColors.primary,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  buildHeader(),
                  buildTodayAttendance(),
                  const SizedBox(height: 24),
                  const Text(
                    "Quick Access",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  buildMenuCard(
                    title: "My Profile",
                    subtitle: "View personal, institutional & contact details",
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    onTap: openProfile,
                  ),
                  buildMenuCard(
                    title: "Attendance History",
                    subtitle: "Review monthly timeline, check-in & breaks",
                    icon: Icons.calendar_month_outlined,
                    iconColor: const Color(0xFF0284C7),
                    onTap: openAttendance,
                  ),
                  buildMenuCard(
                    title: "Salary Slips",
                    subtitle: "Monthly payroll slips, allowances & deductions",
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: const Color(0xFF0D9488),
                    onTap: openSalary,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}