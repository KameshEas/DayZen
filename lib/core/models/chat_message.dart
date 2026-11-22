/// A single turn in the embedded AI assistant conversation.
///
/// Mirrors the backend's plain user/assistant text shape - tool-calling
/// happens entirely inside the n8n workflow, so the client never sees
/// tool_use/tool_result blocks, only the final reply text per turn.
class ChatMessage {
  const ChatMessage({required this.role, required this.content, this.isError = false});

  factory ChatMessage.user(final String content) => ChatMessage(role: 'user', content: content);

  factory ChatMessage.assistant(final String content) =>
      ChatMessage(role: 'assistant', content: content);

  /// A locally-generated error notice shown in the conversation. Marked
  /// [isError] so it renders distinctly.
  factory ChatMessage.error(final String content) =>
      ChatMessage(role: 'assistant', content: content, isError: true);

  final String role; // 'user' or 'assistant'
  final String content;
  final bool isError;

  bool get isUser => role == 'user';
}
