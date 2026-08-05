import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/storage/secure_storage.dart';
import '../data/models/user_model.dart';
import 'repository_providers.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final bool needsProfileSetup;

  const AuthState({this.status = AuthStatus.unknown, this.user, this.needsProfileSetup = false});

  AuthState copyWith({AuthStatus? status, UserModel? user, bool? needsProfileSetup}) => AuthState(
        status: status ?? this.status,
        user: user ?? this.user,
        needsProfileSetup: needsProfileSetup ?? this.needsProfileSetup,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  AuthNotifier(this.ref) : super(const AuthState()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    final hasSession = await SecureStorage.instance.hasSession;
    if (!hasSession) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }
    try {
      final user = await ref.read(userRepositoryProvider).getMe();
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await SecureStorage.instance.clear();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> sendOtp(String phone) => ref.read(authRepositoryProvider).sendOtp(phone);

  Future<void> verifyOtp(String phone, String code) async {
    final result = await ref.read(authRepositoryProvider).verifyOtp(phoneNumber: phone, code: code);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: result.user,
      needsProfileSetup: result.isNewUser || result.user.fullName.isEmpty,
    );
  }

  Future<void> socialLogin(String provider, String idToken) async {
    final result = await ref.read(authRepositoryProvider).socialLogin(provider: provider, idToken: idToken);
    state = state.copyWith(
      status: AuthStatus.authenticated,
      user: result.user,
      needsProfileSetup: result.isNewUser || result.user.fullName.isEmpty,
    );
  }

  void completeProfileSetup(UserModel updated) {
    state = state.copyWith(user: updated, needsProfileSetup: false);
  }

  Future<void> refreshUser() async {
    final user = await ref.read(userRepositoryProvider).getMe();
    state = state.copyWith(user: user);
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
