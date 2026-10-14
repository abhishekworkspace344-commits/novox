import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/network/api_client.dart';
import '../../models/staff_model.dart';
import '../../services/staff_service.dart';

class StaffProfileScreen extends StatefulWidget {
  const StaffProfileScreen({super.key});

  @override
  State<StaffProfileScreen> createState() =>
      _StaffProfileScreenState();
}

class _StaffProfileScreenState
    extends State<StaffProfileScreen> {
  late final StaffService staffService;

  StaffModel? staff;

  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();

    staffService = StaffService(
      ApiClient(),
    );

    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await staffService.getProfile();

      if (!mounted) return;

      setState(() {
        staff = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
        error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            onPressed: loading ? null : _loadProfile,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
              ),
              const SizedBox(height: 16),
              const Text(
                'Unable to load profile',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (staff == null) {
      return const Center(
        child: Text('Staff profile not found'),
      );
    }

    final currentStaff = staff!;

    return RefreshIndicator(
      onRefresh: _loadProfile,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _profileHeader(currentStaff),
          const SizedBox(height: 24),

          _sectionTitle('Personal Information'),

          _infoCard(
            icon: Icons.person_outline,
            title: 'Name',
            value: currentStaff.name,
          ),

          _infoCard(
            icon: Icons.email_outlined,
            title: 'Email',
            value: currentStaff.email,
          ),

          if (currentStaff.phone != null &&
              currentStaff.phone!.isNotEmpty)
            _infoCard(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: currentStaff.phone!,
            ),

          const SizedBox(height: 20),

          _sectionTitle('Employment Information'),

          _infoCard(
            icon: Icons.badge_outlined,
            title: 'Employee Code',
            value: currentStaff.employeeCode,
          ),

          _infoCard(
            icon: Icons.work_outline,
            title: 'Designation',
            value: currentStaff.designation,
          ),

          if (currentStaff.department != null &&
              currentStaff.department!.isNotEmpty)
            _infoCard(
              icon: Icons.business_outlined,
              title: 'Department',
              value: currentStaff.department!,
            ),

          if (currentStaff.joiningDate != null &&
              currentStaff.joiningDate!.isNotEmpty)
            _infoCard(
              icon: Icons.calendar_today_outlined,
              title: 'Joining Date',
              value: currentStaff.joiningDate!,
            ),

          const SizedBox(height: 20),

          _statusCard(currentStaff),
        ],
      ),
    );
  }

  Widget _profileHeader(StaffModel staff) {
    final initial = staff.name.isNotEmpty
        ? staff.name[0].toUpperCase()
        : 'S';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0A1A33),
            Color(0xFF153B69),
          ],
        ),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 42,
            backgroundColor: AppColors.primarySoft,
            child: Text(
              initial,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryLight,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            staff.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            staff.designation,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
        left: 4,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _statusCard(StaffModel staff) {
    return Card(
      child: ListTile(
        leading: Icon(
          staff.isActive
              ? Icons.check_circle
              : Icons.cancel,
          color: staff.isActive
              ? Colors.green
              : Colors.red,
        ),
        title: const Text('Account Status'),
        subtitle: Text(
          staff.isActive
              ? 'Active'
              : 'Inactive',
        ),
      ),
    );
  }
}
