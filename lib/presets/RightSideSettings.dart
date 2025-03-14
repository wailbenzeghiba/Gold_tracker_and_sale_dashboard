import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:gold_tracking_desktop_stock_app/presets/WindowButtons.dart';
import 'package:provider/provider.dart';
import 'package:gold_tracking_desktop_stock_app/providers/api_key_provider.dart';

class RightSideSettings extends StatefulWidget {
  const RightSideSettings({super.key});

  @override
  _RightSideSettingsState createState() => _RightSideSettingsState();
}

class _RightSideSettingsState extends State<RightSideSettings> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _showApiKey = false;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  void _loadApiKey() {
    final apiKeyProvider = Provider.of<ApiKeyProvider>(context, listen: false);
    _apiKeyController.text = apiKeyProvider.apiKey;
  }

  void _changeApiKey() async {
    String? newKey = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change API Key'),
          content: TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'New API Key',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, _apiKeyController.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (newKey != null && newKey.isNotEmpty) {
      final apiKeyProvider = Provider.of<ApiKeyProvider>(context, listen: false);
      await apiKeyProvider.setApiKey(newKey);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('API Key updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        color: const Color.fromARGB(255, 217, 215, 215), // ✅ Match background color
        child: Column(
          children: [
            // Top bar with consistent color and buttons
            Container(
              color: Theme.of(context).cardColor, // ✅ Match theme
              child: WindowTitleBarBox(
                child: Row(
                  children: [
                    Expanded(child: MoveWindow()),
                    Windowbuttons(),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Settings',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: () {
                            setState(() {});
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Form Section
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // API Key Section
                          InkWell(
                            onTap: _changeApiKey,
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
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (_showApiKey) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          _apiKeyController.text,
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
                          const SizedBox(height: 24),

                          // Submit Button
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Settings saved')),
                                );
                              }
                            },
                            child: const Text('Save Settings'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
