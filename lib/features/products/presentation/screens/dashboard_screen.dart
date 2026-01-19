import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ecommerce_sqlite_clean/features/products/presentation/screens/products_list_screen.dart';
import 'package:ecommerce_sqlite_clean/features/cart/presentation/screens/cart_screen.dart';
import 'package:ecommerce_sqlite_clean/features/auth/presentation/screens/profile_screen.dart';
import 'package:ecommerce_sqlite_clean/features/cart/presentation/providers/cart_provider.dart';

final dashboardIndexProvider = StateProvider<int>((ref) => 0);

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(dashboardIndexProvider);

    final List<Widget> screens = [
      const ProductsListScreen(),
      const CartScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: _buildBottomNavBar(context, ref, currentIndex),
    );
  }

  Widget _buildBottomNavBar(
    BuildContext context,
    WidgetRef ref,
    int currentIndex,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFF0A0E21), // CINEMATIC DARK NAVY FOR CONTRAST
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              context,
              ref,
              0,
              Icons.grid_view_rounded,
              'Shop',
              currentIndex,
            ),
            _buildNavItem(
              context,
              ref,
              1,
              Icons.shopping_cart_outlined,
              'Cart',
              currentIndex,
              isCart: true,
            ),
            _buildNavItem(
              context,
              ref,
              2,
              Icons.person_outline_rounded,
              'Profile',
              currentIndex,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    WidgetRef ref,
    int index,
    IconData icon,
    String label,
    int currentIndex, {
    bool isCart = false,
  }) {
    final isSelected = currentIndex == index;
    // White/Gold theme for dark nav bar
    final activeColor = Colors.white;
    final inactiveColor = Colors.white.withOpacity(0.4);
    final color = isSelected ? activeColor : inactiveColor;

    return GestureDetector(
      onTap: () => ref.read(dashboardIndexProvider.notifier).state = index,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, color: color, size: 28),
              if (isCart)
                Consumer(
                  builder: (context, ref, child) {
                    final cartCount = ref.watch(
                      cartProvider.select((s) => s.totalItems),
                    );
                    if (cartCount == 0) return const SizedBox.shrink();
                    return Positioned(
                      top: -4,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.redAccent,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$cartCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
          const SizedBox(height: 4),
          if (isSelected)
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            )
          else
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
