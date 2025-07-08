import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../widgets/query_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search your previous queries...',
                        filled: true,
                        fillColor: AppColors.inputBackground,
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.filter_alt_outlined, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    QueryCard(
                      title: 'How to apply for sick leave?',
                      description: 'You can request leave through the HR portal...',
                      icon: Icons.sick,
                      timeAgo: '2d ago',
                    ),
                    QueryCard(
                      title: 'Password reset procedure',
                      description: 'To reset your password, go to IT support...',
                      icon: Icons.lock,
                      timeAgo: '5d ago',
                    ),
                    QueryCard(
                      title: 'Expense report submission',
                      description: 'Submit your expense reports through the finance...',
                      icon: Icons.receipt_long,
                      timeAgo: '1w ago',
                    ),
                    QueryCard(
                      title: 'Office access card request',
                      description: 'For new access cards, contact administration...',
                      icon: Icons.badge,
                      timeAgo: '2w ago',
                    ),
                    QueryCard(
                      title: 'Team meeting schedule',
                      description: 'Weekly team meetings are scheduled every...',
                      icon: Icons.calendar_today,
                      timeAgo: '3w ago',
                    ),
                    QueryCard(
                      title: 'Software installation guide',
                      description: 'To install new software, follow these steps...',
                      icon: Icons.computer,
                      timeAgo: '1mo ago',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
