import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/validators.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  bool loading = false;
  String? error;

  void _submit() async {
    setState(() {
      error = null;
    });
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => loading = true);
    final auth = ref.read(authStateProvider.notifier);
    final ok = await auth.login(email.trim(), password);
    setState(() => loading = false);
    if (!ok) {
      setState(() => error = 'Login failed. Try using "eve.holt@reqres.in" with password "cityslicka" (ReqRes).');
      return;
    }
    Navigator.of(context).pushReplacementNamed('/users');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.validateEmail,
                      onSaved: (v) => email = v ?? '',
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: Validators.validatePassword,
                      onSaved: (v) => password = v ?? '',
                    ),
                    const SizedBox(height: 16),
                    if (error != null) ...[
                      Text(error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 8),
                    ],
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading ? null : _submit,
                        child: loading ? const CircularProgressIndicator() : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () {
                        // Hint credentials for ReqRes
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Use: eve.holt@reqres.in / cityslicka (ReqRes)'),
                        ));
                      },
                      child: const Text('Need test credentials?'),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
