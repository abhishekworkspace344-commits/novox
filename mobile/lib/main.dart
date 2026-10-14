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
      theme: AppTheme.darkTheme,
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A1830),
                  Color(0xFF050B18),
                  Color(0xFF071329),
                ],
              ),
            ),
          ),
          Positioned(
            top: -190,
            right: -150,
            child: _ambientGlow(460, const Color(0x553B82F6)),
          ),
          Positioned(
            bottom: -250,
            left: -150,
            child: _ambientGlow(560, const Color(0x4424B8E6)),
          ),
          if (child != null)
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: child,
              ),
            ),
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

  Widget _ambientGlow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.2), Colors.transparent],
          stops: const [0, 0.58, 1],
        ),
      ),
    );
  }
}
