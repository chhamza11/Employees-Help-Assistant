import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../widgets/input_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).login(
          _emailController.text.trim(),
          _passwordController.text,
        );

    if (!mounted) return;

    if (success) {
      context.go('/dashboard');
    } else {
      final error = ref.read(authProvider).error;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: const Color(0xFFE74C3C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 32),
                  Image.asset(AppAssets.logo, width: 60, height: 60),
                  const SizedBox(height: 16),
                  const Text('Employee Portal SFD', style: AppStyles.loginTitle),
                  const SizedBox(height: 32),
                  InputField(
                    controller: _emailController,
                    hintText: 'Email address',
                    prefixIcon: Iconsax.sms,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 16),
                  InputField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Iconsax.lock,
                    obscureText: _obscurePassword,
                    suffixIcon: _obscurePassword
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    onSuffixTap: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                    keyboardType: TextInputType.visiblePassword,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: authState.isLoading ? 'Signing In...' : 'Sign In',
                    onPressed: authState.isLoading ? null : _handleLogin,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: const Text(
                      'First time? Set up your password',
                      style: TextStyle(color: AppColors.primary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Contact HR if you don\'t have an account',
                    style: AppStyles.cardDescription.copyWith(fontSize: 12),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
