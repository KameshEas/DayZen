import 'package:flutter/material.dart';
import '../../core/api/api_client.dart';
import '../../core/models/chat_message.dart';
import '../../core/services/mcp_auth_service.dart';

/// Embedded AI assistant chat panel.
///
/// Sends each message to the backend (`POST /n8n-chat/{chatId}`), which
/// relays it to an n8n workflow (AI Agent + MCP Client Tool) running against
/// `dayzen-mcp-server` on the user's behalf - see
/// `services/dayzen/app/services/n8n_chat_service.py`. Unlike Cashlyze's
/// equivalent screen, the MCP token is minted *here*, client-side, via a
/// full OAuth+PKCE exchange (McpAuthService) rather than by the backend -
/// the first message in a fresh session triggers a one-time "Connect AI
/// Assistant" consent step before anything is sent.
class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({super.key});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  // One id per screen-open - only used as the backend/n8n conversation-memory
  // key, not an auth boundary, so a timestamp is unique enough.
  final String _chatId = DateTime.now().millisecondsSinceEpoch.toString();
  final List<ChatMessage> _messages = [];
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ApiClient _apiClient = ApiClient();

  bool _isSending = false;
  bool _isConnecting = false;
  bool _checkingConnection = true;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final connected = await McpAuthService.instance.isConnected;
    if (!mounted) return;
    setState(() {
      _isConnected = connected;
      _checkingConnection = false;
    });
  }

  Future<void> _connect() async {
    setState(() => _isConnecting = true);
    try {
      await McpAuthService.instance.connect();
      if (!mounted) return;
      setState(() {
        _isConnected = true;
        _isConnecting = false;
      });
    } on McpAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isConnecting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _inputController.text.trim();
    if (text.isEmpty || _isSending) return;

    final mcpToken = await McpAuthService.instance.getValidToken();
    if (mcpToken == null) {
      if (!mounted) return;
      setState(() => _isConnected = false);
      return;
    }

    setState(() {
      _messages.add(ChatMessage.user(text));
      _inputController.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final response = await _apiClient.post('/n8n-chat/$_chatId', {
        'message': text,
        'mcp_token': mcpToken,
      });
      final reply = response['reply'] as String? ?? "The assistant didn't return a reply.";
      if (!mounted) return;
      setState(() => _messages.add(ChatMessage.assistant(reply)));
    } catch (e) {
      if (!mounted) return;
      final message = e is ApiException ? e.message : "Couldn't reach the assistant. Please try again.";
      setState(() => _messages.add(ChatMessage.error(message)));
    } finally {
      if (mounted) setState(() => _isSending = false);
      _scrollToBottom();
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('AI Assistant')),
      body: _checkingConnection
          ? const Center(child: CircularProgressIndicator())
          : !_isConnected
              ? _ConnectPrompt(isConnecting: _isConnecting, onConnect: _connect)
              : Column(
                  children: [
                    Expanded(
                      child: _messages.isEmpty
                          ? _EmptyState(theme: theme)
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length + (_isSending ? 1 : 0),
                              itemBuilder: (final context, final index) {
                                if (index >= _messages.length) {
                                  return const _TypingIndicator();
                                }
                                return _ChatBubble(message: _messages[index]);
                              },
                            ),
                    ),
                    SafeArea(
                      top: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _inputController,
                                minLines: 1,
                                maxLines: 4,
                                // Matches the backend's N8nChatRequest.message cap
                                // (services/dayzen/app/schemas/n8n_chat.py) - the
                                // message is forwarded verbatim to an LLM via n8n,
                                // so an unbounded length is a resource/cost risk.
                                maxLength: 4000,
                                textInputAction: TextInputAction.send,
                                onSubmitted: (_) => _send(),
                                enabled: !_isSending,
                                decoration: const InputDecoration(
                                  hintText: "What's on my plate today?",
                                  filled: true,
                                  counterText: '',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(24)),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton.filled(
                              onPressed: _isSending ? null : _send,
                              icon: _isSending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.arrow_upward_rounded),
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

class _ConnectPrompt extends StatelessWidget {
  const _ConnectPrompt({required this.isConnecting, required this.onConnect});

  final bool isConnecting;
  final VoidCallback onConnect;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome_outlined, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 20),
            Text(
              'Connect Your AI Assistant',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'The assistant can view and manage your tasks, journal entries, and '
              'insights on your behalf. It only ever acts on your own account.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isConnecting ? null : onConnect,
              child: isConnecting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Allow'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(final BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.auto_awesome_outlined,
              size: 40,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Ask me about your day',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '"What\'s on my plate today?"\n'
              '"Log a journal entry about today"\n'
              '"How\'s my focus streak?"',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final isError = message.isError;
    final bubbleColor = isUser
        ? theme.colorScheme.primary
        : isError
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.surface;
    final textColor = isUser
        ? theme.colorScheme.onPrimary
        : isError
            ? theme.colorScheme.onErrorContainer
            : theme.colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser || isError
              ? null
              : Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isError) ...[
              Icon(Icons.error_outline, size: 16, color: textColor),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                message.content,
                style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chat-bubble "typing" indicator: three dots that bounce in a staggered
/// wave, matching the familiar messaging-app pattern (vs. a plain spinner).
class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  static const _dotCount = 3;
  static const _cycleDuration = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _cycleDuration)..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final dotColor = theme.colorScheme.primary;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.colorScheme.onSurface.withValues(alpha: 0.06)),
        ),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (final context, final _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_dotCount, (final i) {
                // Stagger each dot's bounce by 1/dotCount of the cycle.
                final phase = (_controller.value - (i / _dotCount)) % 1.0;
                final bounce = phase < 0.5 ? phase / 0.5 : 1 - ((phase - 0.5) / 0.5);
                final scale = 0.5 + bounce * 0.7;
                return Padding(
                  padding: EdgeInsets.only(right: i < _dotCount - 1 ? 5 : 0),
                  child: Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
