import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/core/auth/auth_provider.dart';
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
import 'package:mobile_customer/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:mobile_customer/features/addresses/presentation/screens/addresses_screen.dart';
import 'package:mobile_customer/features/addresses/presentation/screens/add_edit_address_screen.dart';
import 'package:mobile_customer/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:mobile_customer/features/addresses/domain/entities/address_entity.dart';

final _publicRoutes = {'/splash', '/onboarding', '/login'};

GoRouter buildRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final location = state.matchedLocation;

      if (authState.isLoading) return null;

      final isAuthenticated = authState.value != null;
      final isPublic = _publicRoutes.any((r) => location.startsWith(r));

      if (!isAuthenticated && !isPublic) return '/login';
      if (isAuthenticated && (location == '/login' || location == '/onboarding')) {
        return '/';
      }
      return null;
    },
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
      GoRoute(
        path: '/profile/edit',
        pageBuilder: (_, state) => _slidePage(state, const EditProfileScreen()),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (_, state) => _slidePage(state, const NotificationsScreen()),
      ),
      GoRoute(
        path: '/addresses',
        pageBuilder: (_, state) => _slidePage(state, const AddressesScreen()),
      ),
      GoRoute(
        path: '/addresses/add',
        pageBuilder: (_, state) {
          final address = state.extra as AddressEntity?;
          return _slidePage(state, AddEditAddressScreen(addressToEdit: address));
        },
      ),
    ],
  );
}

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
