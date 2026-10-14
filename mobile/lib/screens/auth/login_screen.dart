import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../../core/network/api_error.dart';
import '../../core/theme/app_theme.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // =========================================================
  // CONTROLLERS
  // =========================================================

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  // =========================================================
  // STATE
  // =========================================================

  bool loading = false;
  bool obscurePassword = true;
  String? selectedRole;

  // =========================================================
  // DISPOSE
  // =========================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // =========================================================
  // FILL DEMO CREDENTIALS
  // =========================================================

  void _fillDemoCredentials(
    String role,
    String email,
    String password,
  ) {
    if (!mounted) return;

    setState(() {
      selectedRole = role;
      emailController.text = email;
      passwordController.text = password;
    });
  }

  // =========================================================
  // LOGIN
  // =========================================================

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // ---------------------------------------------------------
    // VALIDATION
    // ---------------------------------------------------------

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter both email and password",
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    if (loading) {
      return;
    }

    // ---------------------------------------------------------
    // START LOADING
    // ---------------------------------------------------------

    setState(() {
      loading = true;
    });

    try {
      // -------------------------------------------------------
      // CREATE API CLIENT
      // -------------------------------------------------------

      final apiClient = ApiClient();

      // -------------------------------------------------------
      // DEBUG INFORMATION
      // -------------------------------------------------------

      final baseUrl = apiClient.dio.options.baseUrl;
      final loginEndpoint = ApiConstants.login;
      final fullUrl = "$baseUrl$loginEndpoint";

      debugPrint(
        "==================================================",
      );
      debugPrint(
        "NOVOX LOGIN START",
      );
      debugPrint(
        "==================================================",
      );
      debugPrint(
        "BASE URL: $baseUrl",
      );
      debugPrint(
        "LOGIN ENDPOINT: $loginEndpoint",
      );
      debugPrint(
        "FULL LOGIN URL: $fullUrl",
      );
      debugPrint(
        "EMAIL: $email",
      );
      debugPrint(
        "==================================================",
      );

      // -------------------------------------------------------
      // AUTH SERVICE
      // -------------------------------------------------------

      final authService = AuthService(apiClient);

      // -------------------------------------------------------
      // LOGIN REQUEST
      // -------------------------------------------------------

      final user = await authService.login(
        email,
        password,
      );

      // -------------------------------------------------------
      // LOGIN SUCCESS
      // -------------------------------------------------------

      debugPrint(
        "==================================================",
      );
      debugPrint(
        "NOVOX LOGIN SUCCESS",
      );
      debugPrint(
        "==================================================",
      );
      debugPrint(
        "USER ID: ${user.userId}",
      );
      debugPrint(
        "USER NAME: ${user.name}",
      );
      debugPrint(
        "USER ROLE: ${user.role}",
      );
      debugPrint(
        "TOKEN TYPE: ${user.tokenType}",
      );
      debugPrint(
        "==================================================",
      );

      if (!mounted) {
        return;
      }

      // -------------------------------------------------------
      // ROLE NAVIGATION
      // -------------------------------------------------------

      final role = user.role.toLowerCase().trim();

      if (role == "student") {
        Navigator.pushReplacementNamed(
          context,
          "/student",
        );
      } else if (role == "staff") {
        Navigator.pushReplacementNamed(
          context,
          "/staff",
        );
      } else if (role == "admin") {
        Navigator.pushReplacementNamed(
          context,
          "/admin",
        );
      } else {
        debugPrint(
          "UNKNOWN USER ROLE: ${user.role}",
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Unrecognized user role: ${user.role}",
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e, stackTrace) {
      // -------------------------------------------------------
      // LOGIN ERROR
      // -------------------------------------------------------

      debugPrint(
        "==================================================",
      );
      debugPrint(
        "NOVOX LOGIN ERROR",
      );
      debugPrint(
        "==================================================",
      );
      debugPrint(
        "ERROR TYPE: ${e.runtimeType}",
      );
      debugPrint(
        "ERROR: $e",
      );
      debugPrint(
        "STACK TRACE:",
      );
      debugPrint(
        "$stackTrace",
      );
      debugPrint(
        "==================================================",
      );

      if (!mounted) {
        return;
      }

      String message;

      try {
        message = ApiError.message(e);
      } catch (_) {
        message = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Login failed: $message",
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(
            seconds: 5,
          ),
        ),
      );
    } finally {
      // -------------------------------------------------------
      // STOP LOADING
      // -------------------------------------------------------

      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  // =========================================================
  // ROLE CHIP
  // =========================================================

  Widget _roleChip({
    required String label,
    required String role,
    required String email,
    required String pass,
    required IconData icon,
  }) {
    final isSelected = selectedRole == role;

    return InkWell(
      onTap: () {
        _fillDemoCredentials(
          role,
          email,
          pass,
        );
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 4,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0x553B82F6)
              : const Color(0x14FFFFFF),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xAA69C5FF)
                : const Color(0x33FFFFFF),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? const Color(0xFFB8E5FF)
                  : const Color(0xFFB7C9E6),
            ),
            const SizedBox(
              height: 4,
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected
                    ? FontWeight.w700
                    : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFB8E5FF)
                    : const Color(0xFFB7C9E6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _glassInputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: const Color(0x1EFFFFFF),
      labelStyle: const TextStyle(color: Color(0xFFB7C9E6)),
      hintStyle: const TextStyle(color: Color(0x889CB1D2)),
      prefixIcon: Icon(icon, color: const Color(0xFF72C9FF), size: 20),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x44C9E6FF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF58BDF8), width: 1.6),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0x228CA7D9)),
      ),
    );
  }

  Widget _backgroundOrb(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0.24), Colors.transparent],
          stops: const [0, 0.58, 1],
        ),
      ),
    );
  }

  // =========================================================
  // BUILD
  // =========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050B18),
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF09172D),
                  Color(0xFF07101F),
                  Color(0xFF020711),
                ],
              ),
            ),
          ),
          // Soft blue glass orbs replace the old full-screen artwork.
          Positioned(
            top: -145,
            left: -110,
            child: _backgroundOrb(420, const Color(0xAA1769DC)),
          ),
          Positioned(
            top: 70,
            right: -150,
            child: _backgroundOrb(450, const Color(0x8833B8F2)),
          ),
          Positioned(
            bottom: -220,
            left: MediaQuery.sizeOf(context).width * 0.12,
            child: _backgroundOrb(560, const Color(0x773B5BFF)),
          ),
          Positioned(
            top: -100,
            right: MediaQuery.sizeOf(context).width * 0.28,
            child: Transform.rotate(
              angle: -0.48,
              child: Container(
                width: 150,
                height: 520,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(100),
                  gradient: const LinearGradient(
                    colors: [Color(0x001B78E8), Color(0x4437B7FF), Color(0x001B78E8)],
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 20,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 440,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // =================================================
                  // LOGO / BRANDING
                  // =================================================

                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.28,
                          ),
                          blurRadius: 18,
                          offset: const Offset(
                            0,
                            8,
                          ),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      size: 42,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  // =================================================
                  // NOVOX TITLE
                  // =================================================

                  const Text(
                    "NOVOX",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  const Text(
                    "Education Management",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFB9C8E0),
                      letterSpacing: 0.3,
                    ),
                  ),

                  const SizedBox(
                    height: 32,
                  ),

                  // =================================================
                  // LOGIN CARD
                  // =================================================

                  ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
                      child: Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xCC142746),
                              Color(0xB3091A32),
                              Color(0xCC0A1427),
                            ],
                            stops: [0, 0.42, 1],
                          ),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: const Color(0x668FCEFF),
                            width: 1.3,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xAA020610),
                              blurRadius: 52,
                              offset: Offset(0, 20),
                            ),
                            BoxShadow(
                              color: Color(0x443AAFFF),
                              blurRadius: 42,
                              spreadRadius: -10,
                            ),
                            BoxShadow(
                              color: Color(0x338FD7FF),
                              blurRadius: 1,
                              spreadRadius: 0,
                              offset: Offset(0, -1),
                            ),
                          ],
                        ),
                        child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // =================================================
                        // WELCOME
                        // =================================================

                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0x223D91E8),
                            border: Border.all(color: const Color(0x447DC9FF)),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.verified_user_outlined,
                                color: const Color(0xFF80D6FF),
                                size: 15,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'SECURE INSTITUTION PORTAL',
                                style: TextStyle(
                                  color: const Color(0xFFB9E8FF),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.65,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          "Welcome Back",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.55,
                          ),
                        ),

                        const SizedBox(
                          height: 6,
                        ),

                        const Text(
                          "Sign in to your institutional account",
                          style: TextStyle(
                            fontSize: 13,
                            color: const Color(0xFFB7C9E6),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        // =================================================
                        // EMAIL
                        // =================================================

                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType:
                              TextInputType.emailAddress,
                          textInputAction:
                              TextInputAction.next,
                          enabled: !loading,
                          decoration: _glassInputDecoration(
                            label: "Email",
                            hint: "user@novox.com",
                            icon: Icons.email_outlined,
                          ),
                        ),

                        const SizedBox(
                          height: 18,
                        ),

                        // =================================================
                        // PASSWORD
                        // =================================================

                        TextField(
                          controller:
                              passwordController,
                          style: const TextStyle(color: Colors.white),
                          obscureText:
                              obscurePassword,
                          enabled: !loading,
                          textInputAction:
                              TextInputAction.done,
                          onSubmitted: (_) {
                            if (!loading) {
                              login();
                            }
                          },
                          decoration: _glassInputDecoration(
                            label: "Password",
                            hint: "••••••••",
                            icon: Icons.lock_outline_rounded,
                            suffix: IconButton(
                              icon: Icon(
                                obscurePassword
                                    ? Icons
                                        .visibility_outlined
                                    : Icons
                                        .visibility_off_outlined,
                                color: const Color(0xFFB7C9E6),
                                size: 20,
                              ),
                              onPressed: loading
                                  ? null
                                  : () {
                                      setState(() {
                                        obscurePassword =
                                            !obscurePassword;
                                      });
                                    },
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 26,
                        ),

                        // =================================================
                        // LOGIN BUTTON
                        // =================================================

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: loading
                                  ? null
                                  : AppColors
                                      .heroGradient,
                              borderRadius:
                                  BorderRadius.circular(
                                14,
                              ),
                              boxShadow: loading
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppColors
                                            .primary
                                            .withValues(
                                          alpha: 0.32,
                                        ),
                                        blurRadius: 14,
                                        offset:
                                            const Offset(
                                          0,
                                          5,
                                        ),
                                      ),
                                    ],
                            ),
                            child: ElevatedButton(
                              onPressed:
                                  loading
                                      ? null
                                      : login,
                              style: ElevatedButton
                                  .styleFrom(
                                backgroundColor:
                                    loading
                                        ? Colors.grey
                                            .shade300
                                        : Colors
                                            .transparent,
                                shadowColor:
                                    Colors.transparent,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    14,
                                  ),
                                ),
                              ),
                              child: loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        strokeWidth:
                                            2.5,
                                        color: AppColors
                                            .primary,
                                      ),
                                    )
                                  : const Text(
                                      "LOGIN",
                                      style:
                                          TextStyle(
                                        fontSize: 16,
                                        fontWeight:
                                            FontWeight
                                                .w700,
                                        color: Colors
                                            .white,
                                        letterSpacing:
                                            1.0,
                                      ),
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 28,
                        ),

                        // =================================================
                        // DEMO ACCOUNTS DIVIDER
                        // =================================================

                        Row(
                          children: const [
                            Expanded(
                              child: Divider(color: Color(0x338CA3CB)),
                            ),
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: Text(
                                "DEMO ACCOUNTS",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      FontWeight.w700,
                                  color: Color(0xFF9DB1D0),
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(color: Color(0x338CA3CB)),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 14,
                        ),

                        // =================================================
                        // DEMO ROLE BUTTONS
                        // =================================================

                        Row(
                          children: [
                            Expanded(
                              child: _roleChip(
                                label: "Admin",
                                role: "admin",
                                email:
                                    "admin@novox.com",
                                pass:
                                    "Admin@123",
                                icon: Icons
                                    .admin_panel_settings_outlined,
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Expanded(
                              child: _roleChip(
                                label: "Staff",
                                role: "staff",
                                email:
                                    "staff@novox.com",
                                pass:
                                    "Staff@123",
                                icon: Icons
                                    .badge_outlined,
                              ),
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Expanded(
                              child: _roleChip(
                                label: "Student",
                                role: "student",
                                email:
                                    "student@novox.com",
                                pass:
                                    "Student@123",
                                icon: Icons
                                    .school_outlined,
                              ),
                            ),
                          ],
                        ),
                      ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 28,
                  ),

                  // =================================================
                  // SECURITY BADGE
                  // =================================================

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: Color(0xFF9DB1D0),
                      ),
                      SizedBox(
                        width: 6,
                      ),
                      Flexible(
                        child: Text(
                          "Enterprise Edition • 256-Bit SSL",
                          overflow:
                              TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Color(0xFF9DB1D0),
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
          ),
        ],
      ),
    );
  }
}
