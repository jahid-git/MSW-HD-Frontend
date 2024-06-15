import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mswhd/widgets/file_uploader_dialog.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;
  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    // Adding dummy messages
    for (int i = 0; i < 100; i++) {
      _messages.add({
        "sender": i % 2 == 0 ? "Admin" : "User",
        "content": "Message $i",
        "timestamp": "2024-06-12T08:30:00",
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _handleSubmitted(String text) {
    if (text.isNotEmpty) {
      setState(() {
        _messages.add({
          "sender": "User",
          "content": text,
          "timestamp": DateTime.now().toIso8601String(),
        });
        _textController.clear();
        _isComposing = false;
      });
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleImageUpload() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => const FileUploaderDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat with Admin'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: <Widget>[
          Flexible(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: false,
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (_, int index) => _buildMessage(index),
            ),
          ),
          const Divider(height: 1.0),
          Padding(
            padding: const EdgeInsets.all(8),
            child: _buildTextComposer(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(int index) {
    final message = _messages[index];
    final isUserMessage = message['sender'] == 'User';
    final backgroundColor =
    isUserMessage ? Colors.deepPurple : Colors.grey[300];
    final textColor = isUserMessage ? Colors.white : Colors.black;

    final double maxWidth = MediaQuery.of(context).size.width * 0.6;
    final double contentWidth = (message['content'].toString().length * 10.0)
        .clamp(0.0, maxWidth - 24.0); // Subtracting padding

    if (message.containsKey('isImage') && message['isImage'] == true) {
      return Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 175),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: Image.network(
              message['content'],
              width: 250,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    } else {
      return Align(
        alignment: isUserMessage ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
          constraints: BoxConstraints(maxWidth: maxWidth, minWidth: 175),
          child: Container(
            width: contentWidth,
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message['content'],
                  style: TextStyle(color: textColor),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        message['timestamp'],
                        style: const TextStyle(fontSize: 12.0, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.done_all,
                      color: isUserMessage ? Colors.blue : Colors.grey,
                      size: 16.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

  Widget _buildTextComposer() {
    final FocusNode focusNode = FocusNode();

    return IconTheme(
      data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            onPressed: _handleImageUpload, // Trigger image upload logic
          ),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 6 * 24.0),
              child: TextField(
                focusNode: focusNode,
                controller: _textController,
                onChanged: (String text) {
                  setState(() {
                    _isComposing = text.isNotEmpty;
                  });
                },
                onEditingComplete: () {
                  if (_isComposing) {
                    _handleSubmitted(_textController.text);
                    focusNode.requestFocus();
                  }
                },
                maxLines: null, // Unlimited lines, height adjusts automatically
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message',
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isComposing
                ? () {
              _handleSubmitted(_textController.text);
              focusNode.requestFocus();
            }
                : null,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}