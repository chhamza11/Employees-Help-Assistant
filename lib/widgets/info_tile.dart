import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/styles.dart';

class InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const InfoTile({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, color: AppColors.white70, size: 18),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppStyles.tileLabel),
                const SizedBox(height: 2),
                Text(
                  value.isNotEmpty ? value : '-',
                  style: AppStyles.tileValue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
