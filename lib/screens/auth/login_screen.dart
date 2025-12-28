import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/validators.dart';
import '../../utils/helpers.dart';
import '../../widgets/common/app_text_field.dart';
import '../../widgets/common/primary_button.dart';
import 'register_screen.dart';
import 'reset_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _loginEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signIn(_email.text.trim(), _pass.text);
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _loginGoogle() async {
    setState(() => _loading = true);
    try {
      await context.read<AuthProvider>().signInGoogle();
    } catch (e) {
      if (!mounted) return;
      showErrorDialog(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              AppTextField(
                controller: _email,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
                prefixIcon: const Icon(Icons.email),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _pass,
                label: 'Password',
                obscure: true,
                validator: Validators.password,
                prefixIcon: const Icon(Icons.lock),
              ),
              const SizedBox(height: 12),
              PrimaryButton(text: 'Entrar', onPressed: _loginEmail, loading: _loading),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _loading ? null : _loginGoogle,
                icon: const Icon(Icons.login),
                label: const Text('Entrar com Google'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ResetPasswordScreen()),
                ),
                child: const Text('Esqueci-me da password'),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                ),
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
