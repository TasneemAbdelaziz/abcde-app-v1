// [UI] screen — owner: Product.
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/brand_bar.dart';

enum _ChatSender { user, assistant }

class _ChatMessage {
  final String text;
  final _ChatSender sender;

  const _ChatMessage({required this.text, required this.sender});
}

/// AI health advisor chat.
class AiAdvisorScreen extends StatefulWidget {
  const AiAdvisorScreen({super.key});

  @override
  State<AiAdvisorScreen> createState() => _AiAdvisorScreenState();
}

class _AiAdvisorScreenState extends State<AiAdvisorScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Hello Ahmed. I\'m here to help you understand your condition and recovery. What would you like to know?',
      sender: _ChatSender.assistant,
    ),
  ];

  final List<String> _quickReplies = [
    'What does my diagnosis mean?',
    'When can I eat normally?',
    'Explain my medication',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(text: text.trim(), sender: _ChatSender.user));
      _controller.clear();
    });

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatMessage(
            text:
                'Thanks for your question. I\'ll review that and help you understand it clearly.',
            sender: _ChatSender.assistant,
          ),
        );
      });
      _scrollToBottom();
    });

    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgSoft,
      appBar: const BrandBar(title: 'AI Advisor'),
      body: Column(
        children: [
          _buildAdvisorHeader(),
          SizedBox(height: 16.h),
          Expanded(child: _buildMessageList()),
          _buildInputSection(),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildAdvisorHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.teal,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'AI',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Advisor',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'Online · responds in seconds',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 14.h),
            child: Align(
              alignment: message.sender == _ChatSender.user
                  ? Alignment.centerRight
                  : Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (message.sender == _ChatSender.assistant) ...[
                    Container(
                      width: 36.w,
                      height: 36.w,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'AI',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                  ],
                  Container(
                    constraints: BoxConstraints(maxWidth: 280.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                    decoration: BoxDecoration(
                      color: message.sender == _ChatSender.user
                          ? AppColors.blue
                          : Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.r),
                        topRight: Radius.circular(20.r),
                        bottomLeft: Radius.circular(
                          message.sender == _ChatSender.user ? 20.r : 4.r,
                        ),
                        bottomRight: Radius.circular(
                          message.sender == _ChatSender.user ? 4.r : 20.r,
                        ),
                      ),
                      boxShadow: message.sender == _ChatSender.user
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.03),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                    ),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: message.sender == _ChatSender.user
                            ? Colors.white
                            : AppColors.text,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickReplies() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _quickReplies.map((text) {
            return Padding(
              padding: EdgeInsets.only(right: 10.w),
              child: OutlinedButton(
                onPressed: () => _sendMessage(text),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.blue),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  backgroundColor: AppColors.bgCard,
                  foregroundColor: AppColors.blue,
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 12.h,
                  ),
                ),
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Column(
        children: [
          _buildQuickReplies(),
          SizedBox(height: 12.h),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Ask a health question...',
                hintStyle: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textMuted,
                ),
                border: InputBorder.none,
              ),
              style: TextStyle(fontSize: 14.sp, color: AppColors.text),
              onSubmitted: _sendMessage,
            ),
          ),
          GestureDetector(
            onTap: () => _sendMessage(_controller.text),
            child: Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.blue,
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(
                Icons.arrow_forward,
                size: 20.sp,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
