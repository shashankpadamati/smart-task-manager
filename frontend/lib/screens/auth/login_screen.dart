import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggle;
  const LoginScreen({super.key, required this.onToggle});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.surface,
              theme.colorScheme.primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: screenWidth > 500 ? 420 : screenWidth * 0.9,
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color:
                          theme.colorScheme.outline.withValues(alpha: 0.1)),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.08),
                      blurRadius: 40,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo / Brand
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.primary
                                  .withValues(alpha: 0.7),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.task_alt_rounded,
                            size: 40, color: Colors.white),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Welcome Back',
                        style: GoogleFonts.inter(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Sign in to manage your tasks',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Error
                      if (auth.error != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: Colors.red.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.red, size: 18),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.error!,
                                  style: const TextStyle(
                                      color: Colors.red, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Email
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputDeco(theme, 'Email address',
                            Icons.email_rounded),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Password
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscure,
                        decoration: _inputDeco(
                                theme, 'Password', Icons.lock_rounded)
                            .copyWith(
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              size: 20,
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.4),
                            ),
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                          ),
                        ),
                        validator: (v) => v == null || v.length < 6
                            ? 'Password must be at least 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 28),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: FilledButton(
                          onPressed: auth.loading ? null : _login,
                          style: FilledButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          child: auth.loading
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white))
                              : const Text('Sign In',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sign up link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? ",
                              style: TextStyle(
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.5))),
                          GestureDetector(
                            onTap: widget.onToggle,
                            child: Text(
                              'Sign Up',
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
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
        ),
      ),
    );
  }

  InputDecoration _inputDeco(ThemeData theme, String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
      prefixIcon:
          Icon(icon, size: 20, color: theme.colorScheme.primary),
      filled: true,
      fillColor: theme.colorScheme.surface.withValues(alpha: 0.6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
            BorderSide(color: theme.colorScheme.primary, width: 1.5),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthProvider>().clearError();
    await context
        .read<AuthProvider>()
        .login(_emailCtrl.text.trim(), _passCtrl.text);
  }
}
