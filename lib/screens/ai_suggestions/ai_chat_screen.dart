import 'package:flutter/material.dart';
import '../../logic/gemini_service.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});
  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final List<Map<String, String>> _messages = [];
  final _controller = TextEditingController();
  bool _isTyping = false;

  void _sendMessage() async {
    final text = _controller.text;
    if (text.isEmpty) return;
    setState(() { _messages.add({"role": "user", "text": text}); _isTyping = true; });
    _controller.clear();
    try {
      final response = await GeminiService().sendChatMessage(text);
      setState(() => _messages.add({"role": "ai", "text": response}));
    } finally {
      setState(() => _isTyping = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI සහායක"), backgroundColor: Colors.green),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, i) => ListTile(
                title: Align(
                  alignment: _messages[i]['role'] == 'user' ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _messages[i]['role'] == 'user' ? Colors.green[100] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(_messages[i]['text']!),
                  ),
                ),
              ),
            ),
          ),
          if (_isTyping) const Padding(padding: EdgeInsets.all(8.0), child: LinearProgressIndicator(color: Colors.green)),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: "ප්‍රශ්නය විමසන්න..."))),
                IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: Colors.green)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}