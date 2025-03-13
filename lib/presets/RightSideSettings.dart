import 'package:flutter/material.dart';

class RightSideSettings extends StatefulWidget {
  @override
  _RightSideSettingsState createState() => _RightSideSettingsState();
}

class _RightSideSettingsState extends State<RightSideSettings> {
  String _apiKey = 'sk_4d8C933891B5CB9D28AE75B871B991BFc7133A12FBb0ba82';
  bool _showApiKey = false;

  void _changeApiKey() async {
    TextEditingController _controller = TextEditingController(text: _apiKey);

    String? newKey = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change API Key'),
          content: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'New API Key'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newKey != null && newKey.isNotEmpty) {
      setState(() {
        _apiKey = newKey;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          InkWell(
            onLongPress: () {
              setState(() {
                _showApiKey = true;
              });
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  _showApiKey = false;
                });
              });
            },
            onTap: _changeApiKey,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'API Key',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                      if (_showApiKey) ...[
                        const SizedBox(height: 4),
                        Text(
                          _apiKey,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                            fontFamily: 'Courier',
                          ),
                        ),
                      ],
                    ],
                  ),
                  const Icon(Icons.edit, color: Colors.grey),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
