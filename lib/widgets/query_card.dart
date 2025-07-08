import 'package:flutter/material.dart';
import '../core/colors.dart';
import '../core/styles.dart';

class QueryCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData? icon;
  final String? timeAgo;
  final VoidCallback? onTap;
  final bool showTopGradient;

  const QueryCard({
    Key? key,
    required this.title,
    required this.description,
    this.icon,
    this.timeAgo,
    this.onTap,
    this.showTopGradient = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTopGradient)
              Container(
                height: 4,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.secondary],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (icon != null)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(icon, color: AppColors.primary, size: 24),
                    ),
                  if (icon != null) const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppStyles.cardTitle),
                        const SizedBox(height: 4),
                        Text(description, style: AppStyles.cardDescription, maxLines: 5, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (timeAgo != null)
                    Text(timeAgo!, style: const TextStyle(color: AppColors.white70, fontSize: 12)),
                  if (timeAgo == null)
                    const Icon(Icons.arrow_forward_ios, color: AppColors.white70, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
