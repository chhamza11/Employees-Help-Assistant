import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/info_tile.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header with avatar and actions
          Column(
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: AppColors.primary,
                child: Text(
                  user.firstName[0].toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(user.name, style: AppStyles.sectionTitle),
              const SizedBox(height: 4),
              Text(
                '${user.position ?? 'Employee'} - ${user.department ?? 'General'}',
                style: AppStyles.cardDescription,
              ),
              if (user.employeeId != null) ...[
                const SizedBox(height: 4),
                Text('ID: ${user.employeeId}', style: AppStyles.dashboardLabel),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push('/profile/edit'),
                    icon: const Icon(Iconsax.edit_2, size: 16),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Iconsax.setting_2, size: 16),
                    label: const Text('Settings'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.card,
                      foregroundColor: AppColors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // All profile info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                // Personal Information
                _SectionTitle('Personal Information'),
                InfoTile(label: 'Email', value: user.email, icon: Iconsax.sms),
                InfoTile(label: 'Phone', value: user.phone ?? '', icon: Iconsax.call),
                InfoTile(label: 'Address', value: user.address ?? '', icon: Iconsax.location),
                InfoTile(label: 'Date of Birth', value: user.dateOfBirth ?? '', icon: Iconsax.cake),
                InfoTile(label: 'Religion', value: user.religion ?? '', icon: Iconsax.heart),

                _Divider(),

                // Employment Details
                _SectionTitle('Employment Details'),
                InfoTile(label: 'Department', value: user.department ?? '', icon: Iconsax.building),
                InfoTile(label: 'Position', value: user.position ?? '', icon: Iconsax.briefcase),
                InfoTile(label: 'Join Date', value: user.joiningDate ?? user.joinDate ?? '', icon: Iconsax.calendar_1),
                InfoTile(label: 'Employee ID', value: user.employeeId ?? '', icon: Iconsax.personalcard),

                _Divider(),

                // Emergency Contact
                _SectionTitle('Emergency Contact'),
                InfoTile(label: 'Name', value: user.emergencyContactName ?? '', icon: Iconsax.profile_circle),
                InfoTile(label: 'Phone', value: user.emergencyContactPhone ?? '', icon: Iconsax.call),
                InfoTile(label: 'Relation', value: user.emergencyContactRelation ?? '', icon: Iconsax.people),

                if (user.education != null && user.education!.isNotEmpty) ...[
                  _Divider(),
                  _SectionTitle('Education'),
                  ...user.education!.map((e) => InfoTile(
                        label: e.degree,
                        value: '${e.institution} (${e.year})',
                        icon: Iconsax.teacher,
                      )),
                ],

                _Divider(),

                // Bank Details
                _SectionTitle('Bank Details'),
                InfoTile(label: 'Bank', value: user.bankName ?? '', icon: Iconsax.bank),
                InfoTile(
                  label: 'Account',
                  value: user.bankAccountNumber != null
                      ? '****${user.bankAccountNumber!.length > 4 ? user.bankAccountNumber!.substring(user.bankAccountNumber!.length - 4) : user.bankAccountNumber!}'
                      : '',
                  icon: Iconsax.card,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4, top: 4),
      child: Text(title, style: AppStyles.sectionTitle.copyWith(fontSize: 15)),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(color: AppColors.divider, height: 1),
    );
  }
}
