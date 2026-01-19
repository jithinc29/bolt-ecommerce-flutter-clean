import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_sqlite_clean/features/auth/presentation/providers/auth_provider.dart';
import 'dart:math' as math;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;
  late Animation<double> _letterSpacing;
  late Animation<double> _bgAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.7, curve: Curves.elasticOut),
      ),
    );

    _letterSpacing = Tween<double>(begin: 20.0, end: 6.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
      ),
    );

    _bgAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();
    _checkAuthState();
  }

  Future<void> _checkAuthState() async {
    await Future.delayed(const Duration(milliseconds: 3500));
    if (mounted) {
      ref.read(isSplashDoneProvider.notifier).state = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21), // Deep aesthetic navy
      body: Stack(
        children: [
          // Background Geometric Animations
          AnimatedBuilder(
            animation: _bgAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  _buildAnimatedCircle(
                    top: -50 - (20 * _bgAnimation.value),
                    right: -50 - (20 * _bgAnimation.value),
                    size: 250,
                    color: Colors.deepPurple.withOpacity(0.15),
                  ),
                  _buildAnimatedCircle(
                    bottom: 100 + (30 * _bgAnimation.value),
                    left: -80 - (10 * _bgAnimation.value),
                    size: 300,
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                  ),
                ],
              );
            },
          ),

          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoFade.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minimalist Shimmering Logo
                        Container(
                          height: 120,
                          width: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Inner Glow
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withOpacity(0.3),
                                      blurRadius: 30,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.bolt_rounded, // Premium tech/fast vibe
                                size: 60,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                        // Typographic Title with Expanding Letter Spacing
                        Text(
                          'ESTORE',
                          style: GoogleFonts.outfit(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: _letterSpacing.value,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subtitle
                        Text(
                          'DEFINING MODERN COMMERCE',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w300,
                            color: Colors.white.withOpacity(0.5),
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Bottom Loading Indicator (Minimalist)
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 30,
                height: 2,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCircle({
    double? top,
    double? bottom,
    double? left,
    double? right,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
