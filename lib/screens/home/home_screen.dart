import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/query_card.dart';
import 'chat_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _openChatScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Hi Hamza 👋', style: AppStyles.homeGreeting),
              const SizedBox(height: 4),
              Text('What do you need help with today?', style: AppStyles.homeSubtitle),
              const SizedBox(height: 16),
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24, width: 1.2),
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.inputBackground,
                    ),
                    child: Row(
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Icon(Icons.search, color: Colors.white54),
                        ),
                        Expanded(
                          child: TextField(
                            decoration: const InputDecoration(
                              hintText: 'Ask a question...',
                              hintStyle: TextStyle(color: Colors.white54),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                            ),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 7,
                    top: 6,
                    child: Image.asset(
                      'assets/images/arrow.png',
                      width: 50,
                      height: 50,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.3,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _BigActionButton(
                    icon: Icons.smart_toy,
                    label: 'Ask AI',
                    color: AppColors.primary,
                    onTap: () => _openChatScreen(context),
                  ),
                  const _BigActionButton(
                    icon: Icons.history,
                    label: 'Query History',
                    color: AppColors.secondary,
                  ),
                  const _BigActionButton(
                    icon: Icons.policy,
                    label: 'Leave Policies',
                    color: Color(0xFF6C63FF),
                  ),
                  const _BigActionButton(
                    icon: Icons.phone,
                    label: 'Contact HR',
                    color: Color(0xFF00D1A0),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Text('Suggested FAQs', style: AppStyles.sectionTitle),
              const SizedBox(height: 12),
              SizedBox(
                height: 300,
                child: Row(
                  children: [
                    // SizedBox(
                    //   width: MediaQuery.of(context).size.width * 0.80,
                    //   child: QueryCard(
                    //     title: 'How do I request vacation time?',
                    //     description: 'Learn about the process for submitting vacation requests and approval timelines...',
                    //     onTap: () {},
                    //     showTopGradient: true,
                    //   ),
                    // ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.62,
                            child: QueryCard(
                              title: 'What benefits are available?',
                              description: 'Explore the benefits plans and eligibility criteria...',
                              onTap: () {},
                              showTopGradient: true,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.62,
                            child: QueryCard(
                              title: 'How to apply for sick leave?',
                              description: 'You can request leave through the HR portal.You can request leave through the HR portal...You can request leave through the HR portal...',
                              onTap: () {},
                              showTopGradient: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _BigActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _BigActionButton({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          border: Border.all(color: color, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 22,
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(height: 10),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
            ],
          ),
        ),
      ),
    );
  }
}
