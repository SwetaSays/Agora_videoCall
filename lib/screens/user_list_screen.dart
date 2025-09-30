import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_provider.dart';
import '../models/user_model.dart';
import 'video_call_screen.dart';

class UserListScreen extends ConsumerWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(usersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
      ),
      body: usersAsync.when(
        data: (users) {
          if (users.isEmpty) return const Center(child: Text("No users found"));

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.avatar),
                ),
                title: Text('${user.firstName} ${user.lastName}'),
                subtitle: Text(user.email),
                trailing: IconButton(
                  icon: const Icon(Icons.video_call),
                  color: Colors.blue,
                  onPressed: () {
                    // Navigate to Video Call screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const VideoCallScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
