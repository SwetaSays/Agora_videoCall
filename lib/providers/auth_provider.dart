import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

final authServiceProvider = Provider((ref) => AuthService());

final authStateProvider =
StateNotifierProvider<AuthStateNotifier, bool>((ref) {
  return AuthStateNotifier(ref);
});

class AuthStateNotifier extends StateNotifier<bool> {
  final Ref ref;
  AuthStateNotifier(this.ref) : super(false);

  Future<bool> login(String email, String password) async {
    final auth = ref.read(authServiceProvider);
    final ok = await auth.login(email, password);
    state = ok;
    return ok;
  }

  void logout() => state = false;
}
