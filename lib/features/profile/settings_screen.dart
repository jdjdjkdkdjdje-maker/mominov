import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../l10n/app_strings.dart';
import '../../state/app_settings_provider.dart';
import '../../state/repository_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Sozlamalar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(context.tr('language'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _optionTile('O\'zbekcha', locale.languageCode == 'uz', () => _setLocale(ref, 'uz')),
          _optionTile('Русский', locale.languageCode == 'ru', () => _setLocale(ref, 'ru')),
          _optionTile('English', locale.languageCode == 'en', () => _setLocale(ref, 'en')),
          const SizedBox(height: 24),
          Text(context.tr('theme'), style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          _optionTile(context.tr('light_mode'), themeMode == ThemeMode.light, () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.light)),
          _optionTile(context.tr('dark_mode'), themeMode == ThemeMode.dark, () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.dark)),
          _optionTile(context.tr('system_mode'), themeMode == ThemeMode.system, () => ref.read(themeModeProvider.notifier).setThemeMode(ThemeMode.system)),
        ],
      ),
    );
  }

  void _setLocale(WidgetRef ref, String code) {
    ref.read(localeProvider.notifier).setLocale(Locale(code));
    // Backendga ham saqlaymiz (foydalanuvchi profilidagi `language` maydoni).
    ref.read(userRepositoryProvider).updateMe(language: code);
  }

  Widget _optionTile(String label, bool selected, VoidCallback onTap) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label),
        trailing: selected ? const Icon(Icons.check_circle_rounded, color: AppColors.mango) : null,
        onTap: onTap,
      );
}
