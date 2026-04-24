import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Terms & Conditions', style: AppStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms & Conditions',
              style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: April 2026',
              style: AppStyles.cardDescription,
            ),
            const SizedBox(height: 24),
            _section(
              '1. Acceptance of Terms',
              'By accessing and using the Employee Portal SFD application, you agree to be bound by these Terms and Conditions. This application is intended solely for employees of Speedforce Digital.',
            ),
            _section(
              '2. Use of the Application',
              'The application is provided for managing your employment-related activities including attendance tracking, leave requests, and profile management. You agree to use the application only for its intended purposes and in compliance with company policies.',
            ),
            _section(
              '3. Account Security',
              'You are responsible for maintaining the confidentiality of your login credentials. You must notify HR immediately if you suspect unauthorized access to your account. Do not share your password with anyone.',
            ),
            _section(
              '4. Attendance & Location',
              'The application uses your device location to verify attendance clock in and clock out within the designated office geofence. Location data is used solely for attendance verification and is not stored or shared beyond this purpose.',
            ),
            _section(
              '5. Data Privacy',
              'Your personal information is stored securely and is accessible only to authorized HR personnel and system administrators. We do not share your personal data with third parties. All data is processed in accordance with applicable data protection regulations.',
            ),
            _section(
              '6. Leave Management',
              'Leave requests submitted through the application are subject to approval by your manager or HR department. The application enforces company leave policies including annual quotas and monthly caps.',
            ),
            _section(
              '7. Modifications',
              'Speedforce Digital reserves the right to modify these terms at any time. Continued use of the application after changes constitutes acceptance of the updated terms.',
            ),
            _section(
              '8. Disclaimer',
              'The application is provided "as is" without warranties of any kind. Speedforce Digital is not liable for any interruptions, errors, or data loss that may occur during the use of this application.',
            ),
            _section(
              '9. Contact',
              'For questions regarding these terms, please contact HR at +92 329 992 2219 or reach out through the Contact HR feature in the application.',
            ),
            const SizedBox(height: 32),
            Center(
              child: Text(
                'Speedforce Digital',
                style: AppStyles.cardDescription.copyWith(fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: const TextStyle(
              fontFamily: 'Inter',
              color: AppColors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
