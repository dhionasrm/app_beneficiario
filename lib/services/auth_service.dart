import 'package:shared_preferences/shared_preferences.dart';

/// Result of a login attempt.
class AuthResult {
  const AuthResult.success() : errorMessage = null;
  const AuthResult.failure(this.errorMessage);

  final String? errorMessage;
  bool get isSuccess => errorMessage == null;
}

/// Placeholder authentication service.
///
/// There is no backend wired up yet, so this simulates a network round trip
/// and validates against a single demo credential. Swap [login] for a real
/// API call when the operator's backend is available — the session
/// persistence (`shared_preferences`) and the public method signatures can
/// stay the same.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _sessionKey = 'unipoa_session_active';

  // Demo-only credential so the app is testable on a real device before a
  // backend exists. Carteirinha: 0000000000 / Senha: unipoa123
  static const _demoCard = '0000000000';
  static const _demoPassword = 'unipoa123';

  Future<bool> hasActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_sessionKey) ?? false;
  }

  Future<AuthResult> login({
    required String cardNumber,
    required String password,
    required bool rememberMe,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final normalizedCard = cardNumber.trim();
    if (normalizedCard != _demoCard || password != _demoPassword) {
      return const AuthResult.failure(
        'Número da carteirinha ou senha incorretos. Verifique os dados e tente novamente.',
      );
    }

    if (rememberMe) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sessionKey, true);
    }

    return const AuthResult.success();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_sessionKey, false);
  }
}
