import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/screens/dashboard_screen.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/screens/splash_screen.dart';
import 'package:ecommerce_sqlite_clean/features/auth/presentation/providers/auth_provider.dart';
import 'package:ecommerce_sqlite_clean/features/auth/presentation/screens/login_screen.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final isSplashDone = ref.watch(isSplashDoneProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ecommerce App',
      theme: ThemeData(
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
          primary: Colors.deepPurple,
          secondary: Colors.tealAccent,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.black87),
          titleTextStyle: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      home: _getHomeWidget(authState, isSplashDone),
    );
  }

  Widget _getHomeWidget(AuthState authState, bool isSplashDone) {
    if (!isSplashDone) {
      return const SplashScreen();
    }

    if (!authState.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (authState.isAuthenticated) {
      return const DashboardScreen();
    } else {
      return const LoginScreen();
    }
  }
}
