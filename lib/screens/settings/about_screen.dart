import 'package:flutter/material.dart';
import '../../core/assets.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('About', style: AppStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.asset(AppAssets.logo, width: 80, height: 80),
            const SizedBox(height: 16),
            const Text(
              'Employee Portal SFD',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Version 1.0.0',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 32),
            const _InfoRow('Developed by', 'Speedforce Digital'),
            const _InfoRow('Platform', 'Android & iOS'),
            const _InfoRow('Framework', 'Flutter'),
            const _InfoRow('Backend', 'Appwrite'),
            const SizedBox(height: 32),
            Text(
              'Employee Portal SFD is a comprehensive HRMS mobile application designed for employees of Speedforce Digital. It provides easy access to attendance tracking, leave management, working hours, and profile management — all in one place.',
              style: AppStyles.cardDescription.copyWith(fontSize: 14, height: 1.6),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            const Text(
              'Powered by Speedforce Digital',
              style: TextStyle(
                fontFamily: 'Inter',
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppStyles.tileLabel),
          Text(value, style: AppStyles.tileValue),
        ],
      ),
    );
  }
}
