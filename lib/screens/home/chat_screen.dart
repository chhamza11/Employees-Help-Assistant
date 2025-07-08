import 'package:flutter/material.dart';
import '../../core/colors.dart';
import '../../core/styles.dart';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  List<Map<String, String>> faqs = [];
  List<Map<String, String>> filteredFaqs = [];
  final List<Map<String, dynamic>> messages = [];
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _showTypingDots = false;
  int? _animatingMsgIndex;
  FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    _loadFaqs();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 250), _scrollToBottom);
      }
    });
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
      final matches = faqs.where((faq) => faq['question']!.toLowerCase().contains(query)).toList();
      setState(() {
        filteredFaqs = matches;
        _showDropdown = matches.isNotEmpty;
      });
    }
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    setState(() {
      messages.add({'text': text, 'isUser': true, 'time': _getTime(), 'animated': false});
      _controller.clear();
      _isSending = true;
      _showTypingDots = true;
    });
    _scrollToBottom();
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _showTypingDots = false;
      messages.add({
        'text': 'This is a template AI response for: $text',
        'isUser': false,
        'time': _getTime(),
        'animated': true,
      });
      _animatingMsgIndex = messages.length - 1;
      _isSending = false;
    });
    _scrollToBottom();
  }

  void _sendFaq(String question, String answer) async {
    setState(() {
      messages.add({'text': question, 'isUser': true, 'time': _getTime(), 'animated': false});
      _isSending = true;
      _showTypingDots = true;
      _searchController.clear();
      filteredFaqs = [];
      _showDropdown = false;
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
    _searchController.dispose();
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
            padding: EdgeInsets.only(bottom: 128 + bottomInset),
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
          // Search bar, vertical suggestions dropdown, and input bar pinned to bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search for a question...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: AppColors.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      ),
                    ),
                  ),
                  // Vertical suggestions dropdown
                  if (_showDropdown && filteredFaqs.isNotEmpty)
                    Container(
                      color: AppColors.background,
                      constraints: const BoxConstraints(maxHeight: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 12),
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
                              onTap: () => _sendFaq(faq['question']!, faq['answer']!),
                            );
                          },
                        ),
                      ),
                    ),
                  // Input bar
                  Container(
                    color: AppColors.background,
                    padding: EdgeInsets.only(left: 12, right: 12, top: 10, bottom: 10 + bottomInset),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            focusNode: _focusNode,
                            controller: _controller,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Type your question...',
                              hintStyle: const TextStyle(color: Colors.white54),
                              filled: true,
                              fillColor: AppColors.card,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(22),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            ),
                            onSubmitted: _sendMessage,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _sendMessage(_controller.text),
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
                ],
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