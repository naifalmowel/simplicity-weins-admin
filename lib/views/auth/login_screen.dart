import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../widgets/custom_snack_bar.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'admin@admin.com');
  final _passwordController = TextEditingController(text: 'admin123');
  final _pinController = TextEditingController();

  bool _isPinMode = true; // Default quick PIN mode for admin convenience
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    bool success = false;
    if (_isPinMode) {
      if (_pinController.text.trim().isEmpty) {
        CustomSnackBar.showError(context, 'الرجاء إدخال رمز PIN');
        return;
      }
      success = await authProvider.loginWithPin(_pinController.text.trim());
    } else {
      if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
        CustomSnackBar.showError(context, 'الرجاء إدخال البريد الإلكتروني وكلمة المرور');
        return;
      }
      success = await authProvider.loginWithEmail(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
    }

    if (success && mounted) {
      CustomSnackBar.showSuccess(context, 'تم تسجيل الدخول بنجاح! مرحباً بك.');
    } else if (mounted && authProvider.errorMessage != null) {
      CustomSnackBar.showError(context, authProvider.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.paper,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 440),
            padding: const EdgeInsets.all(36),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.lines, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.ink.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Brand Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: AppColors.ink,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.bronze,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  AppConstants.storeNameEn,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  AppConstants.storeNameAr,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.olive,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  AppConstants.sloganEn,
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 2,
                    color: AppColors.textMuted,
                  ),
                ),

                const SizedBox(height: 28),
                const Divider(),
                const SizedBox(height: 20),

                // Toggle Auth Mode
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _isPinMode ? AppColors.ink : Colors.transparent,
                          foregroundColor: _isPinMode ? AppColors.white : AppColors.ink,
                        ),
                        onPressed: () => setState(() => _isPinMode = true),
                        child: const Text('رمز PIN السريع'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: !_isPinMode ? AppColors.ink : Colors.transparent,
                          foregroundColor: !_isPinMode ? AppColors.white : AppColors.ink,
                        ),
                        onPressed: () => setState(() => _isPinMode = false),
                        child: const Text('بريد وكلمة مرور'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                if (_isPinMode) ...[
                  // PIN Input
                  TextField(
                    controller: _pinController,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'رمز الدخول PIN',
                      hintText: '••••••',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'الرمز الافتراضي: 1234',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                ] else ...[
                  // Email Input
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      hintText: 'admin@simplicity.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    onSubmitted: (_) => _handleLogin(),
                  ),
                ],

                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _handleLogin,
                    child: authProvider.isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Text(
                            'تسجيل الدخول إلى اللوحة',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted),
                    SizedBox(width: 4),
                    Text(
                      'التل، ريف دمشق، سوريا',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
