import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../widgets/app_card.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();
  final _emergencyRelationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    if (user != null) {
      _phoneController.text = user.phone ?? '';
      _addressController.text = user.address ?? '';
      _emergencyNameController.text = user.emergencyContactName ?? '';
      _emergencyPhoneController.text = user.emergencyContactPhone ?? '';
      _emergencyRelationController.text = user.emergencyContactRelation ?? '';
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    _emergencyRelationController.dispose();
    super.dispose();
  }

  Future<void> _submitChanges() async {
    final user = ref.read(authProvider).user;
    if (user == null) return;

    final fields = {
      'phone': (_phoneController.text, user.phone ?? ''),
      'address': (_addressController.text, user.address ?? ''),
      'emergencyContactName': (_emergencyNameController.text, user.emergencyContactName ?? ''),
      'emergencyContactPhone': (_emergencyPhoneController.text, user.emergencyContactPhone ?? ''),
      'emergencyContactRelation': (_emergencyRelationController.text, user.emergencyContactRelation ?? ''),
    };

    int submitted = 0;
    for (final entry in fields.entries) {
      final newVal = entry.value.$1.trim();
      final oldVal = entry.value.$2;
      if (newVal != oldVal && newVal.isNotEmpty) {
        await ref.read(profileProvider.notifier).submitUpdate(
              userId: user.id,
              userName: user.name,
              field: entry.key,
              oldValue: oldVal,
              newValue: newVal,
            );
        submitted++;
      }
    }

    if (!mounted) return;
    if (submitted > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$submitted change${submitted > 1 ? 's' : ''} submitted for HR review')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No changes detected')),
      );
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('Edit Profile', style: AppStyles.appBarTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(Iconsax.info_circle, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Changes will be reviewed by HR before taking effect.',
                      style: AppStyles.cardDescription.copyWith(color: AppColors.secondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text('Phone', style: AppStyles.tileLabel),
            const SizedBox(height: 8),
            InputField(
              controller: _phoneController,
              hintText: 'Phone number',
              prefixIcon: Iconsax.call,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            Text('Address', style: AppStyles.tileLabel),
            const SizedBox(height: 8),
            InputField(
              controller: _addressController,
              hintText: 'Home address',
              prefixIcon: Iconsax.location,
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Text('Emergency Contact', style: AppStyles.sectionTitle),
            const SizedBox(height: 12),
            InputField(
              controller: _emergencyNameController,
              hintText: 'Contact name',
              prefixIcon: Iconsax.profile_circle,
            ),
            const SizedBox(height: 12),
            InputField(
              controller: _emergencyPhoneController,
              hintText: 'Contact phone',
              prefixIcon: Iconsax.call,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            InputField(
              controller: _emergencyRelationController,
              hintText: 'Relationship',
              prefixIcon: Iconsax.people,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Submit Changes',
              onPressed: _submitChanges,
            ),
          ],
        ),
      ),
    );
  }
}
