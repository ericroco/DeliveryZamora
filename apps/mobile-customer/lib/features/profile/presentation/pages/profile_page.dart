import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_customer/core/auth/auth_provider.dart';
import 'package:mobile_customer/core/auth/domain/user_profile.dart';
import 'package:mobile_customer/core/constants/app_colors.dart';
import 'package:mobile_customer/shared/widgets/app_bottom_nav.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        title: const Text(
          'Mi perfil',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _ProfileHeader(user: user),
            const SizedBox(height: 8),
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.location_on_outlined,
                  label: 'Mis direcciones',
                  onTap: () => context.push('/addresses'),
                ),
                _MenuItem(
                  icon: Icons.credit_card_outlined,
                  label: 'Métodos de pago',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.receipt_long_outlined,
                  label: 'Historial de pedidos',
                  onTap: () => context.go('/orders'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.notifications_outlined,
                  label: 'Notificaciones',
                  onTap: () => context.push('/notifications'),
                ),
                _MenuItem(
                  icon: Icons.help_outline,
                  label: 'Ayuda y soporte',
                  onTap: () {},
                ),
                _MenuItem(
                  icon: Icons.description_outlined,
                  label: 'Términos y condiciones',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 8),
            _MenuSection(
              items: [
                _MenuItem(
                  icon: Icons.logout,
                  label: 'Cerrar sesión',
                  color: AppColors.primary,
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text(
              'DeliveryZamora v1.0.0',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
    );
  }

  /// Shows a confirmation dialog before logging out.
  /// On confirm: calls AuthNotifier.logout() which clears tokens and sets
  /// authState to null — then navigates to /login explicitly (the router
  /// redirect uses ref.read so it doesn't re-run reactively on state changes).
  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          '¿Cerrar sesión?',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 17,
            color: AppColors.text,
          ),
        ),
        content: const Text(
          'Se cerrará tu sesión en este dispositivo.',
          style: TextStyle(fontSize: 14, color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: AppColors.muted,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Cerrar sesión',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Clear tokens + set authState = null
      await ref.read(authStateProvider.notifier).logout();
      // The router redirect uses ref.read (not ref.watch), so it won't
      // re-fire automatically. Navigate explicitly instead.
      if (context.mounted) {
        context.go('/login');
      }
    }
  }
}

// ── Profile header ─────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserProfile? user;

  @override
  Widget build(BuildContext context) {
    final displayName = user?.name ?? 'Usuario';
    final displayPhone = user?.phone ?? '';
    final initial = displayName[0].toUpperCase();

    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.card,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  displayPhone,
                  style: const TextStyle(fontSize: 13, color: AppColors.muted),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.defaultTagBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Cliente verificado',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/profile/edit'),
            icon: const Icon(Icons.edit_outlined, size: 18),
            color: AppColors.muted,
          ),
        ],
      ),
    );
  }
}

// ── Menu section ───────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.items});

  final List<_MenuItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.card,
      child: Column(
        children: List.generate(items.length * 2 - 1, (i) {
          if (i.isOdd) {
            return const Divider(
              height: 1,
              indent: 56,
              color: AppColors.cardBorder,
            );
          }
          return items[i ~/ 2];
        }),
      ),
    );
  }
}

// ── Menu item ──────────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: c),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: c,
                ),
              ),
            ),
            if (color == null)
              const Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}
