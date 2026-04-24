import 'package:flutter/material.dart';
import '../core/styles.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const SectionHeader({
    Key? key,
    required this.title,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: AppStyles.sectionTitle),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
