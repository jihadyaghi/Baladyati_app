enum MessageRole{user, assistant, system}
class ChatMessage {
  final String id;
  final MessageRole role;
  final String content;
  final DateTime timestamp;
  final bool isLoading;
  final bool isError;
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.isLoading = false,
    this.isError = false,
  });
  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  String get timeLabel {
    final h = timestamp.hour;
    final m = timestamp.minute.toString().padLeft(2, '0');
    final ap = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $ap';
  }
  factory ChatMessage.user(String content) => ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(), 
    role: MessageRole.user, 
    content: content, 
    timestamp: DateTime.now()
    );
  factory ChatMessage.loading() => ChatMessage(
    id: 'loading', 
    role: MessageRole.assistant, 
    content: '', 
    timestamp: DateTime.now(),
    isLoading: true
    );
  factory ChatMessage.assistant(String content, {bool isError = false}) => ChatMessage(
    id: DateTime.now().millisecondsSinceEpoch.toString(), 
    role: MessageRole.assistant, 
    content: content, 
    timestamp: DateTime.now(),
    isError: isError
    );
  factory ChatMessage.welcome() => ChatMessage(
    id: 'Welcome', 
    role: MessageRole.assistant, 
    content: 'مرحباً! أنا المساعد الذكي لبلدية بطرماز. '
             'كيف يمكنني مساعدتك اليوم؟\n\n'
             'Hello! I\'m the AI assistant for Btormaz Municipality. '
             'How can I help you today? ', 
    timestamp: DateTime.now()
    );
}