import 'package:flutter/material.dart';
import '../../core/colors.dart';
// import '../../core/styles.dart';
import '../../widgets/query_card.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  Box? historyBox;

  @override
  void initState() {
    super.initState();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    historyBox = await Hive.openBox('query_history');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (historyBox == null || !historyBox!.isOpen) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }
    List history = historyBox!.values.toList().reversed.toList();
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
                child: history.isEmpty
                    ? const Center(child: Text('No query history yet.', style: TextStyle(color: Colors.white54)))
                    : ListView.builder(
                        itemCount: history.length,
                        itemBuilder: (context, idx) {
                          final entry = history[idx];
                          return QueryCard(
                            title: entry['question'] ?? '',
                            description: entry['answer'] ?? '',
                            icon: Icons.history,
                            timeAgo: '',
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
