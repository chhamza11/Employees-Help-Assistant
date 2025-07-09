import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../widgets/custom_button.dart';

class ChatScreen extends StatefulWidget {
  final String? initialQuestion;

  const ChatScreen({Key? key, this.initialQuestion}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  List<Map<String, String>> faqs = [];
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _showTypingDots = false;
  int? _animatingMsgIndex;
  FocusNode _focusNode = FocusNode();
  bool _faqsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initHive();
    _initChat();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), _scrollToBottom);
      }
    });
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    await Hive.openBox('query_history');
  }

  void _saveToHistory(String question, String answer) async {
    final box = Hive.box('query_history');
    final entry = {
      'question': question,
      'answer': answer,
      'timestamp': DateTime.now().toIso8601String(),
    };
    box.add(entry);
  }

  // --- NEW ASYNC INITIALIZATION METHOD ---
  Future<void> _initChat() async {
    await _loadFaqs(); // Wait for FAQs to load first
    if (widget.initialQuestion != null && widget.initialQuestion!.isNotEmpty) {
      // Only set text and send message AFTER FAQs are loaded
      _controller.text = widget.initialQuestion!;
      _sendMessage(widget.initialQuestion!);
    }
  }

  Future<void> _loadFaqs() async {
    try {
      final String data = await rootBundle.loadString('assets/dumydata.json');
      final Map<String, dynamic> jsonResult = json.decode(data);
      final List<dynamic> faqList = jsonResult['companyPolicyFAQ'];
      setState(() {
        faqs = faqList.map((e) => {
          'question': e['question'] as String,
          'answer': e['answer'] as String,
        }).toList();
        _faqsLoaded = true; // Set loaded to true once data is in `faqs`
      });
    } catch (e) {
      // Handle error if JSON loading fails (e.g., file not found, bad format)
      print('Error loading FAQs: $e');
      setState(() {
        _faqsLoaded = false; // Mark as not loaded if there's an error
      });
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final inputQueryLower = text.trim().toLowerCase();
    Map<String, String> botResponseFaq = {};

    // Ensure FAQs are loaded before attempting to find a match
    if (_faqsLoaded) {
      // 1. Try to find an EXACT match first
      try {
        botResponseFaq = faqs.firstWhere(
              (faq) => faq['question']!.toLowerCase() == inputQueryLower,
        );
      } catch (e) {
        // No exact match, continue to check for keyword match
        // print('No exact match for: "$inputQueryLower"'); // For debugging
      }

      // 2. If no exact match, try to find a KEYWORD match (contains)
      if (botResponseFaq.isEmpty) {
        try {
          botResponseFaq = faqs.firstWhere(
                (faq) => faq['question']!.toLowerCase().contains(inputQueryLower),
          );
        } catch (e) {
          // No keyword match either, botResponseFaq remains empty
          // print('No keyword match for: "$inputQueryLower"'); // For debugging
        }
      }
    } else {
      // If FAQs are not loaded yet, just use generic response
      print('FAQs not loaded yet, sending generic response.'); // For debugging
    }


    setState(() {
      messages.add({'text': text, 'isUser': true, 'time': _getTime(), 'animated': false});
      _controller.clear();
      _isSending = true;
      _showTypingDots = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(seconds: 1)); // Simulate AI processing time

    setState(() {
      _showTypingDots = false;
      if (botResponseFaq.isNotEmpty) {
        // If an FAQ match (exact or keyword) was found, use its answer
        messages.add({
          'text': botResponseFaq['answer']!,
          'isUser': false,
          'time': _getTime(),
          'animated': true,
        });
        _saveToHistory(text, botResponseFaq['answer']!);
      } else {
        // Otherwise, use the generic template response
        messages.add({
          'text': 'This is a template AI response for: $text',
          'isUser': false,
          'time': _getTime(),
          'animated': true,
        });
        _saveToHistory(text, 'This is a template AI response for: $text');
      }
      _animatingMsgIndex = messages.length - 1;
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _sendFaq(String question, String answer) async {
    // This method is now effectively redundant if all FAQ logic goes through _sendMessage
    // but keeping it for now, just in case you plan to call it from somewhere else with pre-known Q&A.
    // If not, you can safely remove it.
    setState(() {
      messages.add({'text': question, 'isUser': true, 'time': _getTime(), 'animated': false});
      _isSending = true;
      _showTypingDots = true;
      _controller.clear();
    });
    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showTypingDots = false;
      messages.add({
        'text': answer,
        'isUser': false,
        'time': _getTime(),
        'animated': true,
      });
      _animatingMsgIndex = messages.length - 1;
      _isSending = false;
    });
    _scrollToBottom();
  }

  String _getTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : now.hour;
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text('AI Assistant', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Stack(
        children: [
          // Chat area
          Padding(
            padding: EdgeInsets.only(bottom: 88 + bottomInset),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length + (_showTypingDots ? 1 : 0),
              itemBuilder: (context, idx) {
                if (_showTypingDots && idx == messages.length) {
                  // Animated typing dots
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _BotAvatar(),
                      const SizedBox(width: 8),
                      _TypingIndicator(),
                    ],
                  );
                }
                final msg = messages[idx];
                final isUser = msg['isUser'] as bool;
                final animated = msg['animated'] == true;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        _BotAvatar(),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                          children: [
                            animated && _animatingMsgIndex == idx
                                ? _TypewriterText(
                              text: msg['text'],
                              isUser: isUser,
                              onFinished: () {
                                setState(() {
                                  _animatingMsgIndex = null;
                                });
                                _scrollToBottom();
                              },
                            )
                                : AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: isUser
                                    ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
                                    : null,
                                color: isUser ? null : AppColors.card,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(18),
                                  topRight: const Radius.circular(18),
                                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                                  bottomRight: Radius.circular(isUser ? 4 : 18),
                                ),
                              ),
                              child: Text(
                                msg['text'],
                                style: TextStyle(
                                  color: isUser ? Colors.white : AppColors.white,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg['time'],
                                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                                ),
                                const SizedBox(width: 8),
                                if (!isUser)
                                  Row(
                                    children: [
                                      Icon(Icons.thumb_up_alt_outlined, color: Colors.white38, size: 16),
                                      const SizedBox(width: 4),
                                      Icon(Icons.thumb_down_alt_outlined, color: Colors.white38, size: 16),
                                    ],
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 8),
                        _UserAvatar(),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
          // Input bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                color: AppColors.background,
                padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10 + bottomInset),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _controller,
                        enabled: _faqsLoaded, // Disable input until FAQs are loaded
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: _faqsLoaded ? 'Type your question...' : 'Loading FAQs...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                          suffixIcon: !_faqsLoaded
                              ? const Padding(
                            padding: EdgeInsets.all(12.0),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            ),
                          )
                              : null,
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _faqsLoaded ? () => _sendMessage(_controller.text) : null, // Disable send button until loaded
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(Icons.send, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BotAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppColors.primary,
      radius: 18,
      child: const Icon(Icons.smart_toy, color: Colors.white, size: 22),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      backgroundColor: AppColors.secondary,
      radius: 18,
      child: const Icon(Icons.person, color: Colors.white, size: 22),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.5, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: ScaleTransition(
            scale: _animation,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      }),
    );
  }
}

// Typewriter animation for bot response
class _TypewriterText extends StatefulWidget {
  final String text;
  final bool isUser;
  final VoidCallback? onFinished;
  const _TypewriterText({required this.text, required this.isUser, this.onFinished});

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  String _displayed = '';
  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 18), (timer) {
      if (_index < widget.text.length) {
        setState(() {
          _index++;
          _displayed = widget.text.substring(0, _index);
        });
      } else {
        timer.cancel();
        if (widget.onFinished != null) widget.onFinished!();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: widget.isUser
            ? const LinearGradient(colors: [AppColors.primary, AppColors.secondary])
            : null,
        color: widget.isUser ? null : AppColors.card,
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(widget.isUser ? 18 : 4),
          bottomRight: Radius.circular(widget.isUser ? 4 : 18),
        ),
      ),
      child: Text(
        _displayed,
        style: TextStyle(
          color: widget.isUser ? Colors.white : AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }
}


void _showContactHRDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.7),
    builder: (context) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.phone, color: AppColors.primary, size: 38),
              const SizedBox(height: 12),
              Text('Contact HR', style: AppStyles.sectionTitle),
              const SizedBox(height: 8),
              Text('How would you like to contact HR?', style: AppStyles.cardDescription, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              CustomButton(
                text: 'Phone Call',
                icon: Icons.phone,
                background: AppColors.primary,
                onPressed: () async {
                  const hrNumber = '+923299922219';
                  final Uri phoneUri = Uri(scheme: 'tel', path: hrNumber);
                  if (await canLaunchUrl(phoneUri)) {
                    await launchUrl(phoneUri);
                  }
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: 'WhatsApp Message',
                icon: Icons.message,
                background: const Color(0xFF25D366),
                onPressed: () async {
                  const hrNumber = '923299922219';
                  const message = 'Hello, I need assistance from HR.';
                  final waUrl = Uri.parse('https://wa.me/$hrNumber?text=${Uri.encodeComponent(message)}');
                  bool launched = false;
                  if (await canLaunchUrl(waUrl)) {
                    launched = await launchUrl(waUrl, mode: LaunchMode.externalApplication);
                  }
                  if (!launched) {
                    // Try whatsapp:// scheme as fallback
                    final whatsappScheme = Uri.parse('whatsapp://send?phone=$hrNumber&text=${Uri.encodeComponent(message)}');
                    if (await canLaunchUrl(whatsappScheme)) {
                      await launchUrl(whatsappScheme);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('WhatsApp is not installed or cannot be opened.')),
                      );
                    }
                  }
                  Navigator.of(context).pop();
                },
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: AppStyles.cardDescription.copyWith(color: AppColors.white70)),
              ),
            ],
          ),
        ),
      );
    },
  );
}