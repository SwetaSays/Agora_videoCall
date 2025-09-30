import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_video_app/providers/auth_provider.dart';
import 'package:flutter_video_app/screens/login_screen.dart';
import 'package:flutter_video_app/screens/splash_screen.dart';
import 'package:flutter_video_app/screens/user_list_screen.dart';
import 'package:flutter_video_app/screens/video_call_screen.dart';


class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return MaterialApp(
      title: 'Flutter Video App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/users': (context) => const UserListScreen(),
        '/call': (context) => const VideoCallScreen(),
      },
      initialRoute: '/',
    );
  }
}
