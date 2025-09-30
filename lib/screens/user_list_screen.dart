import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
        actions: [
          IconButton(
            icon: const Icon(Icons.video_call),
            onPressed: () => Navigator.of(context).pushNamed('/call'),
          ),
        ],
      ),
      body: state.when(
        data: (users) => RefreshIndicator(
          onRefresh: () => ref.read(usersProvider.notifier).load(),
          child: ListView.separated(
            itemCount: users.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final UserModel u = users[index];
              return ListTile(
                leading: CircleAvatar(backgroundImage: NetworkImage(u.avatar)),
                title: Text('${u.firstName} ${u.lastName}'),
                subtitle: Text(u.email),
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text('Failed to load users'),
            ElevatedButton(onPressed: () => ref.read(usersProvider.notifier).load(), child: const Text('Retry'))
          ]),
        ),
      ),
    );
  }
}
