import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/student/student_dashboard.dart';
import 'screens/staff/staff_dashboard.dart';
import 'screens/admin/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const NovoxApp(),
  );
}

class NovoxApp extends StatelessWidget {
  const NovoxApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "NOVOX",
      theme: AppTheme.lightTheme,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/novox_page_background.png',
            fit: BoxFit.cover,
          ),
          const ColoredBox(color: Color(0xDDF4F6FB)),
          ?child,
        ],
      ),
      initialRoute: "/login",
      routes: {
        "/login": (_) => const LoginScreen(),
        "/student": (_) => const StudentDashboard(),
        "/staff": (_) => const StaffDashboard(),
        "/admin": (_) => const AdminDashboard(),
      },
    );
  }
}
