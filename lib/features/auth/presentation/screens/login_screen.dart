import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref
          .read(authProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text.trim());

      if (success && mounted) {
        // Navigation is handled in main.dart
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Cinematic Dark Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF0A0E21), // MATCHING DASHBOARD NAVY
            ),
          ),
          // Subtle radial glows for depth
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.deepPurple.withOpacity(0.15),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: const SizedBox.shrink(),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Brand Identity
                    const Icon(
                      Icons.bolt_rounded,
                      color: Colors.white,
                      size: 64,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'BOLT',
                      style: GoogleFonts.poppins(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'PREMIUM E-COMMERCE',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withOpacity(0.4),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 80),

                    // Simplified Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildMinimalTextField(
                            controller: _emailController,
                            label: 'EMAIL ADDRESS',
                            icon: Icons.alternate_email_rounded,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Invalid Email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          _buildMinimalTextField(
                            controller: _passwordController,
                            label: 'PASSWORD',
                            icon: Icons.lock_outline_rounded,
                            obscureText: !_isPasswordVisible,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: Colors.white.withOpacity(0.4),
                                size: 20,
                              ),
                              onPressed: () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty)
                                return 'Required';
                              if (value.length < 6) return 'Too short';
                              return null;
                            },
                          ),

                          if (authState.errorMessage != null) ...[
                            const SizedBox(height: 24),
                            Text(
                              authState.errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],

                          const SizedBox(height: 56),

                          // Aesthetic Login Button
                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton(
                              onPressed: authState.isLoading ? null : _login,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: const Color(0xFF0A0E21),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: authState.isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF0A0E21),
                                      ),
                                    )
                                  : Text(
                                      'SIGN IN',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 2,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "CREATE ACCOUNT",
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white.withOpacity(0.6),
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: Colors.white.withOpacity(0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
          cursorColor: Colors.white,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            prefixIcon: Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 20,
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 40),
            suffixIcon: suffixIcon,
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            errorBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent.withOpacity(0.5)),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ),
      ],
    );
  }
}
