import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../shared/widgets/common_widgets.dart';
import '../../state/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chiqish'),
        content: const Text('Hisobingizdan chiqishni xohlaysizmi?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Bekor qilish')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Chiqish', style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (confirmed == true) await ref.read(authProvider.notifier).logout();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('profile_title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.mango.withOpacity(0.12),
                backgroundImage: user?.avatarUrl != null ? CachedNetworkImageProvider(user!.avatarUrl!) : null,
                child: user?.avatarUrl == null ? const Icon(Icons.person_rounded, color: AppColors.mango, size: 32) : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? '', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 2),
                    Text(user?.phoneNumber ?? user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.mango, AppColors.mangoDark]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr('bonus_balance'), style: const TextStyle(color: Colors.white70)),
                    const SizedBox(height: 4),
                    Text(formatSum(user?.bonusBalance ?? 0),
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
                  ],
                ),
                const Icon(Icons.stars_rounded, color: Colors.white, size: 36),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _MenuTile(icon: Icons.location_on_rounded, label: context.tr('my_addresses'), onTap: () => context.push('/profile/addresses')),
          _MenuTile(icon: Icons.receipt_long_rounded, label: context.tr('my_orders'), onTap: () => context.push('/orders')),
          _MenuTile(icon: Icons.settings_rounded, label: 'Sozlamalar', onTap: () => context.push('/profile/settings')),
          _MenuTile(icon: Icons.help_outline_rounded, label: 'Yordam', onTap: () {}),
          const SizedBox(height: 12),
          _MenuTile(
            icon: Icons.logout_rounded,
            label: context.tr('logout'),
            color: AppColors.danger,
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const _MenuTile({required this.icon, required this.label, required this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color ?? AppColors.mango),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.lightTextSecondary),
      onTap: onTap,
    );
  }
}
