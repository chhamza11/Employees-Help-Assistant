import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import '../../widgets/app_card.dart';
import '../../widgets/input_field.dart';
import '../buddy/buddy_chat_screen.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  List<Map<String, String>> _allFaqs = [];
  List<Map<String, String>> _filteredFaqs = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
    _searchController.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFaqs() async {
    try {
      final String data = await rootBundle.loadString('assets/dumydata.json');
      final Map<String, dynamic> jsonResult = json.decode(data);
      final List<dynamic> faqList = jsonResult['companyPolicyFAQ'];
      setState(() {
        _allFaqs = faqList
            .map((e) => {
                  'question': e['question'] as String,
                  'answer': e['answer'] as String,
                })
            .toList();
        _filteredFaqs = List.from(_allFaqs);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _onSearch() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredFaqs = List.from(_allFaqs);
      } else {
        _filteredFaqs = _allFaqs
            .where((faq) =>
                faq['question']!.toLowerCase().contains(query) ||
                faq['answer']!.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _openChat(String question) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BuddyChatScreen(initialQuestion: question),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text('FAQ / Help', style: AppStyles.appBarTitle),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: InputField(
                    controller: _searchController,
                    hintText: 'Search FAQs...',
                    prefixIcon: Iconsax.search_normal,
                  ),
                ),
                Expanded(
                  child: _filteredFaqs.isEmpty
                      ? Center(
                          child: Text(
                            'No FAQs found',
                            style: AppStyles.emptyState,
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                          itemCount: _filteredFaqs.length,
                          itemBuilder: (context, index) {
                            final faq = _filteredFaqs[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: AppCard(
                                onTap: () => _openChat(faq['question']!),
                                padding: const EdgeInsets.all(14),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        faq['question']!,
                                        style: AppStyles.cardTitle.copyWith(fontSize: 14),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios,
                                      color: AppColors.white70,
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
