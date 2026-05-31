import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/features/auth/presentation/pages/login_page.dart';
import 'package:mobile_customer/features/auth/presentation/pages/otp_page.dart';
import 'package:mobile_customer/features/cart/presentation/pages/cart_page.dart';
import 'package:mobile_customer/features/checkout/presentation/pages/checkout_page.dart';
import 'package:mobile_customer/features/home/presentation/pages/home_page.dart';
import 'package:mobile_customer/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:mobile_customer/features/orders/presentation/pages/order_tracking_page.dart';
import 'package:mobile_customer/features/orders/presentation/pages/orders_page.dart';
import 'package:mobile_customer/features/profile/presentation/pages/profile_page.dart';
import 'package:mobile_customer/features/splash/presentation/pages/splash_page.dart';
import 'package:mobile_customer/features/store_detail/presentation/pages/store_detail_page.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (_, __) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginPage(),
      routes: [
        GoRoute(
          path: 'otp',
          builder: (_, state) {
            final phone = state.extra as String? ?? '';
            return OtpPage(phone: phone);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/',
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: '/search',
      builder: (_, __) => const HomePage(),
    ),
    GoRoute(
      path: '/store/:id',
      pageBuilder: (_, state) => _slidePage(
        state,
        StoreDetailPage(storeId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/cart',
      pageBuilder: (_, state) => _slidePage(state, const CartPage()),
    ),
    GoRoute(
      path: '/checkout',
      pageBuilder: (_, state) => _slidePage(state, const CheckoutPage()),
    ),
    GoRoute(
      path: '/orders',
      builder: (_, __) => const OrdersPage(),
    ),
    GoRoute(
      path: '/orders/tracking/:id',
      pageBuilder: (_, state) => _slidePage(
        state,
        OrderTrackingPage(orderId: state.pathParameters['id']!),
      ),
    ),
    GoRoute(
      path: '/profile',
      builder: (_, __) => const ProfilePage(),
    ),
  ],
);

CustomTransitionPage<void> _slidePage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.06, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));

      final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);

      return FadeTransition(
        opacity: fade,
        child: SlideTransition(position: slide, child: child),
      );
    },
  );
}
