import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/chat_model.dart';
import 'package:frontend/services/chat_service.dart';

class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage>
with TickerProviderStateMixin {
  static const Color _bg       = Color(0xFF060E08);
  static const Color _surface  = Color(0xFF0E1A10);
  static const Color _card     = Color(0xFF111D13);
  static const Color _surf2    = Color(0xFF162B1C);
  static const Color _green    = Color(0xFF2D9B5A);
  static const Color _greenL   = Color(0xFF3DBD71);
  static const Color _gold     = Color(0xFFC9A84C);
  static const Color _goldDim  = Color(0xFF2E2308);
  static const Color _border   = Color(0xFF1E3A24);
  static const Color _text1    = Color(0xFFF0F5F1);
  static const Color _text2    = Color(0xFFA8C4AF);
  static const Color _text3    = Color(0xFF5A7A62);
  static const Color _red      = Color(0xFFE05252);
  static const Color _userBg   = Color(0xFF1A4A2A);
  final List<ChatMessage> messages = [];
  List<String> suggestions = [
    'What documents can I request?',
    'Waste collection schedule',
    'How to book an appointment?',
    'Report an issue',
  ];
  bool isSending = false;
  final TextEditingController inputCtrl = TextEditingController();
  final ScrollController scrollCtrl = ScrollController();
  final FocusNode inputFocus = FocusNode();
  late AnimationController dotAnim;
  @override
  void initState(){
    super.initState();
    dotAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200) 
      )..repeat();
      Future.delayed(const Duration(milliseconds: 300), (){
        if (!mounted) return;
        setState(() => messages.add(ChatMessage.welcome()));
      });
  }
  @override
  void dispose(){
    dotAnim.dispose();
    inputCtrl.dispose();
    scrollCtrl.dispose();
    inputFocus.dispose();
    super.dispose();
  }
  Future<void> send([String? text]) async{
    final msg = (text ?? inputCtrl.text).trim();
    if (msg.isEmpty || isSending) return;
    inputCtrl.clear();
    setState(() {
      isSending = true;
      suggestions = [];
      messages.add(ChatMessage.user(msg));
      messages.add(ChatMessage.loading());
    });
    scrollToBottom();
    final response = await ChatService.sendMessage(msg);
    if (!mounted) return;
    setState(() {
      isSending = false;
      messages.removeWhere((m)=> m.isLoading);
      if (response.success && response.reply != null){
        messages.add(ChatMessage.assistant(response.reply!));
        suggestions = response.suggestions;
      }
      else {
        messages.add(ChatMessage.assistant(
          response.errorMessage ?? 'Sorry, I couldn\'t process your request. Please try again.',
          isError: true
        ));
      }
    });
    scrollToBottom();
  }
  void scrollToBottom(){
    Future.delayed(const Duration(milliseconds: 120), (){
      if (scrollCtrl.hasClients){
        scrollCtrl.animateTo(
          scrollCtrl.position.maxScrollExtent, 
          duration: const Duration(milliseconds: 350), 
          curve: Curves.easeOut
          );
      }
    });
  }
  Future<void> clearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_)=> AlertDialog(
        backgroundColor: _card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18)
        ),
        title: const Text('Clear chat', style: TextStyle(color: _text1, fontWeight: FontWeight.w800)),
        content: const Text(
          'This will delete the entire conversation history.',
          style: TextStyle(color: _text2,height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: ()=> Navigator.pop(context, false), 
            child: const Text('Cancel', style: TextStyle(color: _greenL, fontWeight: FontWeight.w700)),
            ),
          TextButton(
            onPressed: ()=> Navigator.pop(context, true), 
            child: const Text('Clear', style: TextStyle(color: _red, fontWeight: FontWeight.w700))
            )
        ],
      )
    );
    if (confirm != true || !mounted) return;
    await ChatService.clearHistory();
    setState(() {
      messages.clear();
      suggestions = [
        'What documents can I request?',
        'Waste collection schedule',
        'How to book an appointment?',
        'Report an issue',
      ];
      messages.add(ChatMessage.welcome());
    });
  }
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light
      )   
    );
    return Scaffold(
      backgroundColor: _bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            buildHeader(),
            buildAssistantBadge(),
            Expanded(child: buildMessageList()),
            if (suggestions.isNotEmpty) buildSuggestions(),
            buildInputBar()
          ],
        )
        ),
    );
  }
  Widget buildHeader() {
  return Container(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
    child: Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _surf2,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: _text2,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 12),

        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2D9B5A), Color(0xFF1A5C34)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: _green.withOpacity(0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'AI Assistant',
                style: TextStyle(
                  color: _text1,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: _greenL,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  const Text(
                    'Online · Btormaaz Municipality',
                    style: TextStyle(
                      color: _text3,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        GestureDetector(
          onTap: clearChat,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _surf2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _border),
            ),
            child: const Icon(
              Icons.delete_sweep_rounded,
              color: _text3,
              size: 20,
            ),
          ),
        ),
      ],
    ),
  );
}
  Widget buildAssistantBadge() {
  return Container(
    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: _goldDim,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: _gold),
    ),
    child: const Text(
      'Ask me about documents, appointments, waste schedule, reporting issues, or any municipality service.',
      style: TextStyle(
        color: _gold,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
  Widget buildMessageList(){
    return ListView.builder(
      controller: scrollCtrl,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: messages.length,
      itemBuilder: (_, i){
        final msg = messages[i];
        final showDate = i == 0 || !sameDay(messages[i - 1].timestamp, msg.timestamp);
        return Column(
          children: [
            if (showDate) buildDateSeparator(msg.timestamp),
            buildMessageBubble(msg, i)
          ],
        );
      }
      );
  }
  bool sameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;
  Widget buildDateSeparator(DateTime dt){
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day).difference(DateTime(dt.year, dt.month, dt.day)).inDays;
    final label = diff == 0 ? 'Today' : diff == 1 ? 'Yesterday' : '${dt.day}/${dt.month}/${dt.year}';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 1, color: _border) 
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                label,
                style: TextStyle(
                  color: _text3,
                  fontSize: 11,
                  fontWeight: FontWeight.w600
                ),
              ), 
              ),
              Expanded(child: Container(height: 1,color: _border,))
        ],
      ),
      );
  }
  Widget buildMessageBubble(ChatMessage msg , int index){
    final isUser = msg.isUser;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 300),
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(isUser ? 20 * (1 - v) : -20 * (1 - v), 0),
          child: child, 
          ), 
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!isUser) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2D9B5A), Color(0xFF1A5C34)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight 
                      ),
                      borderRadius: BorderRadius.circular(10)
                  ),
                  child: const Center(
                    child: Text('🤖', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.72
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? _userBg : msg.isError ? _red : _card,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(18),
                        topRight: const Radius.circular(18),
                        bottomLeft: Radius.circular(isUser ? 18 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 18)
                      ),
                      border: Border.all(
                        color: isUser ? _green : msg.isError ? _red : _border
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 6,
                          offset: const Offset(0, 2)
                        )
                      ],
                    ),
                    child: msg.isLoading ? buildTypingDots() : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.isError) Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline_rounded, color: _red, size: 14),
                              SizedBox(width: 5),
                              Text('Error', style: TextStyle(color: _red, fontSize: 11, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          ),
                          Text(
                            msg.content,
                            style: TextStyle(
                              color: isUser ? _text1 : _text2,
                              fontSize: 14.5,
                              height: 1.55
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            msg.timeLabel,
                            style: TextStyle(
                              color: _text3,
                              fontSize: 10.5
                            ),
                          ),
                      ],
                    )
                  ) 
                  ),
                  if (isUser) ...[
                    const SizedBox(width: 8),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _green,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _green)
                      ),
                      child: const Icon(Icons.person_rounded , color: _greenL,size: 18),
                    )
                  ]
              ]
            ],
          ),
          ),
    );
  }
  Widget buildTypingDots(){
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        return AnimatedBuilder(
          animation: dotAnim, 
          builder: (_, __) {
            final phase = (dotAnim.value - i * 0.15).clamp(0.0, 1.0);
            final bounce = (phase < 0.5 ? phase * 2 : (1 - phase) * 2);
            return Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 4),
              transform: Matrix4.translationValues(0, -5 * bounce, 0),
              decoration: BoxDecoration(
                color: _greenL,
                shape: BoxShape.circle
              ),
            );
          }
          );
      }),
    );
  }
  Widget buildSuggestions() {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(bottom: 6),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          final s = suggestions[i];
          return GestureDetector(
            onTap: () => send(s),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: _surf2,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: _border),
              ),
              child: Text(s, style: TextStyle(color: _text2, fontSize: 12.5, fontWeight: FontWeight.w600),),
              ),
          );
        }, 
        separatorBuilder: (_, __) => const SizedBox(width: 8), 
        itemCount: suggestions.length
        ),
    );
  }
  Widget buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      decoration: BoxDecoration(
        color: _surface,
        border: Border(
          top: BorderSide(color: _border)
        )
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: _border)
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: inputCtrl,
                      focusNode: inputFocus,
                      maxLines: 4,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => send(),
                      style: TextStyle(
                        color: _text1,
                        fontSize: 14.5
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Ask anything about the municipality…',
                        hintStyle: TextStyle(color: _text3, fontSize: 14),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12)
                      ),
                    ) 
                    ),
                    const SizedBox(width: 8),
                ],
              ),
            ) 
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: isSending ? null : () => send(),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: isSending ? null : const LinearGradient(
                  colors: [Color(0xFF2D9B5A), Color(0xFF1E7A42)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight
                 ),
                 color: isSending ? _surf2 : null,
                 borderRadius: BorderRadius.circular(16),
                 boxShadow: isSending ? [] : [
                  BoxShadow(
                    color: _green,
                    blurRadius: 12,
                    offset: Offset(0, 4)
                  )
                 ]
                ),
                child: isSending ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: CircularProgressIndicator(strokeWidth: 2, color: _greenL) 
                  ) : const Icon(Icons.send_rounded, color: Colors.white, size: 22)
                ),
            )
        ],
      ),
    );
  }
}