import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../providers/chat_provider.dart';
import '../../models/chat_model.dart';

class TrainerChatListScreen extends StatefulWidget {
  const TrainerChatListScreen({super.key});

  @override
  State<TrainerChatListScreen> createState() => _TrainerChatListScreenState();
}

class _TrainerChatListScreenState extends State<TrainerChatListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().fetchClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ChatProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Chat con Clientes')),
      body: provider.isLoading && provider.clients.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => context.read<ChatProvider>().fetchClients(),
              child: provider.clients.isEmpty
                  ? _buildEmpty()
                  : _buildList(provider.clients),
            ),
    );
  }

  Widget _buildList(List<ChatClient> clients) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      itemCount: clients.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppTheme.spacing8),
      itemBuilder: (_, i) => _buildClientTile(clients[i]),
    );
  }

  Widget _buildClientTile(ChatClient client) {
    return GestureDetector(
      onTap: () => _openChat(client),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacing12),
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(
            color: client.unread > 0
                ? AppTheme.primaryOrange.withValues(alpha: 0.4)
                : context.borderCol,
          ),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppTheme.primaryOrange.withValues(alpha: 0.2),
                  backgroundImage: client.photoUrl != null ? NetworkImage(client.photoUrl!) : null,
                  child: client.photoUrl == null
                      ? Text(
                          client.name[0].toUpperCase(),
                          style: const TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 18),
                        )
                      : null,
                ),
                if (client.unread > 0)
                  Positioned(
                    right: 0, top: 0,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(color: AppTheme.primaryOrange, shape: BoxShape.circle),
                      child: Center(
                        child: Text(
                          client.unread > 9 ? '9+' : '${client.unread}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: AppTheme.spacing12),
            Expanded(
              child: Text(
                client.name,
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: client.unread > 0 ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textTertiary),
          ],
        ),
      ),
    );
  }

  void _openChat(ChatClient client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TrainerChatScreen(
          clientUserId: client.userIdClient,
          clientName: client.name,
        ),
      ),
    ).then((_) {
      if (mounted) context.read<ChatProvider>().fetchClients();
    });
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 72, color: AppTheme.textTertiary),
          const SizedBox(height: 16),
          Text('Sin clientes asignados', style: context.textTheme.headlineMedium),
          const SizedBox(height: 8),
          Text('Cuando tengas clientes podrás chatear con ellos', style: context.textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Trainer-side chat screen (reuses UI, calls trainer endpoints) ─────────────

class TrainerChatScreen extends StatefulWidget {
  final int clientUserId;
  final String clientName;

  const TrainerChatScreen({super.key, required this.clientUserId, required this.clientName});

  @override
  State<TrainerChatScreen> createState() => _TrainerChatScreenState();
}

class _TrainerChatScreenState extends State<TrainerChatScreen> {
  final _msgCtrl    = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool  _sending    = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMessages();
    });
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    context.read<ChatProvider>().clearMessages();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    await context.read<ChatProvider>().fetchMessagesAsTrainer(widget.clientUserId);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    _msgCtrl.clear();
    setState(() => _sending = true);
    final provider = context.read<ChatProvider>();
    final ok = await provider.sendMessageAsTrainer(widget.clientUserId, text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (ok) _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final provider  = context.watch<ChatProvider>();
    final messages  = provider.messages;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.clientName),
            Text('Cliente', style: context.textTheme.bodySmall),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: provider.isLoading && messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : messages.isEmpty
                    ? Center(child: Text('Inicia la conversación', style: context.textTheme.bodyMedium))
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.all(AppTheme.spacing12),
                        itemCount: messages.length,
                        itemBuilder: (_, i) => _buildBubble(messages[i]),
                      ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildBubble(dynamic msg) {
    final isMine = msg.isMine as bool;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMine ? AppTheme.primaryOrange : context.cardColor,
          borderRadius: BorderRadius.only(
            topLeft:     const Radius.circular(16),
            topRight:    const Radius.circular(16),
            bottomLeft:  Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
          border: isMine ? null : Border.all(color: context.borderCol),
        ),
        child: Text(
          msg.message as String,
          style: TextStyle(color: isMine ? Colors.white : Theme.of(context).colorScheme.onSurface, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border(top: BorderSide(color: context.borderCol)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _msgCtrl,
                minLines: 1,
                maxLines: 4,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  filled: true,
                  fillColor: Theme.of(context).scaffoldBackgroundColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _sending ? null : _send,
                icon: _sending
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.send_rounded, color: AppTheme.primaryOrange),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
