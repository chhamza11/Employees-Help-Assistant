import 'package:flutter/material.dart';
import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 32),
                Image.asset(AppAssets.logo, width: 60, height: 60),
                const SizedBox(height: 16),
                Text('AI Assistant', style: AppStyles.loginTitle),
                const SizedBox(height: 32),
                InputField(
                  hintText: 'Email address',
                  prefixIcon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                InputField(
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: true,
                  suffixIcon: Icons.visibility_off_outlined,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    child: const Text('Forgot Password?', style: TextStyle(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: 8),
                CustomButton(
                  text: 'Sign In',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('OR', style: TextStyle(color: Colors.grey)),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade400)),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Continue with Google',
                  icon: Icons.g_mobiledata ,
                  background: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {},
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Continue with Apple',
                  icon: Icons.apple,
                  background: Colors.black,
                  textColor: Colors.white,
                  onPressed: () {},
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                    GestureDetector(
                      onTap: () {},
                      child: const Text('Sign up', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
