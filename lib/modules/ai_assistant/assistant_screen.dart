// lib/modules/ai_assistant/assistant_screen.dart
import 'package:flutter/material.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _queryController = TextEditingController();
  final List<Map<String, String>> _chatHistory = [
    {'sender': 'assistant', 'text': 'Greetings. I am connected directly to EduSphere databases. What metrics can I compute for you?'}
  ];

  void _submitQuery() {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _chatHistory.add({'sender': 'user', 'text': _queryController.text.trim()});
      // Emulating backend response delay
      _chatHistory.add({'sender': 'assistant', 'text': 'Scanning target metrics collection parameters...'});
    });
    
    _queryController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('EduSphere AI Engine')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chatHistory.length,
              itemBuilder: (context, index) {
                final message = _chatHistory[index];
                final isUser = message['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blueAccent : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12).copyWith(
                        bottomRight: isUser ? Radius.zero : const Radius.circular(12),
                        topLeft: !isUser ? Radius.zero : const Radius.circular(12)
                      ),
                    ),
                    child: Text(
                      message['text'] ?? '',
                      style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 15),
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _queryController,
                    decoration: const InputDecoration(hintText: 'Ask anything (e.g., Run attendance audit...)', border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(30)))),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(onPressed: _submitQuery, child: const Icon(Icons.send_rounded)),
              ],
            ),
          )
        ],
      ),
    );
  }
}