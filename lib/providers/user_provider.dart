import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

final userServiceProvider = Provider((ref) => UserService());

final usersProvider = StateNotifierProvider<UserListNotifier, AsyncValue<List<UserModel>>>(
      (ref) {
    return UserListNotifier(ref);
  },
);

class UserListNotifier extends StateNotifier<AsyncValue<List<UserModel>>> {
  final Ref ref;
  UserListNotifier(this.ref) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final svc = ref.read(userServiceProvider);
      final users = await svc.fetchUsers();
      state = AsyncValue.data(users);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
