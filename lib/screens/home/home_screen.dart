import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/query_card.dart';
import '../history/history_screen.dart';
import 'chat_screen.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, String>> faqs = [];
  List<Map<String, String>> filteredFaqs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _loadFaqs() async {
    final String data = await rootBundle.loadString('assets/dumydata.json');
    final Map<String, dynamic> jsonResult = json.decode(data);
    final List<dynamic> faqList = jsonResult['companyPolicyFAQ'];
    setState(() {
      faqs = faqList.map((e) => {
        'question': e['question'] as String,
        'answer': e['answer'] as String,
      }).toList();
      filteredFaqs = [];
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      setState(() {
        filteredFaqs = [];
        _showDropdown = false;
      });
    } else {
      final matches = faqs.where((faq) => faq['question']!.toLowerCase().contains(query)).take(3).toList();
      setState(() {
        filteredFaqs = matches;
        _showDropdown = matches.isNotEmpty;
      });
    }
  }

  void _onSuggestionTap(Map<String, String> faq) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          initialQuestion: faq['question'],
        ),
      ),
    );
    _searchController.clear();
    setState(() {
      _showDropdown = false;
      filteredFaqs = [];
    });
  }

  void _openChatScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatScreen()),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('Hi Hamza 👋', style: AppStyles.homeGreeting),
              const SizedBox(height: 4),
              Text('What do you need help with today?', style: AppStyles.homeSubtitle),
              const SizedBox(height: 16),
              // Search bar
              Padding(
                padding: const EdgeInsets.only(bottom: 0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Ask a question...',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                  ),
                ),
              ),
              // Suggestions dropdown
              if (_showDropdown && filteredFaqs.isNotEmpty)
                Container(
                  color: AppColors.background,
                  constraints: const BoxConstraints(maxHeight: 180),
                  margin: const EdgeInsets.only(top: 4, bottom: 8),
                  child: Material(
                    color: Colors.transparent,
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: filteredFaqs.length,
                      separatorBuilder: (_, __) => const Divider(height: 1, color: Colors.white12),
                      itemBuilder: (context, idx) {
                        final faq = filteredFaqs[idx];
                        return ListTile(
                          title: Text(
                            faq['question']!,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          onTap: () => _onSuggestionTap(faq),
                        );
                      },
                    ),
                  ),
                ),
              // Only show action buttons/grid if no suggestions
              if (!_showDropdown)
                ...[
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
                      _BigActionButton(
                        icon: Icons.history,
                        label: 'Query History',
                        color: AppColors.secondary,
                        onTap: () => HistoryScreen(),
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
                  // Vertically expanded Suggested FAQs (up to 3)
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      QueryCard(
                        title: 'What benefits are available?',
                        description: 'Explore the benefits plans and eligibility criteria...',
                        onTap: () {},
                        showTopGradient: true,
                      ),
                      QueryCard(
                        title: 'How to apply for sick leave?',
                        description: 'You can request leave through the HR portal.You can request leave through the HR portal...You can request leave through the HR portal...',
                        onTap: () {},
                        showTopGradient: true,
                      ),
                      QueryCard(
                        title: 'How often does Speedforce Digital review employee performance?',
                        description: 'Annually.',
                        onTap: () {},
                        showTopGradient: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
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