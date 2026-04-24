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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authProvider.notifier).register(
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
      appBar: AppBar(
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.white),
          onPressed: () => context.go('/login'),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(AppAssets.logo, width: 50, height: 50),
                  const SizedBox(height: 16),
                  const Text('Set Up Your Account', style: AppStyles.loginTitle),
                  const SizedBox(height: 8),
                  Text(
                    'Enter the email HR registered for you and create a password',
                    style: AppStyles.cardDescription,
                    textAlign: TextAlign.center,
                  ),
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
                    hintText: 'New Password',
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
                  const SizedBox(height: 16),
                  InputField(
                    controller: _confirmPasswordController,
                    hintText: 'Confirm Password',
                    prefixIcon: Iconsax.lock,
                    obscureText: _obscureConfirm,
                    suffixIcon: _obscureConfirm
                        ? Iconsax.eye_slash
                        : Iconsax.eye,
                    onSuffixTap: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                    keyboardType: TextInputType.visiblePassword,
                    validator: (value) => Validators.confirmPassword(
                      value,
                      _passwordController.text,
                    ),
                  ),
                  const SizedBox(height: 24),
                  CustomButton(
                    text: authState.isLoading ? 'Setting Up...' : 'Create Account',
                    onPressed: authState.isLoading ? null : _handleRegister,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Already have an account? Sign In',
                      style: TextStyle(color: AppColors.primary),
                    ),
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
