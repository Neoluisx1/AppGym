import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../config/theme.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';

class ChatScreen extends StatefulWidget {
  final int trainerUserId;
  final String trainerName;

  const ChatScreen({
    super.key,
    required this.trainerUserId,
    required this.trainerName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      // Poll for new messages every 15 seconds
      _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) => _poll());
    });
  }

  Future<void> _load() async {
    await context.read<ChatProvider>().fetchMessages(widget.trainerUserId);
    _scrollToBottom();
  }

  Future<void> _poll() async {
    if (!mounted) return;
    await context.read<ChatProvider>().fetchMessages(widget.trainerUserId);
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

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    _inputController.clear();
    final provider = context.read<ChatProvider>();
    await provider.sendMessage(widget.trainerUserId, text);
    _scrollToBottom();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    context.read<ChatProvider>().clearMessages();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
              child: Text(
                widget.trainerName.isNotEmpty ? widget.trainerName[0].toUpperCase() : 'T',
                style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.trainerName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('Entrenador', style: TextStyle(fontSize: 11, color: context.textTertCol)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading && provider.messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : provider.messages.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacing16,
                          vertical: AppTheme.spacing8,
                        ),
                        itemCount: provider.messages.length,
                        itemBuilder: (context, index) =>
                            _buildBubble(provider.messages[index]),
                      ),
          ),
          _buildInputBar(provider),
        ],
      ),
    );
  }

  Widget _buildBubble(ChatMessage msg) {
    String formattedTime = '';
    try {
      final dt = DateTime.parse(msg.createdAt);
      formattedTime = DateFormat('HH:mm').format(dt);
    } catch (_) {}

    return Align(
      alignment: msg.isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMine
              ? AppTheme.primaryOrange
              : context.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMine ? 16 : 4),
            bottomRight: Radius.circular(msg.isMine ? 4 : 16),
          ),
          border: msg.isMine
              ? null
              : Border.all(color: context.borderCol),
        ),
        child: Column(
          crossAxisAlignment: msg.isMine
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Text(
              msg.message,
              style: TextStyle(
                color: msg.isMine ? Colors.white : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formattedTime,
                  style: TextStyle(
                    fontSize: 10,
                    color: msg.isMine
                        ? Colors.white.withValues(alpha: 0.7)
                        : context.textTertCol,
                  ),
                ),
                if (msg.isMine) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.readAt != null ? Icons.done_all : Icons.done,
                    size: 12,
                    color: msg.readAt != null
                        ? Colors.lightBlueAccent
                        : Colors.white.withValues(alpha: 0.6),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(ChatProvider provider) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacing12,
        AppTheme.spacing8,
        AppTheme.spacing12,
        AppTheme.spacing8 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              maxLines: null,
              textInputAction: TextInputAction.newline,
              decoration: InputDecoration(
                hintText: 'Escribe un mensaje...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                filled: true,
                fillColor: context.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedOpacity(
            opacity: provider.isSending ? 0.5 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: GestureDetector(
              onTap: provider.isSending ? null : _send,
              child: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppTheme.primaryOrange,
                  shape: BoxShape.circle,
                ),
                child: provider.isSending
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 64, color: context.textTertCol),
          const SizedBox(height: 16),
          Text('Sin mensajes', style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text(
            'Inicia una conversación con ${widget.trainerName}',
            style: context.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
