import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_colors.dart';
import '../../state/auth_provider.dart';
import 'widgets/social_login_buttons.dart';

class PhoneScreen extends ConsumerStatefulWidget {
  const PhoneScreen({super.key});

  @override
  ConsumerState<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends ConsumerState<PhoneScreen> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  String? _error;

  String get _fullPhone => '+998${_controller.text.replaceAll(RegExp(r'\D'), '')}';

  Future<void> _submit() async {
    if (_controller.text.replaceAll(RegExp(r'\D'), '').length != 9) {
      setState(() => _error = "Telefon raqamni to'liq kiriting");
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await ref.read(authProvider.notifier).sendOtp(_fullPhone);
      if (mounted) context.push('/auth/otp', extra: _fullPhone);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleSocialToken(String provider, String idToken) async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authProvider.notifier).socialLogin(provider, idToken);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text("Xush kelibsiz!", style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: 8),
              Text(
                "Davom etish uchun telefon raqamingizni kiriting",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _controller,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  prefixIcon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    alignment: Alignment.center,
                    width: 70,
                    child: const Text('+998', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  hintText: '90 123 45 67',
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('SMS kod olish'),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('yoki', style: TextStyle(color: AppColors.lightTextSecondary)),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 24),
              SocialLoginButtons(
                onToken: _handleSocialToken,
                onError: (e) => setState(() => _error = e.toString()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
