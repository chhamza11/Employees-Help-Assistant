import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../core/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import '../../widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Settings', style: AppStyles.appBarTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SettingsTile(
            icon: Iconsax.message_question,
            title: 'FAQ / Help',
            subtitle: 'Ask SpeedForce Buddy',
            onTap: () => context.push('/faq'),
          ),
          _SettingsTile(
            icon: Iconsax.call,
            title: 'Contact HR',
            subtitle: 'Call or WhatsApp',
            onTap: () => _showContactHRSheet(context),
          ),
          _SettingsTile(
            icon: Iconsax.lock,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: () => _showChangePasswordSheet(context, ref),
          ),
          _SettingsTile(
            icon: Iconsax.info_circle,
            title: 'About',
            subtitle: 'Employee Portal SFD v1.0.0',
            onTap: () => context.push('/about'),
          ),
          _SettingsTile(
            icon: Iconsax.document_text,
            title: 'Terms & Conditions',
            subtitle: 'Read our policies',
            onTap: () => context.push('/terms'),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Logout',
            background: const Color(0xFFE74C3C),
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text('Logout', style: TextStyle(color: AppColors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: AppColors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.white70)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout', style: TextStyle(color: Color(0xFFE74C3C))),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordSheet(BuildContext context, WidgetRef ref) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            20,
            20,
            MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Change Password', style: AppStyles.sectionTitle),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppColors.white70, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                InputField(
                  controller: oldController,
                  hintText: 'Current password',
                  prefixIcon: Iconsax.lock,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 12),
                InputField(
                  controller: newController,
                  hintText: 'New password',
                  prefixIcon: Iconsax.lock,
                  obscureText: true,
                  validator: Validators.password,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: CustomButton(
                    text: 'Update Password',
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final success = await ref
                          .read(authProvider.notifier)
                          .updatePassword(
                            newController.text,
                            oldController.text,
                          );
                      if (ctx.mounted) {
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          SnackBar(
                            content: Text(success
                                ? 'Password updated'
                                : 'Failed to update password'),
                            backgroundColor: success
                                ? AppColors.primary
                                : const Color(0xFFE74C3C),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactHRSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Contact HR', style: AppStyles.sectionTitle),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white70, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'Phone Call',
                  icon: Iconsax.call,
                  onPressed: () async {
                    final Uri phoneUri = Uri(scheme: 'tel', path: '+923299922219');
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: 'WhatsApp',
                  icon: Iconsax.message,
                  background: AppColors.card,
                  onPressed: () async {
                    final waUrl = Uri.parse(
                      'https://wa.me/923299922219?text=${Uri.encodeComponent('Hello, I need assistance from HR.')}',
                    );
                    if (await canLaunchUrl(waUrl)) {
                      await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppCard(
        onTap: onTap,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppStyles.cardTitle.copyWith(fontSize: 15)),
                  Text(subtitle, style: AppStyles.cardDescription.copyWith(fontSize: 12)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: AppColors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
