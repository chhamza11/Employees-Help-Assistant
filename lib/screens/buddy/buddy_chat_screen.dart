import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import '../../core/colors.dart';

class BuddyChatScreen extends StatefulWidget {
  final String? initialQuestion;
  const BuddyChatScreen({Key? key, this.initialQuestion}) : super(key: key);

  @override
  State<BuddyChatScreen> createState() => _BuddyChatScreenState();
}

class _BuddyChatScreenState extends State<BuddyChatScreen>
    with TickerProviderStateMixin {
  List<Map<String, String>> faqs = [];
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showTypingDots = false;
  int? _animatingMsgIndex;
  final FocusNode _focusNode = FocusNode();
  bool _faqsLoaded = false;

  @override
  void initState() {
    super.initState();
    _initChat();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), _scrollToBottom);
      }
    });
  }

  Future<void> _initChat() async {
    await _loadFaqs();
    if (widget.initialQuestion != null && widget.initialQuestion!.isNotEmpty) {
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
        faqs = faqList
            .map((e) => {
                  'question': e['question'] as String,
                  'answer': e['answer'] as String,
                })
            .toList();
        _faqsLoaded = true;
      });
    } catch (e) {
      setState(() => _faqsLoaded = false);
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final inputQueryLower = text.trim().toLowerCase();
    Map<String, String> botResponseFaq = {};

    if (_faqsLoaded) {
      try {
        botResponseFaq = faqs.firstWhere(
          (faq) => faq['question']!.toLowerCase() == inputQueryLower,
        );
      } catch (_) {}

      if (botResponseFaq.isEmpty) {
        try {
          botResponseFaq = faqs.firstWhere(
            (faq) => faq['question']!.toLowerCase().contains(inputQueryLower),
          );
        } catch (_) {}
      }
    }

    setState(() {
      messages.add({
        'text': text,
        'isUser': true,
        'time': _getTime(),
        'animated': false,
      });
      _controller.clear();
      _showTypingDots = true;
    });
    _scrollToBottom();

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _showTypingDots = false;
      if (botResponseFaq.isNotEmpty) {
        messages.add({
          'text': botResponseFaq['answer']!,
          'isUser': false,
          'time': _getTime(),
          'animated': true,
        });
        _saveToHistory(text, botResponseFaq['answer']!);
      } else {
        messages.add({
          'text':
              'I\'m not sure about that. Please contact HR for more details.',
          'isUser': false,
          'time': _getTime(),
          'animated': true,
        });
        _saveToHistory(text, 'I\'m not sure about that. Please contact HR.');
      }
      _animatingMsgIndex = messages.length - 1;
    });
    _scrollToBottom();
  }

  void _saveToHistory(String question, String answer) {
    try {
      final box = Hive.box('query_history');
      box.add({
        'question': question,
        'answer': answer,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  String _getTime() {
    final now = DateTime.now();
    final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final min = now.minute.toString().padLeft(2, '0');
    return '$hour:$min $ampm';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(
          _scrollController.position.maxScrollExtent,
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
        title: const Text('SpeedForce Buddy',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 88 + bottomInset),
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: messages.length + (_showTypingDots ? 1 : 0),
              itemBuilder: (context, idx) {
                if (_showTypingDots && idx == messages.length) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [_BotAvatar(), const SizedBox(width: 8), _TypingIndicator()],
                  );
                }
                final msg = messages[idx];
                final isUser = msg['isUser'] as bool;
                final animated = msg['animated'] == true;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      if (!isUser) ...[_BotAvatar(), const SizedBox(width: 8)],
                      Flexible(
                        child: Column(
                          crossAxisAlignment: isUser
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            animated && _animatingMsgIndex == idx
                                ? _TypewriterText(
                                    text: msg['text'],
                                    isUser: isUser,
                                    onFinished: () {
                                      setState(() => _animatingMsgIndex = null);
                                      _scrollToBottom();
                                    },
                                  )
                                : Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    decoration: BoxDecoration(
                                      gradient: isUser
                                          ? const LinearGradient(colors: [
                                              AppColors.primary,
                                              AppColors.secondary,
                                            ])
                                          : null,
                                      color: isUser ? null : AppColors.card,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        bottomLeft:
                                            Radius.circular(isUser ? 18 : 4),
                                        bottomRight:
                                            Radius.circular(isUser ? 4 : 18),
                                      ),
                                    ),
                                    child: Text(
                                      msg['text'],
                                      style: const TextStyle(
                                        color: AppColors.white,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 4),
                            Text(
                              msg['time'],
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      if (isUser) ...[const SizedBox(width: 8), _UserAvatar()],
                    ],
                  ),
                );
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                color: AppColors.background,
                padding: EdgeInsets.only(
                    left: 12, right: 12, top: 10, bottom: 10 + bottomInset),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _controller,
                        enabled: _faqsLoaded,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: _faqsLoaded
                              ? 'Ask SpeedForce Buddy...'
                              : 'Loading...',
                          hintStyle: const TextStyle(color: Colors.white54),
                          filled: true,
                          fillColor: AppColors.card,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 16),
                        ),
                        onSubmitted: _sendMessage,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap:
                          _faqsLoaded ? () => _sendMessage(_controller.text) : null,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.secondary],
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
    return const CircleAvatar(
      backgroundColor: AppColors.primary,
      radius: 18,
      child: Icon(Icons.smart_toy, color: Colors.white, size: 22),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      backgroundColor: AppColors.secondary,
      radius: 18,
      child: Icon(Icons.person, color: Colors.white, size: 22),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
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
      children: List.generate(
        3,
        (index) => Padding(
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
        ),
      ),
    );
  }
}

class _TypewriterText extends StatefulWidget {
  final String text;
  final bool isUser;
  final VoidCallback? onFinished;
  const _TypewriterText({
    required this.text,
    required this.isUser,
    this.onFinished,
  });

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
        widget.onFinished?.call();
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: widget.isUser
            ? const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary])
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
        style: const TextStyle(
          color: AppColors.white,
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
      ),
    );
  }
}
