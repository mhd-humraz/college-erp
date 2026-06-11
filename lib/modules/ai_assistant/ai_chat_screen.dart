// lib/modules/ai_assistant/ai_chat_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../providers/auth_provider.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key});

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messagesHistory = [
    {'sender': 'bot', 'text': 'EduSphere Intelligent Terminal Online. Secure database routing channels active.'}
  ];
  bool _awaitingAiEngineResponse = false;

  Future<void> _handleMessageDispatch() async {
    final String queryText = _messageController.text.trim();
    if (queryText.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messagesHistory.add({'sender': 'user', 'text': queryText});
      _awaitingAiEngineResponse = true;
    });

    final auth = Provider.of<AuthProvider>(context, listen: false);

    try {
      final response = await http.post(
        Uri.parse('http://localhost:5000/api/ai/ask-intelligence'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${auth.token}',
        },
        body: jsonEncode({'query': queryText}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _messagesHistory.add({'sender': 'bot', 'text': data['answer']});
        });
      }
    } catch (e) {
      setState(() {
        _messagesHistory.add({'sender': 'bot', 'text': 'Connection dropped. System engine offline.'});
      });
    } finally {
      setState(() => _awaitingAiEngineResponse = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Intelligence Core'), backgroundColor: Colors.indigo, foregroundColor: Colors.white),
      body: Column(
        children: [
          // Dynamic Message Stream
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messagesHistory.length,
              itemBuilder: (context, idx) {
                final msg = _messagesHistory[idx];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.indigo : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser ? Radius.zero : const Radius.circular(16),
                        topLeft: !isUser ? Radius.zero : const Radius.circular(16)
                      ),
                    ),
                    child: Text(msg['text'], style: TextStyle(color: isUser ? Colors.white : Colors.black87, fontSize: 14.5)),
                  ),
                );
              },
            ),
          ),
          
          if (_awaitingAiEngineResponse)
            const Padding(padding: EdgeInsets.only(bottom: 8.0), child: LinearProgressIndicator(color: Colors.indigo)),

          // Text Input Console Layout Dock
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Ask EduSphere... (e.g. How is my attendance?)',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14)
                    ),
                    onSubmitted: (_) => _handleMessageDispatch(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _handleMessageDispatch,
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  child: const Icon(Icons.send_rounded),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}